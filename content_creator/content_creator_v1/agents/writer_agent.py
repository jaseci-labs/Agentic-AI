import os
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from tavily import TavilyClient
from state import AgentState

from dotenv import load_dotenv
load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")


class WriterAgent:
    def __init__(self):
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0)
        self.search_tool = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"))
        prompt = ChatPromptTemplate.from_template(
            """
            You are an expert content writer, specializing in creating engaging {output_format} articles.
            Your task is to write a comprehensive article on the topic: "{topic}".

            Use the following research data to ensure your article is factual and up-to-date:
            --- RESEARCH DATA ---
            {research_data}
            --- END RESEARCH DATA ---

            The article should be well-structured, clear, and align with the user's original request for a {output_format}.
            Start with a compelling title. Use markdown for formatting (e.g., # Title, ## Subheading, *italic*).
            """
        )
        self.chain = prompt | self.llm | StrOutputParser()
        
        revision_prompt = ChatPromptTemplate.from_template(
            "You are an expert content writer. Your previous draft was reviewed and needs improvement. "
            "Your task is to revise the article based on the editor's feedback.\n\n"
            "TOPIC: {topic}\n\n"
            "EDITOR'S FEEDBACK:\n{review_notes}\n\n"
            "ORIGINAL RESEARCH DATA:\n{research_data}\n\n"
            "Please rewrite the article, incorporating all the feedback to create a high-quality final version."
        )
        self.revision_chain = revision_prompt | self.llm | StrOutputParser()
    
    def run(self, state: AgentState):
        print("---EXECUTING WRITER AGENT---")
        
        if state.get("review_notes"):
            print("Revising article based on editor feedback...")
            article = self.revision_chain.invoke({
                "topic": state['selected_topic'],
                "review_notes": state['review_notes'],
                "research_data": state['research_data']
            })
            # Clear the review notes after addressing them
            return {"article": article, "review_notes": None}
            
        trending_topics = state['trending_topics']
        user_input = state['user_input']

        # Select the top topic
        selected_topic = trending_topics[0]
        print(f"Selected Topic: {selected_topic}")

        # Researching the selected topic
        research_results = self.search_tool.search(query=f"latest information and key facts about {selected_topic}", max_results=5)
        research_data = "\n\n".join([f"Source: {res['url']}\nContent: {res['content']}" for res in research_results['results']])
        print("Research complete.")

        # Writing the article
        article = self.chain.invoke({
            "topic": selected_topic,
            "research_data": research_data,
            "output_format": user_input['expected_output']
        })

        print("Article generation complete.")
        return {
            "selected_topic": selected_topic,
            "research_data": research_data,
            "article": article
        }
        
     