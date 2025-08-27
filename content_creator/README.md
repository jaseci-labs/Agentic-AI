# Multi-Agent Content Creator
# Content Creator v1

A modular, agent-based content creation system built in Python.

## Project Structure

```
content_creator_v1/
│
├── .env                   # Environment variables
├── main.py                # Entry point for the application
├── requirements.txt       # Python dependencies
├── state.py               # State management logic
│
├── agents/                # Specialized agents for content creation
│   ├── editor_agent.py
│   ├── media_agent.py
│   ├── trend_agent.py
│   └── writer_agent.py
│
└── core/                  # Core logic and utilities
    └── graph.py
```

## Architecture Overview

- **main.py**  
  Orchestrates the content creation workflow by coordinating agents and managing state.

- **state.py**  
  Handles the application's state, including data persistence and transitions.

- **agents/**  
  Contains specialized agents, each responsible for a specific aspect of content creation:
  - `trend_agent.py`: Analyzes trends to inform content strategy.
  - `writer_agent.py`: Generates written content.
  - `editor_agent.py`: Edits and refines content by `write_agent`.
  - `media_agent.py`: Handles image integration using DALL-E 2.
