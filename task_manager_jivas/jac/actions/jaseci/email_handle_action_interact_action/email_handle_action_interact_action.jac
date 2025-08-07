import os;
import re;
import json;
import smtplib;
import logging;
import traceback;
import from typing { Union }
import from logging { Logger }
import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }
import from email.mime.text { MIMEText }

node EmailHandleActionInteractAction(InteractAction) {

    static has logger:Logger = logging.getLogger(__name__);
    has sender_email: str = os.getenv("SENDER_EMAIL");
    has sender_password: str = os.getenv("SENDER_PASSWORD");
    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;
    has prompt: str = """
        You are an email handler. Your task is to extract the email content, subject, and recipient from the user's message.
        Respond with a JSON object in this format:
        {{
            "email_content": "Content of the email",
            "email_subject": "Subject of the email",
            "email_recipient": "Recipient's email address"
        }}
        If the user does not provide enough information, return empty strings for each field.
        No explanations or paragraphs, only valid JSON.
        """;

    def touch(visitor: agent_graph_walker) -> bool {
        if visitor.utterance {
            return True;
        }
        return False;
    }

    def execute(visitor: agent_graph_walker) -> None {
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt},
            {"human": utterance}
        ];

        model_action = self.get_agent().get_actions().get(action_label=self.model_action);
        if not model_action {
            self.logger.error("Model action not found.");
            return;
        }
        model_result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={"utterance": utterance},
            kwargs={
                "model_name": self.model_name,
                "model_temperature": self.model_temperature,
                "model_max_tokens": 100
            },
            interaction_node=visitor.interaction_node
        );

        interaction_message = model_result.get_result();
        if not interaction_message {
            visitor.interaction_node.set_message(TextInteractionMessage(content="I couldn't understand the task."));
            return;
        }

        raw_message = re.sub(r"^```json|^```|```$", "", interaction_message.strip(), flags=re.MULTILINE).strip();
        interact_action_json = json.loads(raw_message);
        
        email_content = interact_action_json.get("email_content", "");
        email_subject = interact_action_json.get("email_subject", "New Task Notification");
        email_recipient = interact_action_json.get("email_recipient", self.sender_email);

        if not email_content or not email_recipient {
            visitor.interaction_node.set_message(TextInteractionMessage(content="Email content or recipient is missing."));
            return;
        }

        self.send_email(
            to_email=email_recipient,
            subject=email_subject,
            body=email_content
        );
    }

    def send_email(to_email: str, subject: str, body: str) -> None {
        msg = MIMEText(body);
        msg["Subject"] = subject;
        msg["From"] = self.sender_email;
        msg["To"] = to_email;

        try {
            server = smtplib.SMTP("smtp.gmail.com", 587);
            server.starttls();
            server.login(self.sender_email, self.sender_password);
            server.sendmail(self.sender_email, to_email, msg.as_string());
            server.quit();
            self.logger.info(f"Email sent to {to_email} with subject '{subject}'");
        }
        except Exception as e {
            self.logger.error(f"Failed to send email to {to_email} with subject '{subject}': {e}");
        }
    }
}