import logging;
import from logging { Logger }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.memory.memory { Memory }
import from jivas.agent.memory.frame { Frame }
import from jivas.agent.memory.interaction { Interaction }
import from jivas.agent.modules.action.path { action_walker_path }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }

walker test_interactions(agent_graph_walker) {

    has session_id:str = "";
    has max_interactions:int = 5;
    has response:list = [];
    has reporting:bool = True;

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    class __specs__ {
        static has private: bool = False;
        static has path: str = action_walker_path(__module__);
    }

    can on_agent with Agent entry {
        visit [-->](`?Memory);
    }

    can on_memory with Memory entry {

        frame_nodes = here.get_frames(self.session_id);

        for frame_node in frame_nodes {
            for interaction in frame_node.get_interactions() {
                # limit the number of interactions to report
                if len(self.response) >= self.max_interactions {
                    break;
                }

                if "ModelActionResult" in interaction.data {
                    self.response.append({
                        "utterance": interaction.get_utterance(),
                        "ModelActionResult": interaction.data_get("ModelActionResult")
                    });
                }
            }
        }
        report self.response;
    }


}

