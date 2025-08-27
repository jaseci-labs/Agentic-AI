from langgraph.graph import StateGraph, END
from state import AgentState
from agents.trend_agent import TrendAgent
from agents.writer_agent import WriterAgent
from agents.media_agent import MediaAgent
from agents.editor_agent import EditorAgent

class WorkflowGraph:
    def __init__(self):
        self.trend_agent = TrendAgent()
        self.writer_agent = WriterAgent()
        self.media_agent = MediaAgent()
        self.editor_agent = EditorAgent()
        
        self.app = self._build_graph()

    def _decide_to_rewrite(self, state: AgentState):
        """
        If review notes exist and the review count is less than 3, loop back to the writer.
        Otherwise, proceed to the media agent.
        """
        review_notes = state.get("review_notes")
        review_count = state.get("review_count", 0)

        if not review_notes:
            print("Decision: Article approved.")
            return "media_agent"

        if review_count >= 3:
            print("Decision: Max review limit (3) reached.")
            return "media_agent"
        else:
            print(f"Decision: Revisions required (Review #{review_count}). Looping back to Writer.")
            return "writer_agent"

    def _build_graph(self):
        workflow = StateGraph(AgentState)

        workflow.add_node("trend_agent", self.trend_agent.run)
        workflow.add_node("writer_agent", self.writer_agent.run)
        workflow.add_node("media_agent", self.media_agent.run)
        workflow.add_node("editor_agent", self.editor_agent.run)

        workflow.set_entry_point("trend_agent")
        workflow.add_edge("trend_agent", "writer_agent")
        workflow.add_edge("writer_agent", "editor_agent")
        
        workflow.add_conditional_edges(
            "editor_agent",
            self._decide_to_rewrite,
            {
                "writer_agent": "writer_agent",
                "media_agent": "media_agent"
            }
        )
        
        workflow.add_edge("media_agent", END)

        return workflow.compile()