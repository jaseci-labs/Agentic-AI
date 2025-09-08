#!/usr/bin/env python3
# Step 3: LLM-based router + TaskHandling (in-memory) + Email draft (no send)

import os
import re
import json
from datetime import datetime, timedelta
from typing import List, TypedDict, Literal, Dict, Any

from dotenv import load_dotenv
from langgraph.graph import StateGraph, START, END
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage, BaseMessage
from langchain_core.prompts import ChatPromptTemplate

load_dotenv()

# ===== LLM =====
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o")
llm = ChatOpenAI(model=MODEL, temperature=0)

# ===== In-memory tasks =====
TASKS: List[Dict[str, Any]] = []
TASK_COUNTER = 0
def _next_task_id() -> int:
    global TASK_COUNTER
    TASK_COUNTER += 1
    return TASK_COUNTER

# ===== State =====
class AppState(TypedDict, total=False):
    utterance: str
    history: List[BaseMessage]
    route: Literal["TASK_HANDLING", "EMAIL_HANDLING", "GENERAL_CHAT"]
    task_action: Literal["EXTRACT_AND_ADD", "SUMMARIZE"]
    response: str

# ===== Prompts =====
ROUTER_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You are a strict router. Decide the next node for the user's latest message.
Choices:
- TASK_HANDLING: adding/listing/summarizing tasks, deadlines, schedules, reminders.
- EMAIL_HANDLING: drafting or sending emails.
- GENERAL_CHAT: everything else.

Return ONLY valid JSON on one line, exactly:
{{"route":"TASK_HANDLING"|"EMAIL_HANDLING"|"GENERAL_CHAT"}}"""),
    ("human", "History:\n{history}\n\nUser: {utterance}")
])

EMAIL_DRAFT_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You generate a complete email draft.
If no recipient is specified, put a reasonable placeholder like someone@example.com and greet with 'Hi'.
Return ONLY JSON on one line:
{{"to":"someone@example.com","subject":"...","body":"..."}}"""),
    ("human", "History:\n{history}\n\nUser request:\n{utterance}")
])

TASK_DECIDER_PROMPT = ChatPromptTemplate.from_messages([
    ("system", """You decide which ONE tool to use for TaskHandling.
Options:
- EXTRACT_AND_ADD: if the user is describing a new task to schedule/add.
- SUMMARIZE: if the user asks to summarize, list, or show existing tasks.

Return ONLY valid JSON on one line:
{{"task_action":"EXTRACT_AND_ADD"|"SUMMARIZE"}}"""),
    ("human", "History:\n{history}\n\nUser: {utterance}")
])

# ===== Minimal date/time parsing for tasks =====
DATE_RE = re.compile(r"\b(\d{4})-(\d{2})-(\d{2})\b")
TIME_RE = re.compile(r"\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b", re.I)

def normalize_datetime(utterance: str) -> tuple[str, str]:
    now = datetime.now()
    date_part = None
    time_part = None
    text = utterance.lower()

    if "tomorrow" in text:
        date_base = (now + timedelta(days=1)).date()
        date_part = datetime.combine(date_base, datetime.min.time())
    elif "today" in text:
        date_base = now.date()
        date_part = datetime.combine(date_base, datetime.min.time())

    m_date = DATE_RE.search(utterance)
    if m_date:
        y, mo, d = map(int, m_date.groups())
        date_part = datetime(y, mo, d)

    m_time = TIME_RE.search(utterance)
    if m_time:
        hh = int(m_time.group(1))
        mm = int(m_time.group(2) or 0)
        ap = (m_time.group(3) or "").lower()
        if ap == "pm" and hh != 12: hh += 12
        if ap == "am" and hh == 12: hh = 0
        time_part = (hh, mm, 0)

    if date_part and time_part:
        dt = datetime(date_part.year, date_part.month, date_part.day, *time_part)
    elif date_part:
        dt = datetime(date_part.year, date_part.month, date_part.day, 0, 0, 0)
    elif time_part:
        dt = datetime(now.year, now.month, now.day, *time_part)
    else:
        dt = now

    return dt.strftime("%Y-%m-%d %H:%M:%S"), dt.strftime("%H:%M:%S")

# ===== Nodes =====
def router_llm_node(state: AppState) -> AppState:
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m,'content','')}" for m in state.get("history", [])[-10:]
    )
    result = (ROUTER_PROMPT | llm).invoke({"history": hist_txt, "utterance": state.get("utterance","")}).content
    try:
        data = json.loads(result)
        route = data.get("route", "GENERAL_CHAT")
        if route not in {"TASK_HANDLING", "EMAIL_HANDLING", "GENERAL_CHAT"}:
            route = "GENERAL_CHAT"
    except Exception:
        route = "GENERAL_CHAT"
    state["route"] = route  # type: ignore
    return state

