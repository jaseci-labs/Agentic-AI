import logging;
import from logging { Logger }
import from jivas.agent.core.agents { Agents }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


walker delete_agent(agent_graph_walker) {

    has agent_id:str = "";
    has response:bool = False;

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    can on_agents with Agents entry {
       self.response = here.delete(self.agent_id);
    }

}