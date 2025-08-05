import from jac_cloud.jaseci.utils.logger { logger }
import from profile { profile }
import from profile { visit_profile } 
import from pydantic { EmailStr }
import from jaseci_sdk { get_user_by_email, get_node_by_root_id, grant_permission, get_current_user }
import from fastapi { HTTPException, status }
import from datetime { datetime }


enum FriendRequestStatus {
    PENDING = "pending",
    ACCEPTED = "accepted",
    REJECTED = "rejected"
}

edge friend_request {
    has status: FriendRequestStatus = FriendRequestStatus.PENDING;
    has created_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}

walker send_friend_request(visit_profile) {
    has email: EmailStr;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can send_friend_request with profile entry;
}