def task_decider_node(state: AppState) -> AppState:
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m,'content','')}"
        for m in state.get("history", [])[-10:]
    )
    raw = (TASK_DECIDER_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": state.get("utterance", "")
    }).content

    try:
        data = json.loads(raw)
        action = data.get("task_action", "EXTRACT_AND_ADD")
        if action not in {"EXTRACT_AND_ADD", "SUMMARIZE"}:
            action = "EXTRACT_AND_ADD"
    except Exception:
        action = "EXTRACT_AND_ADD"
    
    state["task_action"] = action
    return state

def task_add_node(state: AppState) -> AppState:
    user = state.get("utterance", "").strip()
    task_text = re.sub(r"\b(add task|remind me to|remind me|i need to|need to|submit|schedule|deadline)\b",
                       "", user, flags=re.I).strip() or user
    date_full, time_str = normalize_datetime(user)
    tid = _next_task_id()
    TASKS.append({
        "id": tid, "task": task_text, "date": date_full, "time": time_str,
        "status": "pending", "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })
    state["response"] = f"Task: {task_text}, Date: {date_full}, Time: {time_str} is added successfully (id={tid})."
    return state

def task_summarize_node(state: AppState) -> AppState:
    if not TASKS:
        state["response"] = "No tasks found."
        return state
    lines = [
        f"- [{t['status']}] (#{t['id']}) {t['task']} — {t['date']} / {t['time']}"
        for t in sorted(TASKS, key=lambda x: x["id"], reverse=True)
    ]
    state["response"] = "Here are your tasks:\n" + "\n".join(lines)
    return state

def email_draft_node(state: AppState) -> AppState:
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m,'content','')}" for m in state.get("history", [])[-10:]
    )
    raw = (EMAIL_DRAFT_PROMPT | llm).invoke({"history": hist_txt, "utterance": state.get("utterance","")}).content
    try:
        data = json.loads(raw)
        draft = f"To: {data.get('to','someone@example.com')}\nSubject: {data.get('subject','')}\n\n{data.get('body','')}"
        state["response"] = "Here is your email draft (sending is not enabled in this step):\n\n" + draft
    except Exception as e:
        state["response"] = f"Couldn't prepare the email draft. ({e})"
    return state

def general_chat_node(state: AppState) -> AppState:
    print("*****general_chat*****")
    history = state.get("history", [])
    utterance = state.get("utterance", "")
    messages = [SystemMessage(content="You are a concise, helpful assistant.")] + history[-10:] + [HumanMessage(content=utterance)]
    result = llm.invoke(messages)
    state["response"] = result.content
    return state

# ===== Graph =====
def build_graph():
    graph = StateGraph(AppState)

    graph.add_node("router", router_llm_node)

    # TaskHandling
    graph.add_node("task_decider", task_decider_node)
    graph.add_node("task_add", task_add_node)
    graph.add_node("task_summarize", task_summarize_node)

    # Email
    graph.add_node("email_draft", email_draft_node)

    # General chat
    graph.add_node("general_chat", general_chat_node)

    # Edges
    graph.add_edge(START, "router")
    graph.add_conditional_edges(
        "router",
        lambda s: s["route"],
        {
            "TASK_HANDLING": "task_decider",
            "EMAIL_HANDLING": "email_draft",
            "GENERAL_CHAT": "general_chat",
        },
    )
    graph.add_conditional_edges(
        "task_decider",
        lambda s: s["task_action"],
        {
            "EXTRACT_AND_ADD": "task_add",
            "SUMMARIZE": "task_summarize",
        },
    )
    graph.add_edge("task_add", END)
    graph.add_edge("task_summarize", END)
    graph.add_edge("email_draft", END)
    graph.add_edge("general_chat", END)

    return graph.compile()

# ===== CLI =====
def main():
    app = build_graph()
    history: List[BaseMessage] = []

    print("TaskManager (Step 3). Type 'exit' to quit.")
    print("Examples:")
    print(" - 'I need to submit the report by tomorrow 7pm'  (TaskHandling → add)")
    print(" - 'summarize tasks'                              (TaskHandling → summarize)")
    print(" - 'email Brian about the meeting next week'      (EmailHandling → draft)")
    while True:
        user = input("You: ").strip()
        if user.lower() in {"exit", "quit"}:
            print("Bye.")
            break

        state: AppState = {"utterance": user, "history": history}
        out = app.invoke(state)
        reply = out.get("response", "")
        print("\nAssistant:", reply, "\n")

        history.append(HumanMessage(content=user))
        history.append(AIMessage(content=reply))

if __name__ == "__main__":
    main()
