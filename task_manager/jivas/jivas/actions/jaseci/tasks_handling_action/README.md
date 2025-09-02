# Tasks Handling Action

> **Note:** This action interacts with the LLM using the `LangChainModelAction`. All prompt processing and intent detection are powered by this model integration.

This action enables the agent to create, summarize, and manage tasks from natural language input. Below is a detailed guide to its code, prompt design, flow, and integration.

---

## 1. Overview & Purpose

`TasksHandlingAction` is a custom JIVAS action for:
- Creating tasks from user input
- Summarizing scheduled tasks
- Managing (edit/delete) tasks

---

## 2. Code Structure

**Main files:**
- `tasks_handling_action.jac`: Core logic and prompts
- `task.jac`: Task node definition
- `list_tasks.jac`: Walker for listing tasks
- `info.yaml`: Metadata for registration

---

## 3. Prompt Design

Prompts are defined as attributes in the Jac node:

```py
has prompt_extracting_task: str = """
	Extract all tasks the user wants to schedule. For each, return a short one-sentence task with a clear date (YYYY-MM-DD) and time (HH:MM, 24-hour). Respond only with a list of JSON objects in this format:
	{{
	"task": "short one-sentence task summary",
	"date": "YYYY-MM-DD",
	"time": "HH:MM"
	}}
	If the user does not mention any task or give scheduling information, return a single object with empty strings:
	{{
	"task": "",
	"date": "",
	"time": ""
	}}
	No explanations or paragraphs, only valid JSON.
""";

has prompt_detect_intent: str = """
	Determine the user's intent from the message. Choose one of: "create_task" or "summarize_tasks".
	Respond only with the string: "create_task, "summarize_tasks" or "no_task".
""";

has prompt_summarize_all_tasks: str = """
	The following is a list of scheduled tasks. Create a brief human-friendly summary in natural language.
	Format it in a helpful way for the user. Use bullet points or paragraph form.
""";
```

**How to adjust prompts:**
- Edit the prompt strings to change extraction logic, intent detection, or summary style.
- Prompts are designed for LLMs (e.g., GPT-4o) and can be tuned for your use case.

---

## 4. Main Flow & Logic

### Intent Detection
```py
def execute(visitor:agent_graph_walker) -> None {
	utterance = visitor.utterance;
	prompt_messages = [
		{"system": self.prompt_detect_intent},
		{"human": utterance}
	];
	...
	intent = model_result.get_result().strip().lower();
	if intent == "create_task" {
		self.handle_task_creation(visitor);
	} elif intent == "summarize_tasks" {
		self.handle_task_summary(visitor);
	}
}
```

### Task Creation
```py
def handle_task_creation(visitor:agent_graph_walker) -> None {
	...
	prompt_messages = [
		{"system": self.prompt_extracting_task + f"\nCurrent time: {current_time}"},
		{"human": utterance}
	];
	...
	tasks = ... # parsed from LLM output
	for task_obj in tasks {
		is_task_added = self.add_task(...);
		if is_task_added {
			visitor.interaction_node.set_message(TextInteractionMessage(content="Task created successfully: " + task_obj.get("task", "")))
		}
	}
}
```

### Task Summarization
```py
def handle_task_summary(visitor:agent_graph_walker) -> None {
	scheduled_tasks = self.check_scheduled_tasks();
	...
	prompt_messages = [
		{"system": self.prompt_summarize_all_tasks},
		{"human": tasks_text}
	];
	...
	summary = result.get_result().strip();
	visitor.interaction_node.set_message(TextInteractionMessage(content=summary));
}
```

### Task Node
```py
node Task(GraphNode) {
	has task:str = "";
	has date:str = "";
	has time:str = "";
	has status: str = "pending";
}
```

---

## 5. Tools & Utilities Used

- **LLM Model:** Uses `LangChainModelAction` (default: GPT-4o)
- **Datetime & Sorting:** For scheduling and conflict checks
- **Regex & JSON:** For parsing LLM output
- **Jac Nodes & Walkers:** For graph-based agent logic

---

## 6. Integration with Agent

Register the action in your agent's `descriptor.yaml`:

```yaml
actions:
  - name: tasks_handling_action
	version: 0.0.1
	description: Handles task creation and management
	# Add other required metadata fields here
```

---

## 7. Extending & Customizing

- Adjust prompts for different extraction or summary needs
- Add/edit methods for new task logic (priority, categories, etc.)
- Use `tasks_handling_action.test.jac` for test cases

---

## 8. Example Usage

- **User:** "Schedule a call with Alice tomorrow at 10am"

- **Agent:** "Task created successfully: call with Alice"

- **User:** "What are my tasks?"

- **Agent:** "- Call with Alice on 2025-09-03 at 10:00"

---

---

**Next:** Return to the [Main Tutorial Table of Contents](../../../docs/README.md) to continue with the next action or section.

> **Important:** After creating or modifying this action, call the `/walker/import_agent` endpoint to register it with your agent. Only then can you use this action in your workflow.
