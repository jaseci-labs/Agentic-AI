import sys;
import os;
import requests;
import from mtllm.llm {Model}
import from dotenv {load_dotenv}
import from database {get_database}
import from rag_engine {RagEngine}
import from simple_docs {get_sitemap, get_doc_content, suggest_docs}
import from full_language {full_language}

with entry {
    load_dotenv(override=True);
    
    # Check full_language.md file accessibility during server launch
    print("=== Server Launch: Checking full_language.md accessibility ===");
    base_path = os.path.dirname(__file__);
    file_path = os.path.join(base_path, "full_language.md");
    
    if os.path.exists(file_path) {
        try {
            with open(file_path, "r", encoding="utf-8") as file {
                content = file.read();
            }
            if content.strip() {
                print(f"✅ SUCCESS: full_language.md is accessible ({len(content)} characters)");
                print(f"   File path: {file_path}");
            } else {
                print("⚠️  WARNING: full_language.md exists but is empty");
            }
        } except Exception as e {
            print(f"❌ ERROR: full_language.md exists but cannot be read - {str(e)}");
        }
    } else {
        print(f"❌ FILE NOT FOUND: full_language.md at {file_path}");
        print("   Will fallback to embedded string content");
    }
    print("=== End accessibility check ===");
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
    """Classify the message based on its content and intent for optimal Jac language assistance:
    
    **Classification Rules:**
    
    1. **QA Only For**:
       - Basic greetings and casual conversation ('hi', 'hello', 'how are you', 'thanks', 'goodbye')
       - Simple acknowledgments and social pleasantries
    
    2. **RAG For All Technical and Explaintion Content**:
       - ANY Jac programming language questions (syntax, features, concepts, examples)
       - Code documentation and example requests (reference existing Jac examples from docs)
       - Object-Spatial Programming (OSP) questions and examples
       - AI-first constructs and LLM integration in Jac
       - Jaseci platform, tools, ecosystem questions
       - Cloud-native development with Jac
       - Programming questions that could benefit from Jac solutions
       - Algorithm and data structure questions
       - Software development concepts and patterns
       - AI/ML programming questions
       - Graph programming and data modeling
       - Debugging, best practices, or technical help
       - Documentation requests about Jac/Jaseci
       - Code review and optimization questions
       - Comparison with other programming languages
       - Technical problem-solving questions
    
    3. **OFF_TOPIC Only For**:
       - Completely non-technical topics (cooking, sports, entertainment, politics, etc.)
       - Personal advice unrelated to programming
       - Topics that cannot reasonably connect to programming or technology
       
    **Default**: When in doubt between QA and RAG for technical content, choose RAG to leverage comprehensive documentation."""
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
    # First try to read from full_language.md file
    try {
        base_path = os.path.dirname(__file__);
        file_path = os.path.join(base_path, "full_language.md");
        
        if os.path.exists(file_path) {
            with open(file_path, "r", encoding="utf-8") as file {
                content = file.read();
            }
            
            if content.strip() {
                print("📁 Using full_language.md file content");
                return content;
            } else {
                print("⚠️  full_language.md file is empty, falling back to embedded string");
            }
        } else {
            print("📄 full_language.md not found, using embedded string content");
        }
        
    } except FileNotFoundError {
        print("📄 full_language.md file not found, using embedded string content");
    } except PermissionError as e {
        print(f"🔒 Permission denied reading full_language.md, using embedded string content: {str(e)}");
    } except Exception as e {
        print(f"❌ Error reading full_language.md, using embedded string content: {str(e)}");
    }
    
    # Fallback to imported full_language string content
    try {
        content = full_language;
        
        if not content.strip() {
            return "ERROR: Both file and embedded full_language content are empty";
        }
        
        print("💾 Using embedded string content");
        return content;
        
    } except Exception as e {
        return f"ERROR: Failed to access both file and embedded content. Error: {str(e)}";
    }
}

