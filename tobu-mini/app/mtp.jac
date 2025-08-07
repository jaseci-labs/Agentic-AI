import from mtllm.llm  { Model, Image }
import from typing { List }

glob llm = Model(model_name="gpt-4.1");

obj Response {
    has follow_up_questions: str;
    has summary: str;
    has when: str;
    has who: List[str];
    has what: str;
}

obj InitResponse(Response) {
    has location_type: str;
}

obj ContinueResponse(Response) {
    has where: List[str];
    has save_memory: bool;
    has show_summary: bool;
}

sem InitResponse = "Memory details inferred from the image, city, date, and people.";
sem InitResponse.follow_up_questions = "Ask one follow-up question to continue the conversation.";
sem InitResponse.summary = "A concise summary of the memory.";
sem InitResponse.when = "The date of the memory in YYYY-MM-DD format.";
sem InitResponse.who = "Exact names of people in the memory (e.g., [John, Kate]); return [] if none.";
sem InitResponse.what = "What the memory is about.";
sem InitResponse.location_type = "Location type inferred from the image (e.g., waterfall, restaurant).";

sem ContinueResponse = "Memory details refined using the user’s input and prior context.";
sem ContinueResponse.follow_up_questions = "Ask one follow-up question to continue the conversation.";
sem ContinueResponse.summary = "A concise summary of the memory.";
sem ContinueResponse.when = "The date of the memory in YYYY-MM-DD format.";
sem ContinueResponse.who = "Exact names of people in the memory (e.g., [John, Kate]); return [] if none.";
sem ContinueResponse.where = "List of places relevant to the memory.";
sem ContinueResponse.what = "What the memory is about.";
sem ContinueResponse.save_memory = "True if the user asked to save the memory; otherwise false.";
sem ContinueResponse.show_summary = "True if all required details are present and the summary should be shown.";

""" Extract memory details from the image, city, date and people."""
def extract_memory_details(
    image: Image, 
    city: str = "",
    date: str = "",
    people: List[str] = []
) -> InitResponse by llm();

""" Update memory details based on user input and context."""
def update_memory_details(
    image: Image, 
    utterance: str,
    summary: str = "",
    when: str = "",
    who: List[str] = [],
    where: List[str] = [],
    what: str = "",
    conversation: List[dict] = [],
    show_summary: bool = False,
    save_memory: bool = False
) -> ContinueResponse by llm();