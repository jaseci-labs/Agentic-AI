import from dotenv { load_dotenv }
import sys;
import from utils { get_current_datetime }

node Memory {}

node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();

    def add_history(entry: str) {
        self.history = self.history + [entry];
    }
    def get_history -> str {
        return "\n".join(self.history[-10:]);
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