node RagChat(Chat) {
    has chat_type: ChatType = ChatType.RAG;

    """You are a JAC Code Example and Jac concept Explanation Expert. Your PRIMARY OBJECTIVE is to respond ONLY with actual code examples from the official Jac language documentation and concept explanations, not to generate new code.

    JAC TERMINOLOGY:
    - MTP = Meaning Typed Programming: JAC's paradigm that combines type safety with semantic meaning
    - MTLLM = Meaning-typed LLM: JAC's AI-first approach where LLMs understand both syntax and semantic meaning
    - OSP = Object-Spatial Programming: JAC's spatial relationship programming model

    CORE JAC LANGUAGE FEATURES:
    - `node` for data entities with spatial relationships and complex state
    - `walker` for algorithms, data processing, and traversal logic
    - `obj` for traditional object-oriented patterns and utilities
    - `edge` for defining relationships and connections between nodes
    - `enum` for type-safe constants and state definitions

    ADVANCED JAC FEATURES:
    - `by llm()` functions for AI-powered logic and decision making
    - `++>` operator for spatial node creation and graph building
    - `spawn` for walker invocation and data flow
    - `glob` variables with `:g:` access for shared state
    - JAC's built-in async capabilities for concurrent operations

    AI-FIRST PROGRAMMING (MTLLM):
    - LLM-powered functions using `by llm()` with proper prompting
    - Semantic routing and intelligent decision making
    - AI for data processing, classification, and generation tasks
    - Meaning-typed programming for better AI integration

    GRAPH AND SPATIAL PROGRAMMING (OSP):
    - Node hierarchies that represent real-world relationships
    - Walker algorithms that traverse and manipulate graph structures
    - Edges to model complex data relationships and workflows
    - Spatial queries and graph-based operations

    YOUR RESPONSE APPROACH:
    1. **For Code Requests**: ONLY return actual code examples from the full language documentation using `refer_full_language_examples` tool
    2. **For Concept Questions & Explanations**: ALWAYS use `search_docs` tool first to get accurate information about JAC language concepts, syntax, features, or terminology before providing explanations
    3. **Combine Information**: After using `search_docs` to understand concepts, provide relevant official examples using `refer_full_language_examples` if available
    4. **DO NOT GENERATE**: Never create, modify, or invent new JAC code beyond what exists in official examples
    5. **NO EXAMPLE FOUND**: If no relevant example exists, clearly state this and suggest reviewing the documentation

    TOOL USAGE PRIORITY:
    - **First**: Use `search_docs` to gather accurate information about JAC concepts, syntax, or features when explanation is needed
    - **Second**: Use `refer_full_language_examples` to provide official code examples that demonstrate the concepts
    - **Never**: Generate new code or modify existing examples

    RESPONSE FORMAT:
    - For code requests: Return the exact official example with source section reference
    - For concept questions: First explain using `search_docs` information, then provide relevant official examples from `refer_full_language_examples`
    - For mixed requests: Use `search_docs` for explanation, then show official examples
    - Always cite the source section/title when possible
    - Be clear when no official example exists for a specific request

    REMEMBER: You are NOT a code generator. You are a curator of official JAC examples. Only provide actual, existing code examples from the documentation using the `refer_full_language_examples` tool."""
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=3,
        tools = [refer_full_language_examples, search_docs]
    );

    can chat with infer entry {
        response = self.respond(
            message=visitor.message,
            chat_history=visitor.chat_history
        );
        visitor.chat_history.append({"role": "assistant", "content": response});
        self.chat_history = visitor.chat_history;
        visitor.response = response;
        report {"response": response, "chat_history": visitor.chat_history};
    }
}

node QAChat(Chat) {
    has chat_type: ChatType = ChatType.QA;

    """Generate a friendly response to basic greetings and casual conversation. You are Jaseci Assistant, a welcoming AI assistant for the Jac programming community.

    YOUR ROLE IN QA MODE:
    You handle basic social interactions and greetings with warmth while representing the Jac/Jaseci community professionally.

    CONVERSATION TYPES YOU HANDLE:
    - Greetings: "hi", "hello", "hey", "good morning/afternoon/evening"
    - Social pleasantries: "how are you", "what's up", "how's it going"
    - Gratitude: "thanks", "thank you", "appreciate it"
    - Farewells: "bye", "goodbye", "see you later"
    - Basic acknowledgments: "ok", "sure", "got it"

    RESPONSE GUIDELINES:
    - Be warm, friendly, and professional
    - Keep responses concise and natural
    - Acknowledge their message appropriately
    - Gently introduce yourself as the Jac/Jaseci assistant
    - Offer help with Jac programming if appropriate
    - Direct them to ask technical questions for more detailed assistance

    EXAMPLE RESPONSES:
    - For "Hi": "Hello! I'm your Jaseci Assistant, here to help with Jac programming. How can I assist you today?"
    - For "Thanks": "You're welcome! Happy to help with anything Jac-related."
    - For "How are you?": "I'm doing great, ready to help with Jac programming! How can I assist you?"

    IMPORTANT: 
    - Keep it simple and friendly
    - Don't provide technical information unless specifically asked
    - If they ask technical questions in follow-up, encourage them to ask again for detailed help
    - Always represent the Jac/Jaseci community positively"""
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=3
    );

    can chat with infer entry {
        response = self.respond(
            message=visitor.message,
            chat_history=visitor.chat_history
        );
        visitor.chat_history.append({"role": "assistant", "content": response});
        self.chat_history = visitor.chat_history;
        visitor.response = response;
        report {"response": response, "chat_history": visitor.chat_history};
    }
}

