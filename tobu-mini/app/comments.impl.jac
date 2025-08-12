impl add_comment.go_to_memory with profile entry {
    visit [here<-:shared_memory:<-](?memory_id==self.memory_id) else {
        logger.error(f"friends | add_comment | Memory with id {self.memory_id} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found");
    }
}

impl add_comment.add_comment with memory entry {
    logger.debug(f"friends | add_comment | Adding comment to memory {self.memory_id}");
    comment_node = here ++> comment();
    memory_owner = get_node_owner(node=here);
    commenter = get_current_user();
    if not memory_owner {
        logger.error(f"friends | add_comment | Memory owner not found for memory {self.memory_id}");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory owner not found");
    }
    
    if commenter.get("root_id") != memory_owner.get("root_id") {
        comment_edge = [edge here-->comment_node[0]];
        grant_permission(node=comment_edge[0], permission_level="WRITE", root_id=commenter.get("root_id"));
    } else {
        logger.debug(f"friends | add_comment | User commenting on their own memory {self.memory_id}");
    }
    visit comment_node[0];
}

impl add_comment.report_comment with comment entry {
    logger.debug(f"friends | add_comment | Reporting comment {here.comment_id}");
    here.content = self.content;
    response = {
        "comment_id": here.comment_id,
        "content": here.content,
        "created_at": here.created_at
    };
    report response;
}