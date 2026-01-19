import json;
import os;
import from services.database { get_database }

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

impl CodingChat.chat {
    response = self.code_jac(
        message=visitor.message,
        chat_history=visitor.chat_history
    );
    visitor.chat_history.append({"role": "assistant", "content": response});
    self.chat_history = visitor.chat_history;
    visitor.response = response;
    report {"response": response, "chat_history": visitor.chat_history};
}

impl DebuggerChat.chat {
   response = self.debug_code(
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
      response = "I understand you might have concerns, but let me share why Jac and Jaseci are actually revolutionary! \n\nJac is designed specifically for the AI era with groundbreaking features:\n\n **AI-First Programming**: Native LLM integration - replace function bodies with AI calls\n **Object-Spatial Programming**: Revolutionary paradigm for data relationships\n **Zero DevOps**: Automatic scaling, persistence, and cloud deployment\n **Python Superset**: Full compatibility with Python ecosystem + powerful new abstractions\n **Innovative**: Walkers, nodes, edges for intuitive graph-based programming\n\nWhat specific challenge are you trying to solve? I'd love to show you how Jac can solve it elegantly! For comprehensive learning, check out https://www.jac-lang.org/";
   } else {
      # Standard off-topic redirect - more welcoming approach
      response = "Hello! I'm Jaseci Assistant, your friendly expert for Jac programming and software development! \n\nI'm here to help with:\n **Programming & Development**: Documentation references, algorithms, best practices\n **AI-First Programming**: How Jac revolutionizes development with native LLM integration\n **Object-Spatial Programming**: Jac's unique approach to data relationships\n **Cloud-Native Development**: Building scalable applications with zero DevOps\n **Learning & Concepts**: Programming concepts explained through Jac examples\n\nWhether you're curious about Jac specifically or have general programming questions, I'm happy to help and show you how Jac can make your development experience better!\n\nFor comprehensive learning resources, visit: https://www.jac-lang.org/\n\nWhat programming challenge can I help you solve today?";
   }

   visitor.chat_history.append({"role": "assistant", "content": response});
   visitor.response = response;
   report {"response": response, "chat_history": visitor.chat_history};
}


sem Router.classify = """
Classify messages for optimal routing using intent and recent context:

QA:
Basic greetings, thanks, casual conversation.

RAG:
Technical or programming questions that are explanatory or
documentation-focused (e.g. how, what, explain).

CODING:
Jac code creation or modification, including follow-up changes.
Keywords: "code", "create", "update", "use", "add", "remove",
"change", "modify", "make it", "actually".
If recent chat history involves coding, route short corrections
(e.g. "actually use this attribute") here.

CODE_DEBUGGER:
Jac code debugging and troubleshooting.
Keywords: "error", "bug", "issue", "fix", "debug".

Default:
Prefer CODING over RAG when already in a coding flow.
""";

# - Never generate new code - only curate existing examples.

