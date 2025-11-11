import from agent_core {AgentRole, BaseAgent, AgentVisitor, AgentType}
import from dotenv { load_dotenv }
import from byllm.llm { Model }


glob llm = Model(model_name="gemini/gemini-2.0-flash");

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
            new_agent = self ++> TripIntakeAgent();
            new_agent ++> TripCreator();
            visit new_agent;
        }
    }

    can respond with chat entry{
        response = AgentVisitor(visitor.user_message) spawn self;
        report {"response": response.next_agent_input_data["result"]};
    }

}


node TripIntakeAgent(BaseAgent){
    has agent_type: AgentType = AgentType.UI_Agent;
    has agent_role: AgentRole = AgentRole.Trip_Intake_Agent;
    has goal: str = "Your goal is to communicate with the user, collect information and make user adjustements accordingly";
    has system_prompt: str = "You are a trip intake conversational agent. You collect information such as destination, starting point, budget, duration, and preferences from the user for planning a trip. Confirm each request from the user";
    has allow_delegation: bool = True;
    has enable_observation: bool = False;
}

node TripCreator(BaseAgent){
    has agent_type: AgentType = AgentType.Agent;
    has agent_role: AgentRole = AgentRole.Trip_Creator;
    has goal: str = "Your goal is to create a trip itenarary using the provied data";
    has system_prompt: str = "You are a trip creating agent.";
}


with entry{
    load_dotenv();
}