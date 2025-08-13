import from uuid { uuid4 }
import from fastapi { HTTPException, status }
import from datetime { datetime }
import from jac_cloud.jaseci.utils.logger { logger }
import from profile { visit_profile, profile }
import from memory { memory }
import from share_memory { shared_memory }
import from jaseci_sdk { grant_permission, get_node_owner, get_current_user, grant_permission_to_all }


node comment{
    has comment_id: str = uuid4().hex;
    has content: str = "";
    has created_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}

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