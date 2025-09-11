impl send_friend_request.send_friend_request with profile entry {
    reciver = get_user_by_email(email=self.email);
    current_user = get_current_user();
    if not reciver {
        logger.error(f"friends | send_friend_request | User with email {self.email} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found");
    }

    if current_user["email"]==reciver["email"] {
        logger.error(f"friends | send_friend_request | Cannot send friend request to self: {current_user['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot send friend request to self");
    }
    
    logger.debug(f"friends | send_friend_request | checking existing friend request");
    reciver_profile = get_node_by_root_id(root_id=reciver["root_id"], node_type="profile");
    
    if not reciver_profile {
        logger.error(f"friends | send_friend_request | Profile for user {reciver['email']} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found");
    }

    send_request = [edge here->:friend_request:->reciver_profile];
    if send_request {
        logger.error(f"friends | send_friend_request | Friend request already sent to {reciver['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request already sent");
    }

    received_request = [edge reciver_profile->:friend_request:->here];
    if received_request {
        logger.debug(f"friends | send_friend_request | Friend request already received from {reciver['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request already received");
    }

    logger.debug(f"friends | send_friend_request | Sending friend request to {reciver['email']}");
    here +>:friend_request:+> reciver_profile;
    try {
        received_request_edge = [edge here->:friend_request:->reciver_profile][0];
        if received_request_edge {
            logger.debug(f"friends | send_friend_request | Friend request sent successfully to {reciver['email']}");
            grant_permission(node=received_request_edge, permission_level="WRITE", root_id=reciver["root_id"]);
            report {
                "status": FriendRequestStatus.PENDING.value,
                "message": f"Friend request sent to {reciver['email']}",
                "user_email": reciver["email"]
            };
        }
    } except Exception as e {
        logger.error(f"friends | send_friend_request | Error sending friend request: {e}");
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error sending friend request");
    }
}

impl accept_friend_request.accept_friend_request with profile entry {
    sender = get_user_by_email(email=self.email);
    current_user = get_current_user();
    if not sender {
        logger.error(f"friends | accept_friend_request | User with email {self.email} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found");
    }

    if current_user["email"]==sender["email"] {
        logger.error(f"friends | accept_friend_request | Cannot accept friend request from self: {current_user['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot accept friend request from self");
    }

    logger.debug(f"friends | accept_friend_request | checking existing friend request");
    sender_profile = get_node_by_root_id(root_id=sender["root_id"], node_type="profile");
    if not sender_profile {
        logger.error(f"friends | accept_friend_request | Profile for user {sender['email']} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found");
    }

    received_request = [edge sender_profile->:friend_request:->here];
    if not received_request {
        logger.error(f"friends | accept_friend_request | No friend request received from {sender['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No friend request received");
    }
    received_request_edge = received_request[0];
    if received_request_edge.status.value == FriendRequestStatus.PENDING.value {
        logger.debug(f"friends | accept_friend_request | Accepting friend request from {sender['email']}");   
        sender_profile del--> here;
        here <+:friend_request(status=FriendRequestStatus.ACCEPTED):+> sender_profile;
        request_edge = [edge here->:friend_request:->sender_profile][0];
        grant_permission(node=request_edge, permission_level="WRITE", root_id=sender["root_id"]);
        report {
            "status": "success",
            "message": f"Friend request from {sender['email']} accepted",
            "status": FriendRequestStatus.ACCEPTED.value,
            "user_email": sender["email"]
        };
    } else {
        logger.error(f"friends | accept_friend_request | Friend request from {sender['email']} is not pending");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request is not pending");
    }   
}

impl reject_friend_request.reject_friend_request with profile entry {
    sender = get_user_by_email(email=self.email);
    current_user = get_current_user();
    if not sender {
        logger.error(f"friends | reject_friend_request | User with email {self.email} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found");
    }

    if current_user["email"]==sender["email"] {
        logger.error(f"friends | reject_friend_request | Cannot reject friend request from self: {current_user['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot reject friend request from self");
    }

    logger.debug(f"friends | reject_friend_request | checking existing friend request");
    sender_profile = get_node_by_root_id(root_id=sender["root_id"], node_type="profile");
    if not sender_profile {
        logger.error(f"friends | reject_friend_request | Profile for user {sender['email']} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found");
    }

    received_request = [edge sender_profile->:friend_request:->here];
    if not received_request {
        logger.error(f"friends | reject_friend_request | No friend request received from {sender['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No friend request received");
    }
    
