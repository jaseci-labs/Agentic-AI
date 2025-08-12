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
        grant_permission_to_all(permission_level="READ", node=comment_edge[0]);
    } else {
        logger.debug(f"friends | add_comment | User commenting on their own memory {self.memory_id}");
    }
    visit comment_node[0];
}

impl add_comment.report_comment with comment entry {
    logger.debug(f"friends | add_comment | Reporting comment {here.comment_id}");
    grant_permission_to_all(permission_level="READ", node=here);
    here.content = self.content;
    response = {
        "comment_id": here.comment_id,
        "content": here.content,
        "created_at": here.created_at
    };
    report response;
}

impl get_my_comment.get_memories with profile entry {
    visit [here<-:shared_memory:<-] else {
        logger.error(f"friends | get_comment | Memory with id {self.comment_id} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found");
    }
}

impl get_my_comment.get_comments with memory entry {
    logger.debug(f"friends | get_comment | Retrieving comments for memory {here.memory_id}");
    comment_nodes = [here-->](`?comment);
    comment_node = comment_nodes(?comment_id==self.comment_id);
    if comment_node {
        self.memory_node = here;
        visit comment_node;
    } else {
        logger.debug(f"friends | get_comment | commnet not found in memory {here.memory_id}");
    }
}

impl get_my_comment.report_comment with comment entry {
    self.comment_node = here;
    response = {
        "comment_id": here.comment_id,
        "content": here.content,
        "created_at": here.created_at
    };
    if self.if_report {
        report response;
    }
}

impl delete_my_comment.delete_comment with profile entry {
    walker_obj = here spawn get_my_comment(
        comment_id=self.comment_id,
        if_report=False
    );
    logger.debug(f"friends | delete_comment | Deleting comment {self.comment_id}");
    walker_obj.memory_node del--> walker_obj.comment_node;
    comment_nodes = [walker_obj.memory_node-->](`?comment);
    comment_node = comment_nodes(?comment_id==self.comment_id);
    if comment_node {
        logger.error(f"friends | delete_comment | Comment deleting failed {self.comment_id}");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found");
    } else {
        logger.debug(f"friends | delete_comment | Comment deleted successfully {self.comment_id}");
        response = {
            "status": "success",
            "comment_id": self.comment_id
        };
        report response;
    }
}
