import from dotenv { load_dotenv }
import sys;
import from utils { get_current_datetime }

node Memory {}

node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();
    has current_state: dict = {};
    has agent_execution_sequence: list = [];
    has max_iterations: int = 3;
    has max_consecutive_same_agent: int = 3;

    def add_history(entry: str) {
        self.history = self.history + [entry];
    }
    def get_history -> str {
        return "\n".join(self.history[-10:]);
    }
    def set_current_state(state: dict) {
        self.current_state = state;
    }
    def get_current_state -> dict {
        return self.current_state;
    }
    def add_agent_execution(agent_name: str) {
        self.agent_execution_sequence = self.agent_execution_sequence + [agent_name];
    }
    def get_execution_count -> int {
        return len(self.agent_execution_sequence);
    }
    def get_consecutive_count(agent_name: str) -> int {
        count = 0;
        for i in range(len(self.agent_execution_sequence) - 1, -1, -1) {
            if self.agent_execution_sequence[i] == agent_name {
                count += 1;
            } else {
                break;
            }
        }
        return count;
    }
    def should_prevent_loop(agent_name: str) -> bool {
        if self.get_execution_count() >= self.max_iterations {
            return True;
        }
        if self.get_consecutive_count(agent_name) >= self.max_consecutive_same_agent { # Check if same agent is being called too many times consecutively
            return True;
        }
        if len(self.agent_execution_sequence) >= 4 { # Check for ping-pong pattern (A->B->A->B...)
            recent = self.agent_execution_sequence[-4:];
            if recent[0] == recent[2] and recent[1] == recent[3] and recent[0] != recent[1] {
                return True;
            }
        }
        return False;
    }
    def get_execution_summary -> str {
        return " -> ".join(self.agent_execution_sequence);
    }
}

node Toolbox {
    def route_and_run(utterance: str, history: str) -> str abs;
    can execute with agent entry {
        session = visitor.session;
        response = self.route_and_run(visitor.utterance, session.get_history());
        session.add_history(
            "user: " + visitor.utterance + "\nai: " + response
        );
        report {
            "session_id": jid(visitor.session),
            "response": response
        };
    }
}

enum RoutingNodes {
    GENERAL_CHAT = "GeneralChat"
}

enum AgentTypes {
    NONE,
}

# supervisor's task is to route the user input to the appropriate agent
# Based on the user input, it will decide which agent to invoke
# Each agent will handle its own logic and return the response to the supervisor
# The supervisor will then return the final response to the user
walker supervisor {
    has utterance: str = "";
    has session_id: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }
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
    def route_to_agent(utterance: str, history: str) -> AgentTypes abs;
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
        routed_agent = self.route_to_agent(self.utterance, self.session.get_history());
        if routed_agent == AgentTypes.NONE {
            report {
                "session_id": jid(self.session),
                "response": "I'm sorry, I couldn't determine how to assist you."
            };
            disengage;
        }
        print("**********", routed_agent);
        agent_cls = self.get_agent_class(routed_agent.value);
        if not agent_cls {
            report {
                "session_id": jid(self.session),
                "response": "I'm sorry, I couldn't find the appropriate agent."
            };
            disengage;  
        }
        agent_inst = agent_cls();
        agent_inst(
            utterance = self.utterance,
            session_id = jid(self.session)
        ) spawn root;
    }
    
}

walker agent {
    has utterance: str = "";
    has session_id: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }
    def get_node_class(class_name: str) {
        main_mod = sys.modules.get("__main__");
        if main_mod and hasattr(main_mod, class_name) {
            return getattr(main_mod, class_name, None);
        }

        for (mod_name, mod) in sys.modules.items() {
            if mod and hasattr(mod, class_name) {
                return getattr(mod, class_name);
            }
        }
        return None;
    }
    def route_to_node(utterance: str, history: str) -> RoutingNodes abs;
    can execute with `root entry {
        self.session = &(self.session_id);
        routed_node = self.route_to_node(self.utterance, self.session.get_history());
        node_cls = self.get_node_class(routed_node.value);
        if not node_cls {
            print("Failed to get node class");
            return;
        }
        node_inst = node_cls();
        visit [-->(`?node_cls)] else {
            attached_routed_node = here ++> node_inst;
            visit attached_routed_node;
        }
    }
}

walker get_all_sessions {
    obj __specs__ {
        static has auth: bool = False;
    }
    can get_all_sessions with `root entry {
        memory_list = [here --> (`?Memory)];
        if not memory_list {
            report "No sessions found.";
            disengage;
        }
        memory = memory_list[0];
        session_list = [memory --> (`?Session)];
        report [{
            "id": jid(session),
            "created_at": session.created_at
        } for session in session_list];
    }
}

with entry {
    load_dotenv();
}