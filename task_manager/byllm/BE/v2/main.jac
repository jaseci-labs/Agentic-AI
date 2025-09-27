import from byllm.llm { Model }
import from email.mime.text { MIMEText }
import smtplib;
import os;
include agent_core;
import from utils { get_current_datetime }

glob llm = Model(model_name="gpt-4o", verbose=False);

enum RoutingNodes {
    GENERAL_CHAT = "GeneralChat",
    TASK_HANDLING = "TaskHandling",
    EMAIL_HANDLING = "EmailHandling"
}

node Task {
    has task:str = "";
    has date:str = "";
    has time:str = "";
}

node TaskHandling(Toolbox) {
    def add_task(task: str, date: str, time: str) -> str;
    def check_scheduled_tasks -> list[Task];
    def extract_task_info(utterance: str) -> str by llm(
        method="ReAct",
        tools=([self.add_task, get_current_datetime])
    );
    def summarize_tasks() -> str by llm(
        method="ReAct",
        tools=([self.check_scheduled_tasks])
    );
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.extract_task_info, self.summarize_tasks])
    );
}

node EmailHandling(Toolbox) {
    has sender_email: str = os.getenv("SENDER_EMAIL");
    has sender_password: str = os.getenv("SENDER_PASSWORD");
    has sender_name: str = os.getenv("SENDER_NAME");

    def write_email_content(utterance: str, history: str) -> str by llm();
    def send_email(email_content: str, email_subject: str, email_to: str) -> None;
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.write_email_content, self.send_email])
    );
}

node GeneralChat(Toolbox) {
    def chat(utterance: str, history: str) -> str by llm();
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.chat])
    );
}

walker task_manager(agent) {
    def route_to_node(utterance: str, history: str) -> RoutingNodes by llm();
}

walker get_all_tasks {
    obj __specs__ {
        static has auth: bool = False;
    }
    can get_all_tasks with `root entry;
}
