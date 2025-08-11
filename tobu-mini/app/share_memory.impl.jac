impl share_memory.share_memory with memory entry {
    response = {
        "success": [],
        "failed": []
    };
    walker_obj = root spawn get_friends(if_report=False);
    friends_lookup = {friend["email"]: friend for friend in walker_obj.friends};
    for email in self.share_with {
        if email in friends_lookup {
            reciver = get_user_by_email(email=email);
            if not reciver {
                logger.error(f"friends | share_memory | User with email {self.email} not found");
                response["failed"].append(email);
                continue;
            }

            reciver_profile = get_node_by_root_id(root_id=reciver["root_id"], node_type="profile");

            if not reciver_profile {
                logger.error(f"friends | share_memory | Profile not found for user {reciver.email}");
                response["failed"].append(email);
                continue;
            }

            if [edge here->:shared_memory:->reciver_profile] {
                logger.debug(f"friends | share_memory | Memory {here.memory_id} already shared with {email}");
                response["success"].append(email);
                continue;
            }

            logger.debug(f"friends | share_memory | Sharing memory {here.memory_id} with {email}");
            here +>:shared_memory:+> reciver_profile;
            try {
                shared_memory_edge = [edge here->:shared_memory:->reciver_profile][0];
                if shared_memory_edge {
                    logger.debug(f"friends | share_memory | Memory shared successfully with {email}");
                    grant_permission(node=shared_memory_edge, permission_level="WRITE", root_id=reciver["root_id"]);
                    response["success"].append(email);
                }
            } except Exception as e {
                logger.error(f"friends | share_memory | Error sharing memory: {e}");
                response["failed"].append(email);
            }
        } else {
            response["failed"].append(email);
        }
    }
    report response;
}