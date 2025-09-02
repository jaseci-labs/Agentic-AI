import logging;
import from logging { Logger }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.actions { Actions }
import from jivas.agent.modules.action.path { action_walker_path }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


walker test_llm_call(agent_graph_walker) {

    has llm_prompt_message:str = "";
    has model_name:str = "";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 4096;
    has response:dict = {};
    has reporting:bool = True;

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    class __specs__ {
        static has private: bool = False;
        static has path: str = action_walker_path(__module__);
    }

    can on_agent with Agent entry {
        visit [-->](`?Actions);
    }

    can on_actions with Actions entry {
        visit [-->](`?Action)(?enabled==True)(?label=='AgentUtilsAction');
    }

    can on_action with Action entry {
        self.response = here.test_llm_call(llm_prompt_message=self.llm_prompt_message, model_name=self.model_name, model_temperature=self.model_temperature, model_max_tokens=self.model_max_tokens);
        self.logger.warning("test_llm_call");
        self.logger.warning(self.response);

        if self.reporting {
            report self.response;
        }
    }
    
}

