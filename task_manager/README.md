# Task Manager using JIVAS

**Task Manager using JIVAS** is a task manager application being developed using the [Jivas](https://github.com/TruSelph/jivas) platform. It allows users to manage tasks through a chat interface. The system identifies when the user is referring to a task, checks existing tasks for scheduling conflicts, and suggests or creates new tasks accordingly.

---

## Overview

Task Manager using JIVAS is designed to simplify task management through natural conversation.

- When a user mentions a task in chat:
  - The system detects and extracts task details
  - It checks current tasks to find any scheduling conflicts
  - It suggests free time slots or directly adds the task

Planned features include:
- Summarizing scheduled tasks
- Responding to questions about the current schedule
- Allowing task edits and deletions via chat

---

## Key Features (Planned)

- Chat-based task creation
- Conflict checking and time slot suggestions
- Viewing and summarizing tasks
- Agent-driven task updates and logic

---

## Architecture Overview

<img src="assets/task_manager_jivas_architecture.png" alt="Task Manager using JIVAS Architecture" width="500"/>

---

## Repositories

- Implementation: [chat-powered-task-agent](jac/README.md)
- Based on: [Jivas](https://github.com/TrueSelph/jivas.git)

---

## Project Status

This repository is for documentation and planning. Development will take place in the implementation repository.
