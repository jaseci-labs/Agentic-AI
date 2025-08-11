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