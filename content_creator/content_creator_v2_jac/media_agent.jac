import from langchain_core.prompts { ChatPromptTemplate }
import from langchain_openai { ChatOpenAI }
import from langchain_core.output_parsers { StrOutputParser }
import from openai { OpenAI }
import from state { AgentState }

import from tavily { TavilyClient }
import from dotenv { load_dotenv }
import os;
import base64;


with entry {
    load_dotenv();
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY');
    tavily_client = TavilyClient(api_key=os.getenv('TAVILY_API_KEY'));
}


obj MediaAgent {
    def init {
        self.prompt_llm = ChatOpenAI(model='gpt-4o', temperature=0);
        self.image_client = OpenAI();
        prompt =
            ChatPromptTemplate.from_template(
                "You are an expert at creating relevant image prompts for a DALL-E model."
                "Based on the following article, create a single, concise prompt that visually represents the core message."
                "The prompt should describe the main theme or idea of the article"
                "Do not create a futuristic image. It should be a graphic flyer type."
                "Do not ask me a question, just provide the prompt."
                "Create a graphic representation of the article's content, include the title as a text."
                "ARTICLE: {article}\n"
            );
        self.prompt_chain = ((prompt | self.prompt_llm) | StrOutputParser());
    }

    # Generates an image for the article and saves it using base64 data.
    def run(state: AgentState) {
        print('---EXECUTING MEDIA AGENT---');
        article = state[ 'article' ];
        print('Generating image prompt...');
        image_prompt = self.prompt_chain.invoke({'article' : article });
        print(f"'Generated Image Prompt: '{image_prompt}");
        print('Generating image with DALL-E');
        response =
            self.image_client.images.generate(
                model='dall-e-2',
                prompt=image_prompt,
                size='1024x1024',
                n=1,
                response_format='b64_json'
            );
        image_base64 = response.data[ 0 ].b64_json;
        image_bytes = base64.b64decode(image_base64);
        print('Image generation completed.');
        image_filename = 'generated_article_image.png';
        try {
            with open(image_filename, 'wb') as f  {
                f.write(image_bytes);
            }
            print(f"'Image saved as '{image_filename}");
        } except Exception as e {
            print(f"'Error saving image: '{e}");
            image_filename = None;
        }
        return {'media_url' : None , 'saved_image_path' : image_filename };
    }
}

