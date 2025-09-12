import from jac_cloud.jaseci.utils.logger { logger }
import from profile { visit_profile } 
import from pydantic { EmailStr }
import from jaseci_sdk { get_user_by_email, get_node_by_root_id, grant_permission, get_current_user, get_nodes }
import from fastapi { HTTPException, status }
import from datetime { datetime }
import from nodes_and_edges { profile, friend_request, FriendRequestStatus }


walker send_friend_request(visit_profile) {
    has email: EmailStr;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can send_friend_request with profile entry;
}

walker accept_friend_request(visit_profile) {
    has email: EmailStr;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can accept_friend_request with profile entry;
}

walker reject_friend_request(visit_profile) {
    has email: EmailStr;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can reject_friend_request with profile entry;
}

walker unfriend(visit_profile) {
    has email: EmailStr;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can unfriend with profile entry;
}

walker get_received_friend_requests(visit_profile) {

    class __specs__ {
        has tags: list = ["friends"];
    }

    can get_received_friend_requests with profile entry;
}

walker get_sent_friend_requests(visit_profile) {

    class __specs__ {
        has tags: list = ["friends"];
    }

    can get_sent_friend_requests with profile entry;
}

walker get_friends(visit_profile) {
    has friends: list = [];
    has if_report: bool = True;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can get_friends with profile entry;
}

walker list_users {
    has page: int = 1;
    has page_size: int = 10;

    class __specs__ {
        has tags: list = ["friends"];
    }

    can get_all_users with `root entry;
} 