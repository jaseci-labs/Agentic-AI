import from byllm.llm { Model }
import from dotenv { load_dotenv }

glob llm = Model(model_name="gemini/gemini-2.0-flash");

enum AgentType {
  Trip_Intake_Agent,
  Flight_Finder_Agent,
  City_Advisor_Agent,
  Accommodation_Curation_Agent,
  Daily_Itinerary_Agent,
  Quality_Review_Agent,
}

obj UserInput{
    has destination: str;
    has starting_point: str;
    has budget: str;
    has duration: str;
    has preferences: list[str];
}

obj llm{
    has tools: list;

    """
    Generate a result based on the current_goal, system prompt, and memory context
    """
    def generate_result(current_goal: str, system_prompt: str, memory_context: list) -> str by llm(method= "ReAct", tools = self.tools);

    """
    True if the result meets the current_goal, False otherwise
    """
    def observe_result(current_goal: str, system_prompt: str, memory_context: list) -> bool by llm();

    def decide_next_agent() -> AgentType by llm();

}


obj memory{
    has items: list = [];

    def append(item: dict) -> None{
        self.items.append(item);
    }

    def get_context(k: int = 20) -> List[Dict[str, Any]]{
        return self.items[-k:];
    }
    
    def snapshot() -> dict {
        return {"items": self.items};
    }
}

node BaseAgent{
    has agent_type: AgentType;
    has current_goal: str;
    has system_prompt: str;
    has llm: llm = llm([self.tools]);
    has memory: memory = memory();
    has tools: list = [];
    has agent_status: str = "Not started";
    has execution_count: int = 0;
    has max_executions: int = 3;
    has final_result: dict = {};

    def change_agent_status(){
        if self.agent_status == "Not started"{
            self.agent_status = "In progress";
            print(f"The {self.AgentType} is now running...");
        } elif self.agent_status == "In progress"{
            self.agent_status = "Completed";
            print(f"{self.AgentType} execution completed.");
            self.agent_status == "Not started";
        }
    }

    def print_final_result(final_result: dict){
        for (key, value) in final_result.items(){
            print(f"{key}: {value}")
        }
    }

    can execute with manage_travel_planner entry{
        self.change_agent_status();
        agent_result = llm.generate_result(self.current_goal, self.system_prompt, self.memory.get_context());
        observation_result  = llm.observe_result(self.current_goal, self.system_prompt, self.memory.get_context());
        self.memory.append({"execution": self.iteration_count, "result": agent_result, "observation": observation_result});
        
        if observation_result == True{
            final_result = {"agent": self.agent_type, "result": agent_result};
        } elif execution_count > self.max_executions{
            final_result = {"agent": self.agent_type, "result": "Agent failed to complete the task within the maximum allowed executions."};
        } else{
            self.execution_count += 1;
        }
        self.change_agent_status();
        self.print_final_result(final_result);
    }
}


