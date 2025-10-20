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
    def find_next_agent(user_input: dict, current_agent_response: str, current_state: dict) -> AgentTypes by llm();
    def call_next_agent(user_input: dict, current_agent_response: str = "", current_state: dict) -> None;
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

    obj __specs__ {
        static has auth: bool = False;
    }
    def find_next_agent(user_input: dict, current_agent_response: str, current_state: dict) -> AgentTypes by llm();
    can supervise with `root entry;
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
    can execute with planner_agent entry;
}
sem PlanerHandling.plan_the_contenct = "You are a content planning expert. Create a detailed, actionable plan for a blog post, including title, introduction, main sections, code snippet placement, and conclusion.";

node WriterHandling {
    def perform_tavily_search(topic: str) -> str;
    def write_the_content(topic: str, output_format: str, plan: str, tone: str, audience: str, write_as: str) -> str by llm(
        method = "ReAct",
        tools = ([self.perform_tavily_search])
    );
    can execute with writer_agent entry;
}
sem WriterHandling.write_the_content = "You are an expert content writer. Write or revise a well-structured, engaging article based on the topic, content plan, tone, audience, and feedback provided.";

node ReviewHandling {
    has max_revisions: int = 3;

    def review_the_content(article: str, tone: str, topic: str, output_format: str, plan: str, audience: str, write_as: str) -> str by llm();
    can execute with review_agent entry;
}
sem ReviewHandling.review_the_content = "You are an expert editor. Review the article for quality, structure, engagement, and tone. Approve if excellent; otherwise, provide 2-3 actionable feedback points.";

node MediaHandling {
    def create_prompt_to_generate_media(article: str) -> str by llm();
    def generate_media_for_article(prompt: str) -> None;
    can execute with media_agent entry;
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
        "write_as": "personal blog post",
    };
    SupervisorAgent(user_input, "") spawn root;
}
