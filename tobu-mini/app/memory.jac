import from uuid { uuid4 }
import from fastapi { HTTPException, status }
import from jac_cloud.jaseci.utils.logger { logger }


node memories {}

node memory {
    has memory_id: str = uuid4().hex;
    has session_id: str = "";
    has summary: str = "";
    has when: str = "";
    has who: list = [];
    has where: list = [];
    has what: str = "";
    has created_at: str = "";
    has updated_at: str = "";
    has image_url: str = "";
    has conversation: list = [];
}

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