import from agent_core { Memory, Session }
import from byllm.llm { Model }
import sys;

glob llm = Model(model_name="gpt-4o");

enum AgentTypes {
    PLANNER_AGENT,
    WRITER_AGENT,
    REVIEW_AGENT,
    END
}

def write_content(agent: str, response: str) {
    import json, time;
    with open("output.jsonl", "a") as f {
        rec = {
            "ts": int(time.time()),
            "agent": agent,
            "response": response
        };
        f.write(json.dumps(rec, ensure_ascii=False));
        f.write("\n");
    }
}

walker agent {
    obj __specs__ {
        static has auth: bool = False;
    }

    def find_next_agent(user_input: dict, current_agent_response: str, current_state: dict) -> AgentTypes by llm();
    def call_next_agent(user_input: dict, current_agent_response: str = "", current_state: dict) -> None {        
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

        } else {
            print("No valid next agent found, stopping execution.");
            disengage;
        }
    }
}

walker SupervisorAgent(agent) {
    has user_input: dict = {
        field: "",
        topic: "",
        output_format: "",
        tone: "",
        audience: "",
        write_as: "",
    };
    has session_id: str = "";

    def find_next_agent(user_input: dict, current_agent_response: str, current_state: dict) -> AgentTypes by llm();
    can supervise with `root entry {
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
        
        self.call_next_agent(
            self.user_input, 
            "", 
            self.session.current_state
        );
        print();
    }
}

walker planner_agent(agent) {
    has session: Session;
    has user_input: dict = {
        topic: "",
        context: "",
    };
}

walker writer_agent(agent) {
    has session: Session;
    has user_input: dict = {
        topic: "",
        output_format: "",
        tone: "",
        audience: "",
        write_as: "",
    };
}

walker review_agent(agent) {
    has session: Session;
    has user_input: dict = {
        tone: "",
    };
}

# walker media_agent {
#     has session: Session;

#     can execute with `root entry {
#         print("media agent executed");
#         media_response = "Media content created: An infographic illustrating the key features and applications of Agentic AI, along with a short video explaining the concept in simple terms.";
#         self.session.current_state["media_response"] = media_response;
#         print("Media content details added to session history.", self.session.current_state);
#         # return media_response;
#     } 
# }


node PlanerHandling {
    def plan_the_content(topic: str, context: str) -> str by llm();
    can execute with planner_agent entry {
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
}
sem PlanerHandling.plan_the_content = "You are a content planning expert. Create a detailed, actionable plan for a blog post, including title, introduction, main sections, code snippet placement, and conclusion.";

node WriterHandling {
    def write_the_content(topic: str, output_format: str, plan: str, tone: str, audience: str, write_as: str) -> str by llm();
    can execute with writer_agent entry {
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
}
sem WriterHandling.write_the_content = "You are an expert content writer. Write or revise a well-structured, engaging article based on the topic, content plan, tone, audience, and feedback provided.";

node ReviewHandling {
    has max_revisions: int = 3;

    def review_the_content(article: str, tone: str) -> str by llm();
    can execute with review_agent entry {
        review = self.review_the_content(visitor.session.current_state["article"], visitor.user_input["tone"]);
        write_content("review_agent", review);
        visitor.session.current_state["review_agent"] = review;
        if "review_count" not in visitor.session.current_state {
            visitor.session.current_state["review_count"] = 0;
        }
        visitor.session.current_state["review_count"] += 1;
        if visitor.session.current_state["review_count"] >= self.max_revisions {
            visitor.session.current_state["review_agent"] = "Max revisions reached. Approving article as is. Stop further editing.";
        }
        visitor.call_next_agent(
            visitor.user_input, 
            "review response: " + review, 
            visitor.session.current_state
        );
    }
}
sem ReviewHandling.review_the_content = "You are an expert editor. Review the article for quality, structure, engagement, and tone. Approve if excellent; otherwise, provide 2-3 actionable feedback points.";


with entry {
    user_input = {
        "field": "technology",
        "topic": "The Future of AI in Content Creation",
        "output_format": "markdown",
        "tone": "informative and engaging",
        "audience": "tech enthusiasts and professionals",
        "write_as": "a knowledgeable industry expert",
    };
    SupervisorAgent(user_input, "") spawn root;
}
