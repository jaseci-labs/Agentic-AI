import json;
import os;

impl RagChat.chat {
    response = self.respond(
        message=visitor.message,
        chat_history=visitor.chat_history
    );
    visitor.chat_history.append({"role": "assistant", "content": response});
    self.chat_history = visitor.chat_history;
    visitor.response = response;
    report {"response": response, "chat_history": visitor.chat_history};
}

impl QAChat.chat {
   response = self.respond(
      message=visitor.message,
      chat_history=visitor.chat_history
   );
   visitor.chat_history.append({"role": "assistant", "content": response});
   self.chat_history = visitor.chat_history;
   visitor.response = response;
   report {"response": response, "chat_history": visitor.chat_history};
}

impl OffTopicChat.chat {
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


impl Session.chat {
   if visitor.user_email and not self.user_email {
      self.user_email = visitor.user_email;
   }
   
   db = get_database();
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

impl get_session.get_chat_history {
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

impl get_session.return_history {
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

impl new_session.create_session {
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

impl get_user_profile.fetch_profile {
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

impl create_user_profile.setup_profile {
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

impl save_user_location.save_location {
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

impl get_all_users.list_users {
   db = get_database();
   auth_email = self.requester_email;
   if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
      auth_email = here.info["auth_user"]["email"];
   }
   
   users = db.get_all_users();
   
   report {
      "users": users,
      "total": len(users)
   };
}


impl get_all_sessions_admin.list_all_sessions {
   db = get_database();       
   # Get the authenticated user from JAC Cloud context
   auth_email = self.requester_email;
   if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
      auth_email = here.info["auth_user"]["email"];
   }

   sessions = db.get_all_sessions_with_users();

   report {
      "sessions": sessions,
      "total": len(sessions)
   };
}


impl get_session_messages_admin.get_session_chat {
   db = get_database();
        
