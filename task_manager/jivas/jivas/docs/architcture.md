
# JIVAS Architecture for Task Manager

This section provides an overview of how the Task Manager is structured and operates within the JIVAS platform.



## System Overview

The Task Manager leverages JIVAS’s agentic architecture to manage tasks through natural language interactions. The agent interprets user input, interacts with custom actions, and updates or queries the task database.



## Architecture Diagram

<img src="../../assets/task_manager_jivas_architecture.png" alt="Task Manager using JIVAS Architecture" width="500"/>


## Key Components

- **Task Manager Agent:** The central entity that coordinates all actions and manages user sessions.
- **Custom Actions:**
  - `routing_interact_action`: Manages routing and interaction logic.
  - `tasks_handling_action`: Handles creating, listing, and managing tasks.
  - `email_handling_action`: Supports email-related features.
- **Default JIVAS Actions:** Provide LLM interaction, persona management, and agent utilities.


## How It Works

1. **User Interaction:**  
  Users interact with the agent via chat.

2. **Intent Detection:**  
  The agent uses LLM-powered actions to understand user requests (e.g., add, list tasks).

3. **Action Execution:**  
  Relevant custom actions are triggered:
    - New tasks creation.
    - Listing tasks summarizes current schedule.
    - Routing and persona actions enhance conversational flow.

4. **Response:**  
  The agent responds with task details, suggestions, or confirmations.


## Extensibility

The architecture is modular - new actions can be added to extend functionality (e.g., notifications, integrations).

---

This overview sets the stage for the next steps, where you’ll learn to implement and customize each part of the Task Manager in JIVAS.


**Next:** Return to the [Main Tutorial Table of Contents](./README.md) to continue create actions.