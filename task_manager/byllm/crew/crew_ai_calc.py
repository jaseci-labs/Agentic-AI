from crewai import Agent, Task, Crew

# --- Define Tools ---
def add_numbers(a: int, b: int) -> int:
    return a + b

def subtract_numbers(a: int, b: int) -> int:
    return a - b

# --- Create Agent ---
math_agent = Agent(
    name="MathAgent",
    role="Performs basic math operations",
    tools=[add_numbers, subtract_numbers]
)

# --- Define Tasks ---
task1 = Task(description="Add 10 and 5", agent=math_agent)
task2 = Task(description="Subtract 3 from 8", agent=math_agent)

# --- Run Crew ---
crew = Crew(agents=[math_agent], tasks=[task1, task2])
results = crew.kickoff()

print("Results:", results)
