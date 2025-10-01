import from dotenv { load_dotenv }
import from graph { WorkflowGraph }
import from state { AgentState }
import from json { load as json_load }
import from rag_setup { setup_rag_pipeline }
import os;

with entry {
    with open("input.json", "r") as f {
        initial_input = json_load(f);
    }
    documents_folder = initial_input["user_input"]["documents_folder"];
    # retriever = setup_rag_pipeline(documents_folder);
    # initial_input["retriever"] = retriever;
    retriever = None;
    if documents_folder and os.path.exists(documents_folder) and len(os.listdir(documents_folder)) > 0 {
        retriever = setup_rag_pipeline(documents_folder);
        initial_input["retriever"] = retriever;
        print(f"RAG retriever set up for folder: {documents_folder}");
    } else {
        print("No documents provided. Skipping RAG retriever setup.");
        initial_input["retriever"] = None;
    }

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