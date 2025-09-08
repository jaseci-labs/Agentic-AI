import from langgraph.graph { StateGraph, START, END }
import from states { AppState }

import from general_chat_node { general_chat_node }
import from router_llm_node { router_llm_node }
import from task_handle_node { task_decider_node, task_add_node, task_summarize_node }
import from email_handle_node { email_decider_node, email_draft_node, send_email }

def build_graph() {
    graph = StateGraph(AppState);
    graph.add_node("router", router_llm_node);

    # TaskHandling
    graph.add_node("task_decider", task_decider_node);
    graph.add_node("task_add", task_add_node);
    graph.add_node("task_summarize", task_summarize_node);

    # Email
    graph.add_node("email_decider", email_decider_node);
    graph.add_node("email_draft", email_draft_node);
    graph.add_node("email_send", send_email) ;

    # General chat
    graph.add_node("general_chat", general_chat_node);

    # Edges
    graph.add_edge(START, "router");
    graph.add_conditional_edges(
        "router",
        lambda s: str: s["route"],
        {
            "TASK_HANDLING": "task_decider",
            "EMAIL_HANDLING": "email_decider",
            "GENERAL_CHAT": "general_chat",
        },
    );
    graph.add_conditional_edges(
        "task_decider",
        lambda s: str: s["task_action"],
        {
            "EXTRACT_AND_ADD": "task_add",
            "SUMMARIZE": "task_summarize",
        },
    );
    graph.add_conditional_edges(
        "email_decider",
        lambda s: str: s["email_action"],
        {
            "DRAFT": "email_draft",
            "SEND": "email_send",
        },
    );

    graph.add_edge("task_add", END);
    graph.add_edge("task_summarize", END);
    graph.add_edge("email_draft", END);
    graph.add_edge("email_send", END);
    graph.add_edge("general_chat", END);

    return graph.compile();
}