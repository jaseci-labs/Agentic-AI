import from typing { List, TypedDict, Dict, Optional }
import from langchain_core.vectorstores {VectorStoreRetriever}

class AgentState(TypedDict) {
    with entry {
        user_input: Dict;
        trending_topics: List[ str ];
        selected_topic: str;
        research_data: str;

        pdf_path: str;  # Path to the input PDF
        retriever: VectorStoreRetriever;
        plan: str;  # The detailed plan created by the Planner Agent
        article: str;
        media_url: Optional[ str ];
        review_notes: Optional[ str ];
        review_count: int;
    }
}

