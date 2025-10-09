import os;
import requests;
import from langchain_community.document_loaders {PyPDFDirectoryLoader, PyPDFLoader, DirectoryLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain.schema.document {Document}
import from langchain_openai {OpenAIEmbeddings}
import from langchain_chroma {Chroma}

glob SERPER_API_KEY: str = os.getenv('SERPER_API_KEY', '');

obj RagEngine {
    has file_path: str = "docs";
    has chroma_path: str = "chroma";

    def postinit {
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
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=800,
        chunk_overlap=80,
        length_function=len,
        is_separator_regex=False);
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

    def get_from_chroma(query: str,chunck_nos: int=5) {
        db = Chroma(
            persist_directory=self.chroma_path,
            embedding_function=self.get_embedding_function()
        );
        results = db.similarity_search_with_score(query,k=chunck_nos);
        return results;
    }
    """Convert local file path to GitHub URL"""
    def convert_to_github_url(source_path: str) -> str {
        
        # Handle different path formats that might be returned
        clean_path = source_path;
        
        # Remove absolute path prefix and keep only the relative path from docs
        if "/docs/" in clean_path {
            # Extract everything after the last "/docs/"
            docs_index = clean_path.rfind("/docs/");
            relative_path = clean_path[docs_index + 6:];  # +6 to skip "/docs/"
        } elif clean_path.startswith('docs/') {
            # Remove 'docs/' prefix
            relative_path = clean_path[5:];
        } else {
            # Assume it's already a relative path within docs
            relative_path = clean_path;
        }
        
        # GitHub repository base URL - the docs are in docs/docs/ in the jaseci repo
        github_base = "https://github.com/jaseci-labs/jaseci/tree/main/docs/docs";
        
        # Combine base URL with relative path
        github_url = f"{github_base}/{relative_path}";
        
        return github_url;
    }

    def search(query: str, chunck_nos: int=5) {
        results = self.get_from_chroma(query=query, chunck_nos=chunck_nos);
        summary = "";
        sources = [];
        
        for (doc, score) in results {
            page = doc.metadata.get('page');
            source = doc.metadata.get('source');
            chunk_txt = doc.page_content[:400];
            
            # Convert local path to GitHub URL
            github_url = self.convert_to_github_url(source);
            
            # Handle display for different file types
            if page is not None {
                summary += f"{source} page {page}: {chunk_txt}\n";
            } else {
                # For markdown files without page numbers
                summary += f"{source}: {chunk_txt}\n";
            }
            
            # Collect unique sources with their GitHub URLs
            if github_url not in sources {
                sources.append(github_url);
            }
        }
        
        # Add sources section at the end with clickable Markdown links
        if sources {
            summary += "\n\n**Sources:**\n";
            for source_url in sources {
                # Extract meaningful path from URL for better link text
                url_parts = source_url.split('/');
                # Get the path after 'docs/docs/'
                if 'docs' in url_parts {
                    docs_index = url_parts.index('docs');
                    if docs_index + 1 < len(url_parts) and url_parts[docs_index + 1] == 'docs' {
                        # Get path from the second 'docs' onwards
                        relative_path = '/'.join(url_parts[docs_index + 2:]);
                        link_text = relative_path if relative_path else url_parts[-1];
                    } else {
                        link_text = url_parts[-1];
                    }
                } else {
                    link_text = url_parts[-1];
                }
                summary += f"- [{link_text}]({source_url})\n";
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