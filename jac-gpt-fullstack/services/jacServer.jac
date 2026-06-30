import sys;
import os;
import json;
import numpy as np;
import from sentence_transformers {SentenceTransformer}
import requests;
import from byllm.lib {Model}
import from dotenv {load_dotenv}
import from services.rag_engine {RagEngine, load_config}
import from services.mcp_client {McpClient}
import from datetime {datetime}

# Load environment variables (API keys, model overrides) up front, before any
# LLM-backed initialization runs, so credentials are available to the calls below.
with entry {
    load_dotenv(override=True);
}

# Long-lived MCP client subprocess (stdio JSON-RPC)
glob mcp_client: McpClient = McpClient();
glob available_mcp_tools_descriptions: str = mcp_client.get_tool_descriptions() if mcp_client.get_tools_length() > 0 else "";

def categorized_mcp_tools(mcp_tools: str) -> dict[str, list[str]] by llm();
def reorder_categorized_mcp_tools(categorized_tools: dict[str, list[str]]) -> dict[str, list[str]] by llm();

# Categorizing MCP tools needs a working LLM. Build the cache defensively so a
# missing API key or an unreachable LLM degrades to an empty cache instead of
# crashing server startup. The MCP chat abilities read this via .get(..., []),
# so an empty cache is safe. Initialized after `llm` is configured (see below).
def build_mcp_tools_cache() -> dict[str, list[str]] {
    empty = {"syntax_tools": [], "validation_tools": [], "other_tools": []};
    if not available_mcp_tools_descriptions {
        return empty;
    }
    try {
        return reorder_categorized_mcp_tools(categorized_mcp_tools(available_mcp_tools_descriptions));
    } except Exception as e {
        print(f"[MCP TOOLS CACHE] LLM categorization unavailable, continuing with empty cache: {e}");
        return empty;
    }
}

# Load configuration
glob config_name: str = 'faiss_reranking';
glob app_config: dict = load_config(config_name);

# Get the services directory path for relative paths
glob services_dir: str = "./services";
glob docs_path: str = os.path.join(services_dir, app_config.get("paths", {}).get("file_path", "docs"));
glob faiss_path: str = os.path.join(services_dir, app_config.get("paths", {}).get("faiss_path", "faiss_index"));

glob model_name: str = os.environ.get("MODEL", app_config.get("llm", {}).get("model_name", "gpt-4.1-mini"));
glob llm = Model(model_name=model_name);

# Built now that `llm` and the environment are ready; never fails server startup.
glob mcp_tools_cache: dict[str, list[str]] = build_mcp_tools_cache();

with entry {
    print(f"[MCP TOOLS CACHE]: syntax_tools={len(mcp_tools_cache.get('syntax_tools', []))}, validation_tools={len(mcp_tools_cache.get('validation_tools', []))}, other_tools={len(mcp_tools_cache.get('other_tools', []))}");
}

glob embedding_model = SentenceTransformer('all-MiniLM-L6-v2');
        
glob rag_engine: RagEngine = RagEngine(
    file_path=docs_path,
    faiss_path=faiss_path,
    chunk_size=app_config.get("rag_engine", {}).get("chunk_size", 800),
    chunk_overlap=app_config.get("rag_engine", {}).get("chunk_overlap", 80),
    chunk_nos=app_config.get("rag_engine", {}).get("similarity_search", {}).get("k", 5),
    top_n=app_config.get("rag_engine", {}).get("reranking", {}).get("top_n", 5),
    cross_encoder_model=app_config.get("rag_engine", {}).get("reranking", {}).get("model", "cross-encoder/ms-marco-MiniLM-L6-v2")
);

node Router {
}

"""Search for relevant documents using the RAG engine.

    Args:
        query: The search query string

    Returns:
        String containing relevant document content
"""
def search_docs(query: str) -> str {
    results = rag_engine.search(query=query);
    return results;
}

"""Refer `full_language.md` for complete Jac language examples to understand jac syntaxes."""
def refer_full_language_examples() -> str {
    try {
        base_path = os.path.dirname(__file__);
        file_path = os.path.join(base_path, "full_language.md");

        with open(file_path, "r", encoding="utf-8") as file {
            content = file.read();
        }

        if content.strip() {
            return content;
        } else {
            return "Language documentation is empty";
        }

    } except Exception {
        return "Language documentation not available";
    }
}

