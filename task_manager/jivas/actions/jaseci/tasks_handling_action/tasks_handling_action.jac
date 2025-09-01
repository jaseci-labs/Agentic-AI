import from jivas.agent.action.action { Action }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }
import from actions.jaseci.tasks_handling_action.task { Task }
import from jivas.agent.memory.interaction_response { TextInteractionMessage, SilentInteractionMessage }
import from datetime { datetime }
import from operator { itemgetter }
import json;
import re;

node TasksHandlingAction(Action) {
    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;

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

    def execute(visitor:agent_graph_walker) -> None {
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt_detect_intent},
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

        intent = model_result.get_result().strip().lower();
        self.logger.info(f"Detected user intent: {intent}");

        if intent == "create_task" {
            self.handle_task_creation(visitor);
        } elif intent == "summarize_tasks" {
            self.handle_task_summary(visitor);
        }
    }

    def handle_task_creation(visitor:agent_graph_walker) -> None {
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M");
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt_extracting_task + f"\nCurrent time: {current_time}"},
            {"human": utterance}
        ];

        model_action = self.get_agent().get_actions().get(action_label=self.model_action);
        result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={"utterance": visitor.utterance},
            kwargs={
                "model_name": self.model_name,
                "model_temperature": self.model_temperature,
                "model_max_tokens": self.model_max_tokens
            },
            interaction_node=visitor.interaction_node
        );

        interaction_message = result.get_result();
        if not interaction_message {
            visitor.interaction_node.set_message(TextInteractionMessage(content="I couldn't understand the task."));
            return;
        }

        raw_message = re.sub(r"^```json|^```|```$", "", interaction_message.strip(), flags=re.MULTILINE).strip();
        interact_action_json = json.loads(raw_message);

        tasks = (
            [interact_action_json] if isinstance(interact_action_json, dict)
            else interact_action_json if isinstance(interact_action_json, list)
            else []
        );

        for task_obj in tasks {
            is_task_added = self.add_task(
                task=task_obj.get("task", ""),
                date=task_obj.get("date", ""),
                time=task_obj.get("time", "")
            );

            if is_task_added {
                visitor.interaction_node.set_message(
                    TextInteractionMessage(content="Task created successfully: " + task_obj.get("task", ""))
                );
            }
        }
    }

    def handle_task_summary(visitor:agent_graph_walker) -> None {
        scheduled_tasks = self.check_scheduled_tasks();

        if not scheduled_tasks or len(scheduled_tasks) == 0 {
            visitor.interaction_node.set_message(TextInteractionMessage(content="There are no scheduled tasks."));
            return;
        }

        tasks_text = "\n".join([f"- {t.get("task","")} on {t.get("date","")} at {t.get("time","")}" for t in scheduled_tasks]);
        prompt_messages = [
            {"system": self.prompt_summarize_all_tasks},
            {"human": tasks_text}
        ];

        model_action = self.get_agent().get_actions().get(action_label=self.model_action);
        result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={"tasks_text": tasks_text},
            kwargs={
                "model_name": self.model_name,
                "model_temperature": 0.5,
                "model_max_tokens": 512
            },
            interaction_node=visitor.interaction_node
        );

        summary = result.get_result().strip();
        visitor.interaction_node.set_message(TextInteractionMessage(content=summary));
    }

    def add_task(task:str, date:str, time:str) -> str {
        if not task or not date or not time {
            self.logger.info("No Task details are provided.");
            return False;
        }
        collection = self.get_collection();
        collection ++> Task(task=task, date=date, time=time);
        return True;
    }

    def check_scheduled_tasks() -> list {
        collection = self.get_collection();
        scheduled_tasks = [collection --> (`?Task)];
        result:list = [];
        
        for task in scheduled_tasks {
            result.append({
                "task_id": task.id,
                "task": task.task,
                "date": task.date,
                "time": task.time,
                "status": task.status
            });
        }

        result = sorted(result, key=itemgetter("date", "time"));
        return result;
    }
}
