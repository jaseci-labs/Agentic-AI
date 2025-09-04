# Task Manager - Overview

The **Task Manager** is an example agentic application built in jaclang to demonstrate how  tasks can be managed through natural conversation with an agent.  

It is implemented in two different ways using the frameworks available in the Jaseci ecosystem: [**JIVAS**](https://github.com/TrueSelph/jivas) and [**byLLM (MTP)**](https://www.jac-lang.org/learn/jac-byllm/with_llm).

Both frameworks are based on the [**Object Spatial Programming (OSP)**](https://www.jac-lang.org/jac_book/chapter_8) paradigm that JacLang introduces, which makes it possible to model agents, sessions, and tools as connected objects in a **graph-like space.**

---

## What It Can Do

The application works like a **chatbot with agentic capabilities**. Based on the user's message and conversation history, the agent decides what to do:

- **General Chat**  
  When the user asks a normal question, the agent simply chats with the LLM and responds naturally.

- **Task Handling**  
  If the user says something like *“I have to submit my report tomorrow at 5 PM”*, the agent extracts the details and creates a new task.

- **Task Summaries**  
  If the user asks *“What tasks are scheduled?”*, the agent retrieves all tasks from memory and provides a concise summary.

- **Email Handling**  
  If the user says *“Send an email to John with the meeting notes”*, the agent drafts the email and shows it for confirmation.  
  Only after explicit confirmation does the agent send the email.

All of these decisions are made dynamically based on **conversation context and history**.

---

## Framework Implementations

The same Task Manager is implemented in two different ways:

- [**JIVAS**](./jivas/README.md)
- [**byLLM (Multi-Tool Prompting)**](./byllm/README.md) 

Both versions provide the same functionality, but follow different architectural approaches.

---

## How to Set Up

Each implementation includes its own setup guide:

- [Visit JIVAS version](./jivas/README.md)  
- [Visit byLLM version](./byllm/README.md)
