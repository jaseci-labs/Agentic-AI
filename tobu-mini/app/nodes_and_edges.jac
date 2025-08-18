import from uuid { uuid4 }
import from datetime { datetime }

### Enums ###
enum FriendRequestStatus {
    PENDING = "pending",
    ACCEPTED = "accepted",
    REJECTED = "rejected"
}

### Nodes ###
node sessions {}

node session {
    has session_id: str = uuid4().hex;
    has summary: str = "";
    has when: str = "";
    has who: list = [];
    has where: list = [];
    has what: str = "";
    has conversation : list = [];
    has image_url: str = "";
    has save_memory: bool = False;
    has show_summary: bool = False;
}

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

node profile {
    has email: str = "";
    has first_name: str = "";
    has last_name: str = "";
    has profile_picture_url: str = "";
}

node comment{
    has comment_id: str = uuid4().hex;
    has content: str = "";
    has created_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}


### Edges ###
edge shared_memory {
    has shared_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}

edge friend_request {
    has status: FriendRequestStatus = FriendRequestStatus.PENDING;
    has created_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}