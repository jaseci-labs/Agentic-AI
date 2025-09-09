node Memory {}

node Session {
    has history: list = [];
    has last_state: dict = {};

    def add_history(entry: str) {
        self.history = self.history + [entry];
    }
    def get_history -> str {
        return "\n".join(self.history[-10:]);
    }
}