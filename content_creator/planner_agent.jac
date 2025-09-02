import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import from langchain_core.output_parsers { StrOutputParser }
import from langchain.chains.combine_documents { create_stuff_documents_chain }
import from state { AgentState }


obj ContentPlannerAgent {
    def init {
        self.llm = ChatOpenAI(model='gpt-4o');
        prompt =
            ChatPromptTemplate.from_template(
                "You are an expert content planner. Your task is to create a detailed, section-by-section plan for a blog post based on the provided context."
                "The topic of the blog post is: {topic}."
                "Analyze the following context, which contains notes, content, and code snippets from a draft document."
                "CONTEXT: {context}"
                "Create a comprehensive plan that outlines - A catchy title. - An introduction. - A list of main sections with a brief description of what each should cover. - Explicit instructions on where to include specific code snippets mentioned in the context. - A conclusion."
                "Your output should be a clear and actionable plan for the writing agent."
            );
        self.chain = create_stuff_documents_chain(self.llm, prompt);
    }

    def run(state: AgentState) {
        print('---EXECUTING CONTENT PLANNER AGENT---');
        retriever = state[ 'retriever' ];
        topic = state[ 'user_input' ][ 'topic' ];
        all_docs = retriever.invoke(topic);
        plan = self.chain.invoke({'topic' : topic , 'context' : all_docs });
        print('---CONTENT PLAN GENERATED---');
        return {'plan' : plan };
    }
}

