import from states { AppState }
import from prompts { ROUTER_PROMPT, llm }
import json;

def router_llm_node(state: AppState) -> AppState {
    history = state.get("history", [])[-10:];
    hist_txt = "\n".join(history);

    result = (ROUTER_PROMPT | llm).invoke({"history": hist_txt, "utterance": state.get("utterance","")}).content;
    try {
        data = json.loads(result);
        route = data.get("route", "GENERAL_CHAT");
        if route not in {"TASK_HANDLING", "EMAIL_HANDLING", "GENERAL_CHAT"} {
            route = "GENERAL_CHAT";
        }
    } except Exception {
        route = "GENERAL_CHAT";
    }
    state["route"] = route;  # type: ignore
    return state;
}