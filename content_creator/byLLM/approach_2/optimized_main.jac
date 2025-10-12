# Optimized Multi-Agent Content Creator Workflow
import json;
import time;
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

enum WorkflowStage {
    PLANNING = "planning",
    WRITING = "writing", 
    REVIEWING = "reviewing",
    REVISING = "revising",
    COMPLETED = "completed"
}

def write_content(agent: str, response: str) {
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

# Enhanced Supervisor with deterministic routing logic
node Supervisor {
    def determine_next_agent(
        utterance: str, 
        current_state: dict, 
        execution_history: list,
        stage: str
    ) -> AgentTypes {
        # Rule-based routing to avoid LLM inconsistencies
        
        # Check if workflow is completed
        if current_state.get("approved", False) or current_state.get("stage") == "completed" {
            return AgentTypes.END;
        }
        
        # Check for infinite loop prevention
        if len(execution_history) >= 10 {
            print("⚠️ Max iterations reached in supervisor");
            return AgentTypes.END;
        }
        
        # Deterministic stage-based routing
        current_stage = current_state.get("stage", "planning");
        
        if current_stage == "planning" {
            if not current_state.get("planning_complete", False) {
                return AgentTypes.PLANNER_AGENT;
            }
        }
        
        if current_stage == "writing" {
            if not current_state.get("content_created", False) {
                return AgentTypes.WRITER_AGENT;
            }
        }
        
        if current_stage == "reviewing" {
            if not current_state.get("review_complete", False) {
                return AgentTypes.REVIEW_AGENT;
            }
        }
        
        if current_stage == "revising" {
            # Reset review flags for next iteration
            current_state["review_complete"] = False;
            return AgentTypes.WRITER_AGENT;
        }
        
        # Default fallback
        return AgentTypes.END;
    }
}

# Base Agent class
node Agent {
    has agent_type: AgentTypes;
}

# Enhanced Planner Agent
node PlannerAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.PLANNER_AGENT;
    
    """Create a detailed content plan including: 1) Target audience, 2) Key objectives, 3) Content structure, 4) Key points to cover, 5) Tone and style guidelines. Be specific and actionable."""
    def create_content_plan(utterance: str, current_state: dict) -> str by llm();
    
    can execute_plan with agent_executor entry {
        print("🎯 Planner Agent: Creating content strategy");
        visitor.session.add_agent_execution("PLANNER_AGENT");
        
        plan = self.create_content_plan(visitor.utterance, visitor.session.current_state);
        write_content("planner_agent", plan);
        
        # Update state with plan
        visitor.session.current_state["plan"] = plan;
        visitor.session.current_state["stage"] = WorkflowStage.WRITING.value;
        visitor.session.current_state["planning_complete"] = True;
        
        print("✅ Plan created, moving to writing stage");
        visit [<--](`?Supervisor);
    }
}

# Enhanced Writer Agent  
node WriterAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.WRITER_AGENT;
    
    """Create high-quality content based on the provided plan. If feedback is provided, incorporate it to improve the content. Focus on clarity, engagement, and meeting the objectives outlined in the plan."""
    def create_content(utterance: str, plan: str, feedback: str = "") -> str by llm();
    
    can execute_write with agent_executor entry {
        print("✍️ Writer Agent: Creating content");
        visitor.session.add_agent_execution("WRITER_AGENT");
        
        plan = visitor.session.current_state.get("plan", "");
        feedback = visitor.session.current_state.get("feedback", "");
        
        content = self.create_content(visitor.utterance, plan, feedback);
        write_content("writer_agent", content);
        
        # Update state with content and reset review flags
        visitor.session.current_state["content"] = content;
        visitor.session.current_state["stage"] = WorkflowStage.REVIEWING.value;
        visitor.session.current_state["content_created"] = True;
        visitor.session.current_state["review_complete"] = False;  # Reset for new review
        
        print("✅ Content created, moving to review stage");
        visit [<--](`?Supervisor);
    }
}

# Enhanced Review Agent
node ReviewAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.REVIEW_AGENT;
    
    def get_max_word_count -> int {
        return 100;
    }
    
    """Review the content against the plan and word count limit. Provide feedback on:
    1. Word count (max 100 words)
    2. Content quality and clarity
    3. Alignment with plan objectives
    4. Whether the content is approved or needs revision
    Be clear about approval status in your response."""
    def review_content(content: str, plan: str, max_words: int) -> str by llm(
        method="ReAct",
        tools=[self.get_max_word_count]
    );
    
    can execute_review with agent_executor entry {
        print("🔍 Review Agent: Evaluating content");
        visitor.session.add_agent_execution("REVIEW_AGENT");
        
        content = visitor.session.current_state.get("content", "");
        plan = visitor.session.current_state.get("plan", "");
        
        if not content {
            print("❌ No content to review, returning to supervisor");
            visit [<--](`?Supervisor);
            return;
        }
        
        max_words = self.get_max_word_count();
        review_result = self.review_content(content, plan, max_words);
        write_content("review_agent", review_result);
        
        # Extract approval status from review text
        approved = ("approved" in review_result.lower() or 
                   "meets" in review_result.lower() or
                   "good" in review_result.lower() or
                   "passes" in review_result.lower());
        feedback = review_result;
        
        # Update state based on review
        visitor.session.current_state["review_complete"] = True;
        visitor.session.current_state["approved"] = approved;
        visitor.session.current_state["feedback"] = feedback;
        
        if approved {
            visitor.session.current_state["stage"] = WorkflowStage.COMPLETED.value;
            print("✅ Content approved, workflow complete");
        } else {
            visitor.session.current_state["stage"] = WorkflowStage.REVISING.value;
            print("📝 Content needs revision, sending back to writer");
        }
        
        visit [<--](`?Supervisor);
    }
}

# Enhanced Walker with better state management
walker agent_executor {
    has session: Session;
    has utterance: str = "";
    has session_id: str = "";
    has max_iterations: int = 10;

    can route_workflow with Supervisor entry {
        # Check for infinite loop prevention
        if self.session.get_execution_count() >= self.max_iterations {
            print("🛑 Max iterations reached, stopping workflow");
            self.session.current_state["done"] = True;
            disengage;
            return;
        }
        
        # Get current stage
        current_stage = self.session.current_state.get("stage", WorkflowStage.PLANNING.value);
        
        next_agent: AgentTypes = here.determine_next_agent(
            self.utterance, 
            self.session.current_state,
            self.session.agent_execution_sequence,
            current_stage
        );
        
        print(f"📍 Current stage: {current_stage}, Next agent: {next_agent}");
        
        if next_agent == AgentTypes.END or self.session.current_state.get("stage") == WorkflowStage.COMPLETED.value {
            self.session.current_state["done"] = True;
            print("✅ Workflow completed successfully!");
            
            # Print final content
            final_content = self.session.current_state.get("content", "No content generated");
            print("\n🎉 Final Content:");
            print("=" * 50);
            print(final_content);
            print("=" * 50);
            
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

        # Initialize workflow state
        self.session.current_state["stage"] = WorkflowStage.PLANNING.value;
        self.session.current_state["utterance"] = self.utterance;
        
        print(f"🚀 Starting workflow for: {self.utterance}");

        # Create agent graph if it doesn't exist
        visit [-->](`?Supervisor) else {
            router_node = here ++> Supervisor();
            router_node ++> PlannerAgent();
            router_node ++> WriterAgent(); 
            router_node ++> ReviewAgent();
            visit router_node;
        }
    }
}

with entry {
    utterance = "Generate a readme post regarding Agentic AI.";
    agent_executor(utterance) spawn root;
}