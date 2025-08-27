interface DocumentationSuggestion {
  url: string;
  title: string;
  reason: string;
}

interface DocumentationContent {
  success: boolean;
  content: string;
  title: string;
  url: string;
  error?: string;
}

class DocumentationService {
  private baseUrl: string;

  constructor() {
    this.baseUrl = 'http://localhost:8000';
  }

  /**
   * Get documentation suggestions based on a message
   */
  async getSuggestions(message: string, chatHistory: Array<any> = []): Promise<DocumentationSuggestion[]> {
    try {
      const response = await fetch(`${this.baseUrl}/walker/suggest_docs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message,
          chat_history: chatHistory
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      
      if (data.status === 200 && data.reports && data.reports[0]?.success) {
        const report = data.reports[0];
        return report.suggestions.map((suggestion: any) => ({
          title: suggestion.title,
          url: suggestion.url,
          description: suggestion.reason
        }));
      } else {
        throw new Error('Failed to get suggestions from API');
      }
    } catch (error) {
      console.error('Error fetching suggestions:', error);
      return this.getFallbackSuggestions(message);
    }
  }  /**
   * Get documentation content for a specific URL
   */
  async getContent(url: string): Promise<DocumentationContent> {
    try {
      const response = await fetch(`${this.baseUrl}/walker/get_doc_content`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ url })
      });

      if (!response.ok) {
        throw new Error('Failed to fetch documentation');
      }

      const data = await response.json();
      
      if (data.status === 200 && data.reports && data.reports[0]) {
        const report = data.reports[0];
        return {
          success: report.success,
          content: report.content || '',
          title: report.title || 'Documentation',
          url: report.url || url,
          error: report.error
        };
      } else {
        throw new Error('Invalid API response format');
      }
    } catch (error) {
      console.error('Failed to fetch documentation content:', error);
      return {
        success: false,
        content: '',
        title: 'Error',
        url,
        error: 'Failed to load documentation content'
      };
    }
  }

  /**
   * Fallback suggestions when API is not available
   */
  private getFallbackSuggestions(message: string): DocumentationSuggestion[] {
    const messageLower = message.toLowerCase();
    const suggestions: DocumentationSuggestion[] = [];

    // Getting started suggestions
    if (this.containsWords(messageLower, ['start', 'begin', 'new', 'intro', 'hello', 'hi'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/introduction/",
        title: "Introduction to Jac",
        reason: "Perfect starting point for learning Jac programming language"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/getting_started/",
        title: "Getting Started",
        reason: "Step-by-step guide to set up and start coding in Jac"
      });
    }

    // Object-Spatial Programming
    if (this.containsWords(messageLower, ['node', 'edge', 'graph', 'spatial', 'object', 'relationship'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
        title: "Nodes and Edges",
        reason: "Learn about Object-Spatial Programming with nodes and edges"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/walkers/",
        title: "Walkers",
        reason: "Understand how walkers traverse and process data structures"
      });
    }

    // AI and LLM integration
    if (this.containsWords(messageLower, ['ai', 'llm', 'intelligence', 'model', 'gpt', 'openai', 'claude'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
        title: "AI Integration Quickstart",
        reason: "Learn how to integrate AI and LLM capabilities in your Jac applications"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/with_llm/",
        title: "Working with LLMs",
        reason: "Deep dive into using Large Language Models in Jac"
      });
    }

    // Cloud and deployment
    if (this.containsWords(messageLower, ['cloud', 'deploy', 'server', 'scale', 'production', 'hosting'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-cloud/introduction/",
        title: "Jac Cloud Introduction",
        reason: "Learn about cloud deployment and scaling with Jac"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-cloud/deployment/",
        title: "Deployment Guide",
        reason: "Step-by-step deployment instructions for Jac applications"
      });
    }

    // Walkers
    if (this.containsWords(messageLower, ['walker', 'walk', 'traverse', 'visit', 'navigation'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/walkers/",
        title: "Walkers Guide",
        reason: "Complete guide to using walkers for data traversal and processing"
      });
    }

    // Examples and tutorials
    if (this.containsWords(messageLower, ['example', 'tutorial', 'sample', 'demo', 'project'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/examples/rag_chatbot/Overview/",
        title: "RAG Chatbot Example",
        reason: "Build a complete RAG-powered chatbot with Jac"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/jac_book/chapter_1/",
        title: "Jac Book - Chapter 1",
        reason: "Comprehensive tutorial series covering all aspects of Jac"
      });
    }

    // Code and syntax
    if (this.containsWords(messageLower, ['code', 'syntax', 'function', 'class', 'variable', 'programming'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/keywords/",
        title: "Jac Keywords",
        reason: "Reference for all Jac language keywords and syntax"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac_ref/",
        title: "Jac Language Reference",
        reason: "Complete language reference and syntax guide"
      });
    }

    // Tools and development
    if (this.containsWords(messageLower, ['tool', 'cli', 'debug', 'development', 'playground'])) {
      suggestions.push({
        url: "https://www.jac-lang.org/playground/",
        title: "Jac Playground",
        reason: "Try Jac code online without any setup"
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/tools/cli/",
        title: "CLI Tools",
        reason: "Learn about Jac command-line tools and utilities"
      });
    }

    // Default suggestions if no specific keywords found
    if (suggestions.length === 0) {
      suggestions.push(
        {
          url: "https://www.jac-lang.org/learn/introduction/",
          title: "Introduction to Jac",
          reason: "Perfect starting point for learning Jac programming language"
        },
        {
          url: "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
          title: "Nodes and Edges",
          reason: "Learn about Object-Spatial Programming core concepts"
        },
        {
          url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
          title: "AI Integration",
          reason: "Discover how to integrate AI capabilities in Jac"
        }
      );
    }

    // Return top 3 suggestions
    return suggestions.slice(0, 3);
  }

  /**
   * Helper method to check if message contains any of the specified words
   */
  private containsWords(text: string, words: string[]): boolean {
    return words.some(word => text.includes(word));
  }

  /**
   * Get all available documentation URLs
   */
  async getAllUrls(): Promise<any[]> {
    try {
      const response = await fetch(`${this.baseUrl}/walker/get_documentation_urls`);
      if (!response.ok) {
        throw new Error('Failed to fetch documentation URLs');
      }
      const data = await response.json();
      return data.urls || [];
    } catch (error) {
      console.error('Failed to fetch documentation URLs:', error);
      return [];
    }
  }
}

export const documentationService = new DocumentationService();
export type { DocumentationSuggestion, DocumentationContent };
