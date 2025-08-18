import OpenAI from 'openai';

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: import.meta.env.VITE_OPENAI_API_KEY,
  dangerouslyAllowBrowser: true // Enable for client-side usage
});

export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export class OpenAIService {
  private systemPrompt = `You are Jaseci Assistant, an expert AI assistant for the Jac programming language and Jaseci ecosystem. 

Key information about Jac:
- Jac is a modern programming language designed for building AI-native applications
- It features built-in support for graph-based programming, AI/ML workflows, and microservices
- Jac supports automatic serialization, data spatial programming, and seamless integration with AI models
- It's designed to make complex AI application development more intuitive and efficient

Your role:
- Help users learn and use the Jac programming language effectively
- Provide code examples, best practices, and explanations
- Assist with debugging Jac code and solving programming problems
- Explain Jac concepts, syntax, and features clearly
- Guide users through common development patterns in Jac

Always be helpful, accurate, and provide practical examples when possible. If you're unsure about something specific to Jac, acknowledge that and provide the best guidance you can based on general programming principles.`;

  async generateResponse(messages: ChatMessage[]): Promise<string> {
    try {
      // Prepare messages with system prompt
      const chatMessages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
        {
          role: 'system',
          content: this.systemPrompt
        },
        ...messages.map(msg => ({
          role: msg.role as 'user' | 'assistant',
          content: msg.content
        }))
      ];

      const completion = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: chatMessages,
        max_tokens: 1000,
        temperature: 0.7,
        stream: false
      });

      return completion.choices[0]?.message?.content || 'I apologize, but I was unable to generate a response. Please try again.';
    } catch (error) {
      console.error('OpenAI API Error:', error);
      
      if (error instanceof Error) {
        if (error.message.includes('API key')) {
          return 'I apologize, but there seems to be an issue with the API configuration. Please check that the OpenAI API key is properly set.';
        } else if (error.message.includes('quota') || error.message.includes('billing')) {
          return 'I apologize, but the API quota has been exceeded. Please try again later.';
        } else if (error.message.includes('rate limit')) {
          return 'I apologize, but I\'m currently rate-limited. Please wait a moment and try again.';
        }
      }
      
      return 'I apologize, but I encountered an error while processing your request. Please try again.';
    }
  }

  async generateStreamResponse(
    messages: ChatMessage[], 
    onChunk: (chunk: string) => void
  ): Promise<void> {
    try {
      const chatMessages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
        {
          role: 'system',
          content: this.systemPrompt
        },
        ...messages.map(msg => ({
          role: msg.role as 'user' | 'assistant',
          content: msg.content
        }))
      ];

      const stream = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: chatMessages,
        max_tokens: 1000,
        temperature: 0.7,
        stream: true
      });

      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content;
        if (content) {
          onChunk(content);
        }
      }
    } catch (error) {
      console.error('OpenAI Streaming API Error:', error);
      onChunk('I apologize, but I encountered an error while processing your request. Please try again.');
    }
  }
}

export const openaiService = new OpenAIService();
