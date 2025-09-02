import from langchain_community.document_loaders { PyMuPDFLoader, FileSystemBlobLoader }
import from langchain_community.document_loaders.generic { GenericLoader }
import from langchain_community.document_loaders.parsers { PyMuPDFParser }
import from langchain_text_splitters { RecursiveCharacterTextSplitter }
import from langchain_openai { OpenAIEmbeddings }
import from langchain_community.vectorstores { FAISS }

def setup_rag_pipeline(folder_path: str) {
    print(f"'Setting up RAG for PDF: '{folder_path}");

    loader = GenericLoader(
        blob_loader=FileSystemBlobLoader(
            path=folder_path,
            glob="*.pdf",
        ),
        blob_parser=PyMuPDFParser(extract_tables="markdown"),
    );
    documents = loader.load();

    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100);
    chunks = text_splitter.split_documents(documents);

    embeddings = OpenAIEmbeddings();
    vector_store = FAISS.from_documents(chunks, embeddings);
    retriever = vector_store.as_retriever();
    return retriever;
}
