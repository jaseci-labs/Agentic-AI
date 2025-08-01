import from jivas.agent.core.graph_node { GraphNode }
# import:py from jivas.agent.modules.agentlib.utils { Utils }

node Task(GraphNode) {
    has task:str = "";
    has date:str = "";
    has time:str = "";
    has status: str = "pending";

    # can get_doc_entry(id:str) -> DocEntry {
    #     # retrieves an attached document entry by id
    #     return Utils.node_obj([-->](`?DocEntry)(?id == id));
    # }

    # can get_doc_entry_by_name(name:str) -> DocEntry {
    #     # retrieves an attached document entry by id
    #     return Utils.node_obj([-->](`?DocEntry)(?name == name));
    # }

}