import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import from langchain_core.output_parsers { StrOutputParser }
import from state { AgentState }


obj EditorAgent {
    has llm : ChatOpenAI = ChatOpenAI(model='gpt-4o');
    has prompt : ChatPromptTemplate = ChatPromptTemplate.from_template(
        "You are an expert editor. Your job is to review a draft article and decide if it's ready for publication."
        "Check only the content, the visual aids check is not neededIf the article is high-quality, well-structured, and engaging, with a tone of a 3rd party person, respond with 'OK'."
        "If it needs improvement, provide a concise list of 2-3 bullet points with specific, actionable feedback. Do not approve a mediocre article."
        "ARTICLE DRAFT:{article}\n"
        "Make sure it align with the tone user requested, the sample of the tones: {tone_sample}"
    );


    def run(state: AgentState) {
        print('---EXECUTING EDITOR AGENT---');
        self.chain = ((self.prompt | self.llm) | StrOutputParser());
        review_count = (state.get('review_count', 0) + 1);
        print(f"'---EDITOR REVIEW COUNT: '{review_count}'---'");
        article = state[ 'article' ];
        tone_sample = state[ 'user_input' ][ 'tone_sample' ];
        review = self.chain.invoke({'article' : article, 'tone_sample' : tone_sample});
        if (review.strip().upper() == 'OK') {
            print('Editor approved the article.');
            return {'review_notes' : None , 'review_count' : review_count };
        }
            else
            {
            print(f"'Editor requested revisions:\n'{review}");
            return {'review_notes' : review , 'review_count' : review_count };
            }

    }
}

