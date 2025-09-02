import from typing { Union }
import traceback;
import from jivas.agent.action.interact_action { InteractAction }


node IntroInteractAction(InteractAction) {
    # Dispatches an introductory prompt directive to persona_response_action if user is a first-time user.

    has prompt:str = "In a natural and brief manner: \n a. Introduce yourself by name and explain your role \n b. Refer the first-time user to read your AI policy at https://platform.trueselph.com/policy before continuing. It contains our privacy policy.";

    def touch(visitor: agent_graph_walker) -> bool {
        return visitor.interaction_node.is_new_user();
    }

    def execute(visitor: agent_graph_walker) -> None {
        # add directive to issue introductory response
        visitor.interaction_node.add_directive(directive=self.prompt);
    }

    def healthcheck() -> Union[bool, dict] {

        if(not self.prompt) {
            return {
                "status": False,
                "message": "Prompt is not set",
                "severity": "error"
            };
        }

        return True;

    }
}
