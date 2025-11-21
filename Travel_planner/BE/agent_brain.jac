import from byllm.llm { Model }

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

glob agent_results_store: dict = {};

"""
Access the result of a specific agent.
Args:
    agent_role (AgentRole): Role identifier of the required agent
Returns:
    str: Result output from the specified agent
"""
def access_agent_results(agent_role: AgentRole) {
    return agent_results_store[agent_role.value];
}

enum AgentRole {
    Trip_Orchestration_Agent = "Trip Orchestration Agent",
    Trip_Intake_Agent = "Trip Intake Agent",
    Flight_Finder_Agent = "Flight Finder Agent",
    Activities_Planner_Agent = "Activities Planner Agent",
    Accommodation_Curation_Agent = "Accommodation Curation Agent",
    Itinerary_Builder_Agent = "Itinerary Builder Agent",
    Quality_Review_Agent = "Quality Review Agent",
}

"""
Represents the output of an agent's processing.
Contains both the reasoning (thought) and the actual result.
"""
obj AgentResult {
    has thought: str;  # Agent's reasoning process
    has result: str;   # Final output or decision
}

obj NextAgent {
    has agent_role: AgentRole;  # Role of the next agent to execute
    has agent_input_data: str;  # Input data to pass to the next agent
}


"""
Agent's decision-making and processing unit.
"""
obj brain {
    has tools: list = [];  # Available tools for the agent to use

    """Stores the result of an agent's execution in the global results store."""
    def store_agent_result(agent: AgentRole, result: str) {
        agent_results_store[agent.value] = result;
    }

    """
    If the user explicitly said "yes" after the user has provided ALL the required_information and the AI asked to confirm the required_information return True, else False.
    """
    def decide_respond(required_information: str, memory_context: dict) -> bool
        by llm();

    """
    Generates a result based on the current context and objective.
    Use when required.
    Args:
        goal: The objective to achieve
        system_prompt: Instructions for the agent
        memory_context: Historical context and previous interactions
        expected_output: The expected output format/contract
    Returns:
        agent_result: Contains both thought process and final result
    """
    def generate_result(goal: str, system_prompt: str, memory_context: list, expected_output: str) -> AgentResult
        by llm(method="ReAct", tools=self.tools);

    """
    Evaluates if the generated result meets the intended goal.
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
    Select the most suitable agent from the connected_agents list to handle the given task.
    Provide the chosen agent with the data it needs to perform its task. 
    Ensure exactly one agent is always selected.
    Access agents results when required.
    """
    def decide_next_agent(connected_agents: list, goal: str, system_prompt: str, memory_context: list) -> NextAgent
        by llm(method="ReAct", tools=[access_agent_results]);
}
