import from memory { memory, visit_memory }
import from pydantic { EmailStr }
import from jac_cloud.jaseci.utils.logger { logger }
import from friends { get_friends }
import from jaseci_sdk { get_user_by_email, get_node_by_root_id, grant_permission, revoke_permission }
import from profile { visit_profile, profile }
import from datetime { datetime }


edge shared_memory {
    has shared_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}

walker share_memory(visit_memory) {
    has share_with: list[EmailStr];

    class __specs__ {
        has tags: list = ["share_memory"];
    }

    can share_memory with memory entry;
}

walker unshare_memory(visit_memory) {
    has unshare_with: list[EmailStr];

    class __specs__ {
        has tags: list = ["share_memory"];
    }

    can unshare_memory with memory entry;
}

walker get_shared_memories(visit_profile) {
    has if_report: bool = True;

    class __specs__ {
        has tags: list = ["share_memory"];
    }

    can get_shared_memories with profile entry;
}

walker reject_memory(visit_profile) {
    has memory_ids: list[str];

    class __specs__ {
        has tags: list = ["share_memory"];
    }

    can reject_memory with profile entry;
}

