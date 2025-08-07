import json;
import yaml;
import logging;
import traceback;
import from logging { Logger }
import from jivas.agent.action.action { Action }

node AgentUtilsAction(Action) {
    # Provides controls to provide power user controls for the management of agents.

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    def purge_frame_memory(session_id:str) {
        if(result := self.get_agent().get_memory().purge_frame_memory(session_id)) {
            return True;
        } else {
            return False;
        }
    }

    def purge_collection_memory(collection_name:str) {
        try {
            if(result := self.get_agent().get_memory().purge_collection_memory(collection_name)) {
                return True;
            }
            return False;
        } except Exception as e {
            self.logger.warning(f"Unable to purge collection: {e}");
            return False;
        }
    }

    def import_memory(data:str, overwrite:bool) {
        # imports a string-based representation of memory in YAML of JSON

        memory_data = {};

        if isinstance(data, str) {
            # Try to parse the content as JSON
            try {
                memory_data = json.loads(data);
            } except json.JSONDecodeError {}

            # Try to parse the content as YAML
            try {
                memory_data = yaml.safe_load(data);
            } except yaml.YAMLError {}

        } else {
            memory_data = data;
        }

        return self.get_agent().get_memory().import_memory(memory_data, overwrite);
    }


    def test_llm_call(llm_prompt_message:str="", model_name:str="", model_temperature:float=0.4, model_max_tokens:int=4096) {
        model_action := self.get_agent().get_action(action_label="LangChainModelAction");

        if not model_action {
            return {};
        }

        model_action_result = model_action.test_invoke(
            llm_prompt_message = llm_prompt_message,
            model_name=model_name,
            model_temperature=model_temperature,
            model_max_tokens=model_max_tokens,
            prompt_messages=[],
            prompt_variables={}
        );

        return model_action_result;
    }

}