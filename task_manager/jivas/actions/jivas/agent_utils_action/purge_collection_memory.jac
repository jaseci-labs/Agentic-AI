import logging;
import from logging { Logger }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.actions { Actions }
import from jivas.agent.modules.action.path { action_walker_path }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


walker purge_collection_memory(agent_graph_walker) {

    has collection_name:str = "";
    has response:bool = False;
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
        self.response = here.purge_collection_memory(self.collection_name);
        if self.reporting {
            report self.response;
        }
    }

}