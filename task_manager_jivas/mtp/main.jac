import from mtllm.llm { Model }

glob llm = Model(model_name="gpt-4o-mini", verbose=False);

node Task {
    has task:str = "";
    has date:str = "";
    has time:str = "";
    has status: str = "pending";
}

node TaskHandling {
    def add_task(task: Task) -> str {
        print("**********0");
        root ++> task;
        return "Task added successfully";
    }
    def greet_user() -> str {
        return "Hello! How can I assist you with your tasks today?";
    }
    def check_scheduled_tasks -> list[Task] {
        return [self --> (`?Task)];
    }
    def extract_task_info(utterance: str) -> Task by llm(
        method="ReAct",
        tools=([self.add_task])
    );
    def summarize_tasks() -> str by llm(
        method="ReAct",
        tools=([self.greet_user])
    );

    can execute with task_manager entry {
        print(self.extract_task_info(visitor.utterance));
    }
}

node EmailHandling {
    def write_email(utterance: str) -> str by llm();

    can execute with task_manager entry {
        print(self.write_email(here.utterance));
    }
}

node GeneralChat {
    can execute with task_manager entry {
        print("***********2");
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