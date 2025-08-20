import logging;
import traceback;
import from typing { Union }
import from logging { Logger }
import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }

node RoutingInteractAction(InteractAction) {

    has model_action: str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 2048;
    has prompt_routing: str = """
        Analyze the user's message and determine the appropriate action to take.
        Return only the action name. The list of action names are as follows.
    """;
    has all_actions: list[str] = ["TasksHandlingAction", "EmailHandlingAction"];

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    def touch(visitor: agent_graph_walker) -> bool {
        if visitor.utterance {
            return True;
        }
        return False;
    }

    def execute(visitor: agent_graph_walker) -> None {
        utterance = visitor.utterance;
        prompt_messages = [
            {"system": self.prompt_routing + ", ".join(self.all_actions)},
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

        response_action_name = model_result.get_result().strip();
        self.logger.info(f"Response model name: {response_action_name}");
        try {
            self.logger.info(f"Response model name: {response_action_name}");
            tool_action = self.get_agent().get_actions().get(action_label=response_action_name);
            tool_action.execute(visitor);
        } except Exception as e {
            self.logger.error(f"Error occurred while logging response model name: {e}");
        }
    }

    def healthcheck() -> Union[bool, dict] {
        # override to implement healthcheck operation
        # optionally returns a dict of (status:bool, severity:str [error|warning], message:str) if more information is needed
        return True;
    }
}