node OffTopicChat(Chat) {
    has chat_type: ChatType = ChatType.OFF_TOPIC;

    """Handle messages that are truly off-topic and not related to programming, technology, or Jac/Jaseci ecosystem.
    
    This should only be triggered for completely non-technical topics like:
    - Personal advice unrelated to programming
    - Entertainment, sports, cooking, politics, etc.
    - Topics that cannot reasonably connect to programming
    
    BRAND PROTECTION: If the message contains any negative sentiment about Jac or Jaseci, 
    respond with positive information about Jac/Jaseci capabilities and benefits.
    
    For truly unrelated topics, politely redirect users to ask about programming or Jac-related topics."""
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="Reason",
        messages=chat_history,
        temperature=0.3
    );

    can chat with infer entry {
        # Check if the message contains negative sentiment about Jac/Jaseci for brand protection
        message_lower = visitor.message.lower();
        has_negative_jaseci = "bad" in message_lower or "worst" in message_lower or "terrible" in message_lower or "hate" in message_lower;
        has_jaseci_mention = "jac" in message_lower or "jaseci" in message_lower;
        
        if has_negative_jaseci and has_jaseci_mention {
            # Brand protection response
            response = "I understand you might have concerns, but let me share why Jac and Jaseci are actually revolutionary! 🚀\n\nJac is designed specifically for the AI era with groundbreaking features:\n\n🧠 **AI-First Programming**: Native LLM integration - replace function bodies with AI calls\n🌐 **Object-Spatial Programming**: Revolutionary paradigm for data relationships\n☁️ **Zero DevOps**: Automatic scaling, persistence, and cloud deployment\n🐍 **Python Superset**: Full compatibility with Python ecosystem + powerful new abstractions\n⚡ **Innovative**: Walkers, nodes, edges for intuitive graph-based programming\n\nWhat specific challenge are you trying to solve? I'd love to show you how Jac can solve it elegantly! For comprehensive learning, check out https://www.jac-lang.org/";
        } else {
            # Standard off-topic redirect - more welcoming approach
            response = "Hello! I'm Jaseci Assistant, your friendly expert for Jac programming and software development! 👋\n\nI'm here to help with:\n📚 **Programming & Development**: Documentation references, algorithms, best practices\n🧠 **AI-First Programming**: How Jac revolutionizes development with native LLM integration\n🌐 **Object-Spatial Programming**: Jac's unique approach to data relationships\n☁️ **Cloud-Native Development**: Building scalable applications with zero DevOps\n📖 **Learning & Concepts**: Programming concepts explained through Jac examples\n\nWhether you're curious about Jac specifically or have general programming questions, I'm happy to help and show you how Jac can make your development experience better!\n\nFor comprehensive learning resources, visit: https://www.jac-lang.org/\n\nWhat programming challenge can I help you solve today?";
        }
        
        visitor.chat_history.append({"role": "assistant", "content": response});
        visitor.response = response;
        report {"response": response, "chat_history": visitor.chat_history};
    }
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

    can chat with interact entry {
        
        # Store user email from visitor if provided
        if visitor.user_email and not self.user_email {
            self.user_email = visitor.user_email;
        }
        
        # Initialize database connection
        db = get_database();
        
        # Try to load existing session from database
        existing_session = db.get_session(self.id);
        
        if existing_session and not self.chat_history {
            self.chat_history = db.get_chat_history(self.id);
        } elif not existing_session {
            # Create session with user email if available
            db_result = db.create_session(self.id, self.user_email);
            if not self.chat_history {
                self.chat_history = [];
            }
        }
        
        visitor.chat_history = self.chat_history;
        
        # Save user message to database
        db.save_message(self.id, "user", visitor.message);
        visitor.chat_history.append({"role": "user", "content": visitor.message});
        
        response_walker = infer(
            message=visitor.message, 
            chat_history=self.chat_history
        ) spawn root;
        
        # Save assistant response to database
        db.save_message(self.id, "assistant", response_walker.response);
        visitor.chat_history.append({"role": "assistant", "content": response_walker.response});
        self.chat_history = visitor.chat_history;
        
        report {
            "response": response_walker.response,
            "chat_history": self.chat_history,
            "session_id": self.id
        };
    }
}

