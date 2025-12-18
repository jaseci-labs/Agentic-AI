import os;
import json;
import requests;
import from langchain_community.document_loaders {PyPDFDirectoryLoader, PyPDFLoader, DirectoryLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain_core.documents {Document}
import from langchain_openai {OpenAIEmbeddings}
import from langchain_chroma {Chroma}

glob SERPER_API_KEY: str = os.getenv('SERPER_API_KEY', '');

"""Load configuration from JSON file"""
def load_config(config_name: str = "baseline") -> dict {
    try {
        config_path = os.path.join(os.path.dirname(__file__), "config", f"{config_name}.json");
        with open(config_path, 'r', encoding='utf-8') as f {
            return json.load(f);
        }
    } except Exception as e {
        print(f"Error loading config {config_name}: {e}");
        # Return default baseline config
        return {
            "rag_engine": {
                "chunk_size": 800,
                "chunk_overlap": 80,
                "similarity_search": {"k": 5}
            },
            "paths": {
                "file_path": "docs",
                "chroma_path": "chroma"
            }
        };
    }
}

obj RagEngine {
    has file_path: str = "docs";
    has chroma_path: str = "chroma";
    has chunk_size: int = 800;
    has chunk_overlap: int = 80;
    has default_k: int = 5;
    has config: dict = {};

    def postinit {
        # Load configuration
        config_name = os.getenv('RAG_CONFIG', 'baseline');
        self.config = load_config(config_name);
        
        # Set configuration values
        self.file_path = self.config.get("paths", {}).get("file_path", "docs");
        self.chroma_path = self.config.get("paths", {}).get("chroma_path", "chroma");
        self.chunk_size = self.config.get("rag_engine", {}).get("chunk_size", 800);
        self.chunk_overlap = self.config.get("rag_engine", {}).get("chunk_overlap", 80);
        self.default_k = self.config.get("rag_engine", {}).get("similarity_search", {}).get("k", 5);
        
        print(f"RAG Engine initialized with config: {config_name}");
        print(f"Chunk size: {self.chunk_size}, Overlap: {self.chunk_overlap}, Default K: {self.default_k}");
        
        if not os.path.exists(self.file_path) {
            os.makedirs(self.file_path);
        }
        documents: list = self.load_documents();
        chunks: list = self.split_documents(documents);
        self.add_to_chroma(chunks);
    }

    def load_documents {
        documents = [];
        
        # Load PDF files
        try {
            pdf_loader = PyPDFDirectoryLoader(self.file_path);
            pdf_docs = pdf_loader.load();
            documents.extend(pdf_docs);
            print(f"Loaded {len(pdf_docs)} PDF documents");
        } except Exception as e {
            print(f"No PDF files found or error loading PDFs: {e}");
        }
        
        # Load Markdown files
        try {
            md_loader = DirectoryLoader(
                self.file_path,
                glob="**/*.md",
                loader_cls=TextLoader,
                loader_kwargs={"encoding": "utf-8"}
            );
            md_docs = md_loader.load();
            documents.extend(md_docs);
            print(f"Loaded {len(md_docs)} Markdown documents");
        } except Exception as e {
            print(f"No Markdown files found or error loading Markdown: {e}");
        }
        
        print(f"Total documents loaded: {len(documents)}");
        return documents;
    }

    def load_document(file_path: str) {
        if file_path.endswith('.pdf') {
            loader = PyPDFLoader(file_path);
        } elif file_path.endswith('.md') {
            loader = TextLoader(file_path, encoding="utf-8");
        } else {
            raise ValueError(f"Unsupported file type: {file_path}");
        }
        return loader.load();
    }

    def add_file(file_path: str) {
        documents = self.load_document(file_path);
        chunks = self.split_documents(documents);
        self.add_to_chroma(chunks);
    }

    def split_documents(documents: list[Document]) {
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=self.chunk_size,
            chunk_overlap=self.chunk_overlap,
            length_function=len,
            is_separator_regex=False
        );
        return text_splitter.split_documents(documents);
    }

    def get_embedding_function {
        embeddings = OpenAIEmbeddings();
        return embeddings;
    }

    def add_chunk_id(chunks: str) {
        last_page_id = None;
        current_chunk_index = 0;

        for chunk in chunks {
            source = chunk.metadata.get('source');
            page = chunk.metadata.get('page');
            
            # Handle markdown files (no page numbers)
            if page is None {
                current_page_id = f'{source}:0';
            } else {
                current_page_id = f'{source}:{page}';
            }

            if current_page_id == last_page_id {
                current_chunk_index +=1;
            } else {
                current_chunk_index = 0;
            }

            chunk_id = f'{current_page_id}:{current_chunk_index}';
            last_page_id = current_page_id;

            chunk.metadata['id'] = chunk_id;
        }

        return chunks;
    }

    def add_to_chroma(chunks: list[Document]) {
        db = Chroma(persist_directory=self.chroma_path, embedding_function=self.get_embedding_function());
        chunks_with_ids = self.add_chunk_id(chunks);

        existing_items = db.get(include=[]);
        existing_ids = set(existing_items['ids']);

        new_chunks = [];
        for chunk in chunks_with_ids {
            if chunk.metadata['id'] not in existing_ids {
                new_chunks.append(chunk);
            }
        }

        if len(new_chunks) {
            print('adding new documents');
            new_chunk_ids = [chunk.metadata['id'] for chunk in new_chunks];
            db.add_documents(new_chunks, ids=new_chunk_ids);
        } else {
            print('no new documents to add');
        }
    }

    def get_from_chroma(query: str,chunck_nos: int=None) {
        if chunck_nos is None {
            chunck_nos = self.default_k;
        }
        db = Chroma(
            persist_directory=self.chroma_path,
            embedding_function=self.get_embedding_function()
        );
        results = db.similarity_search_with_score(query,k=chunck_nos);
        return results;
    }

    def search(query: str, chunck_nos: int=None) {
        if chunck_nos is None {
            chunck_nos = self.default_k;
        }
        results = self.get_from_chroma(query=query, chunck_nos=chunck_nos);
        summary = "";
        for (doc, score) in results {
            page = doc.metadata.get('page');
            source = doc.metadata.get('source');
            chunk_txt = doc.page_content[:400];
            
            # Handle display for different file types
            if page is not None {
                summary += f"{source} page {page}: {chunk_txt}\n";
            } else {
                # For markdown files without page numbers
                summary += f"{source}: {chunk_txt}\n";
            }
        }
        return summary;
    }
}


obj WebSearch {
    has api_key: str = SERPER_API_KEY;
    has base_url: str = "https://google.serper.dev/search";

    def search(query: str) {
        headers = {"X-API-KEY": self.api_key, "Content-Type": "application/json"};
        payload = {"q": query};
        resp = requests.post(self.base_url, headers=headers, json=payload);
        if resp.status_code == 200 {
            data = resp.json();
            summary = "";
            results = data.get("organic", []) if isinstance(data, dict) else [];
            for r in results[:3] {
                summary += f"{r.get('title', '')}: {r.get('link', '')}\n";
                if r.get('snippet') {
                    summary += f"{r['snippet']}\n";
                }
            }
            return summary;
        }
        return f"Serper request failed: {resp.status_code}";
    }
}