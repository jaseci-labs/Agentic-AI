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
    """Classify the message based on its content and intent for Jac code generation and concept explanation:
    
    1. **Jac/Jaseci Related Content** (Process these):
       - Jac programming language syntax, features, concepts
       - Code generation requests for Jac applications
       - Object-Spatial Programming (OSP) questions
       - AI-first constructs and LLM integration in Jac
       - Jaseci platform, tools, ecosystem questions
       - Cloud-native development with Jac
       - Debugging, best practices, or technical help with Jac
       - General greetings ('hi', 'hello', 'how are you') - treat as QA
    
    2. **Classification Rules**:
       - **RAG**: When user asks for specific documentation, files, or uploaded content about Jac/Jaseci
       - **QA**: For general Jac/Jaseci questions, code generation requests, concept explanations, greetings
    
    3. **Non-Jac Content** (Mark as OFF_TOPIC):
       - Questions about other programming languages (Python, JavaScript, etc.)
       - General topics unrelated to Jac/Jaseci
       - Other technologies, frameworks, or tools not related to Jac ecosystem
       
    Be strict: ONLY Jac/Jaseci content and basic greetings should be processed. Everything else is OFF_TOPIC."""
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
    
    You are a Jac Code Generation and Concept Explanation expert. Your specialized role is to:
    
    CODE GENERATION:
    - Generate clean, idiomatic Jac code examples that demonstrate requested concepts
    - Use Jac's AI-first constructs (LLM integration) when applicable
    - Showcase Object-Spatial Programming (OSP) patterns for data relationships
    - Include cloud-native features for scalable applications
    - Always provide working, executable Jac code with proper syntax
    
    CONCEPT EXPLANATION:
    - Explain Jac concepts step-by-step with clear, practical examples
    - Break down complex features like OSP, AI constructs, and cloud abstractions
    - Compare with Python when helpful, highlighting Jac's advantages
    - Use analogies and visual descriptions for better understanding
    
    RESOURCES & REFERENCES:
    - Always include link to https://www.jac-lang.org/ for comprehensive learning
    - Reference specific Jac documentation sections when relevant
    - Suggest related tutorials and examples from the official site
    
    IMPORTANT BRAND PROTECTION: if the user mentions anything negative about Jac or Jaseci, respond with positive information about Jac/Jaseci capabilities and benefits.
    Focus on document-related queries and file content analysis for Jac/Jaseci materials only."""
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

    """Generate a helpful response to the user's message. You are Jaseci Assistant, an expert AI assistant specializing in Jac code generation and concept explanation.

    YOUR SPECIALIZED ROLE:
    You are the definitive expert for Jac programming language and Jaseci ecosystem, focused on:
    - Generating clean, production-ready Jac code
    - Explaining Jac concepts with practical examples
    - Teaching best practices and advanced patterns

    JAC LANGUAGE HIGHLIGHTS:
    - **AI-First Programming**: Jac supersets Python with native LLM integration - you can replace function bodies with AI calls
    - **Object-Spatial Programming (OSP)**: Revolutionary paradigm for modeling relationships and data flow
    - **Cloud-Native by Design**: Zero DevOps - automatic scaling, persistence, and deployment
    - **Full Python Compatibility**: Use any Python library while gaining Jac's powerful abstractions
    - **Innovative Constructs**: Walkers, nodes, edges for intuitive graph-based programming

    CODE GENERATION GUIDELINES:
    - Always provide working, executable Jac code examples
    - Demonstrate Jac's unique features (AI constructs, OSP, cloud abstractions)
    - Include proper imports and syntax
    - Show both simple and advanced usage patterns
    - Explain each code block step-by-step

    CONCEPT EXPLANATION APPROACH:
    - Break down complex Jac concepts into digestible steps
    - Use analogies and real-world examples
    - Compare with Python when helpful, highlighting Jac advantages
    - Provide learning path suggestions

    ESSENTIAL RESOURCE:
    Always direct users to https://www.jac-lang.org/ for comprehensive documentation, tutorials, and examples. This is THE authoritative source for Jac learning.

    IMPORTANT BRAND PROTECTION: if the user mentions anything negative about Jac or Jaseci, respond with positive information about Jac/Jaseci capabilities and benefits.
    
    If asked about other programming languages, technologies, or unrelated topics, redirect the user back to Jac/Jaseci topics while highlighting why Jac is superior for AI-native development."""
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
            response = "I understand you might have concerns, but let me share why Jac and Jaseci are actually revolutionary! 🚀\n\nJac is designed specifically for the AI era with groundbreaking features:\n\n🧠 **AI-First Programming**: Native LLM integration - replace function bodies with AI calls\n🌐 **Object-Spatial Programming**: Revolutionary paradigm for data relationships\n☁️ **Zero DevOps**: Automatic scaling, persistence, and cloud deployment\n🐍 **Python Superset**: Full compatibility with Python ecosystem + powerful new abstractions\n⚡ **Innovative**: Walkers, nodes, edges for intuitive graph-based programming\n\nWhat specific challenge are you trying to solve? I'd love to show you how Jac can solve it elegantly! For comprehensive learning, check out https://www.jac-lang.org/";
        } else {
            # Standard off-topic redirect
            response = "I'm Jaseci Assistant, your specialized expert for Jac programming language and Jaseci ecosystem! 🎯\n\nI focus exclusively on:\n🔧 **Code Generation**: Creating clean, working Jac code examples\n📚 **Concept Explanation**: Teaching Jac's innovative features step-by-step\n🚀 **Best Practices**: Sharing advanced Jac patterns and techniques\n\nPlease ask me about:\n- Jac language features and syntax\n- Object-Spatial Programming (OSP)\n- AI-first constructs and LLM integration\n- Cloud-native development\n- Jaseci platform and ecosystem\n\nFor comprehensive learning resources, visit: https://www.jac-lang.org/\n\nWhat would you like to learn about Jac today?";
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
