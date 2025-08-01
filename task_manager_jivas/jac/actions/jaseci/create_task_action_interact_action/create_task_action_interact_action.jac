import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }

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
        
        print("Executing CreateTaskActionInteractAction");

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
                }
                print(interaction_message);
            }
        }
        print({"status": "success", "message": "Task created successfully."});
    }

    # Declare your has variables to be persisted here
    # e.g has var_a : str = "string";   

    #* (Abilities - Uncomment and implement as needed)
    can on_register {
        # override to execute operations upon registration of action
    }


    can post_register {
        # override to execute any setup code when all actions are in place
    }

    can on_enable {
        # override to execute operations upon enabling of action
    }

    can on_disable {
        # override to execute operations upon disabling of action
    }

    can on_deregister {
        # override to execute operations upon deregistration of action
    }

    can touch(visitor: interact_graph_walker) -> bool {
        # override to authorize, redirect or deny the interact walker from running execute
    }

    can execute(visitor: interact_graph_walker) -> dict {
        # override to implement action execution
    }

    can pulse() {
        # override to implement pulse operation
    }
    *#
}
