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

sem AgentTypes.PLANNER_AGENT = "Agent responsible for creating content plans and strategies";
sem AgentTypes.WRITER_AGENT = "Agent responsible for writing and revising content based on plans and feedback";
sem AgentTypes.REVIEW_AGENT = "Agent responsible for reviewing content quality, word count, and alignment with objectives";
sem AgentTypes.END = "Workflow termination - use when content is approved or max revisions reached";


enum WorkflowStage {
    PLANNING,
    WRITING, 
    REVIEWING,
    REVISING,
    COMPLETED
}

sem WorkflowStage.PLANNING = "Initial stage - route to PLANNER_AGENT to create content strategy";
sem WorkflowStage.WRITING = "Content creation stage - route to WRITER_AGENT to write or revise content";
sem WorkflowStage.REVIEWING = "Quality check stage - route to REVIEW_AGENT to evaluate content";
sem WorkflowStage.REVISING = "Content rejected and needs rewriting - route to WRITER_AGENT (NOT review agent)";
sem WorkflowStage.COMPLETED = "Final stage - route to END to terminate workflow";


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

node Supervisor {
    def call_next_agent(utterance: str, current_state: dict) -> AgentTypes by llm(method="Reason");
}

node Agent {
    has agent_type: AgentTypes;
}

node PlannerAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.PLANNER_AGENT;
    
    """Create a detailed content plan including: 1) Target audience, 2) Key objectives, 3) Content structure, 4) Key points to cover, 5) Tone and style guidelines. Be specific and actionable."""
    def create_content_plan(utterance: str, current_state: dict) -> str by llm();
    
    can execute_plan with agent_executor entry {
        print("Planner Agent: Creating content strategy");
        visitor.session.add_agent_execution("PLANNER_AGENT");
        
        plan = self.create_content_plan(visitor.utterance, visitor.session.current_state);
        write_content("planner_agent", plan);

        visitor.session.current_state["plan"] = plan;
        visitor.session.current_state["stage"] = WorkflowStage.WRITING;
        visitor.session.current_state["planning_complete"] = True;
        
        print("Plan created, moving to writing stage");
        visit [<--](`?Supervisor);
    }
}
  
node WriterAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.WRITER_AGENT;
    
    """Create high-quality content based on the provided plan. If feedback is provided, incorporate it to improve the content. Focus on clarity, engagement, and meeting the objectives outlined in the plan."""
    def create_content(utterance: str, plan: str, feedback: str = "") -> str by llm();
    
    can execute_write with agent_executor entry {
        print("Writer Agent: Creating content");
        visitor.session.add_agent_execution("WRITER_AGENT");
        
        plan = visitor.session.current_state.get("plan", "");
        feedback = visitor.session.current_state.get("feedback", "");
        print(f"feedback received for writer agent: {feedback}");
        
        content = self.create_content(visitor.utterance, plan, feedback);
        write_content("writer_agent", content);

        visitor.session.current_state["content"] = content;
        visitor.session.current_state["stage"] = WorkflowStage.REVIEWING;
        visitor.session.current_state["content_created"] = True;
        visitor.session.current_state["review_complete"] = False;
        
        print("Content created, moving to review stage");
        visit [<--](`?Supervisor);
    }
}

obj ReviewResult {
    has is_approved: bool;
    has review_comments: str;
}

sem ReviewResult.is_approved = "if the content meets the criteria, set to true; otherwise, false";
sem ReviewResult.review_comments = "detailed feedback on content quality, clarity, alignment with plan, and max word count compliance.";

node ReviewAgent(Agent) {
    has agent_type: AgentTypes = AgentTypes.REVIEW_AGENT;
    
    def get_max_word_count -> int {
        return 100;
    }
    
    def review_content(content: str, plan: str, max_words_count: int) -> ReviewResult by llm(
        method="Reason",
    );
    
    can execute_review with agent_executor entry {
        print("Review Agent: Evaluating content");
        visitor.session.add_agent_execution("REVIEW_AGENT");
        
        content = visitor.session.current_state.get("content", "");
        plan = visitor.session.current_state.get("plan", "");
        
        if not content {
            print("No content to review, returning to supervisor");
            visit [<--](`?Supervisor);
            return;
        }
        
        max_words = self.get_max_word_count();
        review_result = self.review_content(content, plan, max_words);
        print(f"Review completed={review_result}");
        write_content("review_agent", review_result.review_comments);
        
        approved = review_result.is_approved;
        feedback = review_result.review_comments;
        
        revision_count = visitor.session.current_state.get("revision_count", 0);
        
        visitor.session.current_state["review_complete"] = True;
        visitor.session.current_state["approved"] = approved;
        visitor.session.current_state["feedback"] = feedback;
        
        if approved {
            visitor.session.current_state["stage"] = WorkflowStage.COMPLETED;
            print("Content approved, workflow complete");
        } else {
            revision_count += 1;
            visitor.session.current_state["revision_count"] = revision_count;
            
            if revision_count >= 5 {
                visitor.session.current_state["stage"] = WorkflowStage.COMPLETED;
                visitor.session.current_state["approved"] = True;  # Force completion
                print(f"Max revisions ({revision_count}) reached, stopping workflow");
            } else {
                visitor.session.current_state["stage"] = WorkflowStage.REVISING;
                print(f"Content needs revision (attempt {revision_count}/5), sending back to writer");
            }
        }
        
        visit [<--](`?Supervisor);
    }
}

walker agent_executor {
    has session: Session | None = None;
    has utterance: str = "";
    has session_id: str = "";
    has max_iterations: int = 10;

    can route_workflow with Supervisor entry {
        if self.session.get_execution_count() >= self.max_iterations {
            print("Max iterations reached, stopping workflow");
            self.session.current_state["done"] = True;
            disengage;
            return;
        }
        
        current_stage = self.session.current_state.get("stage", WorkflowStage.PLANNING);
        approved = self.session.current_state.get("approved", False);
        revision_count = self.session.current_state.get("revision_count", 0);

        next_agent = here.call_next_agent(self.utterance, self.session.current_state);
        
        print(f"Current stage: {current_stage}, Next agent: {next_agent}");
        
        if next_agent == AgentTypes.END or self.session.current_state.get("stage") == WorkflowStage.COMPLETED {
            self.session.current_state["done"] = True;
            print("Workflow completed successfully!");

            final_content = self.session.current_state.get("content", "No content generated");
            print("\nFinal Content:");
            print("=" * 50);
            print(final_content);
            print("=" * 50);
            
            disengage;
        } else {
            visit [-->](`?Agent)(?agent_type == next_agent);
        }
    }

    can init_graph with `root entry {
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

        self.session.current_state["stage"] = WorkflowStage.PLANNING;
        self.session.current_state["utterance"] = self.utterance;
        
        print(f"Starting workflow for: {self.utterance}");

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
    agent_executor(utterance=utterance) spawn root;
}