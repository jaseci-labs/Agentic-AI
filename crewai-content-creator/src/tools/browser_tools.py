"""This module contains tools for web crawling, taking screenshots, and querying webpages."""

import base64
import hashlib
import json
import os
from datetime import datetime
from dotenv import load_dotenv
from exa_py import Exa

from langchain.agents import tool
from langchain.chains.combine_documents.stuff import StuffDocumentsChain
from langchain.chains.llm import LLMChain

from langchain_community.document_loaders import PlaywrightURLLoader, WebBaseLoader
from langchain_community.utilities.google_serper import GoogleSerperAPIWrapper
from langchain_community.vectorstores import FAISS

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate, PromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.tools import Tool
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

from langchain_text_splitters import CharacterTextSplitter


from playwright.sync_api import sync_playwright

import requests


load_dotenv()

search = GoogleSerperAPIWrapper()


def google_serper(tool: GoogleSerperAPIWrapper) -> Tool:
    """Create a Google Serper tool."""
    return Tool(
        name="google search",
        func=lambda query: (
            tool.run(query["description"])
            if isinstance(query, dict) and "description" in query
            else tool.run(query)
        ),
        description="Search the web using Google Serper API.",
    )


web_search_tool = google_serper(search)


class ExaSearchTool:
    """This tool uses the Exa API to search the web and get the contents of webpages."""

    @staticmethod
    @tool
    def search(query: str) -> dict:
        """Search for webpages based on a query using Exa API."""
        return ExaSearchTool._exa().search(
            f"{query}", use_autoprompt=True, num_results=5
        )

    @staticmethod
    @tool
    def find_similar(url: str) -> dict:
        """Search for webpages similar to a given URL.The url passed in should be a URL returned from `search`."""
        return ExaSearchTool._exa().find_similar(url, num_results=3)

    @staticmethod
    @tool
    def get_contents(ids: str) -> str:
        """Get the contents of a webpage.The ids must be passed in as a list,a list of ids returned from `search`."""
        ids = eval(ids)
        contents = ExaSearchTool._exa().get_contents(ids)
        print(contents)
        contents = contents.split("URL:")
        contents = [content[:1000] for content in contents]
        return "\n\n".join(contents)

    @staticmethod
    def tools() -> list:
        """Return a list of tools in this tool class."""
        return [
            ExaSearchTool.search,
            ExaSearchTool.find_similar,
            ExaSearchTool.get_contents,
        ]

    @staticmethod
    def _exa() -> Exa:
        return Exa(api_key=os.environ["EXA_API_KEY"])


class WebCrawlingTool:
    """This tool provides functionality for web crawling and querying webpages."""

    @staticmethod
    @tool("open_webpage")
    def open_webpage(url: str) -> str:
        """Use this tool to open webpage and get the summary of content. Input must be the URL of the webpage."""
        if isinstance(url, dict):
            if "url" in url:
                url = url["url"]
            else:
                return "Error: Input dictionary must contain 'url' key."

        if url.startswith("https://www.tripadvisor."):
            return "Error: URLs from TripAdvisor are not supported by this tool."

        if url.endswith(".aspx"):
            return "Error: URLs ending with .aspx are not supported by this tool."

        try:
            if url.endswith(".pdf"):
                return "Error: PDF files cannot be processed by this tool."

            loader = WebBaseLoader(url)
            docs = loader.load()
            llm = ChatOpenAI(temperature=0, model="gpt-4o-mini")

            prompt_template = """Write a summary of the following:
            "{text}"
            CONCISE SUMMARY:"""
            prompt = PromptTemplate.from_template(prompt_template)
            llm_chain = LLMChain(llm=llm, prompt=prompt)
            stuff_chain = StuffDocumentsChain(
                llm_chain=llm_chain, document_variable_name="text"
            )
            summary = stuff_chain.invoke(docs)
            return summary["output_text"]
        except ConnectionError as e:
            return f"Error: Failed to connect to the server. {e}"

    @staticmethod
    @tool("open_js_webpage")
    def open_js_webpage(url: str) -> str:
        """Only this to open javascript rendered webpages and get a summary of content."""
        if isinstance(url, dict):
            if "url" in url:
                url = url["url"]
            else:
                return "Error: Input dictionary must contain 'url' key."

        if url.startswith("https://www.tripadvisor."):
            return "Error: URLs from TripAdvisor are not supported by this tool."

        if url.endswith(".aspx"):
            return "Error: URLs ending with .aspx are not supported by this tool."

        try:
            if url.endswith(".pdf"):
                return "Error: PDF files cannot be processed by this tool."

            loader = PlaywrightURLLoader(
                urls=[url],
                remove_selectors=["header", "footer"],
            )
            docs = loader.load()
            llm = ChatOpenAI(temperature=0, model="gpt-4o-mini")

            prompt_template = """Write a summary of the following:
            "{text}"
            CONCISE SUMMARY:"""
            prompt = PromptTemplate.from_template(prompt_template)
            llm_chain = LLMChain(llm=llm, prompt=prompt)
            stuff_chain = StuffDocumentsChain(
                llm_chain=llm_chain, document_variable_name="text"
            )
            summary = stuff_chain.invoke(docs)
            return summary["output_text"]
        except ConnectionError as e:
            return f"Error: Failed to connect to the server. {e}"

    @staticmethod
    @tool
    def query_webpage(url: str, query: str) -> str:
        """Use this tool to query a webpage. Input is the URL you found using search_query with search the internet tool and a query."""
        if url.startswith("https://www.tripadvisor."):
            return "Error: URLs from TripAdvisor are not supported by this tool."
        if url.endswith(".aspx"):
            return "Error: URLs ending with .aspx are not supported by this tool."
        try:
            if url.endswith(".pdf"):
                return "Error: PDF files cannot be processed by this tool."

            loader = WebBaseLoader(url)
            documents = loader.load()
            embeddings = OpenAIEmbeddings()
            text_splitter = CharacterTextSplitter(chunk_size=200, chunk_overlap=0)
            docs = text_splitter.split_documents(documents)
            vectorstore = FAISS.from_documents(docs, embeddings)
            retriever = vectorstore.as_retriever(search_kwargs={"k": 5})

            template = """You are given a query/question and some extracted parts of a webpage that maybe usefull to
            answer the question.

            ==========
            Question: {question}
            =========
            {context}
            =========
            """
            prompt = ChatPromptTemplate.from_template(template)

            model = ChatOpenAI(temperature=0, model="gpt-4o-mini")

            chain = (
                {"context": retriever, "question": RunnablePassthrough()}
                | prompt
                | model
                | StrOutputParser()
            )

            ans = chain.invoke(query)
            return ans
        except ConnectionError as e:
            return f"Error: Failed to connect to the server. {e}"


