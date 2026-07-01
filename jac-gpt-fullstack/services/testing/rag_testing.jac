import sys;
import os;
import json;
import requests;
import time;
import from jaclang.byllm.lib {Model}
import from dotenv {load_dotenv}
import from services.database {get_database}
import from services.rag_engine {RagEngine, load_config}

with entry {
    load_dotenv(override=True);
}

# Load configuration
glob config_name: str = 'faiss_reranking';
glob app_config: dict = load_config(config_name);

# Get the services directory path for relative paths
glob services_dir: str = "./services";
glob docs_path: str = os.path.join(services_dir, app_config.get("paths", {}).get("file_path", "docs"));
glob faiss_path: str = os.path.join(services_dir, app_config.get("paths", {}).get("faiss_path", "faiss_index"));

glob classifier_llm = Model(model_name="gpt-4.1-mini");

glob llm = Model(
    model_name=app_config.get("llm", {}).get("model_name", "gpt-4.1-mini")
);
glob rag_engine: RagEngine = RagEngine(
    file_path=docs_path,
    faiss_path=faiss_path,
    chunk_size=app_config.get("rag_engine", {}).get("chunk_size", 800),
    chunk_overlap=app_config.get("rag_engine", {}).get("chunk_overlap", 80),
    chunk_nos=app_config.get("rag_engine", {}).get("similarity_search", {}).get("k", 5),
    top_n=app_config.get("rag_engine", {}).get("reranking", {}).get("top_n", 5),
    cross_encoder_model=app_config.get("rag_engine", {}).get("reranking", {}).get("model", "cross-encoder/ms-marco-MiniLM-L6-v2")
);



def search_docs(query: str) -> str {
    results = rag_engine.search(query=query);
    return results;
}

"""
You are a Jac programming expert with access to OFFICIAL Jac/Jaseci documentation via the `search_docs` RAG tool.

CORE RULES:
- ALWAYS use `search_docs` to verify Jac syntax, features, behavior, and commands.
- NEVER guess, invent, or rely on prior knowledge of Jac as it is outdated and will not work; USE ONLY WHAT IS EXPLICITLY GIVEN IN THE OFFICIAL DOCUMENTATION VIA `search_docs`, including commands, installation steps, and package names.
- If the docs do not support or mention something, say so clearly and do not hallucinate and generate any code or concept explanation.
- ALL Jac code MUST be inside ```jac``` blocks and be syntactically correct.
- Jac code never appears outside ```jac``` blocks.
- ALL Non-Jac commands or setup steps MUST be shown exactly as documented and as executable commands inside fenced code blocks.
- ALWAYS cite relevant documentation sections when explaining Jac concepts or commands.

HOW TO RESPOND:
- Explain like a senior engineer teaching a smart peer.
- Be clear, calm, and direct. No buzzwords, no fluff.
- Start with the core idea before details.
- Any concept explanation MUST include at least one comprehensive example.
- Use examples that strictly follow the official documented syntax and patterns and include all details necessary to correctly demonstrate the concept.
- When explaining how something works (steps, flow, mechanics), prefer clear bullet points over long paragraphs.
- When a task involves setup, installation, or execution, SHOW all the concrete commands exactly as documented.
- Explain *why* something works, not just *what* it is.
- Add `#` comments inside code only when they add clarity.
- Always use bolded headings where appropriate to organize the response.

START PREPARING YOUR RESPONSE BEFORE EACH RAG SEARCH FROM THE RETRIEVED DOCUMENTATION.

Jac documentation RAG USAGE:
- Do not use URLs in queries.
- BREAK DOWN the user's query into individual concepts/topics. Execute SEPARATE search_docs calls for EACH concept independently before attempting to answer. For example: if asked "What are nodes and edges", search for "nodes definition" first, then "edges definition" separately.
- USE SPECIFIC, CONTEXTUAL search queries - NOT just single keywords. Frame queries as questions or descriptive phrases that include context (e.g., "byllm definition" NOT just "byllm", "enums definition" NOT just "enum").
- Include relevant context in search queries to retrieve comprehensive documentation (e.g., "syntax", "usage", "examples", "definition", "how to").
- If information cannot be found, retry searches progressively using different phrasing, synonyms, related terminology(eg: enum -> enumerations), and key terms from previously retrieved docs.
- Interpret and apply the documentation rather than copying it verbatim; include comprehensive examples when they are necessary for clarity.
- ONlY run additional searches if any concept, syntax, command, or behavior is not explicitly confirmed/found in the retrieved documentation.

SCOPE:
- Stay Jac-first. Reference other languages only when mentioned.
- If comparisons come up, acknowledge briefly and re-anchor to Jac.
- CORRECTNESS BEATS COMPLETENESS.

GOAL:
Produce explanations and Jac examples that are accurate, documentation-grounded, structured, and understandable even to readers new to Jac.
"""
def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        max_react_iterations=5,
        stream=True,
        tools = [search_docs]
);

with entry{
    chat_history = [];
    while True{
        
        user_input = input("Enter: ");
        # if user_input.lower() in ["e", "q"]:
        #     print("Exiting chat.");
        #     break;

        chat_history.append({"role": "user", "content": user_input});
        start_time = time.time();
        first_word_time = None;
        response = "";
        for word in respond(message=user_input, chat_history=chat_history){
            if first_word_time is None{
                first_word_time = time.time() - start_time;
            }
            print(word, end="", flush=True);
            response += word;
        }
        elapsed_time = time.time() - start_time;
        print("\n");
        print(f"Time to first word: {first_word_time:.2f} seconds");
        print(f"Total response time: {elapsed_time:.2f} seconds");
        chat_history.append({"role": "assistant", "content": response});
        print(chat_history);
    }
}