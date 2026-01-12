import sys;
import os;
import json;
import requests;
import from byllm.lib {Model}
import from dotenv {load_dotenv}
import from database {get_database}
import from rag_engine {RagEngine, load_config}

with entry {
    load_dotenv(override=True);
}

# Load configuration
glob config_name: str = 'faiss_reranking';
glob app_config: dict = load_config(config_name);

glob classifier_llm = Model(model_name="gpt-4.1-mini");

glob llm = Model(
    model_name=app_config.get("llm", {}).get("model_name", "gpt-4.1-mini")
);
glob rag_engine: RagEngine = RagEngine(
    file_path=app_config.get("paths", {}).get("file_path", "docs"),
    faiss_path=app_config.get("paths", {}).get("faiss_path", "faiss_index"),
    chunk_size=app_config.get("rag_engine", {}).get("chunk_size", 800),
    chunk_overlap=app_config.get("rag_engine", {}).get("chunk_overlap", 80),
    chunk_nos=app_config.get("rag_engine", {}).get("similarity_search", {}).get("k", 5),
    top_n=app_config.get("rag_engine", {}).get("reranking", {}).get("top_n", 5),
    cross_encoder_model=app_config.get("rag_engine", {}).get("reranking", {}).get("model", "cross-encoder/ms-marco-MiniLM-L6-v2")
);


"""
ChatType enum defines the types of chat interactions. ChatType must be one of:
- RAG: For interactions that require conceptual explanation about Jac/Jaseci.
- CODING: For interactions that require code generation or code modification.
- QA: For interactions that does not require more knowledge (syntaxes) about Jac/Jaseci.
- OFF_TOPIC: For interactions that are not related to Jac programming language or Jaseci ecosystem.
"""
enum ChatType {
    RAG = "RAG",
    CODING = "CODING",
    QA = "QA",
    OFF_TOPIC = "OFF_TOPIC"
}

node Router {
    def classify(message: str, previous_messages: list[str]) -> ChatType by classifier_llm(method="Reason", temperature=0.2);
}

node Chat {
    has chat_type: ChatType;
}

walker infer {
    has message: str;
    has chat_history: list[dict];
    has response: str = "";

    can init_router with `root entry {
        visit [-->](`?Router) else {
            router_node = here ++> Router();
            router_node ++> RagChat();
            router_node ++> CodingChat();
            router_node ++> QAChat();
            router_node ++> OffTopicChat();
            visit router_node;
        }
    }

    can route with Router entry {
        print(self.chat_history[-3:]);
        print("Classifying history");
        classification = here.classify(message = self.message, previous_messages = self.chat_history[-3:]);
        print("Routing message:", self.message, "to chat type:", classification);
        visit [-->](`?Chat)(?chat_type==classification);
    }
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

node RagChat(Chat) {
    has chat_type: ChatType = ChatType.RAG;

    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=5,
        tools = [search_docs]
    );

    can chat with infer entry;
}

node QAChat(Chat) {
    has chat_type: ChatType = ChatType.QA;

    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=3
    );

    can chat with infer entry;
}

node CodingChat(Chat) {
    has chat_type: ChatType = ChatType.CODING;

    def code_jac(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=5,
        tools = [search_docs]
    );

    can chat with infer entry;
}

node OffTopicChat(Chat) {
    has chat_type: ChatType = ChatType.OFF_TOPIC;
    
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="Reason",
        messages=chat_history,
        temperature=0.3
    );

    can chat with infer entry;
}

walker interact {
    has message: str;
    has session_id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can init_session with `root entry {
        visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, user_email=self.user_email, chat_history=[]);
            print("Session Node Created for:", self.session_id, "User:", self.user_email);
            visit session_node;
        }
    }
}

node Session {
    has id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];
    has status: int = 1;

    can chat with interact entry ;
}

walker get_session {
    has session_id: str;

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_chat_history with `root entry;

    can return_history with Session entry;
}

walker new_session {
    has session_id: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can create_session with `root entry;
}

walker get_session_stats {
    has session_id: str;

    can get_stats with `root entry {
        db = get_database();
        stats = db.get_session_stats(self.session_id);
        report stats;
    }
}

walker close_session {
    has session_id: str;

    can close_session_db with `root entry {
        db = get_database();
        db.close_session(self.session_id);
        report {
            "session_id": self.session_id,
            "status": "closed"
        };
    }
}

