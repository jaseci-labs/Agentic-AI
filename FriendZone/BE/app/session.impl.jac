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
    city = None;
    if self.location.latitude and self.location.longitude {
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

    if self.use_byllm {
        ai_response = extract_memory_details(
            image=Image(self.image_url),
            city=city,
            date=convert_date_to_valid_format(self.date)
        );
    } else {
        ai_response = openai_client.extract_memory_details(
            image_url=self.image_url,
            city=city,
            date=convert_date_to_valid_format(self.date)
        );
        if not ai_response {
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to extract memory details from AI service."
            );
        }   
    }

    logger.debug(f"session | init_session | extracted memory details: {ai_response}");
    here.image_url = self.image_url;
    here.summary = ai_response.summary;
    here.when = convert_date_to_valid_format(ai_response.when);
    here.who = ai_response.who;
    here.what = ai_response.what;
    here.conversation.append(
        {
            "assistant": ai_response.follow_up_questions
        }
    );
    if ai_response.location_type {
        logger.debug(f"session | init_session | Fetching places for location description: {ai_response.location_type}");
        places = google_location_service.get_detailed_location(
            latitude=self.location.latitude,
            longitude=self.location.longitude,
            radius=100,
            search_query=ai_response.location_type,
            top_n=3
        );
        if places {
            logger.debug(f"session | init_session | Places found: {places}");
            here.where = list(dict.fromkeys(here.where[:1] + places));
        } else {
            logger.warning("session | init_session | No places found for the provided location description.");
        }
    }
    response = {
        "session_id": here.session_id,
        "follow_up_questions": ai_response.follow_up_questions,
        "summary": here.summary,
        "when": here.when,
        "who": here.who,
        "where": here.where,
        "what": here.what,
        "conversation": here.conversation,
        "image_url": here.image_url,
        "save_memory": here.save_memory,
        "show_summary": here.show_summary
    };
    report response;
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
    if here.image_url {
        if self.use_byllm {
            ai_response = update_memory_details(
                image=Image(here.image_url),
                utterance=self.utterance,
                summary=here.summary,
                when=here.when,
                who=here.who,
                where=here.where,
                what=here.what,
                conversation=here.conversation,
                show_summary=here.show_summary,
                save_memory=here.save_memory
            );
        } else {
            ai_response = openai_client.update_memory_details(
                image_url=here.image_url,
                utterance=self.utterance,
                summary=here.summary,
                when=here.when,
                who=here.who,
                where=here.where,
                what=here.what,
                conversation=here.conversation,
                show_summary=here.show_summary,
                save_memory=here.save_memory
            );
            if not ai_response {
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Failed to update memory details from AI service."
                );
            }   
        }
        logger.debug(f"session | continue_session | updated memory details: {ai_response}");
        here.summary = ai_response.summary;
        here.when = ai_response.when;
        here.who = ai_response.who;
        here.where = ai_response.where;
        here.what = ai_response.what;
        is_saved = here.save_memory;
        here.save_memory = ai_response.save_memory;
        here.show_summary = ai_response.show_summary;
        here.conversation.append(
            {
                "user": self.utterance,
                "assistant": ai_response.follow_up_questions
            }
        );
        response = {
            "session_id": here.session_id,
            "follow_up_questions": ai_response.follow_up_questions,
            "summary": here.summary,
            "when": here.when,
            "who": here.who,
            "where": here.where,
            "what": here.what,
            "conversation": here.conversation,
            "image_url": here.image_url,
            "save_memory": here.save_memory,
            "show_summary": here.show_summary
        };
        report response;
        if not is_saved and ai_response.save_memory {
            logger.debug("session | continue_session | Saving memory as requested.");
            root spawn save_memory(
                session_id=here.session_id
            );
        }
    } else {
        logger.warning("session | continue_session | No image URL provided for updating session.");
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Image URL is required to update the session."
        );
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
        "save_memory": here.save_memory,
        "show_summary": here.show_summary
    };
    if self.if_report {
        report self.response;
    }
}

impl save_memory.create_memory with memories entry {
    logger.debug("session | save_memory | creating new memory");
    memory_node = here ++> memory();
    visit memory_node[0];
}

impl save_memory.update_memory with memory entry {
    logger.debug("session | save_memory | updating memory");
    walker_obj = root spawn get_session(
        session_id=self.session_id,
        if_report=False
    );
    response = walker_obj.response;
    if not response {
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found, please initialize the session first."
        );
    }
    here.session_id = response["session_id"];
    here.summary = response["summary"];
    here.when = response["when"];
    here.who = response["who"];
    here.where = response["where"];
    here.what = response["what"];
    here.image_url = response["image_url"];
    here.conversation = response["conversation"];
    here.updated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
    here.created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
    here.save_memory = response["save_memory"];
    here.show_summary = response["show_summary"];

    response = {
        "memory_id": here.memory_id,
        "session_id": here.session_id,
        "summary": here.summary,
        "when": here.when,  
        "who": here.who,
        "where": here.where,
        "what": here.what,
        "image_url": here.image_url,
        "conversation": here.conversation,
        "created_at": here.created_at,
        "updated_at": here.updated_at,
        "save_memory": here.save_memory,
        "show_summary": here.show_summary
    };
    report response;
}