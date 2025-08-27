from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from state import AgentState

class EditorAgent:
    def __init__(self):
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0)
        prompt = ChatPromptTemplate.from_template(
            "You are an expert editor. Your job is to review a draft article and decide if it's ready for publication. "
            "Check only the content, the visual aids check is not needed"
            "If the article is high-quality, well-structured, and engaging, with a tone of a 3rd part person, respond with 'OK'. "
            "If it needs improvement, provide a concise list of 2-3 bullet points with specific, actionable feedback. Do not approve a mediocre article.\n\n"
            "ARTICLE DRAFT:\n{article}"
        )
        self.chain = prompt | self.llm | StrOutputParser()

    def run(self, state: AgentState):
        print("---EXECUTING EDITOR AGENT---")
        
        review_count = state.get('review_count', 0) + 1
        
        print(f"---EDITOR REVIEW COUNT: {review_count}---")

        article = state['article']
        review = self.chain.invoke({"article": article})

        if review.strip().upper() == "OK":
            print("Editor approved the article.")
            return {"review_notes": None, "review_count": review_count}
        else:
            print(f"Editor requested revisions:\n{review}")
            return {"review_notes": review, "review_count": review_count}