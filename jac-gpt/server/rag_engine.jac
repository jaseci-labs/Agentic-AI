import os;
import json;
import requests;
import from langchain_community.document_loaders {PyPDFDirectoryLoader, PyPDFLoader, DirectoryLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain_core.documents {Document}
import from langchain_openai {OpenAIEmbeddings}
import from langchain_community.vectorstores {FAISS}

glob SERPER_API_KEY: str = os.getenv('SERPER_API_KEY', '');

"""Load configuration from JSON file"""
def load_config(config_name: str) -> dict {
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
    has file_path: str;
    has faiss_path: str;
    has chunk_size: int;
    has chunk_overlap: int;
    has default_k: int;
    has vectorstore: FAISS = None;

    def postinit {
        print(f"RAG Engine initialized");
        print(f"Chunk size: {self.chunk_size}, Overlap: {self.chunk_overlap}, Default K: {self.default_k}");
        
        if not os.path.exists(self.file_path) {
            os.makedirs(self.file_path);
        }
        
        # Load or create FAISS index
        if os.path.exists(self.faiss_path) and os.path.isdir(self.faiss_path) {
            print(f"Loading existing FAISS index from {self.faiss_path}");
            self.vectorstore = FAISS.load_local(
                self.faiss_path,
                self.get_embedding_function(),
                allow_dangerous_deserialization=True
            );
        } else {
            print("Creating new FAISS index");
            documents: list = self.load_documents();
            chunks: list = self.split_documents(documents);
            self.create_faiss_index(chunks);
        }
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
        self.add_to_faiss(chunks);
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

    def create_faiss_index(chunks: list[Document]) {
        if len(chunks) > 0 {
            print(f"Creating FAISS index with {len(chunks)} chunks");
            self.vectorstore = FAISS.from_documents(
                chunks,
                self.get_embedding_function()
            );
            self.vectorstore.save_local(self.faiss_path);
            print(f"FAISS index saved to {self.faiss_path}");
        } else {
            print("No documents to index");
        }
    }

    def add_to_faiss(chunks: list[Document]) {
        if self.vectorstore is None {
            self.create_faiss_index(chunks);
        } else {
            if len(chunks) > 0 {
                print(f"Adding {len(chunks)} new documents to FAISS index");
                self.vectorstore.add_documents(chunks);
                self.vectorstore.save_local(self.faiss_path);
                print("FAISS index updated");
            } else {
                print("No new documents to add");
            }
        }
    }

    def get_from_faiss(query: str, chunck_nos: int=None) {
        if chunck_nos is None {
            chunck_nos = self.default_k;
        }
        if self.vectorstore is None {
            print("FAISS index not initialized");
            return [];
        }
        results = self.vectorstore.similarity_search_with_score(query, k=chunck_nos);
        return results;
    }

    def search(query: str, chunck_nos: int=None) {
        if chunck_nos is None {
            chunck_nos = self.default_k;
        }
        results = self.get_from_faiss(query=query, chunck_nos=chunck_nos);
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