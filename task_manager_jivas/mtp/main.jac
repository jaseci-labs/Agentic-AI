import from mtllm.llm { Model }
import from email.mime.text { MIMEText }
import from dotenv { load_dotenv }
import smtplib;
import os;
include utils;

glob llm = Model(model_name="gpt-4o", verbose=False);

node Task {
    has task:str = "";
    has date:str = "";
    has time:str = "";
    has status: str = "pending";
}

node Memory {
    has history: list = [];

    def add_memory(entry: str) {
        self.history = self.history + [entry];
    }
    def get_memory -> str {
        return "\n".join(self.history);
    }
}

node TaskHandling {
    def add_task(task: Task) -> str {
        self ++> task;
        return "Task added successfully";
    }
    def check_scheduled_tasks -> list[Task] {
        return [self --> (`?Task)];
    }
    def extract_task_info(utterance: str) -> Task by llm(
        method="ReAct",
        tools=([self.add_task, get_current_datetime])
    );
    def summarize_tasks() -> str by llm(
        method="ReAct",
        tools=([self.check_scheduled_tasks])
    );
    def route_and_run(utterance: str) -> str by llm(
        method="ReAct",
        tools=([self.extract_task_info, self.summarize_tasks])
    );
    can execute with task_manager entry {
        report self.route_and_run(visitor.utterance);
    }
}
sem TaskHandling.extract_task_info = "time and date should be extracted in the format of 'YYYY-MM-DD HH:MM:SS'.";
sem TaskHandling.route_and_run = "Select and Execute only one tool provided.";
sem TaskHandling.summarize_tasks = "Summarize the tasks in a concise manner. But all relevant task information should be included.";

node EmailHandling {
    has sender_email: str = os.getenv("SENDER_EMAIL");
    has sender_password: str = os.getenv("SENDER_PASSWORD");
    has sender_name: str = os.getenv("SENDER_NAME");

    def write_email_content(utterance: str, memory: str) -> str by llm();
    def send_email(email_content: str, email_subject: str, email_to: str) {
        msg = MIMEText(email_content);
        msg["Subject"] = email_subject;
        msg["From"] = self.sender_email;
        msg["To"] = email_to;

        try {
            server = smtplib.SMTP("smtp.gmail.com", 587);
            server.starttls();
            server.login(self.sender_email, self.sender_password);
            server.sendmail(self.sender_email, email_to, msg.as_string());
            server.quit();
        }
        except Exception as e {
            print(f"Failed to send email to {email_to} with subject '{email_subject}': {e}");
        }
    }
    def route_and_run(utterance: str, memory: str) -> str by llm(
        method="ReAct",
        tools=([self.write_email_content, self.send_email])
    );
    can execute with task_manager entry {
        memory = visitor.memory;
        response = self.route_and_run(visitor.utterance, memory.get_memory());
        memory.add_memory(
            "user: " + visitor.utterance + "\nai: " + response
        );
        report response;
    }
}

sem EmailHandling.route_and_run = """
Step 1: Extract the email content, subject, and recipient from the user's utterance.
- Generate a complete draft of the email. 
- Use 'Hi' as the greeting if the recipient name is not mentioned.
- Show the draft to the user and ask for confirmation (e.g., 'Do you want me to send this email?').

Step 2: If the user confirms (yes), send the email. 
If the user says no, either re-draft based on feedback or cancel.
Never send without explicit confirmation.
""";

node GeneralChat {
    def chat(utterance: str, memory: str) -> str by llm();

    can execute with task_manager entry {
        memory = visitor.memory;
        response = self.chat(visitor.utterance, memory.get_memory());
        memory.add_memory(
            "user: " + visitor.utterance + "\nai: " + response
        );
        report response;
    }
}

enum RoutingNodes{
    TASK_HANDLING = "TaskHandling",
    EMAIL_HANDLING = "EmailHandling",
    GENERAL_CHAT = "GeneralChat"
}

walker task_manager {
    has utterance: str = "";
    
    obj __specs__ {
        static has auth: bool = False;
    }

    def route_to_node(utterance: str, memory: str) -> RoutingNodes by llm();
    can execute with `root entry {
        memory_list = [root --> (`?Memory)];
        if not memory_list {
            memory_list = root ++> Memory();
        }
        self.memory = memory_list[0];
        routed_node = self.route_to_node(self.utterance, self.memory.get_memory());
        node_cls = globals().get(routed_node.value, "");
        if not node_cls {
            return;
        }
        node_inst = node_cls();
        visit [-->(`?node_cls)] else {
            attached_routed_node = here ++> node_inst;
            visit attached_routed_node;
        }
    }
}

with entry {
    load_dotenv();
}