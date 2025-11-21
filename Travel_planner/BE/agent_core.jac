import from byllm.llm { Model }
import from tools { get_tools }
import from dotenv { load_dotenv }
import from agent_brain { brain, AgentType, AgentRole, AgentResult }
import from agent_memory { memory }

# Global LLM instance used for agent reasoning and decision-making
glob llm = Model(model_name="gpt-4o-mini", verbose=False);


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
    has tools: list = [];          # Available tools for the agent
    has brain: brain = brain();    # Cognitive processing unit
    has memory: memory = memory(); # Historical context storage
    has required_information: str = "Not Specified";
    has expected_output: str = "Not Specified";

    # Execution control
    has iteration_count: int = 0;        # Number of execution iterations
    has agent_status: str = "Not started";  # Current execution status
    has retry_count: int = 0;            # Number of retry attempts
    has max_retries: int = 3;            # Maximum allowed retries

    # Behavior flags
    has allow_delegation: bool = False;  # Whether agent can delegate to others
    has enable_observation: bool = False;  # Whether to validate results
    has tools_added: bool = False;

    # Results
    has final_result: str = "";  # Final output of the agent

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


        tools = get_tools();  # retrieve available tools
        funcs_to_add = [tools[name] for name in self.tools if name in tools];
        self.brain.tools = funcs_to_add;  # Assign tools to brain
        # Initialize execution
        self.show_agent_status();

        if len(self.tools) > 0 {
            print(f"tools: {self.tools}");
            print();
        }

        self.memory.append({
            "iteration": self.iteration_count,
            "input_data": visitor.next_agent_input_data,
        });

        print("input: ", visitor.next_agent_input_data);
        print();

        # Decision phase
        decision = False;

        if (self.agent_type == AgentType.UI_Agent) and (visitor.next_agent_input_data["source"] == "user") {
            decision = self.brain.decide_respond(self.required_information, self.memory.get_context());
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

        self.brain.tools = [];

        thought = agent_result.thought;
        result = agent_result.result;

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
                visit self;  # Re-execute current agent
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

        # Delegation phase
        should_delegate = False;

        if self.agent_type == AgentType.Agent {
            should_delegate = self.allow_delegation;
        } else {
            # For UI agents, only delegate if user confirmed workflow continuation
            should_delegate = (decision == True) and (self.allow_delegation == True);
        }

        if should_delegate {
            connected_agents = [-->(`?BaseAgent)] + [<--(`?BaseAgent)];

            # Decide which agent should handle the next step
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
            self.brain.store_agent_result(self.agent_role, self.final_result);  # Store result globally

            if self.agent_type == AgentType.Agent {
                visitor.next_agent_input_data = {
                    "source": self.agent_role.value,
                    "result": "Agent result stored successfully",
                };
                visit [<--];  # Return to parent agent
            } else {
                visitor.next_agent_input_data = {
                    "source": self.agent_role.value,
                    "result": self.final_result,
                };
                disengage;
            }
        }
    }
}