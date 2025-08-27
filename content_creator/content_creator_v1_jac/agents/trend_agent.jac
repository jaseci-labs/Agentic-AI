import from dotenv { load_dotenv }
import os;
import from mtllm {Model}

glob llm = Model(model_name="gpt-4o-mini");


obj UserInput {
    has field: str;
    has topic: str;
    has expected_output: str;
}

sem UserInput.expected_output = "The format of the output the user expects, a JSON object with a single key topics which is a list of strings";

obj TrendingTopics {
    has topics: list[str];
}

sem TrendingTopics.topics = "The trending topics identified by the research.";

"""
You are a trend researcher. Your goal is to find hot and relevant topics.
Based on the user's requested field, topic, and expected output format,
identify 3-5 current trending topics or angles worth writing about today.
"""
def find_trends(
    field: str,
    topic: str,
    output_format: str
) -> TrendingTopics by llm();



def run(user_input: UserInput) -> list[str] {
    print("---EXECUTING TREND AGENT---");

    result: TrendingTopics = find_trends(
        field=user_input.field,
        topic=user_input.topic,
        output_format=user_input.expected_output
    );

    print(f"Found Trends: {result.topics}");

    return result.topics;
}

with entry {
    print("---Starting Trend Research Simulation---");
    load_dotenv();

    user_request = UserInput(
        field="Artificial Intelligence",
        topic="Agentic Workflows",
        expected_output="a blog post"
    );

    trending_topics: list[str] = run(user_input=user_request);

    print("\n---FINAL RESULT---");
    print("Trending topics to write about:");
    for topic in trending_topics {
        print(f"- {topic}");
    }
}