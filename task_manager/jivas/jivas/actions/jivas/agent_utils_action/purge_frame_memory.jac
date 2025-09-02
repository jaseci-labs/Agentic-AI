import logging;
import from logging { Logger }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.actions { Actions }

import from jivas.agent.modules.action.path { action_walker_path }

import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


walker purge_frame_memory(agent_graph_walker) {

    has session_id:str = "";
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
        response = here.purge_frame_memory(self.session_id);
        if self.reporting {
            report response;
        }
    }

}