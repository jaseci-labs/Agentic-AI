import OpenAI from 'openai';

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: import.meta.env.VITE_OPENAI_API_KEY,
  dangerouslyAllowBrowser: true // Note: In production, API calls should be made from backend
});

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

const SYSTEM_PROMPT = `You are a helpful assistant specialized in the Jac programming language. Jac is a modern, AI-first programming language developed by Jaseci Labs. 

Key characteristics of Jac:
- Designed for AI-first constructs and scale-native programming
- Supports modern programming paradigms with unique syntax
- Has Python-like syntax but with distinctive features for AI development
- Includes built-in support for graph computing, walkers, and AI workflows
- Features architypes (objects), walkers (traversal algorithms), and abilities (methods)

When answering questions:
1. Focus on Jac-specific concepts, syntax, and best practices
2. Provide clear, practical code examples using proper Jac syntax
3. Explain concepts in a beginner-friendly way while being technically accurate
4. Use Jac keywords like 'walker', 'node', 'edge', 'can', 'with entry', etc.
5. If you're not certain about a specific Jac feature, acknowledge it honestly
6. Keep responses concise but informative
7. Format code examples with proper Jac syntax highlighting

You should help users with:
- Jac syntax and language features (walkers, nodes, edges, architypes)
- Code examples and best practices
- Graph programming concepts in Jac
- AI integration patterns
- Debugging and troubleshooting
- General programming concepts as they apply to Jac

Always strive to be helpful, accurate, and educational while maintaining focus on Jac programming.`;

export async function getChatCompletion(messages: ChatMessage[]): Promise<string> {
  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        ...messages
      ],
      temperature: 0.7,
      max_tokens: 1000,
    });

    return completion.choices[0]?.message?.content || 'Sorry, I could not generate a response.';
  } catch (error) {
    console.error('Error calling OpenAI API:', error);
    
    if (error instanceof Error && error.message.includes('API key')) {
      return 'Please set your OpenAI API key in the environment variables (VITE_OPENAI_API_KEY) to enable AI responses.';
    }
    
    return 'Sorry, I encountered an error while processing your request. Please try again.';
  }
}