# Admin walkers
walker get_user_profile {
    has email: str;

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can fetch_profile with `root entry;
}

walker create_user_profile {
    has email: str;
    has name: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can setup_profile with `root entry;
}

walker save_user_location {
    has email: str;
    has location: dict = {};

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can save_location with `root entry;
}

walker get_all_users {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can list_users with `root entry;
}

walker get_all_sessions_admin {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can list_all_sessions with `root entry;
}

walker get_session_messages_admin {
    has session_id: str;
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_session_chat with `root entry;
}

# walker get_user_info {
#     has email: str;
#     has requester_email: str = "";

#     can get_user_details with `root entry;
# }

# Documentation-related walkers
walker get_documentation_urls {
    """Get all documentation URLs from sitemap.xml"""
    
    obj __specs__ {
        static has methods: list = ["get"];
        static has auth: bool = False;
    }

    can extract_urls with `root entry {
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

# walker get_documentation_content {
#     """Fetch documentation content from a given URL"""
#     has url: str;
    
#     obj __specs__ {
#         static has methods: list = ["post"];
#         static has auth: bool = False;
#     }

#     can fetch_content with `root entry;
# }

# walker suggest_documentation {
#     """Suggest relevant documentation based on chat message using enhanced AI with section-level granularity"""
#     has message: str;
#     has chat_history: list[dict] = [];
    
#     obj __specs__ {
#         static has methods: list = ["post"];
#         static has auth: bool = False;
#     }

#     can get_enhanced_suggestions with `root entry;
# }


walker get_doc_content {
    """Fetch documentation content from URL or local files"""
    has url: str;
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can fetch_doc with `root entry {
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

walker suggest_docs {
    """Enhanced suggest relevant documentation based on user message with section-level links"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_suggestions with `root entry {
        import json;
        import os;
        
        # Load section-level documentation links
        section_links = [];
        try {
            links_file = os.path.join(os.path.dirname(__file__), "docs_links", "all_section_links.json");
            with open(links_file, 'r', encoding='utf-8') as f {
                section_links = json.load(f);
            }
        } except Exception as e {
            print(f"Error loading section links: {str(e)}");
        }
        
        message_lower = self.message.lower();
        suggestions = [];
        
        print(f"Processing message: {message_lower}");
        
        # First: Check for specific section matches with high priority
        for link in section_links {
            section_title_lower = link.get("section_title", "").lower();
            
            # High priority exact matches
            if ("beyond oop" in message_lower and "beyond oop" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Direct match for {link['section_title']} concept",
                    "score": 25
                });
            } elif ("agentic programming" in message_lower and "agentic" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Learn about {link['section_title']}",
                    "score": 25
                });
            } elif ("programming abstractions" in message_lower and "programming abstractions" in section_title_lower) {
                suggestions.append({
                    "url": link["url"],
                    "title": link["section_title"],
                    "reason": f"Discover {link['section_title']}",
                    "score": 24
                });
            }
        }
        
        print(f"Found {len(suggestions)} exact section matches");
        
        # Second: Keyword-based suggestions (always add if keywords match)
        
        # Walker-specific
        if "walker" in message_lower {
            print("Found walker keyword");
            # Look for walker-specific sections
            for link in section_links {
                section_title_lower = link.get("section_title", "").lower();
                if "walker" in section_title_lower {
                    suggestions.append({
                        "url": link["url"],
                        "title": link["section_title"],
                        "reason": f"Learn about {link['section_title']}",
                        "score": 20
                    });
                }
            }
            # Add general walker documentation
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                "title": "Walkers Guide",
                "reason": "Complete guide to using walkers for data traversal and processing",
                "score": 20
            });
        }
        
        # Node/Edge/Graph concepts and OSP (Object-Spatial Programming)
        spatial_keywords = ["node", "edge", "graph", "spatial", "object", "osp", "object spatial", "object-spatial"];
        spatial_found = False;
        osp_specific = False;
        
        for keyword in spatial_keywords {
            if keyword in message_lower {
                spatial_found = True;
                if keyword == "osp" or "object spatial" in message_lower or "object-spatial" in message_lower {
                    osp_specific = True;
                }
                print(f"Found spatial keyword: {keyword}");
                break;
            }
        }
        
        if osp_specific {
            # OSP-specific comprehensive suggestions
            suggestions.extend([
                {
                    "url": "https://www.jac-lang.org/learn/dspfoundation/",
                    "title": "Object Spatial Programming Specification",
                    "reason": "Complete specification and foundation of Object-Spatial Programming",
                    "score": 22
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                    "title": "Nodes and Edges",
                    "reason": "Core concepts of nodes and edges in Object-Spatial Programming",
                    "score": 21
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/walkers/",
                    "title": "Walkers",
                    "reason": "Learn about walkers for traversing spatial data structures",
                    "score": 20
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/filtering/",
                    "title": "Node and Edges Filtering",
                    "reason": "Advanced filtering techniques for nodes and edges",
                    "score": 19
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/sequence/",
                    "title": "Walker and Node ability trigger sequence",
                    "reason": "Understanding execution sequences in Object-Spatial Programming",
                    "score": 18
                }
            ]);
        } elif spatial_found {
            # General spatial programming suggestions
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                "title": "Nodes and Edges",
                "reason": "Learn about Object-Spatial Programming with nodes and edges",
                "score": 18
            });
        }
        
        # AI/LLM related
        ai_keywords = ["ai", "llm", "artificial intelligence", "language model"];
        ai_found = False;
        for keyword in ai_keywords {
            if keyword in message_lower {
                ai_found = True;
                print(f"Found AI keyword: {keyword}");
                break;
            }
        }
        
        if ai_found {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/#programming-abstractions-for-ai",
                "title": "Programming Abstractions for AI",
                "reason": "Learn about Jac's AI-first programming constructs",
                "score": 17
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/jac-byllm/with_llm/",
                "title": "Working with LLMs",
                "reason": "Deep dive into using Large Language Models in Jac",
                "score": 16
            });
        }
        
        # Getting started
        start_keywords = ["start", "begin", "new", "intro", "hello", "getting started"];
        start_found = False;
        for keyword in start_keywords {
            if keyword in message_lower {
                start_found = True;
                print(f"Found start keyword: {keyword}");
                break;
            }
        }
        
        if start_found {
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/introduction/#beyond-oop-an-agentic-programming-model",
                "title": "Beyond OOP: An Agentic Programming Model",
                "reason": "Perfect introduction to Jac's innovative paradigm",
                "score": 15
            });
            suggestions.append({
                "url": "https://www.jac-lang.org/learn/getting_started/",
                "title": "Getting Started",
                "reason": "Step-by-step guide to start coding in Jac",
                "score": 14
            });
        }
        
        print(f"Total suggestions after keyword matching: {len(suggestions)}");
        
        # Sort by score (highest first) - Manual bubble sort
        for i in range(len(suggestions)) {
            for j in range(len(suggestions) - 1 - i) {
                if suggestions[j]["score"] < suggestions[j + 1]["score"] {
                    temp = suggestions[j];
                    suggestions[j] = suggestions[j + 1];
                    suggestions[j + 1] = temp;
                }
            }
        }
        
        # Default suggestions if still no matches
        if len(suggestions) == 0 {
            suggestions = [
                {
                    "url": "https://www.jac-lang.org/learn/introduction/",
                    "title": "Tour of Jac",
                    "reason": "Complete introduction and tour of the Jac programming language",
                    "score": 1
                },
                {
                    "url": "https://www.jac-lang.org/learn/jac_ref/",
                    "title": "Jac Language Reference",
                    "reason": "Comprehensive reference for Jac language syntax and features",
                    "score": 1
                },
                {
                    "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
                    "title": "Nodes and Edges",
                    "reason": "Master Object-Spatial Programming basics with nodes and edges",
                    "score": 1
                }
            ];
        }
        
        # Return top 5 suggestions
        limited_suggestions = [];
        for i in range(min(5, len(suggestions))) {
            suggestion = suggestions[i];
            limited_suggestions.append({
                "url": suggestion["url"],
                "title": suggestion["title"],
                "reason": suggestion["reason"]
            });
        }
        
        report {
            "success": True,
            "suggestions": limited_suggestions,
            "total": len(limited_suggestions)
        };
    }
}