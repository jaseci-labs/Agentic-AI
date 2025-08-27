# Multi-Agent Content Creator
# Content Creator v1

A modular, agent-based content creation system built in Jac.

## Project Structure

```
content_creator_v1_jac/
│
├── .env                   # Environment variables
├── main.jac              # Entry point for the application
├── requirements.txt       
├── state.jac             # State management logic
│
├── agents/                # Specialized agents for content creation
│   ├── editor_agent.jac
│   ├── media_agent.jac
│   ├── trend_agent.jac
│   └── writer_agent.jac
│
└── core/                  # Core logic and utilities
    └── graph.jac
```

## Architecture Overview

- **main.jac**  
  Orchestrates the content creation workflow by coordinating agents and managing state.

- **state.jac**  
  Handles the application's state, including data persistence and transitions.

- **agents/**  
  Contains specialized agents, each responsible for a specific aspect of content creation:
  - `trend_agent.jac`: Analyzes trends to inform content strategy.
  - `writer_agent.jac`: Generates written content.
  - `editor_agent.py`: Edits and refines content by `write_agent`.
  - `media_agent.py`: Handles image integration using DALL-E 2.
