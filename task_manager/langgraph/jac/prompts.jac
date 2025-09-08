import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import os;

glob MODEL = os.getenv("OPENAI_MODEL", "gpt-4o");
glob llm = ChatOpenAI(model=MODEL, temperature=0);

glob ROUTER_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You are a strict router. Decide the next node for the user's latest message.
Choices:
- TASK_HANDLING: adding/listing/summarizing tasks, deadlines, schedules, reminders.
- EMAIL_HANDLING: drafting or sending emails.
- GENERAL_CHAT: everything else.

Return ONLY valid JSON on one line, exactly:
{{"route":"TASK_HANDLING"|"EMAIL_HANDLING"|"GENERAL_CHAT"}}"""),
    ("human", "History:\n{history}\n\nUser: {utterance}")
]);

glob EMAIL_DRAFT_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You generate a complete email draft.
If no recipient is specified, put a reasonable placeholder like someone@example.com and greet with 'Hi'.
Return ONLY JSON on one line:
{{"to":"someone@example.com","subject":"...","body":"..."}}"""),
    ("human", "History:\n{history}\n\nUser request:\n{utterance}")
]);

glob TASK_DECIDER_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You decide which ONE tool to use for TaskHandling.
Options:
- EXTRACT_AND_ADD: if the user is describing a new task to schedule/add.
- SUMMARIZE: if the user asks to summarize, list, or show existing tasks.

Return ONLY valid JSON on one line:
{{"task_action":"EXTRACT_AND_ADD"|"SUMMARIZE"}}"""),
    ("human", "History:\n{history}\n\nUser: {utterance}")
]);

glob EMAIL_DECIDER_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You decide what email action the user wants to take. 
Options:
- DRAFT: when the user is describing a new email to compose.
- SEND: when the user says "yes", "send", or otherwise confirms sending.

Return ONLY one-line JSON:
{{"action":"DRAFT"|"SEND"}}"""),
    ("human", "History:\n{history}\n\nUser: {utterance}")
]);

glob TASK_EXTRACT_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """Extract a single task from the user's message.

Return ONLY one-line JSON:
{{"task":"<concise task text>",
  "date":"YYYY-MM-DD or empty string",
  "time":"HH:MM[:SS] 24h or empty string"}}

Rules:
- Be concise in "task" (no filler like 'I need to', 'please').
- If date or time not given, return "" (empty string).
- If user wrote 'today'/'tomorrow' or natural time like '7pm', convert to concrete values in the required formats.
- Do NOT include extra keys; output must be valid JSON on one line."""),
    ("human", "History:\n{history}\n\nUser:\n{utterance}")
]);
