import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }
import from actions.jaseci.create_task_action_interact_action.task { Task }
import from jivas.agent.memory.interaction_response { TextInteractionMessage, SilentInteractionMessage }
import json;
import re;

node CreateTaskActionInteractAction(InteractAction) {
    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;
    has prompt: str = """
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



    def touch(visitor:agent_graph_walker) -> bool {
        if visitor.utterance {
            return True;
        }
        return False;
    }

    def execute(visitor:agent_graph_walker) -> None {
        # This action is a placeholder for creating tasks in the Jaseci system.
        # It can be extended to include specific task creation logic.
        
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt},
            {"human": "{utterance}"}
        ];

        if (model_action := self.get_agent().get_actions().get(action_label=self.model_action)) {
            if (model_action_result := model_action.call_model(
                prompt_messages = prompt_messages,
                prompt_variables = {
                    "utterance": visitor.utterance
                },
                kwargs = {
                    "model_name": self.model_name,
                    "model_temperature": self.model_temperature,
                    "model_max_tokens": self.model_max_tokens
                },
                interaction_node = visitor.interaction_node
            )) {
                interaction_message = model_action_result.get_result();
                if not interaction_message {
                    interaction_message = "...";
                    return;
                }
                raw_message = re.sub(r"^```json|^```|```$", "", interaction_message.strip(), flags=re.MULTILINE).strip();
                interact_action_json = json.loads(raw_message);
                print("Parsed JSON:", interact_action_json);

                if isinstance(interact_action_json, dict) {
                    tasks = [interact_action_json];
                } elif isinstance(interact_action_json, list) {
                    tasks = interact_action_json;
                } else {
                    print("Invalid JSON structure");
                    return;
                }

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
        }
        self.logger.info("CreateTaskActionInteractAction executed successfully.");
    }

    def add_task(task:str, date:str, time:str) -> str {
        if not task or not date or not time {
            self.logger.error("Invalid task details provided.");
            return False;
        }
        collection = self.get_collection();
        collection ++> Task(task=task, date=date, time=time);
        return True;
    }
}
