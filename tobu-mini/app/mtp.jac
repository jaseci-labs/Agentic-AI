import from mtllm.llm  { Model, Image }
import from typing { List }

glob llm = Model(model_name="gpt-4.1");

obj Response {
    has follow_up_questions: str;
    has summary: str;
    has when: str;
    has who: List[str];
    has what: str;
    has save_memory: bool;
    has show_summary: bool;
}

obj InitResponse(Response) {
    has location_description: str;
}

obj ContinueResponse(Response) {
    has where: List[str];
}

def extract_memory_details(
    image: Image, 
    city: str = "",
    date: str = ""
) -> InitResponse by llm();

def update_memory_details(
    image: Image, 
    utterance: str,
    summary: str = "",
    when: str = "",
    who: List[str] = [],
    where: List[str] = [],
    what: str = "",
    conversation: List[dict] = [],
    show_summary: bool = False
) -> ContinueResponse by llm();