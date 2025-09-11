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
                    grant_permission(node=here, permission_level="CONNECT", root_id=reciver["root_id"]);
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

impl unshare_memory.unshare_memory with memory entry {
    response = {
        "success": [],
        "failed": []
    };
    walker_obj = root spawn get_friends(if_report=False);
    friends_lookup = {friend["email"]: friend for friend in walker_obj.friends};
    for email in self.unshare_with {
        if email in friends_lookup {
            reciver = get_user_by_email(email=email);
            if not reciver {
                logger.error(f"friends | unshare_memory | User with email {self.email} not found");
                response["failed"].append(email);
                continue;
            }

            reciver_profile = get_node_by_root_id(root_id=reciver["root_id"], node_type="profile");

            if not reciver_profile {
                logger.error(f"friends | unshare_memory | Profile not found for user {reciver.email}");
                response["failed"].append(email);
                continue;
            }

            shared_memory_edge = [edge here->:shared_memory:->reciver_profile];
            if not shared_memory_edge {
                logger.debug(f"friends | unshare_memory | Memory {here.memory_id} not shared with {email}");
                response["success"].append(email);
                continue;
            }
    
            logger.debug(f"friends | unshare_memory | Unsharing memory {here.memory_id} from {email}");
            here del--> reciver_profile;
            try {
                if [edge here->:shared_memory:->reciver_profile] {
                    logger.error(f"friends | unshare_memory | Memory unsharing failed for {email}");
                    response["failed"].append(email);
                } else {
                    logger.debug(f"friends | unshare_memory | Memory unshared successfully from {email}");
                    revoke_permission(node=here, root_id=reciver["root_id"]);
                    response["success"].append(email);
                }
            } except Exception as e {
                logger.error(f"friends | unshare_memory | Error unsharing memory: {e}");
                response["failed"].append(email);
            }
        } else {
            response["failed"].append(email);
        }
    }
    report response;
}

impl get_shared_memories.get_shared_memories with profile entry {
    self.shared_memories = [here<-:shared_memory:<-];
    logger.debug(f"friends | get_shared_memories | Retrieved {len(self.shared_memories)} shared memories");
    response = [];
    for memory in self.shared_memories {
        memory_owner = get_node_owner(memory);
        if not memory_owner {
            logger.error(f"friends | get_shared_memories | Memory owner not found for {memory.memory_id}");
            continue;
        }

        memory_owner_profile = get_node_by_root_id(root_id=memory_owner["root_id"], node_type="profile");
        if not memory_owner_profile {
            logger.error(f"friends | get_shared_memories | Memory owner profile not found for {memory_owner.email}");
            continue;
        }

        response_item = {
            "memory" : {
                "memory_id": memory.memory_id,
                "session_id": memory.session_id,
                "summary": memory.summary,
                "when": memory.when,
                "who": memory.who,
                "where": memory.where,
                "what": memory.what,
                "created_at": memory.created_at,
                "updated_at": memory.updated_at,
                "image_url": memory.image_url,
                "conversation": memory.conversation
            },
            "shared_by": {
                "email": memory_owner["email"],
                "root_id": memory_owner["root_id"],
                "first_name": memory_owner_profile.first_name,
                "last_name": memory_owner_profile.last_name,
                "profile_picture_url": memory_owner_profile.profile_picture_url
            }
        };
        response.append(response_item);
    }
    if self.if_report {
        report response;
    }
}

impl reject_memory.reject_memory with profile entry {
    response = {
        "success": [],
        "failed": []
    };
    walker_obj = root spawn get_shared_memories(if_report=False);
    shared_memories_lookup = {memory.memory_id: memory for memory in walker_obj.shared_memories};
    for memory_id in self.memory_ids {
        if memory_id in shared_memories_lookup {
            memory = shared_memories_lookup[memory_id];
            logger.debug(f"friends | reject_memory | Rejecting memory {memory_id}");
            memory del--> here;
            try {
                if [edge memory->:shared_memory:->here] {
                    logger.error(f"friends | reject_memory | Memory rejection failed for {memory_id}");
                    response["failed"].append(memory_id);
                } else {
                    logger.debug(f"friends | reject_memory | Memory rejected successfully for {memory_id}");
                    response["success"].append(memory_id);
                }
            } except Exception as e {
                logger.error(f"friends | reject_memory | Error rejecting memory: {e}");
                response["failed"].append(memory_id);
            }
        } else {
            response["failed"].append(memory_id);
        }
    }
    report response;
}