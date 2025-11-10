
import from byllm.llm { Model }
import from dotenv { load_dotenv }

glob llm = Model(model_name="gemini/gemini-2.0-flash");

"""
Defines the types of agents in the system:
- UI_Agent: Handles user interface interactions
- Agent: Core processing agent
"""
enum AgentType {
    UI_Agent,
    Ochestrator_Agent,
    Agent
}

enum AgentRole {
    Trip_Creator = "Trip Creator Agent",
    Trip_Intake_Agent = "Trip Intake Agent",
    Flight_Finder_Agent = "Flight Finder Agent",
    City_Advisor_Agent = "City Advisor Agent",
    Accommodation_Curation_Agent = "Accommodation Curation Agent",
    Daily_Itinerary_Agent = "Daily Itinerary Agent",
    Quality_Review_Agent = "Quality Review Agent"
}

"""
Represents the output of an agent's processing
Contains both the reasoning (thought) and the actual result
"""
obj agent_result {
    has thought: str;  # Agent's reasoning process
    has result: str;   # Final output or decision
}

"""
Agent's decision making and processing unit
"""
obj brain {
    has tools: list = [];  # Available tools for the agent to use

    """
    False if the next step is to communicate with the user, True to execute the agents to generate a result
    """
    def decide_next_step(connected_agents: list, goal: str, system_prompt: str, memory_context: dict) -> bool 
        by llm();

    """
    Generates a result based on the current context and objective
    Args:
        goal: The objective to achieve
        system_prompt: Instructions for the agent
        memory_context: Historical context and previous interactions
    Returns:
        agent_result: Contains both thought process and final result
    """
    def generate_result(goal: str, system_prompt: str, memory_context: list) -> agent_result 
        by llm(method="ReAct", tools=self.tools);

    """
    Evaluates if the generated result meets the intended goal
    Args:
        goal: The objective to achieve
        system_prompt: Instructions for the agent
        memory_context: Historical context and previous interactions
    Returns:
        bool: True if result meets goal, False otherwise
    """
    def observe_result(goal: str, system_prompt: str, memory_context: list) -> bool 
        by llm();

    """
    Selects the next appropriate agent to handle the workflow
    Args:
        connected_agents: List of available agents
        goal: The objective to achieve
        system_prompt: Instructions for the agent
        memory_context: Historical context and previous interactions
    Returns:
        AgentRole: Role of the next agent to execute
    """
    def decide_next_agent(connected_agents: list, goal: str, system_prompt: str, memory_context: list) -> AgentRole 
        by llm(method="Reason");
}


"""
Walker responsible for traversing between agents and managing the flow of data
"""
walker AgentVisitor {
    has next_agent_input_data: dict;  # Data to be passed to the next agent
}

"""
Stores and manages agent's memory
"""
obj memory {
    has items: list = [];  # List of memory entries

    """
    Adds an item to memory
    """
    def append(item: dict) -> None {
        self.items.append(item);
    }

    """
    Gets recent memory items
    """
    def get_context(k: int = 20) -> List[Dict[str, Any]] {
        return self.items[-k:];
    }

    """
    Takes a snapshot of memory
    """
    def snapshot() -> dict {
        return {"items": self.items};
    }
}

"""
Base agent node that provides core functionality for all agent types
Handles execution flow, memory management, and agent interactions
"""
node BaseAgent {
    # Core properties
    has agent_type: AgentType;          # Type of the agent (UI or processing)
    has agent_role: AgentRole;          # Specific role/responsibility of the agent
    has goal: str;                      # Current objective of the agent
    has system_prompt: str;             # Instructions/context for the agent

    # Component instances
    has brain: brain = brain();         # Cognitive processing unit
    has memory: memory = memory();      # Historical context storage
    has tools: list = [];               # Available tools for the agent

    # Execution control
    has iteration_count: int = 0;       # Number of execution iterations
    has agent_status: str = "Not started";  # Current execution status
    has retry_count: int = 0;           # Number of retry attempts
    has max_retries: int = 3;           # Maximum allowed retries
    
    # Behavior flags
    has allow_delegation: bool = False;  # Whether agent can delegate to others
    has enable_observation: bool = True; # Whether to validate results
    
    # Results
    has final_result: dict = {};        # Final output of the agent

    """
    Updates and shows agent's status
    """
    def show_agent_status() {
        if self.agent_status == "Not started" {
            self.agent_status = "In progress";
            print();
            print(f"[INFO] The {self.agent_role.value} is now running...");
            print();
        } elif self.agent_status == "In progress" {
            self.agent_status = "Completed";
            print(f"[INFO] {self.agent_role.value} execution completed.");
            print();
            self.agent_status = "Not started";
        }
    }

    """
    Main execution logic for the agent
    """
    can execute with AgentVisitor entry {
        # Initialize execution
        self.show_agent_status();
        self.memory.append({
            "iteration": self.iteration_count, 
            "input_data": visitor.next_agent_input_data
        });

        if self.agent_type == AgentType.UI_Agent{

        }elif self.agent_type == AgentType.Ochestrator_Agent{

        }else{
            agent_result = self.brain.generate_result(
            self.goal, 
            self.system_prompt, 
            self.memory.get_context()
        );
        }
        

        agent_result = self.brain.generate_result(
            self.goal, 
            self.system_prompt, 
            self.memory.get_context()
        );

        thought = agent_result.thought;
        result = agent_result.result;

        # Record thought process
        self.memory.append({
            "iteration": self.iteration_count, 
            "agent_thought": thought
        });
        print("thought:", thought);
        print();

        # Record result
        self.memory.append({
            "iteration": self.iteration_count, 
            "agent_result": result
        });
        print("result:", result);
        print();

        # Validate result if enabled
        agent_result_observation = None;
        if self.enable_observation {
            agent_result_observation = self.brain.observe_result(
                self.goal, 
                self.system_prompt, 
                self.memory.get_context()
            );
            self.memory.append({
                "iteration": self.iteration_count, 
                "agent_result_observation": agent_result_observation
            });
            print("observation:", agent_result_observation);
            print();
        }

        # Handle retry logic
        if self.enable_observation and (agent_result_observation == False) {
            if self.retry_count < self.max_retries {
                self.retry_count += 1;
                print("[INFO] Re-executing agent...");
                print();
                visit self;  # re-execute agent
            } else {
                result = "[INFO] The agent could not complete the task because execution exceeded the maximum retry limit.";
                print(result);
                print();
            }
        }

        # Prepare final result
        self.final_result = {
            "agent": self.agent_role.value, 
            "result": result
        };

        # Update visitor data and status
        visitor.next_agent_input_data = self.final_result;
        self.show_agent_status();

        # Handle agent navigation
        if self.agent_type == AgentType.Agent {
            if self.allow_delegation {
                # Get connected agents and determine next agent
                connected_agents = [-->(`?BaseAgent)] + [<--(`?BaseAgent)];
                next_agent = self.brain.decide_next_agent(
                    connected_agents,
                    self.goal,
                    self.system_prompt,
                    self.memory.get_context()
                );
                # Visit next agent based on role
                visit [-->(`?BaseAgent: agent_role == next_agent)] else {
                    visit [<--(`?BaseAgent: agent_role == next_agent)];
                }
            } else {
                visit [<--];
            }
        } else {
            # Handle UI agent flow
            connected_agents = [-->(`?BaseAgent)];
            print("connected agents", connected_agents);
            result = self.brain.decide_next_step(connected_agents, self.goal, self.system_prompt, self.memory.get_context());
            if result == True {
                visit [-->];
            } else {
                disengage;
            }
        }
    }
}


