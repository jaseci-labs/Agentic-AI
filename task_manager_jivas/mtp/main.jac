import from mtllm.llm { Model }
include utils;

glob llm = Model(model_name="gpt-4o", verbose=False);

node Task {
    has task:str = "";
    has date:str = "";
    has time:str = "";
    has status: str = "pending";
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
    def write_email(utterance: str) -> str by llm();

    can execute with task_manager entry {
        print(self.write_email(here.utterance));
    }
}

node GeneralChat {
    def chat(utterance: str) -> str by llm();

    can execute with task_manager entry {
        print("*********** general chat");
        report self.chat(visitor.utterance);
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

    def route_to_node(utterance: str) -> RoutingNodes by llm();
    can execute with `root entry {
        routed_node = self.route_to_node(self.utterance);
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