class ScreenshotTool:
    """This tool provides functionality for taking screenshots of webpages and querying them."""

    imgbb_api_key = "e5c6861d5c54afb373ce62d603d14bf3"
    imgbb_url = "https://api.imgbb.com/1/upload"
    screenshots_dir = os.path.join("src", "data", "screenshots")

    @staticmethod
    @tool
    def take_screenshot(url: str) -> dict:
        """Use this tool to take a screenshot of a webpage and get the screenshot image link and local path."""
        if isinstance(url, dict):
            if "url" in url:
                url = url["url"]
            else:
                return {"error": "Input dictionary must contain 'url' key."}

        os.makedirs(ScreenshotTool.screenshots_dir, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        url_hash = hashlib.md5(url.encode("utf-8")).hexdigest()[:8]
        screenshot_filename = f"screenshot_{url_hash}_{timestamp}.png"
        screenshot_path = os.path.join(
            ScreenshotTool.screenshots_dir, screenshot_filename
        )

        try:
            with sync_playwright() as p:
                browser = p.chromium.launch(headless=True)
                page = browser.new_page()
                page.goto(url)
                page.wait_for_timeout(
                    5000
                )  # Wait for 5 seconds to allow the page to load
                page.screenshot(path=screenshot_path, full_page=False)
                browser.close()

            with open(screenshot_path, "rb") as file:
                response = requests.post(
                    ScreenshotTool.imgbb_url,
                    params={"expiration": "600", "key": ScreenshotTool.imgbb_api_key},
                    files={"image": file},
                )

            if response.status_code == 200:
                imgbb_data = response.json()
                img_url = imgbb_data["data"]["url"]
                return {"local_path": screenshot_path, "imgbb_url": img_url}
            else:
                return {"error": "Error uploading to imgbb"}
        except Exception as e:
            return {"error": f"Failed to take a screenshot. {e}"}

    @staticmethod
    def image_to_base64(image_path: str) -> str:
        """Convert an image file to a base64-encoded string."""
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode("utf-8")

    @staticmethod
    def send_request(image_base64: str, prompt: str) -> str | None:
        """Send a request to the specified API endpoint with the given image and prompt."""
        data = {
            "model": "llava",
            "prompt": prompt,
            "stream": False,
            "images": [image_base64],
        }
        url = "http://52.23.242.52:11343/api/generate"
        headers = {"Content-Type": "application/json"}

        response = requests.post(url, headers=headers, data=json.dumps(data))

        if response.status_code == 200:
            response_data = response.json()
            return response_data.get("response")
        else:
            print("Error:", response.status_code, response.text)
            return None

    @staticmethod
    @tool
    def query_screenshot(url: str, prompt: str) -> str:
        """Use when you need to analyze branding of a competitor. Use this tool to take a screenshot of a webpage, query the screenshot with a prompt."""
        screenshot_data = ScreenshotTool.take_screenshot(url)
        if "error" in screenshot_data:
            return screenshot_data["error"]

        screenshot_path = screenshot_data["local_path"]
        image_base64 = ScreenshotTool.image_to_base64(screenshot_path)
        response = ScreenshotTool.send_request(image_base64, prompt)

        if response:
            imgbb_url = screenshot_data["imgbb_url"]
            markdown_image_link = f"![Screenshot]({imgbb_url})"
            return f"{response}\n\n{markdown_image_link}\ninclude the screenshot image in report with the analysis."
        else:
            return "Error analyzing the screenshot."
