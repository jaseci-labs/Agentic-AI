import from agent_core {AgentType, BaseAgent, AgentType, traverse_agent}
import from dotenv { load_dotenv }


walker chat{
    has user_message: str;

    obj __specs__ {
        static has auth: bool = False;
    }

    can go with `root entry {
    
        session_node = here ++> session();
        visit session_node;
    
    }
}


node session{

    can interact with chat entry{
        visit [-->](`?BaseAgent) else{
          
            root ++> TripIntakeAgent();
            result = traverse_agent(visitor.user_message) spawn root;

            report {"response": result};
        }
    }

}




node TripIntakeAgent(BaseAgent){
    has agent_type: AgentType = AgentType.Trip_Intake_Agent;
    has system_prompt: str = "You are a trip intake agent. Your job is to gather all necessary details from the user to plan their trip effectively. Always ensure to introduce yourself and output the content in a structured manner.";
    has current_goal: str = "Collect the destination, starting point, budget, duration, and preferences from the user for planning a trip.";
}

with entry{
    load_dotenv();
}