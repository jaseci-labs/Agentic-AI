import sys;
import os;
import requests;
import from mtllm.llm {Model}
import from dotenv {load_dotenv}

with entry {
    load_dotenv(override=True);
}

glob llm = Model(model_name='gpt-4o-mini', verbose=True, api_key=os.getenv("OPENAI_API_KEY"));

"""ChatType enum defines the types of chat interactions. ChatType must be one of:
- RAG: For interactions that require document retrieval.
- QA: For interactions that does not require document retrieval.
"""
enum ChatType {
    RAG = "RAG",
    QA = "QA"
}

node Router {
    """Classify the message as RAG or QA based on whether it requires document retrieval.
    If the user asks about specific documents, files, or uploaded content, classify as RAG.
    Otherwise, classify as QA for general questions."""
    def classify(message: str) -> ChatType by llm(method="Reason", temperature=0.3);
}

node Chat {
    has chat_type: ChatType;
}

walker infer {
    has message: str;
    has chat_history: list[dict];

    can init_router with `root entry {
        visit [-->](`?Router) else {
            router_node = here ++> Router();
            router_node ++> RagChat();
            router_node ++> QAChat();
            visit router_node;
        }
    }

    can route with Router entry {
        classification = here.classify(message = self.message);
        print("Routing message:", self.message, "to chat type:", classification);
        visit [-->](`?Chat)(?chat_type==classification);
    }
}

node RagChat(Chat) {
    has chat_type: ChatType = ChatType.RAG;

    """Generate a helpful response to the user's message about documents or uploaded content.
    Focus on document-related queries and file content analysis."""
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

node QAChat(Chat) {
    has chat_type: ChatType = ChatType.QA;

    """Generate a helpful response to the user's message. You are Jaseci Assistant, an expert AI assistant for the Jac programming language and Jaseci ecosystem.

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

    Always be helpful, accurate, and provide practical examples when possible."""
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
        visitor.chat_history = self.chat_history;
        visitor.chat_history.append({"role": "user", "content": visitor.message});
        
        response = infer(
            message=visitor.message, 
            chat_history=self.chat_history
        ) spawn root;
        
        visitor.chat_history.append({"role": "assistant", "content": response.response});
        self.chat_history = visitor.chat_history;
        
        report {
            "response": response.response,
            "chat_history": self.chat_history,
            "session_id": self.id
        };
    }
}

walker get_session {
    has session_id: str;

    can get_chat_history with `root entry {
        visit [-->](`?Session)(?id == self.session_id) else {
            report {"chat_history": [], "session_id": self.session_id, "found": false};
        }
    }

    can return_history with Session entry {
        report {
            "chat_history": here.chat_history,
            "session_id": here.id,
            "found": true
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
        
        session_node = here ++> Session(
            id=self.session_id, 
            chat_history=[]
        );
        
        report {
            "session_id": self.session_id,
            "status": "created",
            "chat_history": []
        };
    }
}
