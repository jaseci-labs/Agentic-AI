walker get_attached_nodes {
    has node_id: str = "";
    can get_attach_nodes with `root entry {
        if(self.node_id == "") {
            report jid(here);
        } else {
            selected_node = &self.node_id;
            attached_nodes = [selected_node-->];
            report attached_nodes;
        }        
    }
}