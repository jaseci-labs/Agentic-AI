import from datetime { datetime }

def get_current_datetime() -> str {
    return str(datetime.now());
}

node Memory {}

node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();
    has current_state: dict = {};

    def add_history(entry: str) {
        self.history = self.history + [entry];
    }
    def get_history -> str {
        return "\n".join(self.history[-10:]);
    }
}

# To checked the already created sessions
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
