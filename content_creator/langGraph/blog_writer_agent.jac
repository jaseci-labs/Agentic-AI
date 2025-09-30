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
    has llm : ChatOpenAI = ChatOpenAI(model='gpt-4o', temperature=0);
    has prompt : ChatPromptTemplate = ChatPromptTemplate.from_template(
        "You are an expert content writer, specializing in creating engaging {output_format} articles."
        "Your task is to write a comprehensive article on the topic: {topic}\n"
        "You must strictly follow the provided content plan {plan}, including all sections, topics, and code snippets as instructed."
        "You must adopt the following tone and style. TONE EXAMPLE {tone_sample}"
        "The target audience for this article is: {audience}\n"
        "The article should be written from the perspective of: {write_as}\n"
        "The article should be well-structured, clear, and align with the user's original request for a {output_format}.\n"
    );

    has revision_prompt : ChatPromptTemplate = ChatPromptTemplate.from_template(
        "You are an expert content writer. Your previous draft was reviewed and needs improvement. Your task is to revise the article based on the editor's feedback."
        "TOPIC: {topic}\n"
        "EDITOR'S FEEDBACK: {review_notes}\n"
        "ORIGINAL PLAN: {plan}\n"
                "The target audience for this article is: {audience}\n"
                "The article should be written from the perspective of: {write_as}\n"
                "Please rewrite the article, incorporating all the feedback to create a high-quality final version."
    );

    def run(state: AgentState) {
        print('---EXECUTING WRITER AGENT---');
        self.chain = ((self.prompt | self.llm) | StrOutputParser());
        self.revision_chain = ((self.revision_prompt | self.llm) | StrOutputParser());
        user_input = state[ 'user_input' ];
        if state.get('review_notes') {
            print('Revising article based on editor feedback...');
            article =
                self.revision_chain.invoke(

                    {'topic' : user_input[ 'topic'], 'review_notes' : state[ 'review_notes' ] , 'tone_sample' : user_input[ 'tone_sample' ], 'audience' : user_input[ 'audience' ], 'write_as' : user_input[ 'write_as' ], 'plan' : state[ 'plan' ] }
                );
            return {'article' : article , 'review_notes' : None };
        }
        article =
            self.chain.invoke(

                {'topic' : user_input[ 'topic'] , 'plan' : state[ 'plan' ], 'tone_sample' : user_input[ 'tone_sample' ], 'audience' : user_input[ 'audience' ], 'write_as' : user_input[ 'write_as' ], 'output_format' : user_input[ 'expected_output' ] }
            );
        print('Article generation complete.');
        return
        {'article' : article };
    }
}

