import logging;
import traceback;
import from typing { Optional, Union }
import from logging { Logger }
import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI, AzureChatOpenAI }
import from langchain_community.callbacks { get_openai_callback }
import from langchain.schema { get_buffer_string }
import from jivas.agent.action.model_action { ModelAction, ModelActionResult }

node LangChainModelAction(ModelAction) {
    # JIVAS action wrapper around LangChain library for abstracted LLM interfacing
    # you def register multiple instances of this action, each with different api keys and model configurations
    # for use in other actions

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    has provider:str = "chatopenai"; # azurechatopenai
    has api_key:str = "";
    has api_version: str = "";
    has azure_endpoint: str = "";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.4;
    has model_max_tokens:int = 4096;

    def invoke(
        prompt_messages:list,
        prompt_variables:dict,
        **kwargs:dict
    ) -> Optional[ModelActionResult] {

        llm = None;

        if not self.api_key {
            self.logger.error("LangChainModelAction: API key not set.");
            return None;
        }

        # Validate prompt_messages
        if not isinstance(prompt_messages, list) {
            self.logger.error("LangChainModelAction: prompt_messages must be a list.");
            return None;
        }
        if not prompt_messages {
            self.logger.error("LangChainModelAction: prompt_messages list is empty.");
            return None;
        }
        for (idx, item) in enumerate(prompt_messages) {
            if not isinstance(item, dict) {
                self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] is not a dict.");
                return None;
            }
            if len(item) != 1 {
                self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] must have exactly one role-message pair.");
                return None;
            }
            (role, message) = next(iter(item.items()));
            if not isinstance(role, str) or not isinstance(message, str) {
                self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] role and message must be strings.");
                return None;
            }
            if not role or not message {
                self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] role or message is empty.");
                return None;
            }
        }

        # Validate prompt_variables
        if not isinstance(prompt_variables, dict) {
            self.logger.error("LangChainModelAction: prompt_variables must be a dict.");
            return None;
        }

        # Convert prompt_messages to array of tuples
        prompt_tuples = [(role, message) for item in prompt_messages for (role, message) in item.items()];
        template = ChatPromptTemplate.from_messages(prompt_tuples);

        op = kwargs.get("op", self.provider) or "chatopenai";
        functions = kwargs.get("functions", []);
        temperature = kwargs.get("model_temperature", self.model_temperature);
        model_name = kwargs.get("model_name", self.model_name);
        max_tokens = kwargs.get("model_max_tokens", self.model_max_tokens);
        streaming = kwargs.get("streaming", False);
        tool_choice = kwargs.get("tool_choice", "any");

        if op == "chatopenai" {
            llm = ChatOpenAI(
                temperature = temperature,
                model_name = model_name,
                openai_api_key = self.api_key,
                max_tokens = max_tokens
            );
        } elif op == "azurechatopenai" {
            if not self.azure_endpoint {
                self.logger.error("LangChainModelAction: Azure endpoint not set.");
                return None;
            }
            if not self.api_version {
                self.logger.error("LangChainModelAction: Azure API version not set.");
                return None;
            }
            llm = AzureChatOpenAI(
                temperature = temperature,
                openai_api_version = self.api_version,
                openai_api_key = self.api_key,
                azure_endpoint = self.azure_endpoint,
                deployment_name = model_name,
                max_tokens = max_tokens
            );
        }

        if llm {
            try {
                messages = template.format_messages(**prompt_variables);

                if functions {
                    llm = llm.bind_tools(functions, tool_choice = tool_choice);
                }

                with get_openai_callback() as cb {
                    if streaming {
                        return ModelActionResult(
                            prompt = get_buffer_string(messages),
                            tokens = cb.total_tokens,
                            generator = llm.stream(messages),
                            temperature = temperature,
                            model_name = model_name,
                            max_tokens = max_tokens
                        );
                    } elif (message := llm.invoke(messages)) {
                        return ModelActionResult(
                            prompt = get_buffer_string(messages),
                            functions = functions,
                            tokens = cb.total_tokens,
                            result = message.tool_calls if functions else message.content,
                            temperature = temperature,
                            model_name = model_name,
                            max_tokens = max_tokens
                        );
                    }
                }
            } except Exception as e {
                self.logger.error(f"An exception occurred in invoke: {traceback.format_exc()}");
            }
        }

        return None;
    }

    def test_invoke(
        prompt_messages:list,
        prompt_variables:dict,
        **kwargs:dict
    ) -> Optional[ModelActionResult] {

        llm = None;

        if not self.api_key {
            self.logger.error("LangChainModelAction: API key not set.");
            return None;
        }
        llm_prompt_message = kwargs.get("llm_prompt_message", "");

        if not llm_prompt_message {

            # Validate prompt_messages
            if not isinstance(prompt_messages, list) {
                self.logger.error("LangChainModelAction: prompt_messages must be a list.");
                return None;
            }
            if not prompt_messages {
                self.logger.error("LangChainModelAction: prompt_messages list is empty.");
                return None;
            }

            for (idx, item) in enumerate(prompt_messages) {
                if not isinstance(item, dict) {
                    self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] is not a dict.");
                    return None;
                }
                if len(item) != 1 {
                    self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] must have exactly one role-message pair.");
                    return None;
                }
                (role, message) = next(iter(item.items()));
                if not isinstance(role, str) or not isinstance(message, str) {
                    self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] role and message must be strings.");
                    return None;
                }
                if not role or not message {
                    self.logger.error(f"LangChainModelAction: prompt_messages[{idx}] role or message is empty.");
                    return None;
                }
            }
        }


        # Validate prompt_variables
        if not isinstance(prompt_variables, dict) {
            self.logger.error("LangChainModelAction: prompt_variables must be a dict.");
            return None;
        }

        # Convert prompt_messages to array of tuples
        prompt_tuples = [(role, message) for item in prompt_messages for (role, message) in item.items()];
        template = ChatPromptTemplate.from_messages(prompt_tuples);

        op = kwargs.get("op", self.provider) or "chatopenai";
        functions = kwargs.get("functions", []);
        temperature = kwargs.get("model_temperature", self.model_temperature);
        model_name = kwargs.get("model_name", self.model_name);
        max_tokens = kwargs.get("model_max_tokens", self.model_max_tokens);
        streaming = kwargs.get("streaming", False);
        tool_choice = kwargs.get("tool_choice", "any");
        # llm_prompt_message = kwargs.get("llm_prompt_message", "");

        if op == "chatopenai" {
            llm = ChatOpenAI(
                temperature = temperature,
                model_name = model_name,
                openai_api_key = self.api_key,
                max_tokens = max_tokens
            );
        } elif op == "azurechatopenai" {
            if not self.azure_endpoint {
                self.logger.error("LangChainModelAction: Azure endpoint not set.");
                return None;
            }
            if not self.api_version {
                self.logger.error("LangChainModelAction: Azure API version not set.");
                return None;
            }
            llm = AzureChatOpenAI(
                temperature = temperature,
                openai_api_version = self.api_version,
                openai_api_key = self.api_key,
                azure_endpoint = self.azure_endpoint,
                deployment_name = model_name,
                max_tokens = max_tokens
            );
        }

        if llm {
            try {
                if llm_prompt_message {
                    messages = llm_prompt_message;
                } else {
                    messages = get_buffer_string(template.format_messages(**prompt_variables));
                }

                if functions {
                    llm = llm.bind_tools(functions, tool_choice = tool_choice);
                }

                with get_openai_callback() as cb {
                    if streaming {
                        return ModelActionResult(
                            prompt = messages,
                            tokens = cb.total_tokens,
                            generator = llm.stream(messages),
                            temperature = temperature,
                            model_name = model_name,
                            max_tokens = max_tokens
                        );
                    } elif (message := llm.invoke(messages)) {
                        return ModelActionResult(
                            prompt = messages,
                            functions = functions,
                            tokens = cb.total_tokens,
                            result = message.tool_calls if functions else message.content,
                            temperature = temperature,
                            model_name = model_name,
                            max_tokens = max_tokens
                        );
                    }
                }
            } except Exception as e {
                self.logger.error(f"An exception occurred in invoke: {traceback.format_exc()}");
            }
        }

        return None;
    }

    def healthcheck() -> Union[bool, dict] {

        if not self.api_key {
            return {
                "status": False,
                "message": "API key not set.",
                "severity": "error"
            };
        }

        test_prompt_messages = [{"system" : "Output the result of 2 + 2"}];

        try {
            if( model_action_result := self.call_model(
                    prompt_messages = test_prompt_messages, 
                    prompt_variables = {}, 
                    model_name=self.model_name,
                    model_temperature=self.model_temperature,
                    model_max_tokens=self.model_max_tokens
                )) {               # set the interaction message+
                interaction_message = model_action_result.get_result();
                if not interaction_message {
                    return {
                        "status": False,
                        "message": "No valid result from LLM call. Check API key and model configuration.",
                        "severity": "error"
                    };
                } else {
                    return True;
                }
            }
            return {
                "status": False,
                "message": "Unable to excute LLM call. Check API key and model configuration.",
                "severity": "error"
            };
        } except Exception as e {
            self.logger.error(f"An exception occurred in {self.label}:\n{traceback.format_exc()}\n");
            return {
                "status": False,
                "message": f"There is an issue with the action. {e}",
                "severity": "error"
            };
        }
    }

}
