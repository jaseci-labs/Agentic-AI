
# Routing Interact Action

> **Note:** This action interacts with the LLM using the `LangChainModelAction` for prompt processing and action routing.

---

## 1. Overview & Purpose

`RoutingInteractAction` enables the agent to analyze user input and route it to the appropriate custom action. It uses LLM prompts to determine which action should handle the user's request.

---

## 2. Code Structure

**Main files:**
- `routing_interact_action.jac`: Core logic and prompts
- `info.yaml`: Metadata for registration

---

## 3. Prompt Design

Prompts are defined as attributes in the Jac node:

```py
has prompt_routing: str = """
	Analyze the user's chat and determine the appropriate action to take.
	Return only the action name. If the chat is not relevant to any action return "NoCustomAction".
	The list of action names are as follows.
""";
```

**How to adjust prompts:**
- Edit the prompt string to change routing logic or action selection behavior.
- Prompts are designed for LLMs and can be tuned for your use case.

---

## 4. Main Flow & Logic

### Action Routing
```py
def execute(visitor: agent_graph_walker) -> None {
	...
	system_prompt = self.prompt_routing + ", ".join(self.get_actions_list());
	...
	model_result = model_action.call_model(...);
	response_action_name = model_result.get_result().strip();
	if response_action_name != "NoCustomAction" {
		tool_action = self.get_agent().get_actions().get(action_label=response_action_name);
		tool_action.execute(visitor);
	}
}
```

### Action List Filtering
```py
def get_actions_list() -> list[str] {
	agent_actions = self.get_agent().get_actions();
	all_actions = [agent_actions --> (`?Action)];
	filtered_actions = [action.label for action in all_actions if action._package.get("meta", {}).get("is_custom", False)];
	return filtered_actions;
}
```

---

## 5. Tools & Utilities Used

- **LLM Model:** Uses `LangChainModelAction` (default: GPT-4o)
- **Jac Nodes & Walkers:** For graph-based agent logic

---

## 6. Integration with Agent

Register the action in your agent's `descriptor.yaml`:

```yaml
actions:
  - name: routing_interact_action
	version: 0.0.1
	description: Routes user input to the correct custom action
	# Add other required metadata fields here
```

---

## 7. Extending & Customizing

- Adjust prompts for different routing logic or action selection
- Add/edit methods for new routing features or health checks

---

## 8. Example Usage

- **User:** "Schedule a meeting tomorrow at 3pm"
- **Agent:** (routes to `tasks_handling_action`)
- **User:** "Send an email to Bob about the meeting"
- **Agent:** (routes to `email_handling_action`)

---

---

**Next:** Return to the [Main Tutorial Table of Contents](../../../docs/README.md) to continue with the next action or section.

> **Important:** After creating or modifying this action, call the `/walker/import_agent` endpoint to register it with your agent. Only then can you use this action in your workflow.

