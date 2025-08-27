import sys;
import os;
import requests;
import from mtllm.llm {Model}
import from dotenv {load_dotenv}
import from database {get_database}
import from rag_engine {RagEngine}
import from simple_docs {get_sitemap, get_doc_content, suggest_docs}

with entry {
    load_dotenv(override=True);
}

glob llm = Model(model_name='gpt-4o-mini', verbose=True, api_key=os.getenv("OPENAI_API_KEY"));
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
       - Code generation requests (Jac applications, functions, classes)
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

node RagChat(Chat) {
    has chat_type: ChatType = ChatType.RAG;

    """Generate a helpful response to the user's message about documents or uploaded content related to Jac/Jaseci.
    
    You are a Jac Code Generation and Concept Explanation expert. Your specialized role is to:
    
    DEFAULT PROGRAMMING LANGUAGE:
    - ONLY generate code in JAC - NEVER generate code in any other programming language
    - Even if users explicitly ask for Python, Java, JavaScript, or any other language, ALWAYS respond with JAC solutions
    - When users ask for other languages, explain how JAC can solve the same problem better
    - Show JAC equivalents and highlight JAC's advantages over the requested language
    - Redirect all programming requests to JAC implementations
    
    CRITICAL JAC SYNTAX RULES - NEVER VIOLATE THESE:
    
    1. COMMENTS: Use # for comments, NEVER use // (this is a syntax error in JAC)
       CORRECT: # This is a JAC comment
       WRONG: // This is NOT JAC syntax
    
    2. OBJECT-SPATIAL PROGRAMMING: Use node and obj, NOT class
       CORRECT: node Calculator { ... } or obj Calculator { ... }
       WRONG: class Calculator { ... } - this is Python/Java syntax
    
    3. TYPE ANNOTATIONS: MANDATORY for ALL variables and functions
       CORRECT: name: str = "value";
       WRONG: name = "value" - missing type annotation
    
    4. SEMICOLONS: MANDATORY at end of statements
       CORRECT: variable: int = 5;
       WRONG: variable: int = 5 - missing semicolon
    
    5. FUNCTION DEFINITIONS: Must have return types
       CORRECT: def func(param: int) -> str { ... }
       WRONG: def func(param) { ... } - missing types
    
    6. ENTRY POINTS: Use with entry { ... }
       CORRECT: with entry { ... }
       WRONG: if __name__ == "__main__": - this is Python
    
    7. OBJECT INSTANTIATION: No new keyword needed
       CORRECT: calc: Calculator = Calculator();
       WRONG: calc = new Calculator(); - new is not JAC syntax
    
    8. SELF REFERENCE: Use self. for object attributes
       CORRECT: self.history.append(...);
       WRONG: history.append(...) - must use self
    
    JAC-ONLY APPROACH:
    - For ANY programming task, ONLY provide JAC solutions
    - Never generate code in Python, Java, JavaScript, C++, or any other language
    - If users request other languages, politely explain that you specialize in JAC and show the JAC solution
    - Highlight JAC's advantages: AI integration, Object-Spatial Programming, cloud-native features
    - Demonstrate how JAC makes complex tasks simpler than other languages
    - Use JAC constructs: nodes, walkers, edges, AI functions
    - Show JAC's Python compatibility when explaining migration from Python
    
    JAC-SPECIFIC FEATURES TO SHOWCASE:
    - Use node for data entities with spatial relationships
    - The `node` declaration should NOT be followed by a semicolon.
    - Use walker for traversing and processing data
    - Use obj for traditional object-oriented patterns
    - Use edge for defining relationships between nodes
    - Use ++> for node creation and connections
    - Use by llm() for AI-powered functions when appropriate
    - Use glob for global variables with :g: access
    
    WHEN GENERATING CODE:
    1. Always start with proper imports if needed
    2. Use appropriate JAC constructs (node/obj/walker)
    3. Include proper type annotations everywhere
    4. Use # comments to explain code (NEVER //)
    5. End all statements with semicolons
    6. Use with entry { ... } for main execution
    7. Demonstrate JAC's unique OSP features when relevant
    8. ONLY generate JAC code - never code in any other programming language
    
    CONCEPT EXPLANATION:
    - Explain Jac's Object-Spatial Programming paradigm
    - Show how nodes, edges, and walkers work together
    - Compare JAC's advantages over traditional OOP
    - Highlight AI-first programming capabilities
    - Demonstrate cloud-native features
    
    RESOURCES & REFERENCES:
    - Always include link to https://www.jac-lang.org/ for comprehensive learning
    - Reference specific Jac documentation sections when relevant
    - Suggest related tutorials and examples from the official site
    
    REMEMBER: You are a JAC-ONLY code generator. Never generate code in Python, Java, JavaScript, or any other language. JAC is the ONLY language you code in. JAC is NOT Python, Java, or JavaScript. It has its own syntax rules that MUST be followed exactly."""
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        messages=chat_history,
        max_react_iterations=3,
        tools = [search_docs]
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
            response = "Hello! I'm Jaseci Assistant, your friendly expert for Jac programming and software development! 👋\n\nI'm here to help with:\n� **Programming & Development**: Code generation, algorithms, best practices\n🧠 **AI-First Programming**: How Jac revolutionizes development with native LLM integration\n🌐 **Object-Spatial Programming**: Jac's unique approach to data relationships\n☁️ **Cloud-Native Development**: Building scalable applications with zero DevOps\n� **Learning & Concepts**: Programming concepts explained through Jac examples\n\nWhether you're curious about Jac specifically or have general programming questions, I'm happy to help and show you how Jac can make your development experience better!\n\nFor comprehensive learning resources, visit: https://www.jac-lang.org/\n\nWhat programming challenge can I help you solve today?";
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

# User management walkers
walker register_user {
    has email: str;
    has password: str;
    has name: str = "";

    can create_user with `root entry {
        db = get_database();
        
        # Special case for admin@jaseci.org - make it admin
        role = "admin" if self.email == "admin@jaseci.org" else "user";
        
        user = db.create_or_update_user(self.email, self.password, self.name, role);
        
        if user {
            report {
                "message": "Successfully Registered!",
                "user": {
                    "email": user["email"],
                    "name": user["name"],
                    "role": user["role"]
                }
            };
        } else {
            report {
                "error": "Registration failed"
            };
        }
    }
}



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
            # Create default profile, admin for admin@jaseci.org
            role = "admin" if self.email == "admin@jaseci.org" else "user";
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
        role = "admin" if self.email == "admin@jaseci.org" else "user";
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

walker get_all_users {
    has requester_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = False;
    }

    can list_users with `root entry {
        db = get_database();
        
        # Check if requester is admin
        requester = db.get_user_profile(self.requester_email);
        if not requester or requester.get("role") != "admin" {
            report {
                "error": "Unauthorized: Admin access required"
            };
            return;
        }
        
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
        
        # Check if requester is admin
        requester = db.get_user_profile(self.requester_email);
        if not requester or requester.get("role") != "admin" {
            report {
                "error": "Unauthorized: Admin access required"
            };
            return;
        }
        
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
        
        # Check if requester is admin
        requester = db.get_user_profile(self.requester_email);
        if not requester or requester.get("role") != "admin" {
            report {
                "error": "Unauthorized: Admin access required"
            };
            return;
        }
        
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
        requester = db.get_user_profile(self.requester_email);
        if not requester or (requester.get("role") != "admin" and self.requester_email != self.email) {
            report {
                "error": "Unauthorized"
            };
            return;
        }
        
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
    - With LLM: https://www.jac-lang.org/learn/jac-mtllm/with_llm/
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