"""
Call an MCP tool by name with JSON-encoded arguments.

PARAMETERS:
    tool_name     : Exact tool name as a string (e.g.:- "syntax_lookup", "validate_code").
    tool_args_json: MUST be a valid JSON string with double-quoted keys and values.
                    Use "" or "{}" if the tool takes no arguments. Never pass None.
                    e.g.:- CORRECT  : '{"code":"obj Calculator {\\n    has result: float = 0.0;\\n\\n    def add(x: float) -> float;\\n    def get_result() -> float;\\n}\\n\\nimpl Calculator.add(x: float) -> float {\\n    self.result += x;\\n    return self.result;\\n}\\n\\nimpl Calculator.get_result() -> float {\\n    return self.result;\\n}\\n\\nwith entry {\\n    calc = Calculator();\\n    calc.add(5.0);\\n    print(calc.get_result());\\n}"}' | '{}'

USAGE:
    call_mcp_tool("tool_name", '{"key": "value"}')
    Never call mcp_client directly — always go through this function.

RETURNS:
    Tool output on success. "MCP call failed: ..." on error.
    Always check the return value before proceeding to the next step.
"""
def call_mcp_tool(tool_name: str, tool_args_json: str) -> str {
    try {
        tool_args = json.loads(tool_args_json) if tool_args_json else {};

        if not isinstance(tool_args, dict) {
            return "MCP call failed: tool_args_json must decode to a JSON object (e.g. {\"key\":\"value\"}).";
        }

        return mcp_client.call_tool(name=tool_name, args=tool_args);
    } except json.JSONDecodeError as e {
        start = max(0, e.pos - 30);
        end = min(len(tool_args_json), e.pos + 30);
        preview = tool_args_json[start:end];
        return (
            f"MCP call failed: invalid tool_args_json at line {e.lineno}, "
            f"column {e.colno} (char {e.pos}). "
            f"Reason: {e.msg}. "
            f"Snippet near error: {preview!r}. "
            f"Tip: escape newlines as \\\\n and quotes inside strings as \\\"."
        );
    } except Exception as e {
        return f"MCP call failed: {e}";
    }
}

node RagChat {

    def respond_rag(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        max_react_iterations=5,
        temperature=0.5,
        stream = True,
        logging = True,
        tools = [search_docs]
    );

    def respond_mcp(message: str, chat_history: list[dict], syntax_mcp_tools: list) -> str by llm(
        method="ReAct",
        max_react_iterations=10,
        temperature=0.5,
        stream = True,
        logging = True,
        tools = [call_mcp_tool]
    );

    can chat with interact entry;
}

node QAChat {

    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        stream = True,
        logging = True,
        max_react_iterations=3
    );

    can chat with interact entry;
}

node CodingChat {

    def code_jac_rag(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=20,
        temperature=0.3,
        stream = True,
        logging = True,
        tools = [search_docs]
    );

    def code_jac_mcp(message: str, chat_history: list[dict], syntax_mcp_tools: list, validation_mcp_tools: list) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=20,
        temperature=0.3,
        stream = True,
        logging = True,
        tools = [call_mcp_tool]
    );

    can chat with interact entry;
}

node DebuggerChat {

    def debug_code_rag(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        stream = True,
        logging = True,
        tools = [search_docs]
    );

    def debug_code_mcp(message: str, chat_history: list[dict], syntax_mcp_tools: list, validation_mcp_tools: list) -> str by llm(
        method="ReAct",
        messages=chat_history,
        stream = True,
        logging = True,
        tools = [call_mcp_tool]
    );

    can chat with interact entry;
}

node OffTopicChat{

    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="Reason",
        messages=chat_history,
        temperature=0.3
    );

    can chat with interact entry;
}

walker :pub interact {
    has message: str;
    has session_id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];
    has mode: str = "";
    has skip_history: bool = False;

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can route with Router entry {
        visit [-->] by llm(incl_info={"message" : self.message, "chat_history" : self.chat_history[-5:], "instruction": instruction});
    }

    can init_session with Root entry {
        print("Initializing session for:", self.session_id, "User:", self.user_email);
        all_sessions = [-->(?:Session)];
        found_session = None;
        for session in all_sessions {
            if session.id == self.session_id {
                found_session = session;
                break;
            }
        }
        if found_session {
            print("Session Node Found for:", self.session_id, "User:", found_session.user_email);
            visit found_session;
        } else {
            now = datetime.now().isoformat();
            session_node = here ++> Session(
                id=self.session_id,
                user_email=self.user_email,
                chat_history=[],
                created_at=now,
                updated_at=now
            );
            print("Session Node Created for:", self.session_id, "User:", self.user_email);
            visit session_node;
        }
    }
}

node Session {
    has id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];
    has status: str = "active";
    has created_at: str = "";
    has updated_at: str = "";

    can chat with interact entry;
}

node UserLocation {
    has email: str;
    has latitude: float = 0.0;
    has longitude: float = 0.0;
    has city: str = "";
    has country: str = "";
    has ip: str = "";
    has updated_at: str = "";
}

