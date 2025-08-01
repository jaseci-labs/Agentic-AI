impl visit_profile.visit_profile with `root entry {
    visit [-->](`?profile) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found, please initialize the user first."
        );
    }
}

impl update_profile.update_profile with profile entry {
    if not (self.first_name or self.last_name or self.profile_picture_url) {
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one of first_name, last_name, or profile_picture_url must be provided."
        );
    }
    if self.first_name {
        here.first_name = self.first_name;
    }
    if self.last_name {
        here.last_name = self.last_name;
    }
    if self.profile_picture_url {
        here.profile_picture_url = self.profile_picture_url;
    }
    response = {
        "message": "Profile updated successfully",
        "profile": {
            "email": here.email,
            "first_name": here.first_name,
            "last_name": here.last_name,
            "profile_picture_url": here.profile_picture_url
        }
    };
    report response;
}