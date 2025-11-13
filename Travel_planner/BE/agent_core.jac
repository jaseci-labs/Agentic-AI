import from byllm.llm { Model }
import from dotenv { load_dotenv }
import from agent_brain {brain}
import from agent_memory {memory}

glob llm = Model(model_name="gpt-4o-mini", verbose=False);

"""
Defines the types of agents in the system:
- UI_Agent: Handles user interface interactions
- Agent: Core processing agent
"""
enum AgentType {
    UI_Agent,
    Agent,
}

enum AgentRole {
    # Trip_Creator = "Trip Creator Agent",
    Trip_Orchestration_Agent = "Trip Orchestration Agent",
    Trip_Intake_Agent = "Trip Intake Agent",
    Flight_Finder_Agent = "Flight Finder Agent",
    City_Advisor_Agent = "City Advisor Agent",
    Accommodation_Curation_Agent = "Accommodation Curation Agent",
    Daily_Itinerary_Agent = "Daily Itinerary Agent",
    Quality_Review_Agent = "Quality Review Agent",
}

"""
Walker responsible for traversing between agents and managing the flow of data.
"""
walker AgentVisitor {
    has next_agent_input_data: dict;  # Data to be passed to the next agent
}

"""
Base agent node that provides core functionality for all agent types.
Handles execution flow, memory management, and agent interactions.
"""
node BaseAgent {
    # Core properties
    has agent_type: AgentType;     # Type of the agent (UI or processing)
    has agent_role: AgentRole;     # Specific role/responsibility of the agent
    has goal: str;                 # Current objective of the agent
    has system_prompt: str;        # Instructions/context for the agent

    # Component instances
    has brain: brain = brain();    # Cognitive processing unit
    has memory: memory = memory(); # Historical context storage
    has tools: list = [];          # Available tools for the agent
    has required_information: str = "Not Specified";
    has expected_output: str = "Not Specified";

    # Execution control
    has iteration_count: int = 0;        # Number of execution iterations
    has agent_status: str = "Not started";  # Current execution status
    has retry_count: int = 0;            # Number of retry attempts
    has max_retries: int = 3;            # Maximum allowed retries

    # Behavior flags
    has allow_delegation: bool = False;  # Whether agent can delegate to others
    has enable_observation: bool = True; # Whether to validate results

    # Results
    has final_result: str = "";          # Final output of the agent

    """
    Updates and shows the agent's status.
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
    Main execution logic for the agent.
    """
    can execute with AgentVisitor entry {
        # Initialize execution
        self.show_agent_status();

        self.memory.append({
            "iteration": self.iteration_count,
            "input_data": visitor.next_agent_input_data,
        });

        # print("input", visitor.next_agent_input_data);

        decision = False;

        if (self.agent_type == AgentType.UI_Agent) and (visitor.next_agent_input_data["source"] == "user") {
            decision = self.brain.decide_respond(self.required_information, self.memory.get_context());
            # print(decision);
            print();

            if decision == True {
                print("[INFO] Starting agentic workflow");
                print();
                agent_result = AgentResult(
                    thought="User has confirmed the request and information; must invoke next agent",
                    result="Invoking next agent",
                );
            } else {
                # Generate result for the user
                print("[INFO] Responding to user");
                print();
                agent_result = self.brain.generate_result(
                    self.goal,
                    self.system_prompt,
                    self.memory.get_context(),
                    self.expected_output,
                );
            }
        } else {
            # Generate result for non-UI agents
            agent_result = self.brain.generate_result(
                self.goal,
                self.system_prompt,
                self.memory.get_context(),
                self.expected_output,
            );
        }

        thought = agent_result.thought;
        result  = agent_result.result;

        # Record thought process
        self.memory.append({
            "iteration": self.iteration_count,
            "agent_thought": thought,
        });
        print();
        print("thought: ", thought);
        print();

        # Record result
        self.memory.append({
            "iteration": self.iteration_count,
            "agent_result": result,
        });
        print("result: ", result);
        print();

        # Validate result if enabled
        agent_result_observation = None;

        if self.enable_observation {
            agent_result_observation = self.brain.observe_result(
                self.goal,
                self.system_prompt,
                self.memory.get_context(),
            );

            self.memory.append({
                "iteration": self.iteration_count,
                "agent_result_observation": agent_result_observation,
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
                visit self;  # Re-execute agent
            } else {
                result = "[INFO] The agent could not complete the task because execution exceeded the maximum retry limit.";
                print(result);
                print();
            }
        }

        # Prepare final result
        self.final_result = result;

        # Update status
        self.show_agent_status();

        # Efficient agent navigation and delegation
        should_delegate = False;

        if self.agent_type == AgentType.Agent {
            should_delegate = self.allow_delegation;
        } else {
            should_delegate = (decision == True) and (self.allow_delegation == True);
        }

        if should_delegate {
            connected_agents = [-->(`?BaseAgent)] + [<--(`?BaseAgent)];
            # print(connected_agents);

            next_agent_data = self.brain.decide_next_agent(
                connected_agents,
                self.goal,
                self.system_prompt,
                self.memory.get_context(),
            );

            next_agent = next_agent_data.agent_role;

            visitor.next_agent_input_data = {
                "source": self.agent_role.value,
                "input_data": next_agent_data.agent_input_data,
            };

            print();
            print(f"Routing to {next_agent.value}...");
            print();

            # Visit next agent based on role
            visit [-->(`?BaseAgent: agent_role == next_agent)] else {
                visit [<--(`?BaseAgent: agent_role == next_agent)];
            }
        } else {
            visitor.next_agent_input_data = {
                "source": self.agent_role.value,
                "result": self.final_result,
            };

            if self.agent_type == AgentType.Agent {
                visit [<--];
            } else {
                disengage;
            }
        }
    }
}