walker :pub get_session {
    has session_id: str;

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can get_chat_history with Root entry;

    can return_history with Session entry;
}

walker :pub new_session {
    has session_id: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can create_session with Root entry;
}

walker :pub save_turn {
    has session_id: str;
    has content: str;
    has role: str = "assistant";

    # Persists a single chat turn. Called by the client after the SSE stream
    # completes so the assistant response is committed within a normal walker
    # request (the streamed generator that produced the text runs after the
    # walker commits, so it cannot persist the turn itself).
    can save with Root entry {
        matching_sessions = ([-->(?:Session)](?id==self.session_id));
        if len(matching_sessions) > 0 {
            session_node = matching_sessions[0];
            session_node.chat_history.append({"role": self.role, "content": self.content});
            session_node.updated_at = datetime.now().isoformat();
            report {"success": True, "session_id": self.session_id};
        } else {
            report {"success": False, "session_id": self.session_id, "error": "session_not_found"};
        }
    }
}

walker get_session_stats {
    has session_id: str;

    can get_stats with Root entry {
        all_sessions = [-->(?:Session)];
        for session in all_sessions {
            if session.id == self.session_id {
                user_msgs = len([m for m in session.chat_history if m["role"] == "user"]);
                assistant_msgs = len([m for m in session.chat_history if m["role"] == "assistant"]);
                report {
                    "session_id": session.id,
                    "total_messages": len(session.chat_history),
                    "user_messages": user_msgs,
                    "assistant_messages": assistant_msgs,
                    "created_at": session.created_at,
                    "updated_at": session.updated_at
                };
                return;
            }
        }
        report {};
    }
}

walker :pub close_session {
    has session_id: str;

    can close_session_db with Root entry {
        all_sessions = [-->(?:Session)];
        for session in all_sessions {
            if session.id == self.session_id {
                session.status = "closed";
                session.updated_at = datetime.now().isoformat();
                break;
            }
        }
        report {
            "session_id": self.session_id,
            "status": "closed"
        };
    }
}

# Admin walkers
walker :pub get_user_profile {
    has email: str;

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can fetch_profile with Root entry;
}

walker :pub create_user_profile {
    has email: str;
    has name: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can setup_profile with Root entry;
}

walker :pub save_user_location {
    has email: str;
    has location: dict = {};

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can save_location with Root entry;
}

walker :pub get_all_users {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can list_users with Root entry;
}

walker :pub get_all_sessions_admin {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can list_all_sessions with Root entry;
}

walker :pub get_session_messages_admin {
    has session_id: str;
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can get_session_chat with Root entry;
}

# Documentation-related walkers
walker :pub get_documentation_urls {
    """Get all documentation URLs from sitemap.xml"""

    obj __specs__ {
        static has methods: list = ["get"];
    }

    can extract_urls with Root entry {
        import xml.etree.ElementTree as ET;
        import os;

        try {
            # Read sitemap.xml file
            sitemap_path = os.path.join(os.path.dirname(__file__), "sitemap.xml");
            tree = ET.parse(sitemap_path);
            root_element = tree.getroot();

            # Extract URLs and their metadata
            urls = [];
            namespace = {'ns': 'http://www.sitemaps.org/schemas/sitemap/0.9'};

            for url_element in root_element.findall('ns:url', namespace) {
                loc = url_element.find('ns:loc', namespace);
                lastmod = url_element.find('ns:lastmod', namespace);
                priority = url_element.find('ns:priority', namespace);

                if loc is not None {
                    url_info = {
                        "url": loc.text,
                        "lastmod": lastmod.text if lastmod is not None else "",
                        "priority": float(priority.text) if priority is not None else 0.5
                    };
                    urls.append(url_info);
                }
            }

            # Sort by priority (highest first) and then by URL structure
            def sort_key(x: dict) -> tuple {
                return (-x["priority"], x["url"]);
            }
            urls.sort(key=sort_key);

            report {
                "success": True,
                "urls": urls,
                "total": len(urls)
            };
        } except Exception as e {
            report {
                "success": False,
                "error": str(e),
                "urls": [],
                "total": 0
            };
        }
    }
}

