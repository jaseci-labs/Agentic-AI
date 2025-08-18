impl visit_memories.visit_memories with `root entry {
    visit [-->](`?memories) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memories not found, please initialize the user first."
        );
    }
}

impl visit_memory.visit_memory with memories entry {
    visit [-->](?memory_id==self.memory_id) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memory not found."
        );
    }
}

impl get_memory.check_memories with memories entry {
    logger.debug(f"friends | get_memory | Retrieving memory {self.memory_id}");
    memory_node = [here-->](?memory_id==self.memory_id);
    if not memory_node {
        logger.warning(f"friends | get_memory | Memory with id {self.memory_id} not found");
        logger.debug(f"friends | get_memory | Checking shared memories");
        walker_obj = root spawn visit_profile();
        visit walker_obj.profile_node;
    }
    visit memory_node;
}

impl get_memory.check_shared_memories with profile entry {
    logger.debug(f"friends | get_memory | Checking shared memories for {self.memory_id}");
    shared_memories = [here<-:shared_memory:<-];
    if not shared_memories {
        logger.error(f"friends | get_memory | No shared memories found for {self.memory_id}");
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memory not found."
        );
    }
    for memory_node in shared_memories {
        if memory_node.memory_id == self.memory_id {
            logger.debug(f"friends | get_memory | Memory {self.memory_id} found in shared memories");
            visit memory_node;
            break;
        }
    } else {
        logger.error(f"friends | get_memory | Memory {self.memory_id} not found in shared memories");
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memory not found."
        );
    }
}

impl get_memory.get_memory with memory entry {
    comments = [here-->](`?comment);
    comment_details = [];
    comment_map = {};
    for comment_node in comments {
        comment_owner = get_node_owner(node=comment_node);
        root_id = comment_owner.get("root_id");
        profile_node = get_node_by_root_id(root_id=root_id, node_type="profile");
        profile_details = {
            "email": profile_node.email,
            "first_name": profile_node.first_name,
            "last_name": profile_node.last_name,
            "profile_picture_url": profile_node.profile_picture_url
        };
        comment_details.append({
            "comment_id": comment_node.comment_id,
            "content": comment_node.content,
            "created_at": comment_node.created_at,
            "profile": profile_details
        });
        if comment_map.get(profile_node.email) {
            comment_map[profile_node.email]["comments"].append(comment_node.content);
        } else {
            comment_map[profile_node.email] = {
                "comments": [comment_node.content],
                "profile": profile_details
            };
        }
    }
    filtered_comments = {email: {"comments": data["comments"], "name": data["profile"]["first_name"]} for (email, data) in comment_map.items() if data["comments"]};
    comment_summary_and_povs = generate_comment_summary_and_povs(memory_summary=here.summary, comments=filtered_comments);
    povs = [];
    for pov in comment_summary_and_povs.povs {
        if pov.email in comment_map {
            povs.append({
                "pov": pov.pov,
                "profile": comment_map[pov.email]["profile"]
            });
        } else {
            logger.warning(f"friends | get_memory | POV for email {pov.email} not found");  
        }
    }
    response = {
        "memory": {
            "memory_id": here.memory_id,
            "session_id": here.session_id,
            "summary": here.summary,
            "when": here.when,
            "who": here.who,
            "where": here.where,
            "what": here.what,
            "created_at": here.created_at,
            "image_url": here.image_url,
            "conversation": here.conversation
        },
        "comments": comment_details,
        "comment_summary": comment_summary_and_povs.comment_summary,
        "povs": povs
    };
    report response;
}

impl list_memories.list_memories with memories entry {
    memories_list = [here-->](`?memory);
    if not memories_list {
        logger.warning(f"friends | list_memories | No memories found");
    }
    sorted_memories = sorted(
        memories_list,
        key=lambda x: memory : x.created_at,
        reverse=True
    );
    for memory_node in sorted_memories {
        here spawn get_memory(memory_id=memory_node.memory_id);
    }
}