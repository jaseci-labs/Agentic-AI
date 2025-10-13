# Optimized Multi-Agent Content Creator Workflow
import json;
import time;
import from typing {List}
import from agent_core { Memory, Session }
import from byllm.llm { Model }
import sys;

glob llm = Model(model_name="gpt-4o", verbose=False);


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

sem WorkflowStage.PLANNING = "initial planning stage";
sem WorkflowStage.WRITING = "content creation stage";
sem WorkflowStage.REVIEWING = "content review stage";
sem WorkflowStage.REVISING = "content revision stage";
sem WorkflowStage.COMPLETED = "workflow completed";

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
    """You are a workflow supervisor. Follow these rules in EXACT ORDER:

    1. END CONDITIONS (check first):
       - current_state["approved"] == True → return END 
       - current_state.get("revision_count", 0) >= 5 → return END

    2. STAGE ROUTING (if not ending):
       - "PLANNING" in str(current_state["stage"]) → return PLANNER_AGENT
       - "WRITING" in str(current_state["stage"]) → return WRITER_AGENT
       - "REVIEWING" in str(current_state["stage"]) → return REVIEW_AGENT
       - "REVISING" in str(current_state["stage"]) → return WRITER_AGENT

    🚨 CRITICAL: "REVISING" stage means content was REJECTED and needs REWRITING
    → ALWAYS return WRITER_AGENT for REVISING (never REVIEW_AGENT, never END)
    
    Only return: PLANNER_AGENT, WRITER_AGENT, REVIEW_AGENT, or END"""
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
        print(f"feedback received for writer agent: {feedback}");
        
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

obj ReviewResult {
    has is_approved: bool;
    has review_comments: str;
}

sem ReviewResult.is_approved = "if the content meets the criteria, set to true; otherwise, false";
sem ReviewResult.review_comments = "detailed feedback on content quality, clarity, alignment with plan, and max word count compliance.";

# Enhanced Review Agent
node ReviewAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.REVIEW_AGENT;
    
    def get_max_word_count -> int {
        return 100;
    }
    
    """Review the content for APPROVAL. Only reject if content has CRITICAL issues:

    CRITICAL REJECTION CRITERIA (is_approved = false):
    1. Word count exceeds 100 words (MANDATORY rejection)
    2. Content is completely unrelated to the plan
    3. Content is gibberish or incomprehensible

    APPROVAL CRITERIA (is_approved = true):
    - Word count is 100 words or less
    - Content is reasonably related to the plan  
    - Content is understandable

    DO NOT reject for minor improvements, suggestions, or subjective preferences.
    If content meets basic requirements, APPROVE it even if it could be improved.
    
    Return ReviewResult with is_approved and detailed review_comments."""
    def review_content(content: str, plan: str, max_words_count: int) -> ReviewResult by llm(
        method="Reason",
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
        print(f"📝 Review completed={review_result}");
        write_content("review_agent", review_result.review_comments);
        
        # Extract structured data from ReviewResult object
        approved = review_result.is_approved;
        feedback = review_result.review_comments;
        
        # Track revision attempts
        revision_count = visitor.session.current_state.get("revision_count", 0);
        
        # Update state based on review
        visitor.session.current_state["review_complete"] = True;
        visitor.session.current_state["approved"] = approved;
        visitor.session.current_state["feedback"] = feedback;
        
        if approved {
            visitor.session.current_state["stage"] = WorkflowStage.COMPLETED;
            print("✅ Content approved, workflow complete");
        } else {
            # Increment revision count and check limit
            revision_count += 1;
            visitor.session.current_state["revision_count"] = revision_count;
            
            if revision_count >= 5 {
                visitor.session.current_state["stage"] = WorkflowStage.COMPLETED;
                visitor.session.current_state["approved"] = True;  # Force completion
                print(f"⚠️ Max revisions ({revision_count}) reached, stopping workflow");
            } else {
                visitor.session.current_state["stage"] = WorkflowStage.REVISING;
                print(f"📝 Content needs revision (attempt {revision_count}/5), sending back to writer");
            }
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
        
        current_stage = self.session.current_state.get("stage", WorkflowStage.PLANNING);
        approved = self.session.current_state.get("approved", False);
        revision_count = self.session.current_state.get("revision_count", 0);
        
        # Debug information
        print(f"🔍 Debug - Stage: {current_stage}, Approved: {approved}, Revisions: {revision_count}");
        
        # Use LLM-based supervisor to determine next agent
        next_agent = here.call_next_agent(self.utterance, self.session.current_state);
        
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