# Optimized Multi-Agent Content Creator Workflow
import json;
import time;
import from agent_core { Memory, Session }
import from byllm.llm { Model }
import sys;

glob llm = Model(model_name="gpt-4o");


"Choose Planner agent for planning tasks, writer agent for writing tasks, review agent for reviewing tasks"
enum AgentTypes {
    PLANNER_AGENT,
    WRITER_AGENT,
    REVIEW_AGENT,
    END
}

enum WorkflowStage {
    PLANNING,
    WRITING, 
    REVIEWING,
    REVISING,
    COMPLETED
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

# Supervisor with LLM-based routing logic
node Supervisor {
    """You are a workflow supervisor for a content creation pipeline. Route based on the current stage:

    Workflow Stages & Routing Rules:
    - PLANNING stage + no plan -> PLANNER_AGENT
    - WRITING stage + no content -> WRITER_AGENT  
    - REVIEWING stage + content exists but not reviewed -> REVIEW_AGENT
    - REVISING stage + content needs revision -> WRITER_AGENT (CRITICAL: Always route to WRITER_AGENT when stage is REVISING)
    - COMPLETED stage or approved=True -> END

    Available Agents: PLANNER_AGENT, WRITER_AGENT, REVIEW_AGENT, END

    IMPORTANT: When current_state["stage"] == WorkflowStage.REVISING, you MUST return WRITER_AGENT to revise the content.
    Only return END when stage is COMPLETED or approved is True."""
    def call_next_agent(utterance: str, current_state: dict) -> AgentTypes by llm(method="Reason");
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
        visitor.session.current_state["stage"] = WorkflowStage.WRITING;
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
        visitor.session.current_state["stage"] = WorkflowStage.REVIEWING;
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
    Be clear about approval status in your response, if it doesn't meet the word count, do not approve."""
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
        
        # Extract approval status from review text - be more precise
        review_lower = review_result.lower();
        
        # Check for explicit rejection indicators first
        is_rejected = ("not approved" in review_lower or 
                      "needs revision" in review_lower or
                      "exceeds" in review_lower or
                      "too long" in review_lower or
                      "must be revised" in review_lower);
        
        # Only approve if explicitly approved AND not rejected
        is_approved = ("approval status: approved" in review_lower or
                      "status: approved" in review_lower or
                      (("approved" in review_lower or "passes" in review_lower) and not is_rejected));
        
        approved = is_approved and not is_rejected;
        feedback = review_result;
        
        # Update state based on review
        visitor.session.current_state["review_complete"] = True;
        visitor.session.current_state["approved"] = approved;
        visitor.session.current_state["feedback"] = feedback;
        
        if approved {
            visitor.session.current_state["stage"] = WorkflowStage.COMPLETED;
            print("✅ Content approved, workflow complete");
        } else {
            visitor.session.current_state["stage"] = WorkflowStage.REVISING;
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
        
        # Use LLM-based supervisor to determine next agent
        next_agent: AgentTypes = here.call_next_agent(self.utterance, self.session.current_state);
        
        current_stage = self.session.current_state.get("stage", WorkflowStage.PLANNING);
        print(f"📍 Current stage: {current_stage}, Next agent: {next_agent}");
        
        if next_agent == AgentTypes.END or self.session.current_state.get("stage") == WorkflowStage.COMPLETED {
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
        self.session.current_state["stage"] = WorkflowStage.PLANNING;
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