import json;
import logging;
import traceback;
import from logging { Logger }
import from jivas.agent.modules.agentlib.utils { Utils }
import from jivas.agent.action.interact_action { InteractAction }
import from jivas.agent.memory.interaction_response { TextInteractionMessage, SilentInteractionMessage }
import from jivas.agent.action.agent_graph_walker { agent_graph_walker }


node PersonaInteractAction(InteractAction) {
    # driven by a modular prompt to provide role, history and context for LLM chat and/or retrieval augmented generation

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    has timezone:str = "America/Guyana";
    has history:bool = True;
    has history_size:int = 3;
    has max_statement_length:int = 500;
    has model_action:str = "LangChainModelAction";
    has model_name:str = "gpt-4o";
    has model_temperature:float = 0.3;
    has model_max_tokens:int = 4096;
    has prompt:str = "Your name is Agent. Refer to the user as '{user}', if not None. Keep in mind '{date}' and '{time}' to be aware of the current date and time. {directives}";
    has channel_format_directives: dict = {
        "facebook": (
            "Structure Facebook content with these formatting rules:\n"
            "- Italic: Wrap text with underscores (_text_)\n"
            "- Bold: Wrap text with asterisks (*text*)\n"
            "- Strikethrough: Wrap text with tildes (~text~)\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Separate paragraphs with line breaks"
        ),

        "whatsapp": (
            "Structure WhatsApp messages with these rules:\n"
            "- Italic: Surround with underscores (_text_)\n"
            "- Bold: Surround with asterisks (*text*)\n"
            "- Strikethrough: Surround with tildes (~text~)\n"
            "- Bullet lists: Start lines with * or -\n"
            "- Numbered lists: Begin with 1. 2. 3.\n"
            "- Quotes: Prefix lines with > symbol\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Separate sections with line breaks"
        ),

        "instagram": (
            "Structure Instagram content with:\n"
            "- Bold: Surround text with asterisks (*text*)\n"
            "- Italic: Surround text with underscores (_text_)\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Use single line breaks between paragraphs\n"
            "- Maximum 30 hashtags at caption end"
        ),

        "twitter": (
            "Structure Twitter/X posts with:\n"
            "- Bold: Use asterisks (*text*)\n"
            "- Italic: Use underscores (_text_)\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Threads: Start with (1/3) indicator\n"
            "- Keep under 280 characters per tweet"
        ),

        "linkedin": (
            "Structure LinkedIn posts with:\n"
            "- Bold: Asterisks around text (*text*)\n"
            "- Italic: Underscores around text (_text_)\n"
            "- Bullets: Start lines with * or -\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Sections: Separate with --- on own line\n"
            "- Paragraphs: Maximum 5 lines each"
        ),

        "email": (
            "Structure emails with:\n"
            "- Bold: Surround with asterisks (*important*)\n"
            "- Italic: Surround with underscores (_emphasis_)\n"
            "- Lists: Use * or - for bullet points\n"
            "- Quotes: Begin lines with > symbol\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Subject lines: Under 60 characters\n"
            "- Include formal greetings/closings"
        ),

        "sms": (
            "Structure SMS messages with:\n"
            "- No special formatting symbols\n"
            "- URLs: Reformat all URLs to use raw URLs and not hyperlinks.\n"
            "- Length: Maximum 160 characters\n"
            "- Line breaks: Use basic separation\n"
            "- Avoid emojis unless requested"
        )
    };

    def post_register() {
        # to ensure compatibility, this action is added to the exception list in intent_classifier

        if(intent_interact_action_node := self.get_agent().get_actions().get(action_label='IntentInteractAction')) {
            if(self.get_type() not in intent_interact_action_node.exceptions) {
                intent_interact_action_node.exceptions += [self.get_type()];
            }
        }
    }

    def touch(visitor:agent_graph_walker) -> bool {
        # authorize, redirect or deny the interact walker here
        # only executes if response message is empty
        return (visitor.utterance and not visitor.interaction_node.has_response());
    }

    def execute(visitor:agent_graph_walker) -> None {

        # format response by channel
        self.handle_channel_format(visitor=visitor);

        # grab user's name, if set
        user = visitor.frame_node.get_user_name();

        date = Utils.date_now(timezone=self.timezone, date_format='%A, %d %B, %Y');
        time = Utils.date_now(timezone=self.timezone, date_format='%I:%M %p');

        # prepare directives
        directives = self.prepare_persona_task_directives( visitor.interaction_node.get_directives() );

        # prepare the prompt with utterance
        prompt_messages = [];

        # add history to prompt if configured.
        if (self.history) {
            # grab the history
            statements = visitor.frame_node.get_transcript_statements(
                interactions = self.history_size,
                max_statement_length = self.max_statement_length,
                with_events = True
            );
            if (statements) {
                # prepend statements to the prompt messages
                prompt_messages = statements;
            }
        }
        # add human message
        prompt_messages.append({"human": "{utterance}"});

        # add any active events in this interaction
        if events := visitor.frame_node.get_active_event_statements() {
            prompt_messages.append(events);
        }

        # add the system prompt last
        prompt_messages.append({"system": self.prompt});

        model_action := self.get_agent().get_action(action_label=self.model_action);
        if not model_action {
            return;
        }

        model_action_result = model_action.call_model(
            prompt_messages=prompt_messages,
            prompt_variables={
                "user": user,
                "date": date,
                "time": time,
                "directives": directives,
                "utterance": visitor.utterance
            },
            streaming=visitor.streaming,
            interaction_node=visitor.interaction_node,
            model_name=self.model_name,
            model_temperature=self.model_temperature,
            model_max_tokens=self.model_max_tokens
        );

        if not model_action_result {
            return;
        }

        # set the interaction message
        interaction_message = model_action_result.get_result() or "...";
        visitor.interaction_node.set_message(
            TextInteractionMessage(content=interaction_message)
        );
    }

    def prepare_persona_task_directives(directives:list) -> str {
        directives_str = "";
        index = 1;

        for directive in directives {
            directives_str = directives_str + (str(index) + ". " + directive + "\n");
            index = index + 1;
        }

        if(directives_str) {
            directives_str = "### RESPONSE DIRECTIVES \n Generate your response by executing the directives below carefully and in order: \n" + directives_str;
        }

        return directives_str;
    }

    def handle_channel_format(visitor: agent_graph_walker) -> dict {
        channel = visitor.interaction_node.channel;

        if(channel in self.channel_format_directives) {
            visitor.interaction_node.add_directive(directive=self.channel_format_directives[channel]);
        }
    }

    def healthcheck() -> bool {
        try {
            if(
                self.prompt and
                (model_action := self.get_agent().get_actions().get(action_label=self.model_action))
            ){
                return True;
            }
            return False;
        } except Exception as e {
            self.logger.error(f"An exception occurred in {self.label}:\n{traceback.format_exc()}\n");
            return False;
        }
    }
}
