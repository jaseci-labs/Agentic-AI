from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import JsonOutputParser
from state import AgentState

from tavily import TavilyClient
from dotenv import load_dotenv
load_dotenv()
import os


OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
tavily_client = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"))

class TrendAgent:
    def __init__(self):
        self.llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
        prompt = ChatPromptTemplate.from_template(
            """
            You are a trend researcher. Your goal is to find hot and relevant topics.
            Based on the user's requested field "{field}", topic "{topic}", and expected output format "{output_format}",
            identify 3-5 current trending topics or angles worth writing about today.

            Return your answer as a JSON object with a single key "topics" which is a list of strings.
            Example: {{"topics": ["Topic 1", "Topic 2", "Topic 3", etc.]}}
            """
        )
        self.chain = prompt | self.llm | JsonOutputParser()

    def run(self, state: AgentState):
        """
        The entry point for the Trend Agent node.
        """
        print("---EXECUTING TREND AGENT---")
        user_input = state['user_input']
        
        result = self.chain.invoke({
            "field": user_input['field'],
            "topic": user_input['topic'],
            "output_format": user_input['expected_output']
        })

        print(f"Found Trends: {result['topics']}")
        return {"trending_topics": result['topics']}