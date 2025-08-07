import logging;
import from logging { Logger }
import from jivas.agent.core.agents { Agents }
import from jivas.agent.modules.action.path { action_walker_path }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


walker delete_agent(agent_graph_walker) {

    has agent_id:str = "";
    has response:bool = False;
    has reporting:bool = True;

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    class __specs__ {
        static has private: bool = False;
        static has path: str = action_walker_path(__module__);
    }

    can on_agents with Agents entry {
        self.response = here.delete(self.agent_id);
        if self.reporting {
            report self.response;
        }
    }

}