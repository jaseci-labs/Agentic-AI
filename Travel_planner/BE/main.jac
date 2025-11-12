import from agent_core {AgentRole, BaseAgent, AgentVisitor, AgentType}
import from dotenv { load_dotenv }
import from byllm.llm { Model }



walker chat{
    has user_message: str;

    obj __specs__ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        if [-->(`?Session)] {
            visit [-->];
        } else {
            new_session = here ++> Session();
            if new_session {
                print("[INFO] New session created");
                print();
            }
            visit new_session;
        }
    }
}

node Session{

    can generate_result with AgentVisitor entry{
        if [-->](`?BaseAgent){
            visit [-->];
        }else{
            UI_Agent = self ++> TripIntakeAgent();
            # UI_Agent ++> TripCreator();
            Orchestration_Agent = UI_Agent ++> TripOrchestrationAgent();
            Orchestration_Agent ++> FlightFinderAgent();
            Orchestration_Agent ++> CityAdvisorAgent();
            Orchestration_Agent ++> AccommodationCurationAgent();
            Orchestration_Agent ++> DailyItineraryAgent();
            Orchestration_Agent ++> QualityReviewAgent();

            visit UI_Agent;
        }
    }

    can respond with chat entry{
        
        response = AgentVisitor({"source": "user", "user_message": visitor.user_message}) spawn self;
        report {"response": response.next_agent_input_data["result"]};
    }

}


node TripIntakeAgent(BaseAgent){
    has agent_type: AgentType = AgentType.UI_Agent;
    has agent_role: AgentRole = AgentRole.Trip_Intake_Agent;
    has goal: str = "Your goal is to communicate with the user, collect all of the required information and make user adjustments accordingly in order to make a trip itinerary";
    has system_prompt: str = "You are a trip intake conversational agent. You first collect the required information such as {destination, starting point, budget, duration, and preferences, departure date} from the user for planning a trip. You always confirm the required information from the user after receiving it. You are also good at displaying trip itineraries in a conversational manner.";
    has required_information: str = "destination, starting point, budget, duration, preferences, departure date";
    has allow_delegation: bool = True;
    has enable_observation: bool = False;
}

node TripCreator(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Trip_Creator;
    has goal: str = "Your goal is to create a trip itinerary using only the provided data";
    has system_prompt: str = "You are good at creating trip itineraries using the available data. You ensure";
}

node TripOrchestrationAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Trip_Orchestration_Agent;
    has goal: str = "You are the Trip Orchestrator. You oversee the entire trip planning workflow. Your role is to monitor what information exists, what has been completed, and what remains pending. Based on this understanding, you decide the next task that should be carried out to move the trip plan forward in the right order.";
    has system_prompt: str = "You are the Trip Orchestrator. The tasks that you have to delegate are to find flights, find the best places to stay, generate the final trip itinerary, review the quality of the itinerary once and provide the final itinerary to the Trip Intake Agent. If the required task is completed do not delegate it again";
    has allow_delegation: bool = True;
    has enable_observation: bool = False;
}

node FlightFinderAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Flight_Finder_Agent;
    has goal: str = "Find realistic flights for the given travel window from origin to destination.";
    has system_prompt: str = "Return 3-6 viable options with airline, price, total time, layovers, baggage rules, and key notes. Be concise and structured.";
    has expected_output: str = "List of flight options with airline, price, duration, layovers, baggage info, and notes.";
}

node CityAdvisorAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.City_Advisor_Agent;
    has goal: str = "Identify the best areas to stay in the destination city.";
    has system_prompt: str = "Assess transit access, safety, vibe, and proximity to sights and food. Match recommendations to budget and stated preferences.";
    has expected_output: str = "2-3 recommended areas with short reasons and practical notes.";
}

node AccommodationCurationAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Accommodation_Curation_Agent;
    has goal: str = "Select good-value stays in the recommended areas within budget.";
    has system_prompt: str = "Provide 2-4 options with price per night, rating, location, cancellation policy, and one line on why it fits.";
    has expected_output: str = "Curated list (2-4) with price, rating, location, cancellation, and a brief fit rationale.";
}

node DailyItineraryAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Daily_Itinerary_Agent;
    has goal: str = "Build a realistic day-by-day plan anchored to confirmed flights and hotel.";
    has system_prompt: str = "Use duration of the trip, user preferences, arrival/departure times and hotel location Cluster stops by area, respect opening hours, and keep pacing comfortable.";
    has expected_output: str = "Daily schedule with activities, rough times, transit segments, rest windows, and optional meal tips.";
}

node QualityReviewAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Quality_Review_Agent;
    has goal: str = "Validate the full trip for accuracy, consistency, and feasibility.";
    has system_prompt: str = "Resolve gaps and conflicts, tighten wording, and ensure is detailed, organised and an appropriate structure.";
    has expected_output: str = "Clean, consistent, user-ready trip plan with issues fixed.";
}

with entry{
    load_dotenv();
}
