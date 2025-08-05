impl send_friend_request.send_friend_request with profile entry {
    reciver = get_user_by_email(email=self.email);
    current_user = get_current_user();
    if not reciver {
        logger.error(f"send_friend_request | send_friend_request | User with email {self.email} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found");
    }

    if current_user["email"]==reciver["email"] {
        logger.error(f"send_friend_request | send_friend_request | Cannot send friend request to self: {current_user['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot send friend request to self");
    }
    
    logger.debug(f"send_friend_request | send_friend_request | checking existing friend request");
    reciver_profile = get_node_by_root_id(root_id=reciver["root_id"], node_type="profile");
    
    if not reciver_profile {
        logger.error(f"send_friend_request | send_friend_request | Profile for user {reciver['email']} not found");
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found");
    }

    send_request = [edge here->:friend_request:->reciver_profile];
    if send_request {
        logger.error(f"send_friend_request | send_friend_request | Friend request already sent to {reciver['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request already sent");
    }

    received_request = [edge reciver_profile->:friend_request:->here];
    if received_request {
        logger.debug(f"send_friend_request | send_friend_request | Friend request already received from {reciver['email']}");
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Friend request already received");
    }

    logger.debug(f"send_friend_request | send_friend_request | Sending friend request to {reciver['email']}");
    here +>:friend_request:+> reciver_profile;
    try {
        received_request_edge = [edge here->:friend_request:->reciver_profile][0];
        if received_request_edge {
            logger.debug(f"send_friend_request | send_friend_request | Friend request sent successfully to {reciver['email']}");
            grant_permission(node=received_request_edge, permission_level="WRITE", root_id=reciver["root_id"]);
            report {
                "status": "success",
                "message": f"Friend request sent to {reciver['email']}",
                "status": FriendRequestStatus.PENDING.value,
                "user_email": reciver["email"]
            };
        }
    } except Exception as e {
        logger.error(f"send_friend_request | send_friend_request | Error sending friend request: {e}");
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error sending friend request");
    }
}