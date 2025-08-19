import re;
import ast;
import json;
import yaml;
import from jivas.agent.modules.data.serialization { LongStringDumper }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }
import from jivas.agent.modules.action.path { action_walker_path }
import from jivas.agent.core.agent { Agent }


walker export_agent(agent_graph_walker) {
    # accepts agent_id and returns dict of exported agent descriptor

    has clean_descriptor: bool = True;
    has remove_api_keys: bool = False;
    has export_json: bool = True;
    has knode_embeddings: bool = False;
    has knode_id: bool = False;
    has response:dict = {};
    has reporting:bool = True;

    class __specs__ {
        static has private: bool = False;
        static has path: str = action_walker_path(__module__);
    }

    can on_agent with Agent entry {

        daf_descriptor = here.get_descriptor();

        # create daf info
        daf_info = {
            "package": {
                "name": daf_descriptor.get('meta', {}).get('namespace', ''),
                "author": daf_descriptor.get('meta', {}).get('author', ''),
                "version": daf_descriptor.get('meta', {}).get('version', ''),
                "meta": {
                    "title": daf_descriptor.get('name'),
                    "description": daf_descriptor.get('description'),
                    "type": "daf"
                },
                "dependencies": daf_descriptor.get('meta', {}).get('dependencies', [])
            }
        };

        # clean descriptor
        if(self.clean_descriptor or self.remove_api_keys){
            for action in daf_descriptor['actions']{
                action_name =action['action'].split('/')[1];

                # remove action variables
                if(action_name == "typesense_vector_store_action"){
                    typesense_vector_store_action_ignore_keys = ["host", "port", "protocol", "api_key", "api_key_name", "connection_timeout", "collection_name"];
                    for variable in typesense_vector_store_action_ignore_keys{
                        if(variable in action['context']){
                            del action['context'][variable];
                        }
                    }
                }

                # remove api keys
                keys_to_remove = [];
                if(self.remove_api_keys){
                    for variable in action['context']{
                        if("_key" in variable){
                            keys_to_remove.append(variable);
                        }
                    }
                }

                # actions ignore keys
                actions_ignore_keys = ["id", "weight", "base_url", "label", "description", "webhook_url"];
                actions_ignore_keys.extend(keys_to_remove);
                for variable in actions_ignore_keys{
                    if(variable in action['context']){
                        del action['context'][variable];
                    }
                }


            }


            # agent ignore keys
            agent_ignore_keys = ["id", "meta", "_context", "descriptor"];
            for variable in agent_ignore_keys{
                if(variable in daf_descriptor){
                    del daf_descriptor[variable];
                }
            }
        }

        # get memory
        daf_memory = (here.get_memory().export_memory())['memory'];

        # get knowledge
        daf_knowledge = [];
        try {
            if(vector_store_action := here.get_actions().get(action_label = here.get_vector_store_action())){
                daf_knowledge = json.loads(vector_store_action.export_knodes(export_json=True, embeddings=self.knode_embeddings, include_id=self.knode_id));
            }
        } except Exception as e {
            self.logger.error(f"Unable to export knowledge");
        }


        data = {
            "descriptor": daf_descriptor,
            "memory": daf_memory,
            "knowledge": daf_knowledge,
            "info": daf_info
        };


        if(self.export_json) {
            self.response = data;
        } else {
            data = json.loads(json.dumps(data));
            self.response = yaml.dump(data, Dumper=LongStringDumper, sort_keys=False);
        }
        
        if self.reporting {
            self.logger.warning(self.response);
            self.logger.warning("self.response");
            report self.response;
        }
    }
}
