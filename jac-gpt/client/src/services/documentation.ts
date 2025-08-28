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
    const suggestions: Array<DocumentationSuggestion & { score: number }> = [];

    // Helper function to check if message contains keywords and return score
    const getKeywordScore = (text: string, words: string[]): number => {
      return words.reduce((score, word) => {
        return text.includes(word) ? score + 1 : score;
      }, 0);
    };

    // MTLLM/MTP specific - High priority for AI/LLM related queries
    const mtllmWords = ['mtllm', 'mtp', 'multi-turn', 'conversation', 'context', 'llm integration', 'language model'];
    const mtllmScore = getKeywordScore(messageLower, mtllmWords);
    if (mtllmScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/with_llm/",
        title: "Working with LLMs - MTLLM",
        reason: "Complete guide to Multi-Turn LLM integration and context management",
        score: mtllmScore + 10
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
        title: "AI Integration Quickstart",
        reason: "Quick start guide for integrating AI capabilities in Jac",
        score: mtllmScore + 8
      });
    }

    // AI and LLM integration - General
    const aiWords = ['ai', 'llm', 'intelligence', 'model', 'gpt', 'claude', 'openai', 'artificial intelligence', 'machine learning'];
    const aiScore = getKeywordScore(messageLower, aiWords);
    if (aiScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/with_llm/",
        title: "Working with LLMs",
        reason: "Deep dive into using Large Language Models in Jac applications",
        score: aiScore + 9
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
        title: "AI Integration Quickstart",
        reason: "Learn how to integrate AI and LLM capabilities in your Jac applications",
        score: aiScore + 7
      });
    }

    // Object-Spatial Programming
    const spatialWords = ['node', 'edge', 'graph', 'spatial', 'object', 'relationship', 'data structure'];
    const spatialScore = getKeywordScore(messageLower, spatialWords);
    if (spatialScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
        title: "Nodes and Edges",
        reason: "Learn about Object-Spatial Programming with nodes and edges",
        score: spatialScore + 8
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/",
        title: "Data-Spatial Programming",
        reason: "Complete guide to data-spatial programming concepts",
        score: spatialScore + 6
      });
    }

    // Walkers
    const walkerWords = ['walker', 'walk', 'traverse', 'visit', 'navigation', 'path'];
    const walkerScore = getKeywordScore(messageLower, walkerWords);
    if (walkerScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/data_spatial/walkers/",
        title: "Walkers Guide",
        reason: "Complete guide to using walkers for data traversal and processing",
        score: walkerScore + 8
      });
    }

    // Cloud and deployment
    const cloudWords = ['cloud', 'deploy', 'server', 'scale', 'production', 'hosting', 'deployment'];
    const cloudScore = getKeywordScore(messageLower, cloudWords);
    if (cloudScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-cloud/introduction/",
        title: "Jac Cloud Introduction",
        reason: "Learn about cloud deployment and scaling with Jac",
        score: cloudScore + 7
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac-cloud/deployment/",
        title: "Deployment Guide",
        reason: "Step-by-step deployment instructions for production",
        score: cloudScore + 6
      });
    }

    // Examples and tutorials
    const exampleWords = ['example', 'tutorial', 'sample', 'demo', 'project', 'build', 'create'];
    const exampleScore = getKeywordScore(messageLower, exampleWords);
    if (exampleScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/examples/rag_chatbot/Overview/",
        title: "RAG Chatbot Example",
        reason: "Build a complete RAG-powered chatbot with Jac",
        score: exampleScore + 7
      });
      suggestions.push({
        url: "https://www.jac-lang.org/jac_book/chapter_1/",
        title: "Jac Book - Examples",
        reason: "Comprehensive examples and tutorials",
        score: exampleScore + 6
      });
    }

    // Syntax and language features
    const syntaxWords = ['syntax', 'code', 'function', 'class', 'variable', 'programming', 'keyword'];
    const syntaxScore = getKeywordScore(messageLower, syntaxWords);
    if (syntaxScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/keywords/",
        title: "Jac Keywords Reference",
        reason: "Complete reference for Jac language keywords and syntax",
        score: syntaxScore + 6
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/jac_ref/",
        title: "Language Reference",
        reason: "Complete Jac language reference and syntax guide",
        score: syntaxScore + 5
      });
    }

    // Getting started
    const startWords = ['start', 'begin', 'new', 'intro', 'hello', 'hi', 'getting started'];
    const startScore = getKeywordScore(messageLower, startWords);
    if (startScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/learn/introduction/",
        title: "Introduction to Jac",
        reason: "Perfect starting point for learning Jac programming language",
        score: startScore + 6
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/getting_started/",
        title: "Getting Started Guide",
        reason: "Step-by-step guide to set up and start coding in Jac",
        score: startScore + 5
      });
    }

    // Tools and development
    const toolsWords = ['tool', 'cli', 'debug', 'development', 'playground', 'ide'];
    const toolsScore = getKeywordScore(messageLower, toolsWords);
    if (toolsScore > 0) {
      suggestions.push({
        url: "https://www.jac-lang.org/playground/",
        title: "Jac Playground",
        reason: "Try Jac code online without any setup",
        score: toolsScore + 6
      });
      suggestions.push({
        url: "https://www.jac-lang.org/learn/tools/cli/",
        title: "CLI Tools",
        reason: "Learn about Jac command-line tools and utilities",
        score: toolsScore + 5
      });
    }

    // Sort suggestions by score (highest first)
    suggestions.sort((a, b) => b.score - a.score);

    // Default suggestions if no specific keywords found
    if (suggestions.length === 0) {
      suggestions.push(
        {
          url: "https://www.jac-lang.org/learn/introduction/",
          title: "Introduction to Jac",
          reason: "Perfect starting point for learning Jac programming language",
          score: 1
        },
        {
          url: "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
          title: "Nodes and Edges",
          reason: "Learn about Object-Spatial Programming core concepts",
          score: 1
        },
        {
          url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
          title: "AI Integration",
          reason: "Discover how to integrate AI capabilities in Jac",
          score: 1
        }
      );
    }

    // Return top 3 suggestions without score
    return suggestions.slice(0, 3).map(({ score, ...suggestion }) => suggestion);
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
