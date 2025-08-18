import from fastapi { HTTPException, status }
import from jac_cloud.jaseci.utils.logger { logger }
import from nodes_and_edges { memories, memory, comment, profile, shared_memory }
import from jaseci_sdk { get_node_owner, get_node_by_root_id }
import from profile { visit_profile }


walker visit_memories {

    class __specs__ {
        has tags: list = ["memory"];
    }
    
    can visit_memories with `root entry;
}

walker visit_memory(visit_memories) {
    has memory_id: str;

    class __specs__ {
        has tags: list = ["memory"];
    }

    can visit_memory with memories entry;
}

walker get_memory(visit_memories) {
    has memory_id: str;

    class __specs__ {
        has tags: list = ["memory"];
    }

    can check_memories with memories entry;
    can check_shared_memories with profile entry;
    can get_memory with memory entry;
}

walker list_memories(visit_memories) {
    class __specs__ {
        has tags: list = ["memory"];
    }

    can list_memories with memories entry;
}