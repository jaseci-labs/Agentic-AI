# Content Creator (Agentic-AI)

An agentic, modular content creation pipeline built with Jac and Python. This project automates the generation of trending topics, detailed articles, and media assets using a graph-based workflow and multiple specialized agents.

---

## Features

- **Agentic Workflow:** Modular Jac agents for trend detection, writing, editing, and media generation.
- **Graph-Based Orchestration:** Flexible workflow defined in `graph.jac` and `app.jac`.
- **Automated Content Generation:** Produces trending topics, detailed articles, and associated images.
- **State Management:** Tracks workflow state and results in `state.jac`.
- **Extensible:** Easily add or modify agents for new content types or workflows.

---

## Project Structure

| File/Folder              | Description                                      |
|--------------------------|--------------------------------------------------|
| `main.jac`               | Entry point Jac script for running the workflow  |
| `app.jac`                | Application logic and workflow orchestration     |
| `graph.jac`              | Defines the workflow graph and agent connections |
| `state.jac`              | State management for the workflow                |
| `trend_agent.jac`        | Agent for detecting trending topics              |
| `writer_agent.jac`       | Agent for generating article content             |
| `editor_agent.jac`       | Agent for editing and refining articles          |
| `media_agent.jac`        | Agent for generating images/media                |
| `input.json`             | Example input for workflow                       |
| `generated_article_final.md` | Output: generated article                    |
| `generated_article_image.png` | Output: generated image                     |
| `trending_topics.md`     | Output: trending topics list                     |
| `requirements.txt`       | Python dependencies                              |
| `.env`                   | Environment variables (API keys, etc.)           |

---

## Getting Started

### Prerequisites

- Python 3.10+
- [Jac language](https://www.jac-lang.org/) (install via `pip install jac[all]`)
- Required API keys (set in `.env` if using LLMs or image generation)

### Installation

```bash
# Clone the repository
git clone <this-repo-url>
cd content_creator

# Install Python dependencies
pip install -r requirements.txt

# Running the Workflow
jac streamlit app.jac
```

### Outputs
- generated_article_final.md — The final generated article.
- generated_article_image.png — Associated image for the article.
- trending_topics.md — List of trending topics detected.
