impl visit_memories.visit_memories with `root entry {
    visit [-->](`?memories) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memories not found, please initialize the user first."
        );
    }
}

impl save_memory.create_memory with memories entry {
    logger.debug("memory | save_memory | creating new memory");
    memory_node = here ++> memory();
    visit memory_node[0];
}

impl save_memory.update_memory with memory entry {
    logger.debug("memory | save_memory | updating memory");
    walker_obj = root spawn get_session(
        session_id=self.session_id,
        if_report=False
    );
    response = walker_obj.response;
    if not response {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found, please initialize the session first."
        );
    }
    here.session_id = response["session_id"];
    here.summary = response["summary"];
    here.when = response["when"];
    here.who = response["who"];
    here.where = response["where"];
    here.what = response["what"];
    here.image_url = response["image_url"];
    here.conversation = response["conversation"];
    here.updated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
    here.created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
    here.save_memory = response["save_memory"];
    here.show_summary = response["show_summary"];

    response = {
        "memory_id": here.memory_id,
        "session_id": here.session_id,
        "summary": here.summary,
        "when": here.when,  
        "who": here.who,
        "where": here.where,
        "what": here.what,
        "image_url": here.image_url,
        "conversation": here.conversation,
        "created_at": here.created_at,
        "updated_at": here.updated_at,
        "save_memory": here.save_memory,
        "show_summary": here.show_summary
    };
    report response;
}
