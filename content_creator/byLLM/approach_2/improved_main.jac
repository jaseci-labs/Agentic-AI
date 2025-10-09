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

# Supervisor node to determine next agent
node Supervisor {
    def call_next_agent(utterance: str, current_state: dict) -> AgentTypes by llm(method="Reason");
}

# Base Agent node
node Agent {
    has agent_type: AgentTypes;
}

# Planner Agent Node
node PlannerAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.PLANNER_AGENT;
    
    def generate_executing_plan_to_generate_better_content(utterance: str, agents: str) -> str by llm();
    
    can execute_plan with agent_executor entry {
        print("planner agent executed");
        visitor.session.add_agent_execution("PLANNER_AGENT");
        
        planner_response = self.generate_executing_plan_to_generate_better_content(
            visitor.utterance, 
            ", ".join([a.value for a in AgentTypes])
        );
        write_content("planner_agent", planner_response);
        visitor.session.current_state["planner_response"] = planner_response;
        print("Current state after planner agent:", visitor.session.current_state);
        
        # Navigate back to router for next decision
        visit [<--](`?Supervisor);
    }
}

# Writer Agent Node  
node WriterAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.WRITER_AGENT;
    
    def write_better_content(utterance: str, current_state: dict) -> str by llm();
    
    can execute_write with agent_executor entry {
        print("writer agent executed");
        visitor.session.add_agent_execution("WRITER_AGENT");
        
        writer_response = self.write_better_content(visitor.utterance, visitor.session.current_state);
        visitor.session.current_state["writer_response"] = writer_response;
        visitor.session.current_state["review_response"] = "requested review";
        print("Current state after writer agent:", visitor.session.current_state);
        
        write_content("writer_agent", writer_response);
        # Navigate back to router for next decision
        visit [<--](`?Supervisor);
    }
}

# Review Agent Node
node ReviewAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.REVIEW_AGENT;
    
    def max_word_count -> int {
        return 100;
    }
    def check_passed_max_word_count(utterance: str, current_state: dict) -> str by llm(
        method="ReAct",
        tools=([self.max_word_count])
    );
    
    can execute_review with agent_executor entry {
        print("review agent executed");
        visitor.session.add_agent_execution("REVIEW_AGENT");
        
        review_response = self.check_passed_max_word_count(visitor.utterance, visitor.session.current_state);
        write_content("review_agent", review_response);
        visitor.session.current_state["review_response"] = review_response;
        print("Current state after review agent:", visitor.session.current_state);
        
        # Navigate back to router for next decision
        visit [<--](`?Supervisor);
    }
}

walker agent_executor {
    has session: Session;
    has utterance: str = "";
    has session_id: str = "";

    can continue_workflow with Supervisor entry {
        next_agent: AgentTypes = here.call_next_agent(self.utterance, self.session.current_state);
        print("Next agent to execute:", next_agent);
        
        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } else {
            # Visit the appropriate agent node
            visit [-->](`?Agent)(?agent_type == next_agent);
        }
    }

    can init_graph with `root entry {
        # Initialize memory and session
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

        # Create agent graph if it doesn't exist
        visit [-->](`?Supervisor) else {
            router_node = here ++> Supervisor();
            router_node ++> PlannerAgent();
            router_node ++> WriterAgent(); 
            router_node ++> ReviewAgent();
            visit router_node;
        }
    }
    
    can start_routing with Supervisor entry {
        # Start the workflow by making the first routing decision
        next_agent: AgentTypes = here.call_next_agent(self.utterance, self.session.current_state);
        print("Next agent to execute:", next_agent);
        
        if next_agent == AgentTypes.END {
            self.session.current_state["done"] = True;
            print("✅ Stopping: better/approved response reached.");
            disengage;
        } else {
            # Visit the appropriate agent node
            visit [-->](`?Agent)(?agent_type == next_agent);
        }
    }
}

with entry {
    utterance = "Generate a readme post regarding Agentic AI.";
    agent_executor(utterance) spawn root;
}