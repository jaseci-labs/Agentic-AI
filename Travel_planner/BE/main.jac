import from agent_core { BaseAgent, AgentVisitor, AgentRole, AgentType }
import from dotenv { load_dotenv }


walker chat {
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
                print();
                print("[INFO] New session created");
                print();
            }

            visit new_session;
        }
    }
}

node Session {
    can generate_result with AgentVisitor entry {
        if [-->](`?BaseAgent) {
            visit [-->];
        } else {
            UI_Agent = self ++> TripIntakeAgent();
            Orchestration_Agent = UI_Agent ++> TripOrchestrationAgent();
            Orchestration_Agent ++> FlightFinderAgent();
            Orchestration_Agent ++> ActivitiesPlannerAgent();
            Orchestration_Agent ++> AccommodationCurationAgent();
            Orchestration_Agent ++> ItineraryBuilderAgent();
            Orchestration_Agent ++> QualityReviewAgent();

            visit UI_Agent;
        }
    }

    can respond with chat entry {
        response = AgentVisitor(
            {
                "source": "user",
                "user_message": visitor.user_message,
            }
        ) spawn self;

        report { "response": response.next_agent_input_data["result"] };
    }
}

node TripIntakeAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.UI_Agent;
    has agent_role: AgentRole = AgentRole.Trip_Intake_Agent;
    has goal: str = "Your goal to be the communicator between the team of agent and the user. You gather information from the user to plan a trip itinerary, and give it to the team who will give the final trip iternarary";
    has system_prompt: str = "You are a fun, conversational agent that acts as the interface between the user and a team of agents. You collect information such as {destination, starting point, budget, duration, departure date}. You always ensure to collect the required information. You always confirm all the required information after receiving it to the team of agents.";
    has required_information: str = "destination, starting point, budget, duration, departure date";
    has allow_delegation: bool = True;
}

node TripCreator(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Trip_Creator;
    has goal: str = "Your goal is to create a trip itinerary using only the provided data";
    has system_prompt: str = "You are good at creating trip itineraries using the available data. You ensure";
}

node TripOrchestrationAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Trip_Orchestration_Agent;
    has goal: str = "You are the Trip Orchestrator. You delegate each task once. You oversee the entire trip planning workflow. Your role is to monitor what information exists, what has been completed, and what remains pending. Based on this understanding, you decide the next task that should be carried out to move the trip plan forward in the right order.";
    has system_prompt: str = "You are the Trip Orchestrator. The tasks that you have to delegate are to find flights, find attractions, find hotels to stay, generate the final Daily trip itinerary, review the quality of the itinerary once and provide the final generated itinerary from the Daily Itinerary Agent to the Trip Intake Agent. If the required task is completed DO NOT delegate it again";
    has allow_delegation: bool = True;
}

node FlightFinderAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Flight_Finder_Agent;
    has goal: str = "Find realistic flights for the given travel window from origin to destination.";
    has system_prompt: str = "You are good at finding flights, according to the user's specific criteria. You always ensure to collect all the required flight information";
    has expected_output: str = "List of flight options, with information about departure and arrival";
    has required_information: str = "Origin location, destination location, duration, budget, departure_date";
    has tools: list = ["search_flights_tool"];
}

node ActivitiesPlannerAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Activities_Planner_Agent;
    has goal: str = "Suggest activities and attractions tailored to the user's interest";
    has system_prompt: str = "You are good at selecting the best activities and attractions, that fulfil the user's request";
    has expected_output: str = "List of activities and attractionsr";
    has required_information: str = "Destination location, departure_date, duration, budget";
    has tools: list = ["search_attractions_tool"];
}

node AccommodationCurationAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Accommodation_Curation_Agent;
    has goal: str = "Select good-value stays in the recommended areas within budget.";
    has system_prompt: str = "Provide 2-4 options with price per night, rating, location, cancellation policy, and one line on why it fits.";
    has expected_output: str = "List of hotel options with their respective information";
    has required_information: str = "Destination location, departure_date, duration, budget";
    has tools: list = ["search_hotels_tool"];
}

node ItineraryBuilderAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Itinerary_Builder_Agent;
    has goal: str = "Generate a realistic, date-specific, day-by-day travel itinerary.";
    has system_prompt: str = "Use the collected flight information, accommodation, activities, dates and times to build a clear, accurate and practical daily itinerary. Ensure the itinerary contains all the details about the flights, attraction and accomodatoin. Ensure the schedule is logically structured and reflects real travel constraints.";
    has expected_output: str = "A structured daily itinerary including dates, times, flights, accommodations(with url), activities and any relevant travel details, and a cost breakdown.";
    has required_information: str = "Dates and Times. Flight, attractions and accomodation details collected from other agents.";
}

node QualityReviewAgent(BaseAgent) {
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Quality_Review_Agent;
    has goal: str = "Ensure the final itinerary is well structured, accurate and consistent";
    has system_prompt: str = "Resolve gaps and conflicts, tighten wording, and ensure it is detailed, organised and an appropriate structure.";
    has expected_output: str = "Clean, consistent, user-ready trip plan with issues fixed.";
    has required_information: str = "Trip itinerary";
}

with entry {    
    load_dotenv();
}

