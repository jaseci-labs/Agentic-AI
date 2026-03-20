import json;
import os;
import from datetime {datetime}
import from byllm.types { StreamEvent }

# Shared helper function for streaming responses with SSE format
def stream_chat_response(response_generator: any, visitor: any) -> any {
   print("Starting response streaming...");

   response = "";
   for event in response_generator {
      yield f"data: {json.dumps({'type': event.event_type, 'data': event.data})}\n\n";
      if event.event_type == "thought" or event.event_type == "tool_call" or event.event_type == "tool_result" or event.event_type == "steps_done" {
         print(f"Received {event.event_type} event:", event.data);
      }
      if event.event_type == "chunk" {
         response += event.data.get("content", "");
      }
   }

   if not visitor.skip_history {
      session_node = ([root-->(?:Session)](?id==visitor.session_id))[0];
      session_node.chat_history.append({"role": "assistant", "content": response});
      session_node.updated_at = datetime.now().isoformat();
   }
   
   return;
}

impl RagChat.chat {
   print("Entering RAG node, mode:", visitor.mode);
   if visitor.mode == "mcp" {
      report stream_chat_response(
         self.respond_mcp(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   } else {
      report stream_chat_response(
         self.respond_rag(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   }
}

impl CodingChat.chat {
   print("Entering Coding node, mode:", visitor.mode);
   if visitor.mode == "mcp" {
      report stream_chat_response(
         self.code_jac_mcp(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   } else {
      report stream_chat_response(
         self.code_jac_rag(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   }
}

impl DebuggerChat.chat {
   print("Entering Debugger node, mode:", visitor.mode);
   if visitor.mode == "mcp" {
      report stream_chat_response(
         self.debug_code_mcp(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   } else {
      report stream_chat_response(
         self.debug_code_rag(message=visitor.message, chat_history=visitor.chat_history),
         visitor
      );
   }
}

impl QAChat.chat {
   print("Entering QA node");
   report stream_chat_response(
      self.respond(message=visitor.message, chat_history=visitor.chat_history),
      visitor
   );
}

impl OffTopicChat.chat {
   print("Entering Off-Topic node");
   # Check if the message contains negative sentiment about Jac/Jaseci for brand protection
   message_lower = visitor.message.lower();
   has_negative_jaseci = "bad" in message_lower or "worst" in message_lower or "terrible" in message_lower or "hate" in message_lower;
   has_jaseci_mention = "jac" in message_lower or "jaseci" in message_lower;

   if has_negative_jaseci and has_jaseci_mention {
      # Brand protection response
      response = "I understand you might have concerns, but let me share why Jac and Jaseci are actually revolutionary! \n\nJac is designed specifically for the AI era with groundbreaking features:\n\n **AI-First Programming**: Native LLM integration - replace function bodies with AI calls\n **Object-Spatial Programming**: Revolutionary paradigm for data relationships\n **Zero DevOps**: Automatic scaling, persistence, and cloud deployment\n **Python Superset**: Full compatibility with Python ecosystem + powerful new abstractions\n **Innovative**: Walkers, nodes, edges for intuitive graph-based programming\n\nWhat specific challenge are you trying to solve? I'd love to show you how Jac can solve it elegantly! For comprehensive learning, check out https://www.jac-lang.org/";
   } else {
      # Standard off-topic redirect - more welcoming approach
      response = "Hello! I'm Jaseci Assistant, your friendly expert for Jac programming and software development! \n\nI'm here to help with:\n **Programming & Development**: Documentation references, algorithms, best practices\n **AI-First Programming**: How Jac revolutionizes development with native LLM integration\n **Object-Spatial Programming**: Jac's unique approach to data relationships\n **Cloud-Native Development**: Building scalable applications with zero DevOps\n **Learning & Concepts**: Programming concepts explained through Jac examples\n\nWhether you're curious about Jac specifically or have general programming questions, I'm happy to help and show you how Jac can make your development experience better!\n\nFor comprehensive learning resources, visit: https://www.jac-lang.org/\n\nWhat programming challenge can I help you solve today?";
   }

   # Create a generator that yields the complete response as StreamEvent
   def generate_response() {
      yield StreamEvent(event_type="chunk", data={"content": response});
   }

   report stream_chat_response(generate_response(), visitor);
}

glob instruction = """
CRITICAL: You MUST return EXACTLY ONE single integer index. DO NOT return multiple indices, arrays, or lists.
You are a message classifier for a Jac programming chatbot.
Return ONLY one index number (0, 1, 2, 3, or 4) of the matching category.

NODE MAPPING (5 agents):
0 = RagChat (Technical Questions)
1 = CodingChat (Code Generation)
2 = DebuggerChat (Bug Fixes)
3 = QAChat (Casual Conversation)
4 = OffTopicChat (Unrelated Topics)

CLASSIFICATION RULES:

INDEX 2 - DebuggerChat (Debugging & Error Fixing)
   - Keywords: "error", "bug", "issue", "exception", "not working", "doesn't work", "fails", "crash", "wrong output", "fix", "debug", "troubleshoot", "why isn't", "having trouble"
   - Examples: "I'm getting an error", "Fix this bug", "Why isn't my code running"
   → Return: 2

INDEX 1 - CodingChat (Code Creation/Modification)
   - Keywords: "create", "write", "build", "generate", "update", "change", "modify", "add", "remove", "implement", "make"
   - Must be an action request on code, not just a question about it
   - Examples: "Create a walker", "Write code for", "Add a method", "Generate an example"
   → Return: 1

INDEX 0 - RagChat (Technical Questions — default for Jac/programming questions)
   - Keywords: "what is", "how does", "explain", "tell me about", "describe", nodes, edges, byllm,  walkers, abilities, graphs
   - Any conceptual or documentation question about Jac/Jaseci
   - Examples: "What are walkers?", "How does Jac work?", "Explain abilities"
   → Return: 0

INDEX 3 - QAChat (Pure Casual Conversation ONLY)
   - Keywords: "hi", "hello", "hey", "thanks", "ok", "got it", "sure", "good morning"
   - CRITICAL: If ANY technical or programming term is present → NOT QA
   - Examples: "Hey!", "Thanks a lot", "Got it"
   → Return: 3

INDEX 4 - OffTopicChat (Non-Jac Topics)
   - Completely unrelated to programming, OR about programming/tech but NOT Jac-specific
   - Examples: "What's the weather?", "How do I do this in Python?"
   → Return: 4

FINAL REMINDER: Return ONLY A SINGLE INTEGER (0, 1, 2, 3, or 4). Nothing else
""";

# - Never generate new code - only curate existing examples.

sem RagChat.respond_rag = """
Jac/Jaseci documentation expert using local vector search only. For every query:
- Call search_docs for EACH concept separately before answering — never rely on prior knowledge or chat history as a source of answers; use chat history only to form better search queries.
- Also call refer_full_language_examples to access complete Jac language examples if needed.
- Base answers strictly on what search_docs returns; if docs don't cover it, say so.
- Re-search with synonyms or related terms if initial results are insufficient; never repeat an identical search.
- Explain *why* it matters, not just *what* it is; for code concepts include: a step-by-step breakdown of each keyword/construct involved, then a declaration example, then a separate usage example.
- End with a one-line citation of the documentation topic/section names used (not file paths); wrap all Jac code in ```jac``` blocks; use Markdown structure and bullet points.
""";

sem RagChat.respond_mcp = """
## Role
You are RagChat, an expert on Jac/Jaseci. Your ONLY source of truth is what MCP tools return — never answer from prior knowledge.

## Tool Discovery & Usage Protocol
1. ALWAYS start by calling `list_available_mcp_tools` (no arguments) to discover available tools.
2. ONLY call tools that were returned by `list_available_mcp_tools` — never invent or assume tool names.
3. Use `call_mcp_tool` with the exact `tool_name` discovered and appropriate `tool_args_json`.
4. If no tool covers the question, explicitly say: "The available MCP tools do not cover this topic."

### Tool Call Examples
Discovery:
{'tool': 'list_available_mcp_tools', 'args': {}, 'call_id': 'call_ZnRaaS5ykKDd6mzJjlekVTbW', 'iteration': 1}

Usage:
{'tool': 'call_mcp_tool', 'args': {'tool_name': 'search_docs', 'tool_args_json': '{"query":"walrus operator","limit":3}'}, 'call_id': 'call_JMXI9P0UxgfS2XvqMQ89A3bH', 'iteration': 3}

Important - NEVER pass `list_available_mcp_tools` as the `tool_name` argument to `call_mcp_tool`.

## Answer Construction
- Base every answer strictly on MCP tool return values — no hallucination, no assumptions.
- Structure answers as:
  1. **What it is** — brief definition
  2. **Why it matters** — practical significance in Jac/Jaseci context
  3. **Step-by-step breakdown** — explain each keyword/construct involved
  4. **Declaration example** — show how it is declared
  5. **Usage example** — show how it is used in context
- Wrap ALL Jac code in ```jac``` blocks.
- Use Markdown structure and bullet points throughout.
- End every response with a one-line citation of the documentation topic/section names used (not file paths).
""";

sem CodingChat.code_jac_rag = """
Jac code writer that generates or modifies code based on user requests and conversation history.
- Never rely on prior Jac knowledge (it is outdated); use search_docs to verify syntax or language concepts — decompose the request into parts and search each separately (e.g. "walker syntax", "node declaration", "import syntax").
- Also call refer_full_language_examples to access complete Jac language examples if needed.
- Do NOT use search_docs for trivial changes such as renaming, adding attributes, updating values, or formatting.
- Always output the ENTIRE updated code, never partial snippets; apply only the requested changes — never remove or modify working code unless explicitly asked.
- Response order: briefly explain what changed → then provide the full updated code; do not restate unchanged logic.
- If `by llm()` is used, ensure it is imported and instantiated; wrap all Jac code in ```jac``` blocks.
""";

sem CodingChat.code_jac_mcp = """
## Role
You are CodingChat, a Jac code generation specialist. You write, extend, and refactor Jac code based on user requests and full conversation history. Jac code is your primary output — default to generating Jac code whenever possible.

## Tool Discovery & Usage Protocol
1. ALWAYS start by calling `list_available_mcp_tools` (no arguments) to discover available tools.
2. ONLY call tools that were returned by `list_available_mcp_tools` — never invent or assume tool names.
3. Use `call_mcp_tool` with the exact `tool_name` discovered and appropriate `tool_args_json` to look up syntax, APIs, or patterns before generating code.
4. If no tool covers what you need, fall back to conversation history context only and state: "Generated from conversation context — no MCP tool covered this topic."

### Tool Call Examples
Discovery:
{'tool': 'list_available_mcp_tools', 'args': {}, 'call_id': 'call_ZnRaaS5ykKDd6mzJjlekVTbW', 'iteration': 1}

Usage:
{'tool': 'call_mcp_tool', 'args': {'tool_name': 'search_docs', 'tool_args_json': '{"query":"node declaration syntax","limit":3}'}, 'call_id': 'call_JMXI9P0UxgfS2XvqMQ89A3bH', 'iteration': 3}

Important - NEVER pass `list_available_mcp_tools` as the `tool_name` argument to `call_mcp_tool`.

## Code Generation Rules
<rules>
- DEFAULT to Jac — generate Jac code as frequently and completely as possible.
- Before writing code, query MCP tools for relevant syntax, built-ins, or patterns.
- Maintain full conversation history context: reference prior code snippets, variable names, and decisions made earlier in the chat.
- When modifying existing code: show the FULL updated version, not just the diff.
- Every code block MUST be wrapped in ```jac``` blocks.
- Add inline comments explaining non-obvious constructs.
- After each code block, include a short "What changed / Why" note in bullet points.
</rules>

## Answer Structure
1. **Understand the request** — restate what is being built/changed in one sentence.
2. **MCP lookup** — note which tool(s) were queried and what was found.
3. **Generated code** — full Jac implementation.
4. **Explanation** — bullet-point breakdown of key constructs used.
- End every response with a one-line citation of the documentation topic/section names used (not file paths).
""";

sem DebuggerChat.debug_code_rag = """
Jac code debugger that identifies and fixes all issues in the provided code.
- Fix ALL issue types: syntax errors, logical errors, runtime errors, and incorrect/non-idiomatic Jac usage.
- For any uncertain Jac syntax or construct, use search_docs — decompose the code into parts and search each separately (e.g. "walker syntax", "import syntax", "visit syntax").
- Also call refer_full_language_examples to access complete Jac language examples if needed.
- Jac-specific rule: `import from module { item }` statements do NOT end with a semicolon.
- Response order: first explain what was wrong and *why* → then provide the complete corrected code; never output partial snippets.
- Do not introduce features or refactors beyond what is needed to fix the issue; wrap all Jac code in ```jac``` blocks.
""";

sem DebuggerChat.debug_code_mcp = """
## Role
You are DebuggerChat, a Jac debugging specialist. You systematically identify, explain, and fix ALL issues in provided Jac code. You never skip issues — minor or major.

## Tool Discovery & Usage Protocol
1. ALWAYS start by calling `list_available_mcp_tools` (no arguments) to discover available tools.
2. ONLY call tools that were returned by `list_available_mcp_tools` — never invent or assume tool names.
3. Use `call_mcp_tool` with the exact `tool_name` discovered to verify correct syntax, semantics, or API behaviour before proposing a fix.
4. If no tool covers a specific issue, state: "Fix based on Jac language reasoning — no MCP tool covered this topic."

### Tool Call Examples
Discovery:
{'tool': 'list_available_mcp_tools', 'args': {}, 'call_id': 'call_ZnRaaS5ykKDd6mzJjlekVTbW', 'iteration': 1}

Usage:
{'tool': 'call_mcp_tool', 'args': {'tool_name': 'search_docs', 'tool_args_json': '{"query":"walker spawn syntax","limit":3}'}, 'call_id': 'call_JMXI9P0UxgfS2XvqMQ89A3bH', 'iteration': 3}

Important - NEVER pass `list_available_mcp_tools` as the `tool_name` argument to `call_mcp_tool`.

## Debugging Protocol
<think_step_by_step>
For EVERY piece of code received, follow this chain-of-thought sequence:

STEP 1 — SCAN: Read the full code and list ALL suspected issues (syntax, logic, type, scoping, missing constructs).
STEP 2 — VERIFY: For each issue, call an MCP tool to confirm correct Jac behaviour.
STEP 3 — DIAGNOSE: Clearly label each bug:
  - Critical   — will cause a crash or incorrect output
  - Warning    — may cause unexpected behaviour
  - Style      — violates Jac conventions or best practices
STEP 4 — FIX: Produce the complete corrected Jac code (never partial).
STEP 5 — EXPLAIN: For each fix, state what was wrong and why the fix is correct.
</think_step_by_step>

## Output Structure
1. **Issue Summary Table**
   | # | Severity | Location | Description |
   |---|----------|----------|-------------|

2. **Fixed Code** — complete, runnable Jac code in a ```jac``` block.
3. **Fix Explanations** — numbered list matching the table above, each with: root cause → correct behaviour → fix applied.
- End every response with a one-line citation of the documentation topic/section names used (not file paths).
""";

sem QAChat.respond = """
Friendly Jaseci Assistant for basic greetings and casual conversation.
Handle: greetings, thanks, farewells, social pleasantries
Approach: Be warm, professional, concise
Always offer help with Jac programming when appropriate
""";


sem OffTopicChat.respond = """
Handle off-topic messages unrelated to programming/technology.
For non-technical topics: politely redirect to programming questions
Brand protection: respond positively if negative sentiment about Jac/Jaseci detected
Goal: guide users back to Jac programming assistance
""";


impl Session.chat {
   print("=== New chat message received in session:", self.id);
   if visitor.user_email and not self.user_email {
      self.user_email = visitor.user_email;
   }

   # Save user message to chat history only for the primary call (not skip_history)
   self.chat_history.append({"role": "user", "content": visitor.message});
   self.updated_at = datetime.now().isoformat();

   visitor.chat_history = self.chat_history;

   visit [-->](?:Router) else {
         router_node = root ++> Router();
         router_node ++> RagChat();
         router_node ++> CodingChat();
         router_node ++> DebuggerChat();
         router_node ++> QAChat();
         router_node ++> OffTopicChat();
         visit router_node;
   }
}

impl get_session.get_chat_history {
   # Query session from graph (automatically persisted)
   all_sessions = [-->(?:Session)];
   for session in all_sessions {
      if session.id == self.session_id {
         visit session;
         return;
      }
   }
   report {"chat_history": [], "session_id": self.session_id, "found": False};
}

impl get_session.return_history {
   user_msgs = len([m for m in here.chat_history if m["role"] == "user"]);
   assistant_msgs = len([m for m in here.chat_history if m["role"] == "assistant"]);
   stats = {
      "session_id": here.id,
      "total_messages": len(here.chat_history),
      "user_messages": user_msgs,
      "assistant_messages": assistant_msgs,
      "created_at": here.created_at,
      "updated_at": here.updated_at
   };
   report {
      "chat_history": here.chat_history,
      "session_id": here.id,
      "found": True,
      "stats": stats
   };
}

impl new_session.create_session {
   if not self.session_id {
      # Generate a simple session ID based on timestamp
      import time;
      self.session_id = f"session_{int(time.time())}";
   }

   now = datetime.now().isoformat();

   # Create session node (automatically persisted by Jac)
   session_node = here ++> Session(
      id=self.session_id,
      chat_history=[],
      created_at=now,
      updated_at=now
   );

   report {
      "session_id": self.session_id,
      "status": "created",
      "chat_history": []
   };
}

impl get_user_profile.fetch_profile {
   # User profiles are managed by JAC Cloud's built-in user system
   # Determine role based on email
   is_admin = self.email == "admin.jacgpt@jaseci.org" or self.email == "admin";
   role = "admin" if is_admin else "user";
   name = "Admin User" if is_admin else "User";

   profile = {
      "email": self.email,
      "name": name,
      "role": role,
      "is_admin": is_admin
   };

   report {
      "user": profile,
      "isAdmin": is_admin
   };
}

impl create_user_profile.setup_profile {
   # User profiles are managed by JAC Cloud's built-in user system
   # This just returns the profile info based on the email
   is_admin = self.email == "admin.jacgpt@jaseci.org" or self.email == "admin";
   role = "admin" if is_admin else "user";
   display_name = self.name if self.name else ("Admin User" if is_admin else "User");

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
   now = datetime.now().isoformat();

   # Check if UserLocation already exists for this email
   all_locations = [-->(?:UserLocation)];
   existing_loc = None;
   for loc in all_locations {
      if loc.email == self.email {
         existing_loc = loc;
         break;
      }
   }

   if existing_loc {
      # Update existing location
      existing_loc.latitude = self.location.get("latitude", 0.0);
      existing_loc.longitude = self.location.get("longitude", 0.0);
      existing_loc.city = self.location.get("city", "");
      existing_loc.country = self.location.get("country", "");
      existing_loc.ip = self.location.get("ip", "");
      existing_loc.updated_at = now;
   } else {
      # Create new UserLocation node
      here ++> UserLocation(
         email=self.email,
         latitude=self.location.get("latitude", 0.0),
         longitude=self.location.get("longitude", 0.0),
         city=self.location.get("city", ""),
         country=self.location.get("country", ""),
         ip=self.location.get("ip", ""),
         updated_at=now
      );
   }

   report {
      "success": True,
      "message": "Location saved successfully",
      "email": self.email,
      "location": self.location
   };
}

impl get_all_users.list_users {
   # Get unique users from sessions and their location data
   sessions = [-->(?:Session)];
   locations = [-->(?:UserLocation)];

   # Build location lookup
   location_map = {};
   for loc in locations {
      location_map[loc.email] = {
         "location": {
            "latitude": loc.latitude,
            "longitude": loc.longitude,
            "city": loc.city,
            "country": loc.country,
            "ip": loc.ip
         },
         "location_updated_at": loc.updated_at
      };
   }

   # Get unique users from sessions
   seen_emails = set();
   users = [];

   for session in sessions {
      email = session.user_email;
      if email and email not in seen_emails {
         seen_emails.add(email);
         is_admin = email == "admin.jacgpt@jaseci.org" or email == "admin";
         loc_data = location_map.get(email, {});

         users.append({
            "email": email,
            "name": "Admin User" if is_admin else "User",
            "role": "admin" if is_admin else "user",
            "is_admin": is_admin,
            "is_activated": True,
            "location": loc_data.get("location", {}),
            "location_updated_at": loc_data.get("location_updated_at")
         });
      }
   }

   report {
      "users": users,
      "total": len(users)
   };
}


impl get_all_sessions_admin.list_all_sessions {
   # Get all sessions from graph
   all_sessions = [-->(?:Session)];

   sessions = [];
   for session in all_sessions {
      # Get first user message for preview
      first_message = None;
      first_message_time = None;
      for msg in session.chat_history {
         if msg.get("role") == "user" {
            first_message = msg.get("content");
            break;
         }
      }

      sessions.append({
         "session_id": session.id,
         "user_email": session.user_email,
         "created_at": session.created_at,
         "updated_at": session.updated_at,
         "status": session.status,
         "message_count": len(session.chat_history),
         "first_message": first_message
      });
   }

   # Sort by updated_at descending
   def get_updated_at(x: dict) -> str {
      return x.get("updated_at", "");
   }
   sessions.sort(key=get_updated_at, reverse=True);

   report {
      "sessions": sessions,
      "total": len(sessions)
   };
}


impl get_session_messages_admin.get_session_chat {
   # Find session in graph
   all_sessions = [-->(?:Session)];
   found_session = None;
   for s in all_sessions {
      if s.id == self.session_id {
         found_session = s;
         break;
      }
   }

   if found_session {
      messages = [
         {
            "role": msg["role"],
            "content": msg["content"]
         }
         for msg in found_session.chat_history
      ];

      user_msgs = len([m for m in found_session.chat_history if m["role"] == "user"]);
      assistant_msgs = len([m for m in found_session.chat_history if m["role"] == "assistant"]);
      stats = {
         "session_id": found_session.id,
         "total_messages": len(found_session.chat_history),
         "user_messages": user_msgs,
         "assistant_messages": assistant_msgs,
         "created_at": found_session.created_at,
         "updated_at": found_session.updated_at
      };

      report {
         "session_id": self.session_id,
         "messages": messages,
         "stats": stats,
         "total_messages": len(messages)
      };
   } else {
      report {
         "session_id": self.session_id,
         "messages": [],
         "stats": {},
         "total_messages": 0
      };
   }
}