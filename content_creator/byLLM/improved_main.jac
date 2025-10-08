# import from agent_core { supervisor, agent, Toolbox}
import from agent_core { Memory, Session }
import from byllm.llm { Model }
import sys;

glob llm = Model(model_name="gpt-4o");

enum AgentTypes {
    PLANNER_AGENT = "planner_agent",
    WRITER_AGENT  = "writer_agent",
    REVIEW_AGENT  = "review_agent",
    END = "end"
}

def write_content(agent: str, response: str) {
    import json, time;
    with open("output.jsonl", "a") as f {
        rec = {
            "ts": int(time.time()),
            "agent": agent,
            "response": response
        };
        f.write(json.dumps(rec, ensure_ascii=False, indent=2));
        f.write("\n");
    }
}

walker SupervisorAgent {
    has utterance: str = "";
    has session_id: str = "";

    def call_next_agent(utterance: str, current_state: dict) -> AgentTypes by llm(
        method="reasoning"
    );
    def start_execution(utterance: str, history: str) {
        next_agent: AgentTypes = self.call_next_agent(self.utterance, self.session.current_state);
        print("Next agent to execute:", next_agent);

        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } elif next_agent == AgentTypes.PLANNER_AGENT {
            planner_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.WRITER_AGENT {
            writer_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.REVIEW_AGENT {
            review_agent(session=self.session, utterance=utterance) spawn root;
        } else {
            print("No valid next agent found, stopping execution.");
            self.session.current_state["done"] = True;
            disengage;
        }
    }

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
        
        self.start_execution(self.utterance, self.session.get_history());
        print();
    }
}

walker planner_agent {
    has session: Session;
    has utterance: str = "";

    def call_next_agent(utterance: str, current_agent_response: str, current_state: dict) -> AgentTypes by llm(
        method="reasoning"
    );
    def generate_executing_plan_to_generate_better_content(utterance: str, agents: str = ", ".join([a.value for a in AgentTypes])) -> str by llm();
    can execute with `root entry {
        print("planner agent executed");
        self.session.add_agent_execution("PLANNER_AGENT");
        
        planner_response = self.generate_executing_plan_to_generate_better_content(
            self.utterance, 
            ", ".join([a.value for a in AgentTypes])
        );
        write_content("planner_agent", planner_response);
        self.session.current_state["planner_response"] = planner_response;
        print("Current state after planner agent:", self.session.current_state);
        print("Execution sequence:", self.session.get_execution_summary());
        
        next_agent: AgentTypes = self.call_next_agent(
            self.utterance, 
            "planner response: " + planner_response, 
            self.session.current_state
        );
        print("Next agent to execute:", next_agent);

        # Check for loop prevention
        if next_agent != AgentTypes.END and self.session.should_prevent_loop(next_agent.value) {
            print("🛑 Loop prevention triggered! Forcing END to prevent infinite loop.");
            print("Execution summary:", self.session.get_execution_summary());
            self.session.current_state["done"] = True;
            disengage;
        }

        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } elif next_agent == AgentTypes.PLANNER_AGENT {
            planner_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.WRITER_AGENT {
            writer_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.REVIEW_AGENT {
            review_agent(session=self.session, utterance=utterance) spawn root;
        } else {
            print("No valid next agent found, stopping execution.");
            self.session.current_state["done"] = True;
            disengage;
        }
    }
}

walker writer_agent {
    has session: Session;
    has utterance: str = "";
    
    def call_next_agent(utterance: str, current_agent_response: str, current_state: dict) -> AgentTypes by llm(
        method="reasoning"
    );
    def write_better_content(utterance: str, current_state: dict) -> str by llm();
    can execute with `root entry {
        print("writer agent executed");
        self.session.add_agent_execution("WRITER_AGENT");
        
        writer_response = self.write_better_content(self.utterance, self.session.current_state);
        self.session.current_state["writer_response"] = writer_response;
        self.session.current_state["review_response"] = "requested review";
        print("Current state after writer agent:", self.session.current_state);
        print("Execution sequence:", self.session.get_execution_summary());
        
        next_agent: AgentTypes = self.call_next_agent(
            self.utterance, 
            "writer response: " + writer_response, 
            self.session.current_state
        );
        write_content("writer_agent", writer_response);
        print("Next agent to execute:", next_agent);

        # Check for loop prevention
        if next_agent != AgentTypes.END and self.session.should_prevent_loop(next_agent.value) {
            print("🛑 Loop prevention triggered! Forcing END to prevent infinite loop.");
            print("Execution summary:", self.session.get_execution_summary());
            self.session.current_state["done"] = True;
            disengage;
        }

        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } elif next_agent == AgentTypes.PLANNER_AGENT {
            planner_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.WRITER_AGENT {
            writer_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.REVIEW_AGENT {
            review_agent(session=self.session, utterance=utterance) spawn root;
        } else {
            print("No valid next agent found, stopping execution.");
            self.session.current_state["done"] = True;
            disengage;
        }
    } 
}

walker review_agent {
    has session: Session;
    has utterance: str = "";

    def call_next_agent(utterance: str, current_agent_response: str, current_state: dict) -> AgentTypes by llm(
        method="reasoning"
    );
    def max_word_count -> int {
        return 100;
    }
    def check_passed_max_word_count(utterance: str, current_state: dict) -> str by llm(
        method="ReAct",
        tools=([self.max_word_count])
    );
    can execute with `root entry {
        print("review agent executed");
        self.session.add_agent_execution("REVIEW_AGENT");
        
        review_response = self.check_passed_max_word_count(self.utterance, self.session.current_state);
        write_content("review_agent", review_response);
        self.session.current_state["review_response"] = review_response;
        print("Current state after review agent:", self.session.current_state);
        print("Execution sequence:", self.session.get_execution_summary());
        
        next_agent: AgentTypes = self.call_next_agent(
            self.utterance, 
            "review response: " + review_response, 
            self.session.current_state
        );
        print("Next agent to execute:", next_agent);
        
        # Check for loop prevention
        if next_agent != AgentTypes.END and self.session.should_prevent_loop(next_agent.value) {
            print("🛑 Loop prevention triggered! Forcing END to prevent infinite loop.");
            print("Execution summary:", self.session.get_execution_summary());
            self.session.current_state["done"] = True;
            disengage;
        }
        
        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } elif next_agent == AgentTypes.PLANNER_AGENT {
            planner_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.WRITER_AGENT {
            writer_agent(session=self.session, utterance=utterance) spawn root;
        } elif next_agent == AgentTypes.REVIEW_AGENT {
            review_agent(session=self.session, utterance=utterance) spawn root;
        } else {
            print("No valid next agent found, stopping execution.");
            disengage;
        }
    } 
}

walker media_agent {
    has session: Session;

    can execute with `root entry {
        print("media agent executed");
        media_response = "Media content created: An infographic illustrating the key features and applications of Agentic AI, along with a short video explaining the concept in simple terms.";
        self.session.current_state["media_response"] = media_response;
        print("Media content details added to session history.", self.session.current_state);
        # return media_response;
    } 
}

with entry {
    utterance = "Generate a readme post regarding Agentic AI.";
    SupervisorAgent(utterance) spawn root;
}