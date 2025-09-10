#!/usr/bin/env python3
# Step 3: LLM-based router + TaskHandling (in-memory) + Email draft (no send)

import os
import re
import json
from datetime import datetime
from typing import List, TypedDict, Literal, Dict, Any
from email.mime.text import MIMEText
import smtplib;

from dotenv import load_dotenv
from langgraph.graph import StateGraph, START, END
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage, BaseMessage

from task_manager_prompts import (
    ROUTER_PROMPT,
    EMAIL_DRAFT_PROMPT,
    TASK_DECIDER_PROMPT,
    EMAIL_DECIDER_PROMPT,
    TASK_EXTRACT_PROMPT,
)

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
    email_action: Literal["DRAFT","SEND"]
    email_to: str
    email_subject: str
    email_content: str
    response: str

# ===== Minimal date/time parsing for tasks =====
DATE_RE = re.compile(r"\b(\d{4})-(\d{2})-(\d{2})\b")
TIME_RE = re.compile(r"\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b", re.I)

def normalize_from_fields(date_s: str, time_s: str) -> tuple[str, str]:
    """
    Inputs from LLM:
      date_s: 'YYYY-MM-DD' or ''
      time_s: 'HH:MM' or 'HH:MM:SS' or ''
    Returns:
      date_full: 'YYYY-MM-DD HH:MM:SS'
      time_only: 'HH:MM:SS'
    Fills missing parts using today's date or 00:00:00.
    """
    now = datetime.now()

    # date
    if date_s:
        try:
            d = datetime.strptime(date_s, "%Y-%m-%d")
        except ValueError:
            d = datetime(now.year, now.month, now.day)
    else:
        d = datetime(now.year, now.month, now.day)

    # time
    if time_s:
        # support HH:MM or HH:MM:SS
        for fmt in ("%H:%M:%S", "%H:%M"):
            try:
                t = datetime.strptime(time_s, fmt)
                hh, mm, ss = t.hour, t.minute, t.second
                break
            except ValueError:
                continue
        else:
            hh, mm, ss = 0, 0, 0
    else:
        hh, mm, ss = 0, 0, 0

    dt = datetime(d.year, d.month, d.day, hh, mm, ss)
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
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m,'content','')}"
        for m in state.get("history", [])[-10:]
    )
    utter = state.get("utterance", "").strip()
    raw = (TASK_EXTRACT_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": utter
    }).content
    
    try:
        data = json.loads(raw)
        task_text = (data.get("task") or "").strip()
        date_s = (data.get("date") or "").strip()
        time_s = (data.get("time") or "").strip()

        if not task_text:
            raise ValueError("empty task")

        # 3) Normalize date/time to canonical forms
        date_full, time_only = normalize_from_fields(date_s, time_s)

        # 4) Save task
        tid = _next_task_id()
        TASKS.append({
            "id": tid,
            "task": task_text,
            "date": date_full,
            "time": time_only,
            "status": "pending",
            "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        })

        state["response"] = (
            f"Task: {task_text}, Date: {date_full}, Time: {time_only} "
            f"is added successfully (id={tid})."
        )
    except Exception as e:
        state["response"] = f"Couldn't add the task. ({e})"
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


def email_decider_node(state: AppState) -> AppState:
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m, 'content', '')}"
        for m in state.get("history", [])[-10:]
    )
    raw = (EMAIL_DECIDER_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": state.get("utterance", "")
    }).content
    try:
        data = json.loads(raw)
        action = data.get("action", "DRAFT")
        if action not in {"DRAFT", "SEND"}:
            action = "DRAFT"
    except Exception:
        action = "DRAFT"
    state["email_action"] = action
    return state

def email_draft_node(state: AppState) -> AppState:
    hist_txt = "\n".join(
        f"{type(m).__name__}: {getattr(m,'content','')}" for m in state.get("history", [])[-10:]
    )
    raw = (EMAIL_DRAFT_PROMPT | llm).invoke({"history": hist_txt, "utterance": state.get("utterance","")}).content
    try:
        data = json.loads(raw)
        draft = f"To: {data.get('to','')}\nSubject: {data.get('subject','')}\n\n{data.get('body','')}"
        state["response"] = "Here is your email draft (sending is not enabled in this step):\n\n" + draft + "\n\n(To send this email, please confirm it.)"
        state["email_to"] = data.get("to","")
        state["email_subject"] = data.get("subject","")
        state["email_content"] = data.get("body","")
    except Exception as e:
        state["response"] = f"Couldn't prepare the email draft. ({e})"
    return state

def send_email(state: AppState) -> AppState:
    email_to = (state.get("email_to") or "").strip()
    email_subject = (state.get("email_subject") or "").strip()
    email_content = state.get("email_content") or ""

    if not email_to or email_to == "someone@example.com":
        state["response"] = "No valid recipient found. Please include a real 'to' address."
        return state
    if not email_subject:
        state["response"] = "Subject is empty. Please add a subject before sending."
        return state
    if not email_content.strip():
        state["response"] = "Body is empty. Please add content before sending."
        return state

    msg = MIMEText(email_content, _charset="utf-8")
    msg["Subject"] = email_subject
    msg["From"] = os.getenv("SENDER_EMAIL")
    msg["To"] = email_to

    try:
        server = smtplib.SMTP("smtp.gmail.com", 587, timeout=30)
        server.ehlo()
        server.starttls()
        server.ehlo()
        server.login(os.getenv("SENDER_EMAIL"), os.getenv("SENDER_PASSWORD"))
        server.sendmail(os.getenv("SENDER_EMAIL"), [email_to], msg.as_string())  # list!
        server.quit()
        state["response"] = f"Email sent to {email_to} with subject '{email_subject}'."
    except Exception as e:
        state["response"] = f"Failed to send email. ({e})"
    return state


def general_chat_node(state: AppState) -> AppState:
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
    graph.add_node("email_decider", email_decider_node)
    graph.add_node("email_draft", email_draft_node)
    graph.add_node("email_send", send_email) 

    # General chat
    graph.add_node("general_chat", general_chat_node)

    # Edges
    graph.add_edge(START, "router")
    graph.add_conditional_edges(
        "router",
        lambda s: s["route"],
        {
            "TASK_HANDLING": "task_decider",
            "EMAIL_HANDLING": "email_decider",
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
    graph.add_conditional_edges(
        "email_decider",
        lambda s: s["email_action"],
        {
            "DRAFT": "email_draft",
            "SEND": "email_send",
        },
    )

    graph.add_edge("task_add", END)
    graph.add_edge("task_summarize", END)
    graph.add_edge("email_draft", END)
    graph.add_edge("email_send", END)
    graph.add_edge("general_chat", END)

    return graph.compile()

def main():
    app = build_graph()
    history: List[BaseMessage] = []
    last_state: Dict[str, Any] = {}

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

        carry_keys = {"email_to", "email_subject", "email_content"}
        carry_forward = {k: v for k, v in last_state.items() if k in carry_keys}

        state: AppState = {"utterance": user, "history": history, **carry_forward}
        out = app.invoke(state)
        reply = out.get("response", "")
        print("\nAssistant:", reply, "\n")

        history.append(HumanMessage(content=user))
        history.append(AIMessage(content=reply))
        last_state = out

if __name__ == "__main__":
    main()
