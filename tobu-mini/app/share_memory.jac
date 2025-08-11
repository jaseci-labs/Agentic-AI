import from memory { memory, visit_memory }
import from pydantic { EmailStr }
import from jac_cloud.jaseci.utils.logger { logger }
import from friends { get_friends }
import from jaseci_sdk { get_user_by_email, get_node_by_root_id, grant_permission }


edge shared_memory {}

walker share_memory(visit_memory) {
    has share_with: list[EmailStr] = [];

    class __specs__ {
        has tags: list = ["share_memory"];
    }

    can share_memory with memory entry ;
}