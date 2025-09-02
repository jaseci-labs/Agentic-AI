# Email Handling Action

> **Note:** This action interacts with the LLM using the `LangChainModelAction` for prompt processing and tool selection.

---

## 1. Overview & Purpose

`EmailHandlingAction` enables the agent to compose, confirm, and send emails based on user input. It uses LLM prompts to generate email content and select the appropriate tool for each step.

---

## 2. Code Structure

**Main files:**
- `email_handling_action.jac`: Core logic and prompts
- `info.yaml`: Metadata for registration

---

## 3. Prompt Design

Prompts are defined as attributes in the Jac node:

```py
has prompt_write_email: str = """
	You are an AI assistant that helps write emails based on user input.
	...
	You will return a JSON object with the following structure:
		{{
			"email_content": "<content of the email>",
			"email_subject": "<subject of the email>",
			"email_recipient": "<recipient email address>"
		}}
	...
	return the JSON object only, no explanations or paragraphs.
""";

has select_tool_prompt: str = """
	Please select a tool to use for email composition.
	...
	Tools names are as follows.
""";
```

**How to adjust prompts:**
- Edit the prompt strings to change email composition logic or tool selection behavior.
- Prompts are designed for LLMs and can be tuned for your use case.

---

## 4. Main Flow & Logic

### Tool Selection & Execution
```py
def execute(visitor: agent_graph_walker) -> None {
	...
	system_prompt = self.select_tool_prompt + ", ".join(self.tools);
	...
	selected_tool = (model_result.get_result() or "").strip();
	if selected_tool in self.tools {
		tool_fn = getattr(self, selected_tool, None);
		if callable(tool_fn) {
			tool_fn(visitor, model_action);
		}
	}
}
```

### Email Composition
```py
def write_email_content(visitor: agent_graph_walker, model_action: ModelAction) -> None {
	...
	prompt_messages = [
		{"system": self.prompt_write_email + f"\nSender's name: {self.sender_name}"},
		{"human": utterance}
	];
	...
	json_email = json.loads(raw_message);
	self.email_content = json_email.get("email_content", "");
	self.email_subject = json_email.get("email_subject", "New Task Notification");
	self.email_recipient = json_email.get("email_recipient", self.sender_email);
	...
	self.get_confirmation_from_user(visitor);
}
```

### Confirmation & Sending
```py
def get_confirmation_from_user(visitor: agent_graph_walker) -> bool {
	confirmation_prompt = (
		"Please confirm to send the email with the following details?\n"
		f"Recipient: {self.email_recipient}\n"
		f"Subject: {self.email_subject}\n"
		f"Content: {self.email_content}"
	);
	visitor.interaction_node.set_message(TextInteractionMessage(content=confirmation_prompt));
}

def send_email(visitor: agent_graph_walker, model_action: ModelAction) -> None {
	...
	try {
		server = smtplib.SMTP("smtp.gmail.com", 587);
		server.starttls();
		server.login(self.sender_email, self.sender_password);
		server.sendmail(self.sender_email, self.email_recipient, msg.as_string());
		server.quit();
		visitor.interaction_node.set_message(TextInteractionMessage(content=f"Email sent successfully to {self.email_recipient}"));
	}
	except Exception as e {
		...
	}
}
```

---

## 5. Tools & Utilities Used

- **LLM Model:** Uses `LangChainModelAction` (default: GPT-4o)
- **SMTP:** For sending emails
- **Jac Nodes & Walkers:** For graph-based agent logic

---

## 6. Integration with Agent

Register the action in your agent's `descriptor.yaml`:

```yaml
actions:
  - name: email_handling_action
	version: 0.0.1
	description: Handles email composition and sending
	# Add other required metadata fields here
```

---

## 7. Extending & Customizing

- Adjust prompts for different email styles or tool selection logic
- Add/edit methods for new email features (attachments, templates, etc.)

---

## 8. Example Usage

- **User:** "Send an email to Bob about the meeting tomorrow"
- **Agent:** "Please confirm to send the email with the following details? Recipient: bob@example.com Subject: Meeting tomorrow Content: ..."
- **User:** "Yes, send it"
- **Agent:** "Email sent successfully to bob@example.com"

---

---

**Next:** Return to the [Main Tutorial Table of Contents](../../../docs/README.md) to continue with the next action or section.

> **Important:** After creating or modifying this action, call the `/walker/import_agent` endpoint to register it with your agent. Only then can you use this action in your workflow.

