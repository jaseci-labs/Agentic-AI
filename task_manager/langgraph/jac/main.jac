import from langchain_core.messages { HumanMessage, AIMessage, SystemMessage, BaseMessage }
import from states { AppState }
import from graph { build_graph }

import from typing { List, Dict, Any }
import from dotenv { load_dotenv }
import os;

walker task_manager {
    has utterance: str = "";
    has history: List[BaseMessage] = [];
    has last_state: Dict[str, Any] = {};
    
    obj __specs__ {
        static has auth: bool = False;
    }
    can call_build_graph with `root entry {
        app = build_graph();
        carry_keys: dict = {"email_to", "email_subject", "email_content"};
        carry_forward = {k: v for (k, v) in self.last_state.items() if k in carry_keys};

        state: AppState = {"utterance": self.utterance, "history": self.history, **carry_forward};
        out = app.invoke(state);
        reply = out.get("response", "");
        print("\nAssistant:", reply, "\n");
        report reply;

        self.history.append(HumanMessage(content=self.utterance));
        self.history.append(AIMessage(content=reply));
        self.last_state = out;
    }
}

with entry {
    load_dotenv();
}