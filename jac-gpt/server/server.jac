import sys;
import os;
import requests;
import from byllm.llm {Model}
import from dotenv {load_dotenv}
import from database {get_database}
import from rag_engine {RagEngine}
import from simple_docs {get_sitemap, get_doc_content, suggest_docs}

with entry {
    load_dotenv(override=True);
}

glob llm = Model(model_name='gpt-4.1-mini', verbose=True, api_key=os.getenv("OPENAI_API_KEY"));
glob rag_engine: RagEngine = RagEngine();


"""ChatType enum defines the types of chat interactions. ChatType must be one of:
- RAG: For interactions that require more knowledge (syntaxes) about Jac/Jaseci.
- QA: For interactions that does not require more knowledge (syntax updates) about Jac/Jaseci.
- OFF_TOPIC: For interactions that are not related to Jac programming language or Jaseci ecosystem.
"""
enum ChatType {
    RAG = "RAG",
    QA = "QA",
    OFF_TOPIC = "OFF_TOPIC"
}

node Router {
    def classify(message: str) -> ChatType by llm(method="Reason", temperature=0.2);
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
            router_node ++> QAChat();
            router_node ++> OffTopicChat();
            visit router_node;
        }
    }

    can route with Router entry {
        classification = here.classify(message = self.message);
        print("Routing message:", self.message, "to chat type:", classification);
        visit [-->](`?Chat)(?chat_type==classification);
    }
}

"""Search for relevant documents using the RAG engine.
    
    Args:
        query: The search query string
        chunck_nos: Number of document chunks to retrieve (default: 5)
        
    Returns:
        String containing relevant document content
"""
def search_docs(query: str, chunck_nos: int = 5) -> str {
    results = rag_engine.search(query=query, chunck_nos=chunck_nos);
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
        max_react_iterations=3,
        tools = [refer_full_language_examples, search_docs]
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

walker get_user_info {
    has email: str;
    has requester_email: str = "";

    can get_user_details with `root entry;
}

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

walker get_documentation_content {
    """Fetch documentation content from a given URL"""
    has url: str;
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can fetch_content with `root entry;
}

walker suggest_documentation {
    """Suggest relevant documentation based on chat message using enhanced AI with section-level granularity"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_enhanced_suggestions with `root entry;

    def suggest_with_ai(message: str, chat_history: list[dict]) -> str by llm(
        method="Reason",
        temperature=0.1
    );
}


