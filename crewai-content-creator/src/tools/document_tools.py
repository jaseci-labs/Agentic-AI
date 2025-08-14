"""This module contains tools that can be used to interact with user's documents."""

import os
from typing import List
from langchain.agents import tool

from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_community.vectorstores import FAISS

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

from langchain_text_splitters import CharacterTextSplitter


class FileTools:
    """A tool that can be used to interact with user's documents."""

    @staticmethod
    def query_existing_document(user_id: str, file_name: str, query: str) -> str:
        """Use this tool to query any existing documents provided by the user.

        Args:
            user_id (str): The ID of the user.
            file_name (str): The name of the file to query.
            query (str): The query string to search for in the document.

        Returns:
            str: Relevant information found in the document.

        Notes:
            File names should be obtained using the open folder tool first.
            Documents may or may not contain relevant information, such as findings
            from their own research.
        """
        embeddings = OpenAIEmbeddings()
        file_path = os.path.join("temp", user_id, file_name)

        if file_name.lower().endswith(".txt"):
            loader = TextLoader(file_path)
        elif file_name.lower().endswith(".pdf"):
            loader = PyPDFLoader(file_path)
        else:
            available_files = [
                f
                for f in os.listdir(os.path.join("temp", user_id))
                if f.lower().endswith(".txt") or f.lower().endswith(".pdf")
            ]
            raise ValueError(
                f"Unsupported file format. Available .txt and .pdf files: {', '.join(available_files)}"
            )

        documents = loader.load()
        text_splitter = CharacterTextSplitter(chunk_size=200, chunk_overlap=0)
        docs = text_splitter.split_documents(documents)

        vectorstore = FAISS.from_documents(docs, embeddings)
        retriever = vectorstore.as_retriever(search_kwargs={"k": 5})

        template = """You are given a question and some extracted context that can be used to answer the question.
        if the answer is not avilble in the given context.
        say that information is not given and mention what is the document is about,

        ==========
        Question: {question}
        =========
        {context}
        =========
        """
        prompt = ChatPromptTemplate.from_template(template)

        model = ChatOpenAI(model="gpt-4o-mini", temperature=0)

        chain = (
            {"context": retriever, "question": RunnablePassthrough()}
            | prompt
            | model
            | StrOutputParser()
        )

        ans = chain.invoke(query)
        return ans

    @staticmethod
    @tool
    def open_user_documents_folder(user_id: str) -> List[str]:
        """Use this tool to open exsisting documents folder and get a list of files in the folder."""
        folder_path = os.path.join("temp", str(user_id))

        if not os.path.exists(folder_path):
            return ["Folder not found."]

        if not os.listdir(folder_path):
            return ["Folder is empty."]

        pdf_files = [
            file for file in os.listdir(folder_path) if file.lower().endswith(".pdf")
        ]
        txt_files = [
            file for file in os.listdir(folder_path) if file.lower().endswith(".txt")
        ]

        if not pdf_files and not txt_files:
            return ["Customer does not have any existing documents (PDF or TXT)."]

        return pdf_files + txt_files
