import os;
import re;
import json;
import smtplib;
import logging;
import traceback;
import from typing { Union }
import from logging { Logger }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }
import from jivas.agent.memory.interaction_response { TextInteractionMessage }
import from jivas.agent.action.model_action { ModelAction }
import from email.mime.text { MIMEText }

node EmailHandlingAction(Action) {

    static has logger:Logger = logging.getLogger(__name__);
    has sender_email: str = os.getenv("SENDER_EMAIL");
    has sender_password: str = os.getenv("SENDER_PASSWORD");
    has sender_name: str = os.getenv("SENDER_NAME", "Jivas AI Assistant");

    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;
    has prompt_write_email: str = """
        You are an AI assistant that helps write emails based on user input.
        You will receive a user's utterance and you need to generate an email content based on that.
        The email should be clear, concise, and professional.
        You will return a JSON object with the following structure:
            {{
                "email_content": "<content of the email>",
                "email_subject": "<subject of the email>",
                "email_recipient": "<recipient email address>"
            }}
        Make sure to include all necessary details in the email content.
        If the user does not provide enough information, keep the missing parts as empty strings.
        return the JSON object only, no explanations or paragraphs.
    """;
    has select_tool_prompt: str = """
        Please select a tool to use for email composition.
        The order of user interaction is as follows:
        1. Write email content
        2. Get confirmation from user
        3. Send email - You should select this tool only if the user confirms the email details.
        Return only the tool name. No explanations or paragraphs. If there is no tool can be selected return "no_selected_tool"
        Tools names are as follows.
        """;
    has tools: list[str] = ["write_email_content", "send_email"];

    has email_recipient: str = "";
    has email_subject: str = "";
    has email_content: str = "";

    def execute(visitor: agent_graph_walker) -> None {
        model_action = self.get_agent().get_actions().get(action_label=self.model_action);
        if not model_action {
            self.logger.error("Model action not found.");
            return;
        }

        prompt_messages: list = [];
        utterance = visitor.utterance;
        statements = visitor.frame_node.get_transcript_statements(interactions = 10, max_statement_length = 500, with_events = True);
        system_prompt = self.select_tool_prompt + ", ".join(self.tools);
        
        prompt_messages.append({"system": system_prompt});
        for stmt in statements {
            for role in ("system", "human", "ai") {
                if role in stmt and stmt[role] {
                    prompt_messages.append({role: stmt[role]});
                }
            }
        }
        prompt_messages.append({"human": utterance});

        model_result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={"utterance": utterance},
            kwargs={
                "model_name": self.model_name,
                "model_temperature": self.model_temperature,
                "model_max_tokens": self.model_max_tokens
            },
            interaction_node=visitor.interaction_node
        );

        selected_tool = (model_result.get_result() or "").strip();
        self.logger.info(f"Model result: {selected_tool}");

        if selected_tool in self.tools {
            tool_fn = getattr(self, selected_tool, None);
            if callable(tool_fn) {
                try {
                    tool_fn(visitor, model_action);
                } except Exception as e {
                    self.logger.error(f"Error occurred while executing {selected_tool}: {e}");
                }
            }
        }
    }

    def write_email_content(visitor: agent_graph_walker, model_action: ModelAction) -> None {
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt_write_email + f"\nSender's name: {self.sender_name}"},
            {"human": utterance}
        ];

        model_result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={"utterance": utterance},
            kwargs={
                "model_name": self.model_name,
                "model_temperature": self.model_temperature,
                "model_max_tokens": self.model_max_tokens
            },
            interaction_node=visitor.interaction_node
        );

        interaction_message = model_result.get_result();
        raw_message = re.sub(r"^```json|^```|```$", "", interaction_message.strip(), flags=re.MULTILINE).strip();
        json_email = json.loads(raw_message);

        self.email_content = json_email.get("email_content", "");
        self.email_subject = json_email.get("email_subject", "New Task Notification");
        self.email_recipient = json_email.get("email_recipient", self.sender_email);

        if not self.email_content or not self.email_recipient {
            visitor.interaction_node.set_message(TextInteractionMessage(content="Email content or recipient is missing."));
            return;
        }
        self.get_confirmation_from_user(visitor);
    }

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
        msg = MIMEText(self.email_content);
        msg["Subject"] = self.email_subject;
        msg["From"] = self.sender_email;
        msg["To"] = self.email_recipient;

        try {
            server = smtplib.SMTP("smtp.gmail.com", 587);
            server.starttls();
            server.login(self.sender_email, self.sender_password);
            server.sendmail(self.sender_email, self.email_recipient, msg.as_string());
            server.quit();
            self.logger.info(f"Email sent to {self.email_recipient} with subject '{self.email_subject}'");
            visitor.interaction_node.set_message(TextInteractionMessage(content=f"Email sent successfully to {self.email_recipient}"));
        }
        except Exception as e {
            self.logger.error(f"Failed to send email to {self.email_recipient} with subject '{self.email_subject}': {e}");
        }
    }
}