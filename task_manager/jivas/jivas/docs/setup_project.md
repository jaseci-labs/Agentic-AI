# JIVAS Project Setup Guide

Follow these steps to set up your environment and initialize your JIVAS project before building the Task Manager application.

## 1. Create a Python Virtual Environment

It is recommended to use a virtual environment to isolate your project dependencies.

```bash
python3 -m venv venv
source venv/bin/activate
```

## 2. Install Jivas via PyPI

Install the Jivas library and its CLI tools (`jvcli`, `jvserve`) using pip:

```bash
pip install jivas
```

## 3. JIVAS Package Repository (JPR)

JPR is used to store and share your created actions. You need to sign up and log in before publishing or installing actions.

### Sign Up for JPR

You can sign up interactively or by providing parameters:

```bash
# Interactive signup
jvcli signup

# With parameters
jvcli signup --username myusername --email user@example.com --password mypassword
```

After successful signup, your authentication token will be saved locally.

### Log In to JPR

Log in to access JPR features:

```bash
jvcli login
```

## 4. Start a New Jivas Project

Initialize your project with all necessary scaffolding and folder structure:

```bash
jvcli startproject task_manager
```

This will create a directory structure as follows.

```
task_manager
├── actions
├── daf
├── tests
├── .env
├── .gitignore
├── env.example
├── globals.jac
├── main.jac
└── README.md
```

You are now ready to begin building your Task Manager application using Jivas!

---

## 6. Create an Agent

Agents are the main building blocks of JIVAS applications. Use the following command to create a new agent with all necessary configuration files:

```bash
jvcli create agent --name task_manager
```

This will create the following structure inside the `daf` folder:

```
daf/{your_name_space}/task_manager
├── descriptor.yaml
├── info.yml
├── knowledge.yaml
├── memory.yaml
```

- `info.yml`: Contains basic metadata about the agent.
- `descriptor.yaml`: Defines agent details, including the list of actions.

### Registering Actions

In `descriptor.yaml`, you’ll find an `actions` attribute. Here, you can list default JIVAS actions (such as `intro_interact_action`, `persona_interact_action`, `agent_utils_action`, `langchain_model_action`) and any custom actions you create.

To create a new action:

```bash
jvcli create action --name my_action --version 0.0.1 --description "My first action"
```

After creating a custom action, add its details under the `actions` section in `descriptor.yaml`.

---

## 7. Validate Initial Setup

Before building task manager-specific actions, validate your JIVAS project setup:

### Launch the Jivas Server

```bash
jvcli server launch
```

This starts the server (default: `localhost:8000`).

### Import the Agent

Use the `/walker/import_agent` endpoint to register your agent and its actions:

```json
POST /walker/import_agent
{
    "reporting": true,
    "daf_name": "{your_namespace}/task_manager"
}
```

If successful, all actions in `descriptor.yaml` are registered.

### List Agents

Get agent details and IDs:

```json
POST /walker/list_agents
{
	"reporting": true
}
```

### List Actions

Get all registered actions for your agent:

```json
POST /walker/list_actions
{
	"reporting": true,
	"agent_id": "{{AGENT_ID}}"
}
```

### Update LLM API Key

```json
POST /walker/list_actions
{
	"reporting": true,
	"agent_id": "{{AGENT_ID}}",
	"action_id": "n:LangChainModelAction:68addbcc148f9ebad6bc3121",
	"action_data": {
		"api_key": "your_openai_api_key"
	}
}
```

### Test Agent Interaction

Send a message to your agent:

```json
POST /interact
{
	"utterance": "Hello how are you",
	"session_id": "",
	"agent_id": "{{AGENT_ID}}",
	"tts": "false",
	"data": {},
	"verbose": "false",
	"streaming": "false"
}
```

If you receive a valid response, your setup is complete and actions are registered successfully.

> **Note:** Only call the import agent endpoint when registering new actions. Re-importing is not needed unless you update the agent or actions.

---

Continue to [Architecture Overview](./architcture.md).
