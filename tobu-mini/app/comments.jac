
import from fastapi { HTTPException, status }
import from nodes_and_edges { comment, memory, profile, shared_memory }
import from jac_cloud.jaseci.utils.logger { logger }
import from profile { visit_profile }
import from jaseci_sdk { grant_permission, get_node_owner, get_current_user, grant_permission_to_all }


walker add_comment(visit_profile) {
    has memory_id: str;
    has content: str;

    class __specs__ {
        has tags: list = ["comments"];
    }

    can go_to_memory with profile entry;
    can add_comment with memory entry;
    can report_comment with comment entry;
}

walker get_my_comment(visit_profile) {
    has comment_id: str;
    has if_report: bool = True;

    class __specs__ {
        has tags: list = ["comments"];
    }

    can get_memories with profile entry;
    can get_comments with memory entry;
    can report_comment with comment entry; 
}

walker delete_my_comment(visit_profile) {
    has comment_id: str;

    class __specs__ {
        has tags: list = ["comments"];
    }

    can delete_comment with profile entry;
}