    received_request_edge = received_request[0];
    if received_request_edge.status.value == FriendRequestStatus.PENDING.value {
        logger.debug(f"friends | reject_friend_request | Rejecting friend request from {sender['email']}");
        sender_profile del--> here;
        here <+:friend_request(status=FriendRequestStatus.REJECTED):+> sender_profile;
        report {
            "status": "success",
            "message": f"Friend request from {sender['email']} rejected",
            "status": FriendRequestStatus.REJECTED.value,
            "user_email": sender["email"]
        };
    } else {
        logger.error(f"friends | reject_friend_request | Friend request from {sender['email']} is not pending");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request is not pending");
    }
}

impl unfriend.unfriend with profile entry {
    friend = get_user_by_email(email=self.email);
    current_user = get_current_user();
    if not friend {
        logger.error(f"friends | unfriend | User with email {self.email} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found");
    }

    if current_user["email"]==friend["email"] {
        logger.error(f"friends | unfriend | Cannot unfriend self: {current_user['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot unfriend self");
    }

    logger.debug(f"friends | unfriend | checking existing friendship");
    friend_profile = get_node_by_root_id(root_id=friend["root_id"], node_type="profile");
    if not friend_profile {
        logger.error(f"friends | unfriend | Profile for user {friend['email']} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found");
    }

    friendship_edge = [edge here->:friend_request:->friend_profile];
    if not friendship_edge {
        logger.error(f"friends | unfriend | No friendship found with {friend['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No friendship found");
    }

    here del--> friend_profile;
    report {
        "status": "success",
        "message": f"You have unfriended {friend['email']}",
        "user_email": friend["email"]
    };
}

impl get_received_friend_requests.get_received_friend_requests with profile entry {
    profile_nodes = [here<-:friend_request:<-](`?profile);
    for profile_node in profile_nodes {
        received_request_edge = [edge profile_node->:friend_request:->here][0];
        if received_request_edge.status.value == FriendRequestStatus.PENDING.value {
            logger.debug(f"friends | get_received_friend_requests | Found received friend request from profile: {profile_node.email}");
            report {
                "email": profile_node.email,
                "first_name": profile_node.first_name,
                "last_name": profile_node.last_name,
                "profile_picture_url": profile_node.profile_picture_url,
                "status": received_request_edge.status.value,
                "created_at": received_request_edge.created_at
            };
        }
    }
}

impl get_sent_friend_requests.get_sent_friend_requests with profile entry {
    profile_nodes = [here->:friend_request:->](`?profile);
    for profile_node in profile_nodes {
        sent_request_edge = [edge here->:friend_request:->profile_node][0];
        if sent_request_edge.status.value == FriendRequestStatus.PENDING.value {
            logger.debug(f"friends | get_sent_friend_requests | Found sent friend request to profile: {profile_node.email}");
            report {
                "email": profile_node.email,
                "first_name": profile_node.first_name,
                "last_name": profile_node.last_name,
                "profile_picture_url": profile_node.profile_picture_url,
                "status": sent_request_edge.status.value,
                "created_at": sent_request_edge.created_at
            };
        }
    }
}

impl get_friends.get_friends with profile entry {
    friends = [here<-:friend_request:->](`?profile);
    for friend in friends {
        friend_edge = [edge here<-:friend_request:->friend][0];
        if friend_edge.status.value == FriendRequestStatus.ACCEPTED.value {
            logger.debug(f"friends | get_friends | Found friend: {friend.email}");
            response = {
                "email": friend.email,
                "first_name": friend.first_name,
                "last_name": friend.last_name,
                "profile_picture_url": friend.profile_picture_url,
                "status": friend_edge.status.value,
                "created_at": friend_edge.created_at
            };
            self.friends.append(response);
            if self.if_report {
                report response;
            }
        }
    }
}

impl list_users.get_all_users with `root entry {
    current_user = _.get_context().connection._user;
    nodes = get_nodes(node_type_str="profile");
    users = [];
    for profile in nodes {
        if not profile.email {
            continue;
        }
        users.append(
            {
                "email" : profile.email , 
                "firstName" : profile.first_name , 
                "lastName" : profile.last_name , 
                "profile_picture_url" : profile.profile_picture_url 
            }
        );
    }
    ::py::
    sorted_users = sorted(users, key=lambda x: x["email"], reverse=False)
    ::py::
    start_index = (self.page - 1) * self.page_size;
    end_index = start_index + self.page_size;
    paginated_users = sorted_users[start_index:end_index];
    total_pages = (len(sorted_users) + self.page_size - 1) // self.page_size;
    payload = {
        "users": paginated_users,
        "total_users": len(sorted_users),
        "total_pages": total_pages,
        "current_page": self.page,
        "page_size": self.page_size,
    };
    report payload;
}