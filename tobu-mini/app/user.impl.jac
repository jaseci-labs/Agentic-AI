impl init_user.initialize_user with `root entry {
    logger.debug("user | init_user | Initializing user");
    visit [-->](`?sessions) else {
        logger.debug("user | init_user | creating sessions node");
        here ++> sessions();
    }

    visit [-->](`?profile) else {
        logger.debug("user | init_user | creating profile node");
        profile_node = here ++> profile();
        visit profile_node[0];
    }

    visit [-->](`?memories) else {
        logger.debug("user | init_user | creating memories node");
        here ++> memories();
    }
}

impl init_user.update_email with profile entry {
    if not here.email {
        logger.debug("user | init_user | No email found in profile, fetching current user");
        user_data = get_current_user();
        here.email = user_data.get("email");
    }
}