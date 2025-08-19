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

node EmailHandlingction(Action) {

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

    def execute(visitor: agent_graph_walker) -> None {
        model_action = self.get_agent().get_actions().get(action_label=self.model_action);
        if not model_action {
            self.logger.error("Model action not found.");
            return;
        }
        (email_recipient, email_subject, email_content) = self.write_email_content(visitor, model_action);

        self.send_email(
            to_email=email_recipient,
            subject=email_subject,
            body=email_content
        );
        visitor.interaction_node.set_message(
            TextInteractionMessage(content=f"Email successfully sent to {email_recipient} with subject '{email_subject}'")
        );
    }

    def write_email_content(visitor: agent_graph_walker, model_action: ModelAction) -> (str, str, str) {
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

        email_content = json_email.get("email_content", "");
        email_subject = json_email.get("email_subject", "New Task Notification");
        email_recipient = json_email.get("email_recipient", self.sender_email);

        if not email_content or not email_recipient {
            visitor.interaction_node.set_message(TextInteractionMessage(content="Email content or recipient is missing."));
            return;
        }
        return (email_recipient, email_subject, email_content);
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