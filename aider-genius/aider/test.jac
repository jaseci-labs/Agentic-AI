import from mtllm { Model }
import from aider.web_search { web_search, create_web_searcher, WebSearcher }
import from typing { Optional, Dict, Any }
import from mcp_client { list_mcp_tools, call_mcp_tool }
import mcp_client;


with entry {
    planning_model = Model(model_name="gemini/gemini-2.5-flash", temperature=0.1,verbose=True);
}

# Perform a web search using the Serper API.

# Args:
#     query (str): The search query.
    
# Returns:
#     Optional[str]: Formatted search results or None if no results found.
# """
# def web_search(query: str) -> Optional[str] {
#     searcher = create_web_searcher();
#     return searcher.search(query);
# }


# def perform_web_search_for_task(task: Dict, last_error_context: Optional[str] = None) -> str by llm(method="ReAct", tools=[web_search]);

"""Get available MCP tool names."""
def list_mcp_tools() -> list[str] {
    return mcp_client.list_mcp_tools();
}

"""Use MCP tool to perform actions.
name must be one of available tools from list_mcp_tools(), do not make up any tool names.

Example input for `use_mcp_tool`:
{"name": "tool_name", "arguments": {"query": "your query"}}

Always pass arguments as a flat dictionary (e.g., {\"query\": \"Your search query\"}), never as a list or schema_dict_wrapper.
"""
def use_mcp_tool(name: str, arguments: dict[str, str]) -> str {
    return mcp_client.call_mcp_tool(name=name, arguments=arguments);
}

"""Perform background research to gather additional context. return a detailed explanation of the task and its requirements, including any relevant details or constraints.
Use available mcp tool when needed.Use list_mcp_tools to find out what are the available tools. 
Always pass arguments as a flat dictionary (e.g., {\"query\": \"Your search query\"}), never as a list or schema_dict_wrapper."""
def background_research(task_description:str) -> str by planning_model(method="ReAct", tools=[use_mcp_tool, list_mcp_tools]);

with entry {
    # task = {'name': 'Create basic calculator in Jac', 'type': 'feature_implementation', 'priority': 1, 'details': "Create a new Jac script file named 'simple_calculator.jac'. Implement basic arithmetic functions: addition, subtraction, multiplication, and division as Jac functions. Provide a main function that reads user input, parses command and operands, and calls the appropriate arithmetic function. Use Jac language syntax for defining functions and input/output. Include error handling for invalid inputs and division by zero.", 'dependencies': [], 'estimated_effort': 'medium', 'file': 'simple_calculator.jac'};
    task = "Create an example using the 'by' keyword in Jac language.";
    web_scraped_info = background_research(task);
    print(f"Background research results: {web_scraped_info}");
    # print(perform_web_search_for_task(task));
}