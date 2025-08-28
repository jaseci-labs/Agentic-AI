import from langgraph.graph { START, StateGraph, END }
import from state { AgentState }
import from trend_agent { TrendAgent }


class WorkflowGraph {
    def init(self: WorkflowGraph) {
        print("Initializing WorkflowGraph");
        self.trend_agent = TrendAgent();
        self.app = self._build_graph();
    }

    def _build_graph(self: WorkflowGraph) {
        workflow = StateGraph(AgentState);
        workflow.add_node('trend_agent', self.trend_agent.run);
        workflow.add_edge(START,'trend_agent');
        workflow.add_edge('trend_agent', END);
        return workflow.compile();
    }
}

