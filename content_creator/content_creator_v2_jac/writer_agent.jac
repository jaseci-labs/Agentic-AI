import os;
import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import from langchain_core.output_parsers { StrOutputParser }
import from tavily { TavilyClient }
import from state { AgentState }

import from dotenv { load_dotenv }
with entry {
    load_dotenv();
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY');
    tavily_client = TavilyClient(api_key=os.getenv('TAVILY_API_KEY'));
}


obj WriterAgent {
    def init {
        print("Initializing WriterAgent init section");
        self.llm = ChatOpenAI(model='gpt-4o', temperature=0);
        self.search_tool = tavily_client;
        prompt =
            ChatPromptTemplate.from_template(
                "You are an expert content writer, specializing in creating engaging {output_format} articles."
                "Your task is to write a comprehensive article on the topic: {topic}\n"
                "Use the research data {research_data} to ensure your article is factual and up-to-date."
                "The article should be well-structured, clear, and align with the user's original request for a {output_format}.\n"
                "Start with a compelling title. Use markdown for formatting (e.g., # Title, ## Subheading, *italic*)."
            );
        self.chain = ((prompt | self.llm) | StrOutputParser());
        revision_prompt =
            ChatPromptTemplate.from_template(
                "You are an expert content writer. Your previous draft was reviewed and needs improvement. Your task is to revise the article based on the editor's feedback."
                "TOPIC: {topic}\n"
                "EDITOR'S FEEDBACK: {review_notes}\n"
                "ORIGINAL RESEARCH DATA: {research_data}\n"
                "Please rewrite the article, incorporating all the feedback to create a high-quality final version."
            );
        self.revision_chain = ((revision_prompt | self.llm) | StrOutputParser());
    }

    def run(state: AgentState) {
        print('---EXECUTING WRITER AGENT---');
        if state.get('review_notes') {
            print('Revising article based on editor feedback...');
            article =
                self.revision_chain.invoke(

                    {'topic' : state[ 'selected_topic' ] , 'review_notes' : state[ 'review_notes' ] , 'research_data' : state[ 'research_data' ] }
                );
            return {'article' : article , 'review_notes' : None };
        }
        trending_topics = state[ 'trending_topics' ];
        user_input = state[ 'user_input' ];
        selected_topic = trending_topics[ 0 ];
        print(f"'Selected Topic: '{selected_topic}");
        research_results =
            self.search_tool.search(
                query=f"'latest information and key facts about '{selected_topic}",
                max_results=5
            );
        research_data =
            '\n\n'.join(
                [ f"'Source: '{res[ 'url' ]}'\nContent: '{res[ 'content' ]}" for res in research_results[ 'results' ] ]
            );
        print('Research complete.');
        article =
            self.chain.invoke(

                {'topic' : selected_topic , 'research_data' : research_data , 'output_format' : user_input[ 'expected_output' ] }
            );
        print('Article generation complete.');
        return
        {'selected_topic' : selected_topic , 'research_data' : research_data , 'article' : article };
    }
}

