from typing import List, TypedDict, Dict, Optional

class AgentState(TypedDict):
    """
    The shared state for the graph.
    """
    user_input: Dict
    trending_topics: List[str]
    selected_topic: str
    research_data: str
    article: str
    media_url: Optional[str]
    review_notes: Optional[str]
    review_count: int