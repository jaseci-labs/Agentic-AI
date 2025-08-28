import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import from langchain_core.output_parsers { JsonOutputParser }
import from state { AgentState }

import from tavily { TavilyClient }
import from dotenv { load_dotenv }
with entry {
    load_dotenv();
}
import os;


with entry {
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY');
    tavily_client = TavilyClient(api_key=os.getenv('TAVILY_API_KEY'));
}


# class TrendAgent {
#     def init(self: TrendAgent) {
#         self.llm = ChatOpenAI(model='gpt-4o-mini', temperature=0);
#         prompt = ChatPromptTemplate.from_template(
#             "You are a trend researcher. Your goal is to find hot and relevant topics. "
#             "Based on the following information, identify 3-5 current trending topics or angles worth writing about today. "
#             "Return your answer as a JSON object with a single key 'topics' which is a list of strings.\n\n"
#             "Field: {field}\n"
#             "Topic: {topic}\n"
#             "Expected Output: {output_format}\n"
#         );
#         self.chain = ((prompt | self.llm) | JsonOutputParser());
#     }
    
#     def run(self: TrendAgent, state: AgentState) {
#         print('---EXECUTING TREND AGENT---');
#         user_input = state[ 'user_input' ];
#         print("state is", state);
#         result =
#             self.chain.invoke(

#                 {'field' : user_input[ 'field' ] , 'topic' : user_input[ 'topic' ] , 'output_format' : user_input[ 'expected_output' ] }
#             );
#         print(f"'Found Trends: '{result[ 'topics' ]}");
#         return {'trending_topics' : result[ 'topics' ] };
#     }
# }



obj TrendAgent {
    def init {
        self.llm = ChatOpenAI(model='gpt-4o-mini', temperature=0);
        prompt = ChatPromptTemplate.from_template(
            "You are a trend researcher. Your goal is to find hot and relevant topics. "
            "Based on the following information, identify 3-5 current trending topics or angles worth writing about today. "
            "Return your answer as a JSON object with a single key 'topics' which is a list of strings.\n\n"
            "Field: {field}\n"
            "Topic: {topic}\n"
            "Expected Output: {output_format}\n"
        );
        self.chain = ((prompt | self.llm) | JsonOutputParser());
    }
    
    def run(state: AgentState) {
        print('---EXECUTING TREND AGENT---');
        user_input = state[ 'user_input' ];
        print("state is", state);
        result =
            self.chain.invoke(

                {'field' : user_input[ 'field' ] , 'topic' : user_input[ 'topic' ] , 'output_format' : user_input[ 'expected_output' ] }
            );
        print(f"'Found Trends: '{result[ 'topics' ]}");
        return {'trending_topics' : result[ 'topics' ] };
    }
}