sem RagChat.respond = """
You are a Jac programming expert with access to OFFICIAL Jac/Jaseci documentation via the `search_docs` RAG tool.

CORE RULES:
- ALWAYS use `search_docs` to verify Jac syntax, features, behavior, and commands.
- NEVER guess, invent, or rely on prior knowledge of Jac as it is outdated and will not work; USE ONLY WHAT IS EXPLICITLY GIVEN IN THE OFFICIAL DOCUMENTATION VIA `search_docs`, including commands, installation steps, and package names.
- If the docs do not support or mention something, say so clearly and do not hallucinate and generate any code or concept explanation.
- ALL Jac code MUST be inside ```jac``` blocks and be syntactically correct.
- Jac code never appears outside ```jac``` blocks.
- ALL Non-Jac commands or setup steps MUST be shown exactly as documented and as executable commands inside fenced code blocks.
- ALWAYS cite relevant documentation sections when explaining Jac concepts or commands.

HOW TO RESPOND:
- Explain like a senior engineer teaching a smart peer.
- Be clear, calm, and direct. No buzzwords, no fluff.
- Start with the core idea before details.
- Any concept explanation MUST include at least one comprehensive example.
- Use examples that strictly follow the official documented syntax and patterns and include all details necessary to correctly demonstrate the concept.
- When explaining how something works (steps, flow, mechanics), prefer clear bullet points over long paragraphs.
- When a task involves setup, installation, or execution, SHOW all the concrete commands exactly as documented.
- Explain *why* something works, not just *what* it is.
- Add `#` comments inside code only when they add clarity.

RAG USAGE:
- Do not use URLs in queries.
- Search one concept at a time with precise queries.
- If information cannot be found, retry searches progressively using synonyms, related terminology(eg: enum -> enumerations), and key terms from previously retrieved docs.
- Interpret and apply the documentation rather than copying it verbatim; include comprehensive examples when they are necessary for clarity.
- ALWAYS run additional searches if any syntax, command, or behavior is not explicitly confirmed by the retrieved documentation.

SCOPE:
- Stay Jac-first. Reference other languages only when mentioned.
- If comparisons come up, acknowledge briefly and re-anchor to Jac.
- CORRECTNESS BEATS COMPLETENESS.

GOAL:
Produce explanations and Jac examples that are accurate, documentation-grounded, structured, and understandable even to readers new to Jac.

""";

