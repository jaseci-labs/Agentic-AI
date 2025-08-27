from dotenv import load_dotenv
from core.graph import WorkflowGraph

def main():
    load_dotenv()

    initial_input = {
        "user_input": {
            "field": "Artificial Intelligence",
            "topic": "Agentic AI",
            "expected_output": "A detailed README.md style blog post"
        }
    }
    graph_builder = WorkflowGraph()
    app = graph_builder.app
    
    print("--- STARTING WORKFLOW ---")

    final_state = app.invoke(initial_input)
    
    print("--- WORKFLOW COMPLETE ---")

    # Save the article
    with open("final_article.md", "w") as f:
        f.write(final_state['article'])
    print("\nArticle saved to final_article.md")


if __name__ == "__main__":
    main()