import from mtllm { Model }
import from aider.web_search { web_search, create_web_searcher, WebSearcher }
import from typing { Optional, Dict, Any }


glob llm = Model(model_name = "gpt-4o-mini");


# """
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


def perform_web_search_for_task(task: Dict, last_error_context: Optional[str] = None) -> str by llm(method="ReAct", tools=[web_search]);

with entry {
    task = {'name': 'Create basic calculator in Jac', 'type': 'feature_implementation', 'priority': 1, 'details': "Create a new Jac script file named 'simple_calculator.jac'. Implement basic arithmetic functions: addition, subtraction, multiplication, and division as Jac functions. Provide a main function that reads user input, parses command and operands, and calls the appropriate arithmetic function. Use Jac language syntax for defining functions and input/output. Include error handling for invalid inputs and division by zero.", 'dependencies': [], 'estimated_effort': 'medium', 'file': 'simple_calculator.jac'};

    print(perform_web_search_for_task(task));
}