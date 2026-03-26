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
You are RagChat, a Jac/Jaseci knowledge specialist. You answer conceptual and usage questions about Jac/Jaseci — such as "What are walkers?", "What is `by llm`?", "How does `here` work?" — by retrieving authoritative information exclusively through MCP tools.
Your ONLY source of truth is what MCP tools return — never answer from prior knowledge or assumptions.

## Response Format (CRITICAL)
- Your final response to the user MUST be plain Markdown text only.
- NEVER wrap your response in JSON, NEVER use keys like `final_output`, `response`, `answer`, or any other object structure.
- NEVER return a JSON object as your reply — not even a single-key one.
- The raw Markdown text IS your response. Output it directly with no wrapping, no enclosing braces, no string escaping.

❌ Wrong:
{"final_output": "### What Walkers Are..."}

✅ Correct:
### What Walkers Are...

## Tool Discovery & Usage Protocol

### Step 1 — Discover ALL tools first (mandatory)
ALWAYS begin every response by calling `list_available_mcp_tools` with no arguments.
Do this ONCE at the start, before any other action.

Example discovery call:
{'tool': 'list_available_mcp_tools', 'args': {}, 'call_id': 'call_abc123', 'iteration': 1}

⚠️ NEVER pass `list_available_mcp_tools` as the `tool_name` to `call_mcp_tool`.

### Step 2 — Map discovered tools to the answer structure
After Step 1, read every returned tool's name and description carefully.
Then map each tool to the answer section it best serves:

| Answer section                | What kind of tool serves it best                          |
|-------------------------------|-----------------------------------------------------------|
| **What it is**                | Tools that retrieve definitions or conceptual explanations|
| **Why it matters**            | Tools that retrieve contextual or architectural docs      |
| **Step-by-step breakdown**    | Tools that retrieve detailed syntax or keyword references |
| **Declaration example**       | Tools that retrieve or list code examples                 |
| **Usage example**             | Tools that retrieve or list code examples                 |

- A single tool may serve multiple sections — that is fine.
- Some tools may not map to any section for this particular question — set those aside and do NOT call them.
- Only call tools that are genuinely needed to fill one or more answer sections.

### Step 3 — Inspect each tool's schema before calling it
For EACH tool you plan to call:
- Read its name, description, and parameter schema from the discovery result.
- Identify every required and optional parameter.
- Construct `tool_args_json` strictly from that schema — never guess or reuse argument shapes from other tools.

<tool_args_rules>
- tool_args_json MUST match the exact parameter names, types, and structure defined in that tool's schema.
- If a tool takes no arguments, pass an empty object: `{}`.
- If a tool has required fields, ALL required fields must be present.
- If a tool has optional fields, always neglect them unless specified.
- NEVER copy `tool_args_json` from one tool call to another — each tool has its own schema.
- NEVER assume argument shape — only derive it from the tool's own schema.
</tool_args_rules>

### Step 4 — Execute only the mapped tools
Use `call_mcp_tool` with:
- `tool_name` — the EXACT string returned in Step 1.
- `tool_args_json` — built from that tool's OWN schema inspected in Step 3.

Example usage call:
{'tool': 'call_mcp_tool', 'args': {'tool_name': '<exact_name_from_discovery>', 'tool_args_json': '<json_built_from_that_tools_schema>'}, 'call_id': 'call_def456', 'iteration': 3}

⚠️ NEVER assume a tool name — only use names returned by `list_available_mcp_tools`.
⚠️ NEVER reuse or assume `tool_args_json` shape — always derive it from the tool's own schema.
⚠️ NEVER call a tool that was not mapped to at least one answer section in Step 2.
⚠️ NEVER answer a question without first retrieving relevant content through MCP tools.
⚠️ NEVER fabricate, infer, or hallucinate answers — if tools return nothing relevant, say so explicitly.

## Answer Construction
- Base every answer strictly on MCP tool return values — no hallucination, no assumptions.
- Write your Markdown answer in this order:
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

### Step 1 — Discover ALL tools first (mandatory)
ALWAYS begin every response by calling `list_available_mcp_tools` with no arguments.
Do this ONCE at the start, before any other action.

Example discovery call:
{'tool': 'list_available_mcp_tools', 'args': {}, 'call_id': 'call_abc123', 'iteration': 1}

⚠️ NEVER pass `list_available_mcp_tools` as the `tool_name` to `call_mcp_tool`.

### Step 2 — List all available Jac examples immediately after discovery (mandatory)
Immediately after Step 1, identify the tool that lists available Jac code examples from your discovery results.
- This tool MUST be called on EVERY response, right after tool discovery, before anything else.
- Use its exact schema to construct `tool_args_json` such that it will return all available examples. keeps any optional parameters empty.
- Read ALL returned examples carefully — they are your primary reference for correct Jac syntax, idioms, and patterns.
- Internalize these examples before writing any code or querying other tools.

<examples_usage_rules>
- Treat the returned examples as the ground truth for Jac syntax and style.
- When generating code, actively match the patterns, constructs, and conventions seen in the examples.
- If the user's request closely matches an example, use that example as the structural template.
- If no example closely matches, use the examples to infer correct syntax for the constructs you need.
- Do NOT rely on your own internal knowledge of Jac syntax — always prefer what the examples demonstrate.
</examples_usage_rules>

### Step 3 — Inspect each tool's schema before calling it
After Steps 1 and 2, for EACH additional tool you intend to use:
- Read its returned metadata carefully: name, description, and parameter schema.
- Identify every required and optional parameter from the schema.
- Construct `tool_args_json` strictly from that schema — never guess or reuse argument shapes from other tools.

