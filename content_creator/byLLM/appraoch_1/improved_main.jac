import from agent_core { Memory, Session }
import from byllm.llm { Model }
import from tavily { TavilyClient }
import from dotenv { load_dotenv }
import from openai { OpenAI }
import base64;
import sys;
import os;

glob llm = Model(model_name="gpt-4o");
glob client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'));
glob tavily_client = TavilyClient(api_key=os.getenv('TAVILY_API_KEY'));

enum AgentTypes {
    PLANNER_AGENT,
    WRITER_AGENT,
    REVIEW_AGENT,
    MEDIA_AGENT,
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

        } elif next_agent == AgentTypes.MEDIA_AGENT {
            media_handling = [root --> (`?MediaHandling)][0];
            media_agent(session=self.session) spawn media_handling;
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
        field: "",
        topic: "",
        output_format: "",
        tone: "",
        audience: "",
        write_as: "",
    };
}

walker media_agent(agent) {
    has session: Session;
}

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
sem PlanerHandling.plan_the_contenct = "You are a content planning expert. Create a detailed, actionable plan for a blog post, including title, introduction, main sections, code snippet placement, and conclusion.";

node WriterHandling {
    def perform_tavily_search(topic: str) -> str {
        print("Performing Tavily search for topic:", topic);
        search_results = tavily_client.search(topic, limit=3);
        snippets = [r["content"] for r in search_results.get("results", []) if "content" in r];
        str_results = "\n".join(snippets);
        return str_results;
    }
    def write_the_content(topic: str, output_format: str, plan: str, tone: str, audience: str, write_as: str) -> str by llm(
        method = "ReAct",
        tools = ([self.perform_tavily_search])
    );
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

    def review_the_content(article: str, tone: str, topic: str, output_format: str, plan: str, audience: str, write_as: str) -> str by llm();
    can execute with review_agent entry {
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
}
sem ReviewHandling.review_the_content = "You are an expert editor. Review the article for quality, structure, engagement, and tone. Approve if excellent; otherwise, provide 2-3 actionable feedback points.";

node MediaHandling {
    def create_prompt_to_generate_media(article: str) -> str by llm();
    def generate_media_for_article(prompt: str) -> None {
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
    can execute with media_agent entry {
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
}
sem MediaHandling.create_prompt_to_generate_media = "You are an expert at creating concise DALL-E prompts. Based on the article, create a graphic flyer-style prompt that represents the main theme, including the title as text.";

with entry {
    load_dotenv();

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