walker :pub get_doc_content {
    """Fetch documentation content from URL or local files"""
    has url: str;

    obj __specs__ {
        static has methods: list = ["post"];
    }

    can fetch_doc with Root entry {
        import os;
        import requests;
        import re;

        try {
            # Basic URL validation
            if "jac-lang.org" not in self.url {
                report {
                    "success": False,
                    "error": "Only jac-lang.org URLs supported",
                    "content": "",
                    "title": ""
                };
                return;
            }

            # Extract path from URL
            url_parts = self.url.split("jac-lang.org");
            if len(url_parts) > 1 {
                path = url_parts[1].strip("/");
            } else {
                path = "";
            }

            # Try to find local documentation file
            local_doc_path = os.path.join(os.path.dirname(__file__), "docs", path);

            # Check for index.html in directory
            if os.path.isdir(local_doc_path) {
                index_path = os.path.join(local_doc_path, "index.html");
                if os.path.exists(index_path) {
                    local_doc_path = index_path;
                }
            }

            # Check for .html extension
            if not local_doc_path.endswith(".html") and os.path.exists(local_doc_path + ".html") {
                local_doc_path += ".html";
            }

            content = "";
            title = "";
            source = "remote";

            if os.path.exists(local_doc_path) {
                # Read local file
                with open(local_doc_path, 'r', encoding='utf-8') as f {
                    content = f.read();
                }
                source = "local";
            } else {
                # Fetch from remote URL
                response = requests.get(self.url, timeout=10);
                response.raise_for_status();
                content = response.text;
            }

            # Extract title from HTML
            title_match = re.search(r'<title>(.*?)</title>', content, re.IGNORECASE | re.DOTALL);
            if title_match {
                title = title_match.group(1).strip();
            } else {
                title = "Documentation";
            }

            # Clean up content for better display
            # Extract main content area
            main_content = "";

            # Try to extract the main article content
            article_match = re.search(r'<article[^>]*class="md-content__inner[^"]*"[^>]*>(.*?)</article>', content, re.DOTALL | re.IGNORECASE);
            if article_match {
                main_content = article_match.group(1);
            } else {
                # Fallback: try to find content div
                content_match = re.search(r'<div[^>]*class="md-content"[^>]*>(.*?)</div>', content, re.DOTALL | re.IGNORECASE);
                if content_match {
                    main_content = content_match.group(1);
                } else {
                    # Use full content as fallback
                    main_content = content;
                }
            }

            # Remove unwanted elements
            main_content = re.sub(r'<script[^>]*>.*?</script>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<style[^>]*>.*?</style>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<nav[^>]*>.*?</nav>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<footer[^>]*>.*?</footer>', '', main_content, flags=re.DOTALL | re.IGNORECASE);
            main_content = re.sub(r'<header[^>]*>.*?</header>', '', main_content, flags=re.DOTALL | re.IGNORECASE);

            # Remove edit buttons and source buttons
            main_content = re.sub(r'<a[^>]*class="md-content__button[^"]*"[^>]*>.*?</a>', '', main_content, flags=re.DOTALL | re.IGNORECASE);

            # Clean up extra whitespace
            main_content = re.sub(r'\s+', ' ', main_content);
            cleaned_content = main_content.strip();

            report {
                "success": True,
                "content": cleaned_content,
                "title": title,
                "url": self.url,
                "source": source
            };

        } except Exception as e {
            report {
                "success": False,
                "error": str(e),
                "content": "",
                "title": "",
                "url": self.url
            };
        }
    }
}

walker :pub suggest_docs {
    """Enhanced suggest relevant documentation based on user message using semantic similarity"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_suggestions with Root entry {
        
        # Load section-level documentation links with embeddings
        section_links = [];
        try {
            links_file = os.path.join(os.path.dirname(__file__), "docs_links", "all_section_links.json");
            with open(links_file, 'r', encoding='utf-8') as f {
                section_links = json.load(f);
            }
        } except Exception as e {
            print(f"Error loading section links: {str(e)}");
            report {
                "success": False,
                "error": f"Failed to load documentation links: {str(e)}",
                "suggestions": [],
                "total": 0
            };
            return;
        }
        
        # Generate embedding for the user's message
        message_embedding = embedding_model.encode(self.message,  show_progress_bar=False);
        
        # Calculate cosine similarity with each documentation title
        similarities = [];
        for link in section_links {
            if 'embedding' in link {
                doc_embedding = np.array(link['embedding']);
                
                # Cosine similarity
                similarity = np.dot(message_embedding, doc_embedding) / (
                    np.linalg.norm(message_embedding) * np.linalg.norm(doc_embedding)
                );
                
                similarities.append({
                    "url": link["url"],
                    "title": link["title"],
                    "similarity": float(similarity)
                });
            }
        }
        
        # Sort by similarity (highest first)
        def get_similarity(x: dict) -> float {
            return x["similarity"];
        }
        similarities.sort(key=get_similarity, reverse=True);
        
        # Get top 3 suggestions
        top_suggestions = [];
        for i in range(min(3, len(similarities))) {
            suggestion = similarities[i];
            top_suggestions.append({
                "url": suggestion["url"],
                "title": suggestion["title"]
            });
        }
        
        report {
            "success": True,
            "suggestions": top_suggestions,
            "total": len(top_suggestions)
        };
    }
}
