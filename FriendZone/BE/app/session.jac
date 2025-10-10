import from uuid { uuid4 }
import from datetime { datetime }
import from pydantic { BaseModel, Field, condecimal }
import from fastapi { HTTPException, status }
import from jac_cloud.jaseci.utils.logger { logger }
import from utils { convert_date_to_valid_format }
import from mtp { extract_memory_details, update_memory_details }
import from byllm { Image }
import from google_maps_service { google_location_service }
import from memory { visit_memories }
import from nodes_and_edges { session, sessions, memory, memories }


class Location(BaseModel) {
    has latitude: float;
    has longitude: float;
}

walker visit_sessions {
    
    class __specs__ {
        has tags: list = ["session"];
    }

    can visit_sessions with `root entry;
}

walker init_session(visit_sessions) {
    has image_url: str;
    has location: Location = Location(latitude=0, longitude=0);
    has date: str = "";

    class __specs__ {
        has tags: list = ["session"];
    }

    can initialize_session with sessions entry; 
    can update_session with session entry;
}

walker continue_session(visit_sessions) {
    has session_id: str;
    has utterance: str;

    class __specs__ {
        has tags: list = ["session"];
    }
    
    can visit_session with sessions entry;
    can update_session with session entry;
}

walker get_session(visit_sessions) {
    has session_id: str;
    has if_report: bool = True;

    class __specs__ {
        has tags: list = ["session"];
    }
    
    can visit_session with sessions entry;
    can report_session with session entry;
}

walker save_memory(visit_memories) {
    has session_id: str;

    class __specs__ {
        has tags: list = ["session"];
    }
    
    can create_memory with memories entry;
    can update_memory with memory entry;
}
