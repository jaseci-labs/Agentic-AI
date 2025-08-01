impl visit_sessions.visit_sessions with `root entry {
    visit [-->](`?sessions) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sessions not found, please initialize the user first."
        );
    }
}

impl init_session.initialize_session with sessions entry {
    logger.debug("session | init_session | creating new session");
    session_node = here ++> session();
    visit session_node[0];
}

impl init_session.update_session with session entry {
    logger.debug("session | init_session | updating session");
    file_path = download_and_save_image(self.image_url);
    if self.location.latitude and self.location.longitude and file_path {
        logger.debug("session | init_session | fetching city for provided coordinates");
        city = google_location_service.get_city(
            latitude=self.location.latitude,
            longitude=self.location.longitude
        );
        if city {
            logger.debug(f"session | init_session | City found: {city}");
            here.where.append(city);
        } else {
            logger.warning("session | init_session | City not found for the provided coordinates.");
        }
    }
    if file_path {
        here.file_path = file_path;
        mtp_response = extract_memory_details(
            image=Image(file_path),
            city=city,
            date=convert_date_to_valid_format(self.date)
        );
        logger.debug(f"session | init_session | extracted memory details: {mtp_response}");
        here.summary = mtp_response.summary;
        here.when = convert_date_to_valid_format(mtp_response.when);
        here.who = mtp_response.who;
        here.what = mtp_response.what;
        here.save_memory = mtp_response.save_memory;
        here.show_summary = mtp_response.show_summary;
        here.conversation.append(
            {
                "assistant": mtp_response.follow_up_questions
            }
        );
        if mtp_response.location_description {
            logger.debug(f"session | init_session | Fetching places for location description: {mtp_response.location_description}");
            places = google_location_service.get_detailed_location(
                latitude=self.location.latitude,
                longitude=self.location.longitude,
                radius=100,
                search_query=mtp_response.location_description,
                top_n=3
            );
            if places {
                logger.debug(f"session | init_session | Places found: {places}");
                here.where = list(set(here.where).union(places));
            } else {
                logger.warning("session | init_session | No places found for the provided location description.");
            }
        }
        response = {
            "session_id": here.session_id,
            "follow_up_questions": mtp_response.follow_up_questions,
            "summary": here.summary,
            "when": here.when,
            "who": here.who,
            "where": here.where,
            "what": here.what,
            "conversation": here.conversation,
            "save_memory": here.save_memory,
            "show_summary": here.show_summary
        };
        report response;
    } else {
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to download or save the image."
        );
    }
}

impl continue_session.visit_session with sessions entry {
    logger.debug("session | continue_session | visiting session");
    visit [-->](?session_id==self.session_id) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session with ID {self.session_id} not found."
        );
    }
}

impl continue_session.update_session with session entry {
    logger.debug("session | continue_session | updating session");
    if here.file_path {
        mtp_response = update_memory_details(
            image=Image(here.file_path),
            utterance=self.utterance,
            summary=here.summary,
            when=here.when,
            who=here.who,
            where=here.where,
            what=here.what,
            conversation=here.conversation,
            show_summary=here.show_summary
        );
        logger.debug(f"session | continue_session | updated memory details: {mtp_response}");
        here.summary = mtp_response.summary;
        here.when = mtp_response.when;
        here.who = mtp_response.who;
        here.where = mtp_response.where;
        here.what = mtp_response.what;
        here.save_memory = mtp_response.save_memory;
        here.show_summary = mtp_response.show_summary;
        here.conversation.append(
            {
                "user": self.utterance,
                "assistant": mtp_response.follow_up_questions
            }
        );
        response = {
            "session_id": here.session_id,
            "follow_up_questions": mtp_response.follow_up_questions,
            "summary": here.summary,
            "when": here.when,
            "who": here.who,
            "where": here.where,
            "what": here.what,
            "conversation": here.conversation,
            "save_memory": here.save_memory,
            "show_summary": here.show_summary
        };
        report response;
    }
}

impl get_session.visit_session with sessions entry {
    logger.debug("session | get_session | visiting session");
    visit [-->](?session_id==self.session_id) else {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session with ID {self.session_id} not found."
        );
    }
}

impl get_session.report_session with session entry {
    logger.debug("session | get_session | reporting session");
    self.response = {
        "session_id": here.session_id,
        "summary": here.summary,
        "when": here.when,
        "who": here.who,
        "where": here.where,
        "what": here.what,
        "conversation": here.conversation,
        "image_url": here.image_url,
        "file_path": here.file_path,
        "save_memory": here.save_memory,
        "show_summary": here.show_summary
    };
    if self.if_report {
        report self.response;
    }
}