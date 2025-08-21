import from fastapi { HTTPException, status }
import from nodes_and_edges { profile }

walker visit_profile {

    class __specs__ {
        has tags: list = ["profile"];
    }
    
    can visit_profile with `root entry;
}

walker update_profile(visit_profile) {
    has first_name: str = "";
    has last_name: str = "";
    has profile_picture_url: str = "";

    class __specs__ {
        has tags: list = ["profile"];
    }
    
    can update_profile with profile entry;
}