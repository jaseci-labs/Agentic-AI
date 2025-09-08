import from langchain_core.messages { BaseMessage }
import from typing { List, TypedDict, Literal }

class AppState(TypedDict) {
    with entry {
        utterance: str;
        history: List[BaseMessage];
        route: Literal["TASK_HANDLING", "EMAIL_HANDLING", "GENERAL_CHAT"];
        task_action: Literal["EXTRACT_AND_ADD", "SUMMARIZE"];
        email_action: Literal["DRAFT","SEND"];
        email_to: str;
        email_subject: str;
        email_content: str;
        response: str;
    }
}