import from dotenv { load_dotenv }
import from graph { WorkflowGraph }
import from state { AgentState }
import from json { load as json_load }
import from rag_setup { setup_rag_pipeline }

with entry {
    with open("input.json", "r") as f {
        initial_input = json_load(f);
    }
    documents_folder = initial_input["user_input"]["documents_folder"];
    retriever = setup_rag_pipeline(documents_folder);
    initial_input["retriever"] = retriever;

    graph_builder = WorkflowGraph();
    app = graph_builder.app;
    print('--- STARTING WORKFLOW ---');
    final_state = app.invoke(initial_input);
    print('--- WORKFLOW COMPLETE ---');
    print("Final State", final_state);

    with open("generated_article_final.md", "w") as f {
        f.write(final_state["article"]);
    }
    print('\nArticle saved to generated_article_final.md');
}