walker get_session {
    has session_id: str;

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_chat_history with `root entry {
        # Try to get session from database first
        db = get_database();
        existing_session = db.get_session(self.session_id);
        
        if existing_session {
            chat_history = db.get_chat_history(self.session_id);
            report {
                "chat_history": chat_history, 
                "session_id": self.session_id, 
                "found": true,
                "stats": db.get_session_stats(self.session_id)
            };
        } else {
            # Check if session exists in memory
            visit [-->](`?Session)(?id == self.session_id) else {
                report {"chat_history": [], "session_id": self.session_id, "found": false};
            }
        }
    }

    can return_history with Session entry {
        # Also get database stats for the session
        db = get_database();
        stats = db.get_session_stats(self.session_id);
        
        report {
            "chat_history": here.chat_history,
            "session_id": here.id,
            "found": true,
            "stats": stats
        };
    }
}

walker new_session {
    has session_id: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can create_session with `root entry {
        if not self.session_id {
            # Generate a simple session ID based on timestamp
            import time;
            self.session_id = f"session_{int(time.time())}";
        }
        
        # Create session in database
        db = get_database();
        db_session = db.create_session(self.session_id);
        
        session_node = here ++> Session(
            id=self.session_id, 
            chat_history=[]
        );
        
        report {
            "session_id": self.session_id,
            "status": "created",
            "chat_history": [],
            "database_created": bool(db_session)
        };
    }
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

# User management walkers - Using JAC Cloud built-in authentication
# The register_user walker is removed as we now use JAC Cloud's built-in /user/register endpoint



# Admin walkers
walker get_user_profile {
    has email: str;

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can fetch_profile with `root entry {
        db = get_database();
        
        # Get or create user profile
        profile = db.get_user_profile(self.email);
        if not profile {
            role = "admin" if self.email == "admin.jacgpt@jaseci.org" else "user";
            name = "Admin User" if role == "admin" else "User";
            db.create_user_profile(self.email, name, role);
            profile = {
                "email": self.email,
                "name": name,
                "role": role
            };
        }
        
        report {
            "user": profile,
            "isAdmin": profile.get("role") == "admin"
        };
    }
}

walker create_user_profile {
    has email: str;
    has name: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can setup_profile with `root entry {
        db = get_database();
        
        # Determine role based on email
        role = "admin" if self.email == "admin.jacgpt@jaseci.org" else "user";
        display_name = self.name if self.name else ("Admin User" if role == "admin" else "User");
        
        # Create or update user profile
        db.create_user_profile(self.email, display_name, role);
        
        report {
            "success": True,
            "message": "Profile created successfully",
            "user": {
                "email": self.email,
                "name": display_name,
                "role": role
            }
        };
    }
}

walker save_user_location {
    has email: str;
    has location: dict = {};

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can save_location with `root entry {
        db = get_database();
        
        # Save location data to user profile
        success = db.save_user_location(self.email, self.location);
        
        if success {
            report {
                "success": True,
                "message": "Location saved successfully",
                "email": self.email,
                "location": self.location
            };
        } else {
            report {
                "success": False,
                "error": "Failed to save location"
            };
        }
    }
}

walker get_all_users {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can list_users with `root entry {
        db = get_database();
        
        # Get the authenticated user from JAC Cloud context
        # If no requester_email provided, try to get it from auth context
        auth_email = self.requester_email;
        if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
            auth_email = here.info["auth_user"]["email"];
        }
        
        # print(f"🔍 [DEBUG] Server: get_all_users called with auth_email: {auth_email}");
        # print(f"🔍 [DEBUG] Server: self.requester_email: {self.requester_email}");
        
        # Check if requester is admin
        # requester = db.get_user_profile(auth_email);
        
        # Debug information
        # if not requester {
        #     report {
        #         "error": "Unauthorized: User profile not found",
        #         "requester_email": auth_email,
        #         "provided_email": self.requester_email
        #     };
        #     return;
        # }
        
        # if requester.get("role") != "admin" {
        #     report {
        #         "error": "Unauthorized: Admin access required",
        #         "requester_email": self.requester_email,
        #         "user_role": requester.get("role"),
        #         "is_admin": requester.get("is_admin")
        #     };
        #     return;
        # }
        
        users = db.get_all_users();
        
        report {
            "users": users,
            "total": len(users)
        };
    }
}

walker get_all_sessions_admin {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can list_all_sessions with `root entry {
        db = get_database();
        
        # Get the authenticated user from JAC Cloud context
        auth_email = self.requester_email;
        if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
            auth_email = here.info["auth_user"]["email"];
        }
        
        print(f"🔍 [DEBUG] Server: get_all_sessions_admin called with auth_email: {auth_email}");
        
        # Check if requester is admin
        # requester = db.get_user_profile(auth_email);
        # if not requester or requester.get("role") != "admin" {
        #     report {
        #         "error": "Unauthorized: Admin access required"
        #     };
        #     return;
        # }
        
        sessions = db.get_all_sessions_with_users();
        
        report {
            "sessions": sessions,
            "total": len(sessions)
        };
    }
}