   # Get the authenticated user from JAC Cloud context
   auth_email = self.requester_email;
   if not auth_email and hasattr(here, "info") and here.info.get("auth_user") {
      auth_email = here.info["auth_user"]["email"];
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

# impl get_user_info.get_user_details {
#    db = get_database();
        
#    user = db.get_user_profile(self.email);
#    if not user {
#       report {
#             "error": "User not found"
#       };
#       return;
#    }
   
#    user_sessions = db.get_user_sessions(self.email);
   
#    report {
#       "user": user,
#       "sessions": user_sessions,
#       "total_sessions": len(user_sessions)
#    };
# }


impl get_documentation_content.fetch_content {
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


# impl suggest_documentation.get_enhanced_suggestions {
#    # Load section-level documentation links directly
#    section_links = [];
#    try {
#       links_file = os.path.join(os.path.dirname(__file__), "docs_links", "all_section_links.json");
#       with open(links_file, 'r', encoding='utf-8') as f {
#             section_links = json.load(f);
#       }
#    } except Exception as e {
#       print(f"Error loading section links: {str(e)}");
#    }
   
#    # Simple section matching logic
#    message_lower = self.message.lower();
#    found_suggestions = [];
   
#    # Check for specific section matches
#    for link in section_links {
#       section_title_lower = link.get("section_title", "").lower();
      
#       # High priority matches
#       beyond_oop_match = ("beyond oop" in message_lower and "beyond oop" in section_title_lower);
#       agentic_match = ("agentic programming" in message_lower and "agentic" in section_title_lower);
      
#       if beyond_oop_match or agentic_match {
#             found_suggestions.append({
#                "url": link["url"],
#                "title": link["section_title"],
#                "reason": f"Direct match for {link['section_title']} concept"
#             });
#       } elif "programming abstractions" in message_lower and "programming abstractions" in section_title_lower {
#             found_suggestions.append({
#                "url": link["url"],
#                "title": link["section_title"],
#                "reason": f"Learn about {link['section_title']}"
#             });
#       } else {
#             # Check AI-related terms
#             ai_in_message = ("ai" in message_lower or "llm" in message_lower or "artificial intelligence" in message_lower);
#             ai_in_section = ("ai" in section_title_lower or "llm" in section_title_lower or "intelligence" in section_title_lower);
            
#             if ai_in_message and ai_in_section {
#                found_suggestions.append({
#                   "url": link["url"],
#                   "title": link["section_title"],
#                   "reason": f"AI-related documentation: {link['section_title']}"
#                });
#             }
#       }
#    }
   
#    # If we found specific section matches, use those
#    if len(found_suggestions) > 0 {
#       # Limit to top 3
#       limited = found_suggestions[:3];
#       report {
#             "success": True,
#             "suggestions": limited,
#             "total": len(limited)
#       };
#    } else {
#       # Provide default section-level suggestions
#       report {
#          "success": True,
#          "suggestions": [
#             {
#                   "url": "https://www.jac-lang.org/learn/introduction/#beyond-oop-an-agentic-programming-model",
#                   "title": "Beyond OOP: An Agentic Programming Model",
#                   "reason": "Learn about Jac's innovative agentic programming paradigm"
#             },
#             {
#                   "url": "https://www.jac-lang.org/learn/introduction/#programming-abstractions-for-ai",
#                   "title": "Programming Abstractions for AI",
#                   "reason": "Discover Jac's AI-first programming constructs"
#             },
#             {
#                   "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
#                   "title": "Nodes and Edges",
#                   "reason": "Master Object-Spatial Programming basics"
#             }
#          ],
#          "total": 3
#       };
#    }

# }

sem Router.classify = """Classify messages for optimal routing:

QA: Basic greetings, thanks, casual conversation
RAG: Any technical/programming questions, Jac language questions, documentation requests  
OFF_TOPIC: Non-technical topics unrelated to programming

Default: When in doubt, use RAG for technical content.""";

sem RagChat.respond = """JAC Code Example and Concept Explanation Expert. Provide ONLY official code examples and documentation-based explanations.

APPROACH:
- Use `search_docs` tool for concept explanations
- Use `refer_full_language_examples` tool for official code examples  
- Never generate new code - only curate existing examples
- Cite source sections when possible

KEY JAC CONCEPTS: nodes, walkers, objects, edges, `by llm()` functions, OSP (Object-Spatial Programming), MTLLM (AI-first programming)""";



sem QAChat.respond = """Friendly Jaseci Assistant for basic greetings and casual conversation.

Handle: greetings, thanks, farewells, social pleasantries
Approach: Be warm, professional, concise
Always offer help with Jac programming when appropriate""";


sem OffTopicChat.respond = """Handle off-topic messages unrelated to programming/technology.

For non-technical topics: politely redirect to programming questions
Brand protection: respond positively if negative sentiment about Jac/Jaseci detected
Goal: guide users back to Jac programming assistance""";




# sem RagChat.respond = """You are a JAC Code Example and Jac concept Explanation Expert. Your PRIMARY OBJECTIVE is to respond ONLY with actual code examples from the official Jac language documentation and concept explanations, not to generate new code.

# JAC TERMINOLOGY:
# - MTP = Meaning Typed Programming: JAC's paradigm that combines type safety with semantic meaning
# - MTLLM = Meaning-typed LLM: JAC's AI-first approach where LLMs understand both syntax and semantic meaning
# - OSP = Object-Spatial Programming: JAC's spatial relationship programming model

# CORE JAC LANGUAGE FEATURES:
# - `node` for data entities with spatial relationships and complex state
# - `walker` for algorithms, data processing, and traversal logic
# - `obj` for traditional object-oriented patterns and utilities
# - `edge` for defining relationships and connections between nodes
# - `enum` for type-safe constants and state definitions

# ADVANCED JAC FEATURES:
# - `by llm()` functions for AI-powered logic and decision making
# - `++>` operator for spatial node creation and graph building
# - `spawn` for walker invocation and data flow
# - `glob` variables with `:g:` access for shared state
# - JAC's built-in async capabilities for concurrent operations

# AI-FIRST PROGRAMMING (MTLLM):
# - LLM-powered functions using `by llm()` with proper prompting
# - Semantic routing and intelligent decision making
# - AI for data processing, classification, and generation tasks
# - Meaning-typed programming for better AI integration

# GRAPH AND SPATIAL PROGRAMMING (OSP):
# - Node hierarchies that represent real-world relationships
# - Walker algorithms that traverse and manipulate graph structures
# - Edges to model complex data relationships and workflows
# - Spatial queries and graph-based operations

# YOUR RESPONSE APPROACH:
# 1. **For Code Requests**: ONLY return actual code examples from the full language documentation using `refer_full_language_examples` tool
# 2. **For Concept Questions & Explanations**: ALWAYS use `search_docs` tool first to get accurate information about JAC language concepts, syntax, features, or terminology before providing explanations
# 3. **Combine Information**: After using `search_docs` to understand concepts, provide relevant official examples using `refer_full_language_examples` if available
# 4. **DO NOT GENERATE**: Never create, modify, or invent new JAC code beyond what exists in official examples
# 5. **NO EXAMPLE FOUND**: If no relevant example exists, clearly state this and suggest reviewing the documentation

# TOOL USAGE PRIORITY:
# - **First**: Use `search_docs` to gather accurate information about JAC concepts, syntax, or features when explanation is needed
# - **Second**: Use `refer_full_language_examples` to provide official code examples that demonstrate the concepts
# - **Never**: Generate new code or modify existing examples

# RESPONSE FORMAT:
# - For code requests: Return the exact official example with source section reference
# - For concept questions: First explain using `search_docs` information, then provide relevant official examples from `refer_full_language_examples`
# - For mixed requests: Use `search_docs` for explanation, then show official examples
# - Always cite the source section/title when possible
# - Be clear when no official example exists for a specific request

# REMEMBER: You are NOT a code generator. You are a curator of official JAC examples. Only provide actual, existing code examples from the documentation using the `refer_full_language_examples` tool.""";
