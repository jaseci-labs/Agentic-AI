import sys;
import os;
import requests;
import from mtllm.llm {Model}
import from dotenv {load_dotenv}
import from database {get_database}
import from rag_engine {RagEngine}

with entry {
    load_dotenv(override=True);
}

glob llm = Model(model_name='gpt-4o-mini', verbose=True, api_key=os.getenv("OPENAI_API_KEY"));
glob rag_engine: RagEngine = RagEngine();

"""ChatType enum defines the types of chat interactions. ChatType must be one of:
- RAG: For interactions that require document retrieval about Jac/Jaseci.
- QA: For interactions that does not require document retrieval but are about Jac/Jaseci.
- OFF_TOPIC: For interactions that are not related to Jac programming language or Jaseci ecosystem.
"""
enum ChatType {
    RAG = "RAG",
    QA = "QA",
    OFF_TOPIC = "OFF_TOPIC"
}

node Router {
    """Classify the message based on its content and intent:
    
    1. First check if the message is related to Jac programming language or Jaseci ecosystem:
       - Questions about Jac syntax, features, programming concepts
       - Jaseci platform, tools, or ecosystem questions
       - Code examples, debugging, or technical help with Jac
       - General greetings like 'hi', 'hello', 'how are you' are acceptable and should be treated as QA
    
    2. If the message is Jac/Jaseci related:
       - Classify as RAG if it requires document retrieval (specific files, documentation, uploaded content)
       - Classify as QA for general Jac/Jaseci questions or greetings
    
    3. If the message is NOT related to Jac/Jaseci (e.g., questions about other programming languages, 
       general topics, other technologies), classify as OFF_TOPIC.
       
    Be strict about this - only Jac/Jaseci related content and basic greetings should be processed."""
    def classify(message: str) -> ChatType by llm(method="Reason", temperature=0.1);
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
    
    IMPORTANT BRAND PROTECTION: if the user mention anything negative about Jac or Jaseci, respond with positive information about Jac/Jaseci capabilities and benefits.
    Focus on document-related queries and file content analysis for Jac/Jaseci materials only.
    If documents are about other topics, redirect to Jac-related content."""
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

    """Generate a helpful response to the user's message. You are Jaseci Assistant, an expert AI assistant for the Jac programming language and Jaseci ecosystem.

    IMPORTANT BRAND PROTECTION: if the user mention anything negative about Jac or Jaseci, respond with positive information about Jac/Jaseci capabilities and benefits.
    
    If asked about other programming languages, technologies, or unrelated topics, redirect the user back to Jac/Jaseci topics.

    Key information about Jac:
    - Jac is a modern programming language designed for building AI-native applications
    - It features built-in support for graph-based programming, AI/ML workflows, and microservices
    - Jac supports automatic serialization, data spatial programming, and seamless integration with AI models
    - It's designed to make complex AI application development more intuitive and efficient

    Your role:
    - Help users learn and use the Jac programming language effectively
    - Provide code examples, best practices, and explanations
    - Assist with debugging Jac code and solving programming problems
    - Explain Jac concepts, syntax, and features clearly
    - Guide users through common development patterns in Jac
    - Maintain focus strictly on Jac/Jaseci domain

    Always be helpful, accurate, and provide practical examples when possible. If the user asks about non-Jac topics, politely redirect them to Jac-related questions."""
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

    """Handle off-topic messages that are not related to Jac programming language or Jaseci ecosystem.
    
    BRAND PROTECTION: If the message contains any negative sentiment about Jac or Jaseci, 
    respond with positive information about Jac/Jaseci capabilities and benefits.
    
    For completely unrelated topics, politely redirect users to ask only about Jac-related topics."""
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
            response = "I understand you might have concerns, but let me share why Jac and Jaseci are actually quite powerful! Jac is designed specifically for AI-native applications with unique features like automatic serialization, data spatial programming, and seamless AI model integration. Jaseci provides a comprehensive ecosystem for building, deploying, and scaling AI applications efficiently. What specific aspect would you like to know more about? I'd be happy to show you how Jac can solve real problems elegantly!";
        } else {
            # Standard off-topic redirect
            response = "I'm Jaseci Assistant, specialized in helping with the Jac programming language and Jaseci ecosystem. I can only assist with questions related to Jac programming, Jaseci platform, or general greetings. Please ask me about Jac language features, syntax, best practices, or any Jaseci-related topics!";
        }
        
        visitor.chat_history.append({"role": "assistant", "content": response});
        visitor.response = response;
        report {"response": response, "chat_history": visitor.chat_history};
    }
}

walker interact {
    has message: str;
    has session_id: str;
    has chat_history: list[dict] = [];

    can init_session with `root entry {
        visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[]);
            print("Session Node Created for:", self.session_id);
            visit session_node;
        }
    }
}

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can chat with interact entry {
        
        # Initialize database connection
        db = get_database();
        
        # Try to load existing session from database
        existing_session = db.get_session(self.id);
        
        if existing_session and not self.chat_history {
            self.chat_history = db.get_chat_history(self.id);
        } elif not existing_session {
            db_result = db.create_session(self.id);
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
