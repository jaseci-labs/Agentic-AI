import from dotenv { load_dotenv }
import from graph { WorkflowGraph }
import from state { AgentState }
import from json { load as json_load }

with entry {
    with open("input.json", "r") as f {
        initial_input = json_load(f);
    }
    graph_builder = WorkflowGraph();
    app = graph_builder.app;
    print('--- STARTING WORKFLOW ---');
    final_state = app.invoke(initial_input);
    print('--- WORKFLOW COMPLETE ---');
    print("Final State", final_state);
    with open('trending_topics.md', 'w') as f{
        for topic in final_state['trending_topics']{
            f.write(topic + '\n');
        }
    }
    print('\Trending Topics saved to trending_topics.md');

    with open("generated_article_final.md", "w") as f {
        f.write(final_state["article"]);
    }
    print('\nArticle saved to generated_article_final.md');
}