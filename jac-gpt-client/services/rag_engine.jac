import os;
import json;
import time;
import requests;
import from langchain_community.document_loaders {PyPDFDirectoryLoader, PyPDFLoader, DirectoryLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain_core.documents {Document}
import from langchain_openai {OpenAIEmbeddings}
import from langchain_community.vectorstores {FAISS}
import from sentence_transformers {CrossEncoder}

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
    has chunk_nos: int;
    has cross_encoder_model: str;
    has top_n: int;
    has vectorstore: FAISS = None;
    has cross_encoder: CrossEncoder = None;
    has use_reranking: bool = True;

    def postinit {
        # Initialize CrossEncoder reranker
        try {
            self.cross_encoder = CrossEncoder(self.cross_encoder_model);
            print(f"CrossEncoder reranking enabled with model: {self.cross_encoder_model}");
        } except Exception as e {
            print(f"Warning: Failed to load CrossEncoder model: {e}");
            print("Reranking will be disabled.");
            self.use_reranking = False;
        }
        print(f"RAG Engine initialized");
        print(f"Chunk size: {self.chunk_size}, Overlap: {self.chunk_overlap}, Chunk Nos: {self.chunk_nos}");

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

    """Create content string enriched with metadata for better semantic matching"""
    def enrich_content_with_metadata(chunk: Document) -> str {
        source = chunk.metadata.get('source', 'unknown');
        page = chunk.metadata.get('page');
        chunk_id = chunk.metadata.get('id', '');

        metadata_prefix = f"Source: {source}";
        if page is not None {
            metadata_prefix += f", Page: {page}";
        }
        if chunk_id {
            metadata_prefix += f", ChunkID: {chunk_id}";
        }

        return f"{metadata_prefix}\n\n{chunk.page_content}";
    }

    def add_chunk_id(chunks: list[Document]) {
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
            # Store original content and set enriched content for embedding
            chunk.metadata['original_content'] = chunk.page_content;
            chunk.page_content = self.enrich_content_with_metadata(chunk);
        }

        return chunks;
    }

    def create_faiss_index(chunks: list[Document]) {
        if len(chunks) > 0 {
            print(f"Creating FAISS index with {len(chunks)} chunks (with metadata enrichment)");
            chunks = self.add_chunk_id(chunks);
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

    def rerank_results(query: str, documents: list, top_n: int = None) {

        if not self.use_reranking or self.cross_encoder is None {
            return documents;
        }

        try {
            rerank_start = time.perf_counter();
            # Extract documents and prepare query-document pairs
            docs_only = [doc for (doc, _) in documents];

            # Create query-document pairs for CrossEncoder with metadata context
            pairs = [];
            for doc in docs_only {
                # Use enriched content with metadata for reranking
                enriched_content = self.enrich_content_with_metadata(doc);
                pairs.append((query, enriched_content));
            }

            # Get reranking scores
            scores = self.cross_encoder.predict(pairs, show_progress_bar=False);

            # Combine documents with their new scores
            doc_score_pairs = list(zip(docs_only, scores));

            # Sort by score in descending order
            doc_score_pairs = sorted(doc_score_pairs, key=lambda x: float: -x[1]);

            # Filter to only include documents with score > 0.5
            results = [(doc, float(score)) for (doc, score) in doc_score_pairs if score > 0.5];

            # Limit to top_n results
            if top_n is not None {
                results = results[:top_n];
            }

            rerank_elapsed = time.perf_counter() - rerank_start;
            print(f"Reranking time: {rerank_elapsed:.4f}s");
            print(f"Reranked {len(results)} documents using CrossEncoder (filtered to score > 0.5)");
            return results;
        } except Exception as e {
            print(f"Error during reranking: {e}");
            print("Falling back to original FAISS results");
            return documents;
        }
    }

    def get_from_faiss(query: str) {

        if self.vectorstore is None {
            print("FAISS index not initialized");
            return [];
        }
        search_start = time.perf_counter();
        results = self.vectorstore.similarity_search_with_score(query, k=self.chunk_nos);
        search_elapsed = time.perf_counter() - search_start;
        print(f"Search time: {search_elapsed:.4f}s");

        # Apply CrossEncoder reranking if enabled
        if self.use_reranking and len(results) > 0 {
            results = self.rerank_results(query, results, top_n=self.top_n);
        }

        return results;
    }

    def search(query: str) {
        print(f'Searching RAG Engine with query: {query}');
        rag_start = time.perf_counter();
        results = self.get_from_faiss(query=query);

        print(f"\n{'='*60}");
        print(f"Retrieved {len(results)} chunks for query: {query}");
        print(f"{'='*60}");

        summary = "";
        for (idx, (doc, score)) in enumerate(results, 1) {
            page = doc.metadata.get('page');
            source = doc.metadata.get('source');
            id = doc.metadata.get('id');
            chunk_txt = doc.page_content;


            # Print chunk details with score
            print(f"\nChunk {idx}:");
            print(f"  Score: {score:.4f}");
            print(f"  Source: {source}");
            print(f"  ID: {id}");
            if page is not None {
                print(f"  Page: {page}");
            }
            print(f"  Content preview: {chunk_txt[:100]}...");

            # Get original content if available (for enriched indexes)
            original_content = doc.metadata.get('original_content', chunk_txt);

            # Handle display for different file types - include chunk id
            if page is not None {
                summary += f"[{id}] {source} page {page} (score: {score:.4f}): {original_content}\n";
            } else {
                # For markdown files without page numbers
                summary += f"[{id}] {source} (score: {score:.4f}): {original_content}\n";
            }
        }

        print(f"\n{'='*60}\n");
        rag_elapsed = time.perf_counter() - rag_start;
        print(f"RAG time: {rag_elapsed:.4f}s");
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
