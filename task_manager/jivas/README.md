## Task Manager - JIVAS Project

This is an agentic task manager built on the [JIVAS](https://github.com/TrueSelph/jivas) framework. It detects task-related intents from natural conversation, schedules tasks, and interacts intelligently with users using agentic AI logic.

---

### Setup Instructions

Follow the steps below to set up and run the Task Manager application.

#### 1. Clone the Repository

```bash
git clone https://github.com/jaseci-labs/Agentic-AI.git
cd Agentic-AI/task_manager
```

#### 2. Navigate to the `jac` Directory

```bash
cd jivas
```

#### 3. Create a Virtual Environment and Activate It

```bash
python3 -m venv venv
source venv/bin/activate     # On Windows: venv\Scripts\activate
```

#### 4. Install Required Packages

you can install all dependencies via the provided requirements.txt

```bash
pip install -r requirements.txt
```

---

### Running the Project

#### 5. Launch the Server

```bash
jvcli server launch
```

Before launching the server, ensure you have set the required environment variables for authentication. If you encounter an error like:

```bash
Missing JIVAS_USER or JIVAS_PASSWORD
```

please run the following commands in your terminal:

```bash
export JIVAS_USER=admin@jivas.com
export JIVAS_PASSWORD=password
```

#### 6. Initialize the Agent

- First-time setup (in a new terminal):

```bash
jvcli server importagent jaseci/task_manager 0.0.1
```

- Subsequent runs:

```bash
jvcli server initagents
```

---

#### Using the Interact Walker

Once the server is running and the agent is initialized, you can interact with it by sending a request to:

```bash
POST http://localhost:8000/walker/interact/interact
```

**Sample JSON Payload**

```json
{
  "utterance": "{{YOU CAN ASK THE QUESTION HERE}}",
  "session_id": "{{SESSION_ID}}",
  "agent_id": "{{AGENT_ID}}",
  "tts": "false",
  "data": {},
  "verbose": "false",
  "streaming": "false"
}
```

**OpenAI API Key Configuration**

To enable LLM-based responses, set your OpenAI API key using the following request:

```bash
POST http://localhost:8000/walker/update_action
```

**Sample JSON Payload**

```json
{
  "reporting": true,
  "agent_id": "{{AGENT_ID}}",
  "action_id": "n:LangChainModelAction:688f65a4f45c35658ca0fb2e",
  "action_data": {
    "api_key": "type api key here"
  }
}
```

---

#### Useful Walkers

Here are some useful endpoints to help manage and debug your setup:

- POST /user/login – login user
- POST /walker/list_agents – list all agents
- POST /walker/list_actions – list all actions

---

-> **Visit [here](docs/README.md) to follow the Tutorial to build Task Manager.**