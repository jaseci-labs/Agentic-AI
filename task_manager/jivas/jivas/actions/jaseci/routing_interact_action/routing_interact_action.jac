import logging;
import traceback;
import from typing { Union }
import from logging { Logger }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }

node RoutingInteractAction(InteractAction) {
    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;
    has prompt_routing: str = """
        Analyze the user's chat and determine the appropriate action to take.
        Return only the action name. If the chat is not relevant to any action return "NoCustomAction".
        The list of action names are as follows.
    """;
    
    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    def touch(visitor: agent_graph_walker) -> bool {
        if visitor.utterance {
            return True;
        }
        return False;
    }

    def execute(visitor: agent_graph_walker) -> None {
        prompt_messages: list = [];
        utterance = visitor.utterance;
        statements = visitor.frame_node.get_transcript_statements(interactions = 10, max_statement_length = 500, with_events = True);
        system_prompt = self.prompt_routing + ", ".join(self.get_actions_list());
        
        prompt_messages.append({"system": system_prompt});
        for stmt in statements {
            for role in ("system", "human", "ai") {
                if role in stmt and stmt[role] {
                    prompt_messages.append({role: stmt[role]});
                }
            }
        }
        prompt_messages.append({"human": utterance});
        self.logger.info(f"Prompt messages: {prompt_messages}");

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

        response_action_name = model_result.get_result().strip();
        self.logger.info(f"Response model name: {response_action_name}");

        if response_action_name != "NoCustomAction" {
            try {
                self.logger.info(f"Response model name: {response_action_name}");
                tool_action = self.get_agent().get_actions().get(action_label=response_action_name);
                tool_action.execute(visitor);
            } except Exception as e {
                self.logger.error(f"Error occurred while logging response model name: {e}");
            }
        }
    }

    def get_actions_list() -> list[str] {
        filtered_actions: list = [];
        agent_actions = self.get_agent().get_actions();
        all_actions = [agent_actions --> (`?Action)];
        filtered_actions = [action.label for action in all_actions if action._package.get("meta", {}).get("is_custom", False)];
        return filtered_actions;
    }

    def healthcheck() -> Union[bool, dict] {
        # override to implement healthcheck operation
        # optionally returns a dict of (status:bool, severity:str [error|warning], message:str) if more information is needed
        return True;
    }
}