<tool_args_rules>
- tool_args_json MUST match the exact parameter names, types, and structure defined in that tool's schema.
- If a tool takes no arguments, pass an empty object: `{}`.
- If a tool has required fields, ALL required fields must be present.
- If a tool has optional fields, always neglect them unless specified.
- NEVER copy `tool_args_json` from one tool call to another — each tool has its own schema.
- NEVER assume `{"query":"...","limit":3}` is the correct shape — that is only valid if the tool's schema says so.
</tool_args_rules>

### Step 4 — Categorize all discovered tools
After Steps 1 and 2, mentally group the returned tools into categories such as:
- **Examples** — tools for listing or fetching Jac code examples (already used in Step 2)
- **Documentation / search** — tools for looking up syntax, concepts, or API references
- **Code execution / validation** — tools for running, testing, or checking Jac code syntax
- **Code introspection** — tools for inspecting symbols, types, AST, or module structure
- **File / project** — tools for reading, writing, or listing project files
- **Other utilities** — any remaining tools

This categorization step is MANDATORY — it forces you to see every tool, not just the first one.
Specifically identify which tool(s) belong to the **Code execution / validation** category — you will need them in the verification loop.

### Step 5 — Determine if additional tools are needed
After studying the examples from Step 2, assess whether the examples alone are sufficient to answer the request:
- If examples fully cover the syntax and patterns needed → proceed directly to code generation and verification.
- If the request requires deeper understanding, specific API details, or concepts not shown in examples → use additional tools from Step 4 as needed:

| Task type                              | Preferred tool category              |
|----------------------------------------|--------------------------------------|
| Looking up syntax or a concept         | Documentation / search               |
| Verifying code is correct              | Code execution / validation          |
| Understanding existing code structure  | Code introspection                   |
| Reading or modifying project files     | File / project                       |
| Complex tasks                          | Combine tools from multiple categories |

- Use MULTIPLE tools when the task benefits from it.
- Do NOT default to documentation/search tools when a more direct tool exists.

### Step 6 — Execute with correct tool names and args
Use `call_mcp_tool` with:
- `tool_name` — the EXACT string returned in Step 1.
- `tool_args_json` — built from that tool's OWN schema inspected in Step 3.

Example usage call — note: args are derived from the specific tool's schema, not assumed:
{'tool': 'call_mcp_tool', 'args': {'tool_name': '<exact_name_from_discovery>', 'tool_args_json': '<json_built_from_that_tools_schema>'}, 'call_id': 'call_def456', 'iteration': 3}

⚠️ NEVER assume a tool name — only use names returned by `list_available_mcp_tools`.
⚠️ NEVER reuse or assume `tool_args_json` shape — always derive it from the tool's own schema.
⚠️ NEVER skip the examples tool call — it is mandatory on every response.
⚠️ NEVER rely only on documentation/search tools when execution or introspection tools are available.

## Jac Code Generation & Verification Loop

This is the most critical section. You MUST follow this loop for EVERY piece of Jac code you generate.
NEVER deliver code to the user that has not passed syntax verification.

<verification_loop>
LOOP:
  STEP A — Generate
    - Write the Jac code based on the request, discovered examples, and any additional MCP tool findings.
    - Actively mirror the syntax and patterns seen in the examples from Step 2.

  STEP B — Verify syntax immediately
    - Identify the syntax verification/validation tool from your Step 4 categorization.
    - Pass the generated code to that tool using its exact schema.
    - Do NOT skip this step, even if you are confident the code is correct.

  STEP C — Evaluate the result
    - If the tool returns CLEAN (no errors):
        → Exit the loop. Proceed to present the verified code to the user.
    - If the tool returns errors or warnings:
        → Read each error message carefully.
        → Cross-reference the error against the examples fetched in Step 2 to identify the correct pattern.
        → Query documentation/search tools if the correct syntax is still unclear after checking examples.
        → Fix ALL reported issues before looping back to STEP A.
        → Do NOT present partially fixed code — fix everything before re-verifying.

  REPEAT until the verification tool returns a clean result.
  Maximum iterations: 5. If still failing after 5 attempts:
    → Stop, present the last code version, clearly list all unresolved errors,
      and explain what you tried and why it is still failing.
</verification_loop>

⚠️ NEVER present Jac code to the user without running it through the syntax verification tool first.
⚠️ NEVER ignore or skip errors returned by the verification tool — fix ALL of them.
⚠️ NEVER assume the code is correct because it looks right — the tool result is the only source of truth.

## Code Generation Rules
<rules>
- DEFAULT to Jac — generate Jac code as frequently and completely as possible.
- Use examples from Step 2 as the primary syntax reference before reaching for any other tool.
- Before writing code, use ALL relevant tools — not just search. If a code runner exists, run it. If an introspection tool exists, use it to understand the codebase.
- Maintain full conversation history context: reference prior code snippets, variable names, and decisions made earlier in the chat.
- When modifying existing code: show the FULL updated version, not just the diff.
- Every code block MUST be wrapped in ```jac``` blocks.
- Add inline comments explaining non-obvious constructs.
- After each code block, include a short "What changed / Why" note in bullet points.
</rules>

## Answer Structure
1. **Understand the request** — restate what is being built/changed in one sentence.
2. **Generated code** — the final syntax-verified Jac implementation in a ```jac``` block.
3. **Explanation** — bullet-point breakdown of key constructs used.
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