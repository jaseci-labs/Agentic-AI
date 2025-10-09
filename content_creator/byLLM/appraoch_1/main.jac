# import from agent_core { supervisor, agent, Toolbox}
import from agent_core { Memory, Session }
import from byllm.llm { Model }
import sys;

glob llm = Model(model_name="gpt-4o");

# node PlanningHandler(Toolbox) {
#     def do_planning(utterance: str, history: str) -> str by llm();
#     def route_and_run(utterance: str, history: str) -> str by llm(
#         method="ReAct",
#         tools=([self.do_planning])
#     );
# }

# node WritingHandler(Toolbox) {
    
# }

# node EditingHandler(Toolbox) {
    
# }

# node MediaHandler(Toolbox) {

# }

# ---------
enum AgentTypes {
    PLANNER_AGENT = "planner_agent",
    WRITER_AGENT = "writer_agent",
    EDITOR_AGENT = "editor_agent",
    MEDIA_AGENT = "media_agent"
}

walker SupervisorAgent {
    has utterance: str = "";
    has session_id: str = "";

    def get_agent_class(class_name: str) {
        main_mod = sys.modules.get("__main__");
        if main_mod and hasattr(main_mod, class_name) {
            return getattr(main_mod, class_name, None);
        }

        for (mod_name, mod) in sys.modules.items() {
            if mod and hasattr(mod, class_name) {
                return getattr(mod, class_name, None);
            }
        }
        return None;
    }
    def spawning_selected_agent_at_root(agent_type: str) -> None {
        print("Spawning agent at root:", agent_type, type(agent_type));
        agent_cls = self.get_agent_class(agent_type);
        if not agent_cls {
            print("Agent class not found");
            report {
                "session_id": jid(self.session),
                "response": "I'm sorry, I couldn't find the appropriate agent."
            };
            disengage;
        }
        agent_inst = agent_cls();
        print("Agent instance created:", agent_inst);
        agent_inst spawn root;
    }
    def find_agent(utterance: str, history: str) -> AgentTypes by llm();
    def decide_agent(utterance: str, history: str) -> str {
        agent_type = self.find_agent(utterance, history);
        return agent_type.value;
    }
    def communicate_agents(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=[self.decide_agent, self.spawning_selected_agent_at_root]
    );
    can supervise with `root entry {
        memory_list = [root --> (`?Memory)];
        if not memory_list {
            memory_list = root ++> Memory();
        }
        memory = memory_list[0];
        if not self.session_id {
            session_list = memory ++> Session();
            self.session = session_list[0];
        } else {
            self.session = &(self.session_id);
        }
        routed_agent = self.communicate_agents(self.utterance, self.session.get_history());
    }
}


walker planner_agent {
    can execute with `root entry {
        print("planner agent executed");
    } 
}

walker writer_agent {
    can execute with `root entry {
        print("writer agent executed");
    } 
}

walker editor_agent {
    can execute with `root entry {
        print("editor agent executed");
    } 
}

walker media_agent {
    can execute with `root entry {
        print("media agent executed");
    } 
}

with entry {
    utterance = "Generate a readme post regarding Agentic AI.";
    SupervisorAgent(utterance) spawn root;
}