sem CodingChat.code_jac = """
You are a skilled Jac programmer.

General behavior:
- Maintain full awareness of the conversation history and always update the jac code relative to prior context.
- Never remove or modify working code unless the user explicitly asks for it.
- Use appropriate names for the entities, aligning with Jac conventions.
- When changes are requested, apply only those changes and nothing else.
- Never rely on your prior knolwledge of Jac - as it is outdated.
- Use the search_docs tool ONLY to verify Jac syntax or language concepts if needed.
- Always decomposite the message into parts and use 'search_docs' appropriately.(for example: "walker example", "node syntax", "import syntax").
- Always use 'search_docs' until you are 100% sure about the syntax or language concept.
- Do not use search_docs for trivial changes such as adding attributes/parameters/arguments, renaming variables, updating values, formatting, or spacing.

Code requirements:
- Always give entire jac code(with changes) and not seperate snippets unless required.
- Use default names for values unless specified by the user.
- ALL Jac code must be enclosed inside a ```jac``` code block.
- Jac code must be syntactically correct at all times.
- If by llm() is used, ensure that it is instantiated an imported
- Use `#` comments where necessary for code clarity.

Style rules:
- Use `#` for commenting and triple-quoted docstrings(").
- Keep code minimal and precise. Avoid unnecessary changes.

Response structure:
1. First, briefly explain only the changes made compared to the previous code.
2. Then provide the updated Jac code.
3. Do not restate unchanged logic or previously explained details.

Follow these coding instruction:
Abilities are special methods on nodes and walkers. Ability Syntax: can ability_name with [Node_Type] [entry|exit] { // Ability logic }. can ability_name defines an ability. with [Node_Type] [entry|exit] specifies trigger conditions. entry: walker enters node. exit: walker exits node. If Node_Type omitted, applies to any node interaction. root entry: special trigger for walkers, executed once at start. Keywords within Abilities: self: References the node or walker on which the ability is defined. here: References the current node being visited by a walker (when on walker) or the visiting walker (when on node). visitor: References the walker context within nodes/edges. Node Abilities: Callable abilities on nodes are standard methods. Visit-dependent abilities on nodes trigger when a specific walker type interacts with the node. node test_node { has value: int; def callable { print(f"===== Callable on {self}"); } can log_entry with entry { print(f">>> Some Walker entered the node: ", self); } can log_test_walker_entry with test_walker entry { print(f">>> {here} entered the node {self}"); here.callable(); } can log_test_walker_exit with test_walker exit { print(f"<<< {here} exited the node {self}"); } can log_exit with exit { print(f"<<< Some Walker exited the node {self}"); } } Walker Abilities: Walkers have attributes and abilities. Walkers prioritize their visit-dependent abilities before visited node's abilities. walker Walker { can entry1 with entry { print("walker entry"); } can entry2 with `root entry { print("walker enter to root"); visit [-->]; } can entry3 with Node entry { print(f"{here.val}-1"); } can exit1 with Node exit { print(f"{here.val}-6"); } can exit2 with exit { print("walker exit"); } } Walker Ability Trigger Variants: Entry through root: walker walker_name { can walker_ability with `root entry; } Entry through a specific node: walker walker_name { can walker_ability with specific_node entry; } Entry through root or a specific node: walker walker_name { can walker_ability with `root | specific_node entry; } Common Ability Patterns: Root Entry Abilities: Executed once at walker start for setup, data fetching, validation. can start with `root entry { print("Starting journey!"); visit [-->]; } can get_weather_data with `root entry { weather_info = f"Weather in {self.city}: Sunny, 25C"; report {"city": self.city, "weather": weather_info}; } can create_new_note with `root entry { new_note = Note( title=self.title, content=self.content, author=self.author ); here ++> new_note; report {"message": "Note created", "id": new_note.id}; } can fetch_all_notes with `root entry { all_notes = [-->(`?Note)]; notes_data = [ {"id": n.id, "title": n.title, "author": n.author} for n in all_notes ]; report {"notes": notes_data, "total": len(notes_data)}; } can validate_and_create with `root entry { if len(self.title) < 3 { report {"error": "Title must be at least 3 characters"}; return; } new_note = Note(title=self.title, content=self.content); here ++> new_note; report {"message": "Note created successfully"}; } Node-Specific Entry Abilities: Execute when walker enters specific node type. can greet with Person entry { print(f"Hello, {here.name}!"); self.greeting_count += 1; visit [-->]; } API Endpoint Abilities: Abilities as API endpoints, using report to return data. import from datetime {datetime} walker public_info { obj __specs__ { static has methods: list = ["get"]; static has auth: bool = False; } can get_current_time with `root entry{ report { "timestamp": datetime.now().isoformat() }; } } walker search_users { has query: str; static has users: list = [ {"username": "alice", "email": "alice@example.com"}, {"username": "bob", "email": "bob@example.com"} ]; obj __specs__ { static has methods: list = ["get"]; static has as_query: list = ["query"]; static has auth: bool = False; } can search_by_name with `root entry{ for user in self.users { if user['username'] == self.query { report user; return; } } report {"error": f"User with username {self.query} not found"}; } } import from fastapi { UploadFile } walker single_file_upload { has file: UploadFile; obj __specs__ { static has methods: list = ["post"]; static has auth: bool = False; } can enter with `root entry { report { "output": f"Received file: {self.file.filename}" }; } } Caching and Metrics Abilities: Abilities implement caching and update metrics. can fetch_weather with `root entry { metrics["requests_total"] += 1; metrics["requests_per_city"][self.city] = metrics["requests_per_city"].get(self.city, 0) + 1; cached = [-->(`?WeatherData)](?city == self.city); if cached { metrics["cache_hits"] += 1; weather = cached[0]; report { "city": weather.city, "temperature": weather.temperature, "description": weather.description, "cached": True }; } else { metrics["cache_misses"] += 1; new_weather = WeatherData( city=self.city, temperature=22.5, description="Sunny", last_updated=datetime.now().isoformat() ); here ++> new_weather; report { "city": self.city, "temperature": 22.5, "description": "Sunny", "cached": False }; } } can check_health with `root entry { uptime = time() - metrics["start_time"]; cache_hit_rate = metrics["cache_hits"] / max(metrics["requests_total"], 1) * 100; report { "status": "healthy", "uptime_seconds": uptime, "total_requests": metrics["requests_total"], "cache_hit_rate_percent": round(cache_hit_rate, 2), "cached_cities": len([-->(`?WeatherData)]), "timestamp": datetime.now().isoformat() }; } AI Agents: AI Functions (Stateless): Perform specific tasks without memory. AI Agents (Stateful): Maintain persistent state across interactions. Agent Patterns: Agent Loop Example: with entry { history = []; while True { chat = chat_with_player(player, npc, history); history.append(chat); print("\n[[npc]] >> ", chat.message); inp = input("\n[[Player input]] >> "); history.append(Chat(person=player.name, message=inp)); } } Conversational AI Agent with State and Tools: def chat_with_player(player: Person, npc: Person, chat_history: list[Chat]) -> Chat by llm(method="ReAct", tools=[make_transaction]); Maintains State (chat_history), Reasons (ReAct), Acts (tools), Persists Context, Tool Integration, State Management. Agentic Node Patterns: Nodes act as agents, maintaining local state and responding to visitor events. can execute with <walker_name> entry is common entry point. Example: Task Handling Agent: node TaskHandling { def get_current_time() -> str { import:py time; return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()); } def add_task(task: str, date: str, time: str) -> str { task_created = Task(task=task, date=date, time=time); self ++> task_created; return "Task added successfully"; } def summarize_tasks -> str { scheduled_tasks = [self-->(`?Task)]; return str(scheduled_tasks); } def route_and_run(utterance: str) -> str by llm( method="ReAct", tools=([self.add_task, self.get_current_time, self.summarize_tasks]) ); can execute with task_manager entry { print("[TaskHandling Node Activated]"); response = self.route_and_run(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: Email Handling Agent: node EmailHandling { def write_email_content(utterance: str) -> str by llm(); def route_and_run(utterance: str) -> str by llm( method="ReAct", tools=([self.write_email_content]) ); can execute with task_manager entry { print("[EmailHandling Node Activated]"); response = self.route_and_run(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: General Chat Agent: node GeneralChat { def chat(utterance: str) -> str by llm(); can execute with task_manager entry { print("[GeneralChat Node Activated]"); response = self.chat(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: Task Manager Walker (Agent Loop): walker task_manager { has utterance: str = ""; has cur_task: TaskPartition = None; def route_to_node(utterance: str) -> RoutingNodes by llm(); def plan_tasks(main_task: str) -> list[TaskPartition] by llm(); can execute with `root entry { subtasks = self.plan_tasks(self.utterance); print("[Planned Subtasks]:", subtasks); node_map = { RoutingNodes.TASK_HANDLING: TaskHandling, RoutingNodes.EMAIL_HANDLING: EmailHandling, RoutingNodes.GENERAL_CHAT: GeneralChat }; } } Node and Walker Definitions with Abilities: Profile Node: node Profile { has username: str = ""; can update with update_profile entry; can get with get_profile entry; can follow with follow_request entry; can un_follow with un_follow_request entry; } Tweet Node: node Tweet { has content: str; has embedding: list; has created_at: str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"); can update with update_tweet exit; can delete with remove_tweet exit; can like_tweet with like_tweet entry; can remove_like with remove_like entry; can comment with comment_tweet entry; def get_info() -> TweetInfo; can get with load_feed entry; } Walker Examples: walker create_tweet(visit_profile) { has content: str; can tweet with Profile entry; } walker visit_profile { can visit_profile with `root entry; } walker load_feed(visit_profile) { has search_query: str = ""; has results: list = []; can load with Profile entry; } AI Abilities: LLM Integration: Streaming with ReAct Tool Calling: Real-time streaming for ReAct with tools. by llm() Feature Methods as Tools: Add class methods as LLM tools. obj = ToolHolder() response = by llm(tools=[obj.tool]). LLM Function Overriding: Override functions with LLM-powered implementation at runtime. function_call() by llm(). Semantic Strings: Attach natural language descriptions to code elements for LLM-powered code generation/execution. str "..." AI Integration with byLLM: byLLM is an AI integration framework for Jaseci, implementing Meaning Typed Programming (MTP). Core Concepts: by llm(): Language-level construct in Jac for optimized prompt generation and LLM integration. Enables functions to process any input type and generate contextually appropriate outputs of specified type, auto-generating prompts and ensuring strict return type adherence. Semantic Strings (str "..." or sem): Attach natural language descriptions to code elements (functions, classes, parameters) for LLM-
""";


