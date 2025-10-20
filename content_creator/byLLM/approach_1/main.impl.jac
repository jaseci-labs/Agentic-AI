impl agent.call_next_agent {
    next_agent = self.find_next_agent(user_input, current_agent_response, current_state);
    print("Next agent to execute:", next_agent);
    
    if next_agent == AgentTypes.END {
        self.session.current_state["done"] = True;
        print("Stopping: better/approved response reached.");
        if "article" in self.session.current_state {
            final_content = self.session.current_state["article"];
            with open("final_output.md", "w") as f {
                f.write(final_content);
            }
            print("Final content saved to 'final_output.md'.");
        } else {
            print("No article content found to save.");
        }
        disengage;

    } elif next_agent == AgentTypes.PLANNER_AGENT {
        plan_handling = [root --> (`?PlanerHandling)][0];
        planner_agent(session=self.session, user_input=user_input) spawn plan_handling;

    } elif next_agent == AgentTypes.WRITER_AGENT {
        writer_handling = [root --> (`?WriterHandling)][0];
        writer_agent(session=self.session, user_input=user_input) spawn writer_handling;

    } elif next_agent == AgentTypes.REVIEW_AGENT {
        review_handling = [root --> (`?ReviewHandling)][0];
        review_agent(session=self.session, user_input=user_input) spawn review_handling;

    } elif next_agent == AgentTypes.MEDIA_AGENT {
        media_handling = [root --> (`?MediaHandling)][0];
        media_agent(session=self.session) spawn media_handling;
    } else {
        print("No valid next agent found, stopping execution.");
        disengage;
    }
}

impl SupervisorAgent.supervise {
    memory_list = [root --> (`?Memory)];
    if not memory_list {
        memory_list = root ++> Memory();
    }
    memory = memory_list[0];
    if not self.session_id {
        session_list = memory ++> Session();
        self.session = session_list[0];
    } else {
        self.session = &(self.session_id);
    }

    if not [root --> (`?PlanerHandling)] {
        root ++> PlanerHandling();
    }
    if not [root --> (`?WriterHandling)] {
        root ++> WriterHandling();
    }
    if not [root --> (`?ReviewHandling)] {
        root ++> ReviewHandling();
    }
    if not [root --> (`?MediaHandling)] {
        root ++> MediaHandling();
    }
    
    self.call_next_agent(
        self.user_input, 
        "", 
        self.session.current_state
    );
    print();
}

impl PlanerHandling.execute {
    print("planner agent executed");
    plan = self.plan_the_content(visitor.user_input["topic"], "");
    write_content("planner_agent", plan);
    visitor.session.current_state["plan"] = plan;
    visitor.call_next_agent(
        visitor.user_input, 
        "planner response: " + plan, 
        visitor.session.current_state
    );
}

impl WriterHandling.perform_tavily_search {
    print("Performing Tavily search for topic:", topic);
    search_results = tavily_client.search(topic, limit=3);
    snippets = [r["content"] for r in search_results.get("results", []) if "content" in r];
    str_results = "\n".join(snippets);
    return str_results;
}

impl WriterHandling.execute {
    print("writer agent executed");
    content = self.write_the_content(
        visitor.user_input["topic"], 
        visitor.user_input["output_format"], 
        visitor.session.current_state["plan"], 
        visitor.user_input["tone"], 
        visitor.user_input["audience"], 
        visitor.user_input["write_as"]
    );
    write_content("writer_agent", content);
    visitor.session.current_state["article"] = content;
    visitor.call_next_agent(
        visitor.user_input, 
        "writer response: " + content, 
        visitor.session.current_state
    );
}

impl ReviewHandling.execute {
    review = self.review_the_content(visitor.session.current_state["article"], visitor.user_input["tone"], visitor.user_input["topic"], visitor.user_input["output_format"], visitor.session.current_state["plan"], visitor.user_input["audience"], visitor.user_input["write_as"]);
    write_content("review_agent", review);
    visitor.session.current_state["review_agent"] = review;
    if "review_count" not in visitor.session.current_state {
        visitor.session.current_state["review_count"] = 0;
    }
    visitor.session.current_state["review_count"] += 1;
    if visitor.session.current_state["review_count"] >= self.max_revisions {
        visitor.session.current_state["review_agent"] = "Max revisions reached. Approving article as is. Generate media as the final step";
    }
    visitor.call_next_agent(
        visitor.user_input, 
        "review response: " + review, 
        visitor.session.current_state
    );
}

impl MediaHandling.generate_media_for_article {
    result = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            size="1536x1024",
            n=1
        );
    image_base64 = result.data[0].b64_json;
    image_bytes = base64.b64decode(image_base64);

    output_path = "article_image.png";
    with open(output_path, "wb") as f {
        f.write(image_bytes);
    }
    print(f"Image saved as {output_path}");
}

impl MediaHandling.execute {
    article = visitor.session.current_state.get("article", "");

    if not article {
        print("No article found to generate media for.");
        disengage;
    }
    prompt = self.create_prompt_to_generate_media(article);
    write_content("media_agent", prompt);
    self.generate_media_for_article(prompt);
    visitor.session.current_state["media_generated"] = True;
    visitor.call_next_agent(
        {}, 
        "Media generated, go to END", 
        visitor.session.current_state
    );
}
