# Task Manager - byLLM Project

This is the **byLLM (Multi-Tool Prompting)** implementation of the Task Manager. It demonstrates how to build an agentic application using a toolbox + tool-based approach within JacLang.

---

## Setup Instructions

Follow the steps below to set up and run the Task Manager using byLLM.

### 1. Clone the Repository

```bash
git clone https://github.com/jaseci-labs/Agentic-AI.git
cd Agentic-AI/task_manager
```

### 2. Clone the Repository

```bash
cd byllm
```

### 3. Create a Virtual Environment and Activate It

```bash
python3 -m venv venv
source venv/bin/activate     # On Windows: venv\Scripts\activate
```

### 4. Create a Virtual Environment and Activate It

Create a .env file in the byllm directory and set the required variables there.
At minimum, you’ll need to provide your LLM provider key (for example, OpenAI):

```bash
export OPENAI_API_KEY=sk-xxxxx
```

### 5. Install Required Packages

You can either install directly:

```bash
pip install byllm jac-cloud
```

Or use the provided requirements file:

```bash
pip install -r requirements.txt
```

### 6. Navigate to the Implementation Version

There are multiple implementations of the Task Manager under byLLM. For example:

```bash
cd v1
```

### 7. Run the Application

```bash
jac serve main.jac
```

This will start a local server with the defined walkers.

## Using the Application

### Task Manager Agent Walker

Start a new session by sending a request to:

```http
POST /walker/task_manager
```

Sample JSON Payload

```json
{
  "utterance": "Need to check all the tasks",
  "session_id": ""
}
```

- For the first message, set "session_id": "".
- The system will return a new session ID.
- Use that session ID for all subsequent messages to continue the conversation.

### Get All Sessions

List all session IDs by calling:

```http
POST /walker/get_all_sessions
````

With this setup, you can chat with the agent, create tasks, view task summaries, and send emails - all through natural conversation powered by byLLM.