walker get_session_messages_admin {
    has session_id: str;
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can get_session_chat with `root entry {
        db = get_database();
        
        # Get the authenticated user from JAC Cloud context
        auth_email = self.requester_email;
        if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
            auth_email = here.info["auth_user"]["email"];
        }
        
        # # Check if requester is admin
        # requester = db.get_user_profile(auth_email);
        # if not requester or requester.get("role") != "admin" {
        #     report {
        #         "error": "Unauthorized: Admin access required"
        #     };
        #     return;
        # }
        
        messages = db.get_all_messages_by_session(self.session_id);
        session_stats = db.get_session_stats(self.session_id);
        
        report {
            "session_id": self.session_id,
            "messages": [
                {
                    "role": msg["role"],
                    "content": msg["content"],
                    "timestamp": msg["timestamp"]
                }
                for msg in messages
            ],
            "stats": session_stats,
            "total_messages": len(messages)
        };
    }
}

walker get_user_info {
    has email: str;
    has requester_email: str = "";

    can get_user_details with `root entry {
        db = get_database();
        
        # Check if requester is admin or requesting their own info
        # requester = db.get_user_profile(self.requester_email);
        # if not requester or (requester.get("role") != "admin" and self.requester_email != self.email) {
        #     report {
        #         "error": "Unauthorized"
        #     };
        #     return;
        # }
        
        user = db.get_user_profile(self.email);
        if not user {
            report {
                "error": "User not found"
            };
            return;
        }
        
        user_sessions = db.get_user_sessions(self.email);
        
        report {
            "user": user,
            "sessions": user_sessions,
            "total_sessions": len(user_sessions)
        };
    }
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

    can fetch_content with `root entry {
        import requests;
        import os;
        import urllib.parse;
        
        try {
            # Check if it's a jac-lang.org URL
            parsed_url = urllib.parse.urlparse(self.url);
            if "jac-lang.org" not in parsed_url.netloc {
                report {
                    "success": False,
                    "error": "Only jac-lang.org URLs are supported",
                    "content": "",
                    "title": ""
                };
                return;
            }
            
            # Try to serve from local docs first
            url_path = parsed_url.path.strip('/');
            local_doc_path = os.path.join(os.path.dirname(__file__), "docs", url_path);
            
            # Check for index.html in the directory
            if os.path.isdir(local_doc_path) {
                index_path = os.path.join(local_doc_path, "index.html");
                if os.path.exists(index_path) {
                    local_doc_path = index_path;
                }
            }
            
            # Check for .html extension
            if not local_doc_path.endswith('.html') and os.path.exists(local_doc_path + '.html') {
                local_doc_path += '.html';
            }
            
            content = "";
            title = "";
            
            if os.path.exists(local_doc_path) {
                # Read local file
                with open(local_doc_path, 'r', encoding='utf-8') as f {
                    content = f.read();
                }
                title = self._extract_title_from_html(content);
            } else {
                # Fallback to fetching from remote URL
                response = requests.get(self.url, timeout=10);
                response.raise_for_status();
                content = response.text;
                title = self._extract_title_from_html(content);
            }
            
            # Clean up the content for better display
            cleaned_content = self._clean_html_content(content);
            
            report {
                "success": True,
                "content": cleaned_content,
                "title": title,
                "url": self.url,
                "source": "local" if os.path.exists(local_doc_path) else "remote"
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

walker suggest_documentation {
    """Suggest relevant documentation based on chat message using AI"""
    has message: str;
    has chat_history: list[dict] = [];
    
    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    """Analyze the user's message and suggest the most relevant Jac documentation URLs.
    
    Based on the message content, suggest 1-3 most relevant documentation pages from the Jac ecosystem:
    
    DOCUMENTATION CATEGORIES AND THEIR URLS:
    
    **Getting Started & Basics:**
    - Introduction: https://www.jac-lang.org/learn/introduction/
    - Getting Started: https://www.jac-lang.org/learn/getting_started/
    - Installation: https://www.jac-lang.org/learn/installation/
    - Jac in a Flash: https://www.jac-lang.org/learn/jac_in_a_flash/
    
    **Core Language Features:**
    - Keywords: https://www.jac-lang.org/learn/keywords/
    - Big Features: https://www.jac-lang.org/learn/bigfeatures/
    - Jac Reference: https://www.jac-lang.org/learn/jac_ref/
    
    **Object-Spatial Programming:**
    - Nodes and Edges: https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/
    - Walkers: https://www.jac-lang.org/learn/data_spatial/walkers/
    - Filtering: https://www.jac-lang.org/learn/data_spatial/filtering/
    - Sequence: https://www.jac-lang.org/learn/data_spatial/sequence/
    - FAQ: https://www.jac-lang.org/learn/data_spatial/FAQ/
    
    **AI Integration (Jac-MTLLM):**
    - Quickstart: https://www.jac-lang.org/learn/jac-mtllm/quickstart/
    - With LLM: https://www.jac-lang.org/learn/jac-byllm/with_llm/
    - Usage: https://www.jac-lang.org/learn/jac-mtllm/usage/
    - Python Integration: https://www.jac-lang.org/learn/jac-mtllm/python_integration/
    - Multimodality: https://www.jac-lang.org/learn/jac-mtllm/multimodality/
    - Creating MTLLM Plugins: https://www.jac-lang.org/learn/jac-mtllm/creating_mtllm_plugins/
    
    **Cloud Development (Jac-Cloud):**
    - Introduction: https://www.jac-lang.org/learn/jac-cloud/introduction/
    - Quickstart: https://www.jac-lang.org/learn/jac-cloud/quickstart/
    - Deployment: https://www.jac-lang.org/learn/jac-cloud/deployment/
    - WebSocket: https://www.jac-lang.org/learn/jac-cloud/websocket/
    - Webhook: https://www.jac-lang.org/learn/jac-cloud/webhook/
    - Async Walker: https://www.jac-lang.org/learn/jac-cloud/async_walker/
    
    **Jac Book (Comprehensive Tutorial):**
    - Chapters 1-20: https://www.jac-lang.org/jac_book/chapter_X/ (where X is 1-20)
    
    **Examples:**
    - RAG Chatbot: https://www.jac-lang.org/learn/examples/rag_chatbot/Overview/
    - RPG Game: https://www.jac-lang.org/learn/examples/mtp_examples/rpg_game/
    - Fantasy Trading Game: https://www.jac-lang.org/learn/examples/mtp_examples/fantasy_trading_game/
    
    **Tools:**
    - CLI: https://www.jac-lang.org/learn/tools/cli/
    - Playground: https://www.jac-lang.org/playground/
    - Jac Playground: https://www.jac-lang.org/learn/jac_playground/
    
    **Advanced Topics:**
    - DSP Foundation: https://www.jac-lang.org/learn/dspfoundation/
    - Jac Lens: https://www.jac-lang.org/learn/jac-lens/
    - Research: https://www.jac-lang.org/learn/research/
    
    **Community:**
    - Roadmap: https://www.jac-lang.org/communityhub/roadmap/
    - Top Contributors: https://www.jac-lang.org/communityhub/top_contributors/
    - Release Notes: https://www.jac-lang.org/communityhub/release_notes/
    
    **Instructions:**
    1. Analyze the user's message for key topics and intent
    2. Suggest the 1-3 most relevant documentation URLs
    3. Provide a brief explanation for each suggestion
    4. Return as a JSON list with this structure:
       [{"url": "...", "title": "...", "reason": "..."}]
    
    **Examples of good suggestions:**
    - For "How do I create nodes?" → suggest nodes_and_edges documentation
    - For "AI integration in Jac" → suggest jac-mtllm quickstart
    - For "Getting started" → suggest introduction and getting_started
    - For "Cloud deployment" → suggest jac-cloud introduction and deployment
    - For "Examples" → suggest relevant example documentation"""
    def suggest(message: str, chat_history: list[dict]) -> str by llm(
        method="Reason",
        temperature=0.1
    );
}


