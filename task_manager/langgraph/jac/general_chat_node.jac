import from states { AppState }
import from langchain_core.messages { SystemMessage, HumanMessage }
import from prompts { llm }

def general_chat_node(state: AppState) -> AppState {
    history = state.get("history", []);
    utterance = state.get("utterance", "");
    messages = [SystemMessage(content="You are a concise, helpful assistant.")] + history[-10:] + [HumanMessage(content=utterance)];
    result = llm.invoke(messages);
    state["response"] = result.content;
    return state;
}