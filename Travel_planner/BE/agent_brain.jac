
"""
Represents the output of an agent's processing.
Contains both the reasoning (thought) and the actual result.
"""
obj AgentResult {
    has thought: str;  # Agent's reasoning process
    has result: str;   # Final output or decision
}

obj NextAgent {
    has agent_role: AgentRole;
    has agent_input_data: str;
}

"""
Agent's decision-making and processing unit.
"""
obj brain {
    has tools: list = [];  # Available tools for the agent to use

    """
    If the user explicitly said "yes" after the AI asked to confirm the required information return True, else False.
    """
    def decide_respond(required_information: str, memory_context: dict) -> bool by llm();

    """
    Generates a result based on the current context and objective.
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
    """
    def decide_next_agent(connected_agents: list, goal: str, system_prompt: str, memory_context: list) -> NextAgent
        by llm(method="Reason");
}
