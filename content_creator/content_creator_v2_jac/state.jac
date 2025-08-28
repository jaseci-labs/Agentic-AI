import from typing { List, TypedDict, Dict, Optional }

class AgentState(TypedDict) {
    with entry {
        user_input: Dict;
        trending_topics: List[ str ];
        selected_topic: str;
        research_data: str;
        article: str;
        media_url: Optional[ str ];
        review_notes: Optional[ str ];
        review_count: int;
    }
}

