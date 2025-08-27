import from dotenv { load_dotenv }
import os;
import from mtllm {Model}
import from tavily { TavilyClient }

glob llm = Model(model_name="gpt-4o-mini");


glob search_tool = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"));

obj UserInput {
    has field: str;
    has topic: str;
    has expected_output: str;
}

"""
You are an expert content writer, specializing in creating engaging articles.
Your task is to write a comprehensive article on the topic".
The article should be well-structured, clear, and align with the user's original request for the output format.
Start with a compelling title. Use markdown for formatting (e.g., # Title, ## Subheading, *italic*).
"""
def write_article(
    topic: str,
    research_data: str,
    output_format: str
) -> str by llm();

sem write_article.research_data = "The research data to ensure your article is factual and up-to-date";



# Revising (For now integrated this)
"""
You are an expert content writer. Your previous draft was reviewed and needs improvement.
Your task is to revise the article based on the editor's feedback.
Please rewrite the article, incorporating all the feedback to create a high-quality final version.
"""
def revise_article(
    topic: str,
    review_notes: str,
    research_data: str
) -> str by llm();


def run(state: dict) -> dict {
    print("---EXECUTING WRITER AGENT---");

    if state.get("review_notes") {
        print("Revising article based on editor feedback");
        
        revised_article: str = revise_article(
            topic=state["selected_topic"],
            review_notes=state["review_notes"],
            research_data=state["research_data"]
        );
        
        return {"article": revised_article, "review_notes": None};
    }

    trending_topics: list[str] = state["trending_topics"];
    user_input: UserInput = state["user_input"];

    # Select the top topic.
    selected_topic: str = trending_topics[0];
    print(f"Selected Topic: {selected_topic}");

    print("Researching the selected topic...");
    research_results = search_tool.search(
        query=f"latest information and key facts about {selected_topic}",
        max_results=5
    );
    
    # Format the research data.
    research_data = "\n\n".join(
        [f"Source: {res['url']}\nContent: {res['content']}" for res in research_results['results']]
    );
    print("Research complete.");

    print("Writing the first draft...");
    article: str = write_article(
        topic=selected_topic,
        research_data=research_data,
        output_format=user_input.expected_output
    );

    print("Article generated.");
    
    return {
        "selected_topic": selected_topic,
        "research_data": research_data,
        "article": article
    };
}

with entry {
    load_dotenv();

    initial_state = {
        "user_input": UserInput(
            field="Artificial Intelligence",
            topic="AI Agents",
            expected_output="a blog post in .md format"
        ),
        "trending_topics": [
            "Breakthroughs in AI",
            "AI's Role in Cybersecurity",
            "The Future of AI in Healthcare"
        ]
    };


    print("\n--- GENERATING FIRST DRAFT ---");
    first_draft_state = run(state=initial_state);
    print(first_draft_state["article"]);

    print("\n\n--- CHANGING THE  DRAFT ---");
    revision_state = {
        "selected_topic": first_draft_state["selected_topic"],
        "research_data": first_draft_state["research_data"],
        "review_notes": "This is a good start, but can you make the tone more optimistic and add a section about the future potential of this technology?"
    };

    final_article_state = run(state=revision_state);
    print("\n--- FINAL ARTICLE ---");
    print(final_article_state["article"]);

    with open("generated_article_final.md", "w") as f {
        f.write(final_article_state["article"]);
    }
}

#for now temporarily gave one feedback on the article