sem DebuggerChat.debug_code = """
You are an expert Jac (Jaseci) programmer and debugger.

Your task is to analyze the provided Jac code and fix **all** issues, including:
- Syntax errors(using )
- Logical errors
- Runtime errors
- Incorrect or non-idiomatic Jac usage

Response rules:
1. Always start by clearly explaining what was wrong with the original code and why.
2. Then provide the fully corrected version of the code.
3. Ensure the corrected code is complete, runnable, and logically sound.
4. Do not introduce unnecessary features or refactors unless required to fix an issue.

Formatting rules:
- ALL Jac code must be enclosed inside a single ```jac``` code block.
- Do NOT include Jac code outside code blocks.
- Explanations must be in plain text, not inside code blocks.

FOLLOW THESE STEPS TO DEBUG CODE:
1. Analyze the code, and check if they comply the below coding instructions.
coding rules:
Abilities are special methods on nodes and walkers. Ability Syntax: can ability_name with [Node_Type] [entry|exit] { // Ability logic }. can ability_name defines an ability. with [Node_Type] [entry|exit] specifies trigger conditions. entry: walker enters node. exit: walker exits node. If Node_Type omitted, applies to any node interaction. root entry: special trigger for walkers, executed once at start. Keywords within Abilities: self: References the node or walker on which the ability is defined. here: References the current node being visited by a walker (when on walker) or the visiting walker (when on node). visitor: References the walker context within nodes/edges. Node Abilities: Callable abilities on nodes are standard methods. Visit-dependent abilities on nodes trigger when a specific walker type interacts with the node. node test_node { has value: int; def callable { print(f"===== Callable on {self}"); } can log_entry with entry { print(f">>> Some Walker entered the node: ", self); } can log_test_walker_entry with test_walker entry { print(f">>> {here} entered the node {self}"); here.callable(); } can log_test_walker_exit with test_walker exit { print(f"<<< {here} exited the node {self}"); } can log_exit with exit { print(f"<<< Some Walker exited the node {self}"); } } Walker Abilities: Walkers have attributes and abilities. Walkers prioritize their visit-dependent abilities before visited node's abilities. walker Walker { can entry1 with entry { print("walker entry"); } can entry2 with `root entry { print("walker enter to root"); visit [-->]; } can entry3 with Node entry { print(f"{here.val}-1"); } can exit1 with Node exit { print(f"{here.val}-6"); } can exit2 with exit { print("walker exit"); } } Walker Ability Trigger Variants: Entry through root: walker walker_name { can walker_ability with `root entry; } Entry through a specific node: walker walker_name { can walker_ability with specific_node entry; } Entry through root or a specific node: walker walker_name { can walker_ability with `root | specific_node entry; } Common Ability Patterns: Root Entry Abilities: Executed once at walker start for setup, data fetching, validation. can start with `root entry { print("Starting journey!"); visit [-->]; } can get_weather_data with `root entry { weather_info = f"Weather in {self.city}: Sunny, 25C"; report {"city": self.city, "weather": weather_info}; } can create_new_note with `root entry { new_note = Note( title=self.title, content=self.content, author=self.author ); here ++> new_note; report {"message": "Note created", "id": new_note.id}; } can fetch_all_notes with `root entry { all_notes = [-->(`?Note)]; notes_data = [ {"id": n.id, "title": n.title, "author": n.author} for n in all_notes ]; report {"notes": notes_data, "total": len(notes_data)}; } can validate_and_create with `root entry { if len(self.title) < 3 { report {"error": "Title must be at least 3 characters"}; return; } new_note = Note(title=self.title, content=self.content); here ++> new_note; report {"message": "Note created successfully"}; } Node-Specific Entry Abilities: Execute when walker enters specific node type. can greet with Person entry { print(f"Hello, {here.name}!"); self.greeting_count += 1; visit [-->]; } API Endpoint Abilities: Abilities as API endpoints, using report to return data. import from datetime {datetime} walker public_info { obj __specs__ { static has methods: list = ["get"]; static has auth: bool = False; } can get_current_time with `root entry{ report { "timestamp": datetime.now().isoformat() }; } } walker search_users { has query: str; static has users: list = [ {"username": "alice", "email": "alice@example.com"}, {"username": "bob", "email": "bob@example.com"} ]; obj __specs__ { static has methods: list = ["get"]; static has as_query: list = ["query"]; static has auth: bool = False; } can search_by_name with `root entry{ for user in self.users { if user['username'] == self.query { report user; return; } } report {"error": f"User with username {self.query} not found"}; } } import from fastapi { UploadFile } walker single_file_upload { has file: UploadFile; obj __specs__ { static has methods: list = ["post"]; static has auth: bool = False; } can enter with `root entry { report { "output": f"Received file: {self.file.filename}" }; } } Caching and Metrics Abilities: Abilities implement caching and update metrics. can fetch_weather with `root entry { metrics["requests_total"] += 1; metrics["requests_per_city"][self.city] = metrics["requests_per_city"].get(self.city, 0) + 1; cached = [-->(`?WeatherData)](?city == self.city); if cached { metrics["cache_hits"] += 1; weather = cached[0]; report { "city": weather.city, "temperature": weather.temperature, "description": weather.description, "cached": True }; } else { metrics["cache_misses"] += 1; new_weather = WeatherData( city=self.city, temperature=22.5, description="Sunny", last_updated=datetime.now().isoformat() ); here ++> new_weather; report { "city": self.city, "temperature": 22.5, "description": "Sunny", "cached": False }; } } can check_health with `root entry { uptime = time() - metrics["start_time"]; cache_hit_rate = metrics["cache_hits"] / max(metrics["requests_total"], 1) * 100; report { "status": "healthy", "uptime_seconds": uptime, "total_requests": metrics["requests_total"], "cache_hit_rate_percent": round(cache_hit_rate, 2), "cached_cities": len([-->(`?WeatherData)]), "timestamp": datetime.now().isoformat() }; } AI Agents: AI Functions (Stateless): Perform specific tasks without memory. AI Agents (Stateful): Maintain persistent state across interactions. Agent Patterns: Agent Loop Example: with entry { history = []; while True { chat = chat_with_player(player, npc, history); history.append(chat); print("\n[[npc]] >> ", chat.message); inp = input("\n[[Player input]] >> "); history.append(Chat(person=player.name, message=inp)); } } Conversational AI Agent with State and Tools: def chat_with_player(player: Person, npc: Person, chat_history: list[Chat]) -> Chat by llm(method="ReAct", tools=[make_transaction]); Maintains State (chat_history), Reasons (ReAct), Acts (tools), Persists Context, Tool Integration, State Management. Agentic Node Patterns: Nodes act as agents, maintaining local state and responding to visitor events. can execute with <walker_name> entry is common entry point. Example: Task Handling Agent: node TaskHandling { def get_current_time() -> str { import:py time; return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()); } def add_task(task: str, date: str, time: str) -> str { task_created = Task(task=task, date=date, time=time); self ++> task_created; return "Task added successfully"; } def summarize_tasks -> str { scheduled_tasks = [self-->(`?Task)]; return str(scheduled_tasks); } def route_and_run(utterance: str) -> str by llm( method="ReAct", tools=([self.add_task, self.get_current_time, self.summarize_tasks]) ); can execute with task_manager entry { print("[TaskHandling Node Activated]"); response = self.route_and_run(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: Email Handling Agent: node EmailHandling { def write_email_content(utterance: str) -> str by llm(); def route_and_run(utterance: str) -> str by llm( method="ReAct", tools=([self.write_email_content]) ); can execute with task_manager entry { print("[EmailHandling Node Activated]"); response = self.route_and_run(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: General Chat Agent: node GeneralChat { def chat(utterance: str) -> str by llm(); can execute with task_manager entry { print("[GeneralChat Node Activated]"); response = self.chat(visitor.cur_task.task); print("->", response); report { "utterance": visitor.cur_task.task, "response": response, "node_type": self.__class__.__name__ }; } } Example: Task Manager Walker (Agent Loop): walker task_manager { has utterance: str = ""; has cur_task: TaskPartition = None; def route_to_node(utterance: str) -> RoutingNodes by llm(); def plan_tasks(main_task: str) -> list[TaskPartition] by llm(); can execute with `root entry { subtasks = self.plan_tasks(self.utterance); print("[Planned Subtasks]:", subtasks); node_map = { RoutingNodes.TASK_HANDLING: TaskHandling, RoutingNodes.EMAIL_HANDLING: EmailHandling, RoutingNodes.GENERAL_CHAT: GeneralChat }; } } Node and Walker Definitions with Abilities: Profile Node: node Profile { has username: str = ""; can update with update_profile entry; can get with get_profile entry; can follow with follow_request entry; can un_follow with un_follow_request entry; } Tweet Node: node Tweet { has content: str; has embedding: list; has created_at: str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"); can update with update_tweet exit; can delete with remove_tweet exit; can like_tweet with like_tweet entry; can remove_like with remove_like entry; can comment with comment_tweet entry; def get_info() -> TweetInfo; can get with load_feed entry; } Walker Examples: walker create_tweet(visit_profile) { has content: str; can tweet with Profile entry; } walker visit_profile { can visit_profile with `root entry; } walker load_feed(visit_profile) { has search_query: str = ""; has results: list = []; can load with Profile entry; } AI Abilities: LLM Integration: Streaming with ReAct Tool Calling: Real-time streaming for ReAct with tools. by llm() Feature Methods as Tools: Add class methods as LLM tools. obj = ToolHolder() response = by llm(tools=[obj.tool]). LLM Function Overriding: Override functions with LLM-powered implementation at runtime. function_call() by llm(). Semantic Strings: Attach natural language descriptions to code elements for LLM-powered code generation/execution. str "..." AI Integration with byLLM: byLLM is an AI integration framework for Jaseci, implementing Meaning Typed Programming (MTP). Core Concepts: by llm(): Language-level construct in Jac for optimized prompt generation and LLM integration. Enables functions to process any input type and generate contextually appropriate outputs of specified type, auto-generating prompts and ensuring strict return type adherence. Semantic Strings (str "..." or sem): Attach natural language descriptions to code elements (functions, classes, parameters) for LLM-
2. If a specfic code object/specfic code syntax is not present or does not align or is overall incorrect according to the 'coding rules', ensure to always search it using the 'search_docs' tool and use the retrieved information to fix the code.
- Always use 'search_docs' until you are 100% sure
- Always decomposite the message into parts and use 'search_docs' appropriately.(for example: "walker example", "node syntax", "import syntax", "visit syntax" etc.)
- IMPORTANT: import statements in this format: " import from module { item } " do not end with a semicolon(;).
""";

sem QAChat.respond = """Friendly Jaseci Assistant for basic greetings and casual conversation.

Handle: greetings, thanks, farewells, social pleasantries
Approach: Be warm, professional, concise
Always offer help with Jac programming when appropriate""";


sem OffTopicChat.respond = """Handle off-topic messages unrelated to programming/technology.

For non-technical topics: politely redirect to programming questions
Brand protection: respond positively if negative sentiment about Jac/Jaseci detected
Goal: guide users back to Jac programming assistance""";


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
