import { useState, useEffect } from 'react';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { ExternalLink, Book, ChevronRight, Loader2 } from 'lucide-react';
import { documentationService } from '@/services/documentation';

interface DocumentationSuggestion {
  url: string;
  title: string;
  reason: string;
}

interface DocumentationContent {
  content: string;
  title: string;
  url: string;
}

interface DocumentationPanelProps {
  message?: string;
  suggestions?: DocumentationSuggestion[];
  isVisible: boolean;
  onToggle: () => void;
}

const DocumentationPanel = ({ message, suggestions = [], isVisible, onToggle }: DocumentationPanelProps) => {
  const [selectedDoc, setSelectedDoc] = useState<DocumentationContent | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Default documentation suggestions
  const defaultSuggestions: DocumentationSuggestion[] = [
    {
      url: "https://www.jac-lang.org/learn/introduction/",
      title: "Introduction to Jac",
      reason: "Perfect starting point for learning Jac programming language"
    },
    {
      url: "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
      title: "Nodes and Edges",
      reason: "Learn about Object-Spatial Programming with nodes and edges"
    },
    {
      url: "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
      title: "AI Integration",
      reason: "Discover how to integrate AI and LLM capabilities"
    }
  ];

  const displaySuggestions = suggestions.length > 0 ? suggestions : defaultSuggestions;

  const fetchDocumentation = async (url: string) => {
    setLoading(true);
    setError(null);
    
    try {
      // Instead of fetching content, directly load the webpage in iframe
      setSelectedDoc({
        content: "", // We'll use iframe instead of content
        title: "Loading Documentation...",
        url: url
      });
      
      // Simulate loading time for better UX
      setTimeout(() => {
        setSelectedDoc({
          content: "", // Content will be loaded via iframe
          title: url.includes('/introduction/') ? 'Introduction to Jac' : 
                 url.includes('/nodes_and_edges/') ? 'Nodes and Edges' :
                 url.includes('/quickstart/') ? 'AI Integration Quickstart' :
                 url.includes('/jac-cloud/') ? 'Jac Cloud Introduction' :
                 url.includes('/walkers/') ? 'Walkers Guide' :
                 url.includes('/rag_chatbot/') ? 'RAG Chatbot Example' :
                 'Jac Documentation',
          url: url
        });
        setLoading(false);
      }, 500);
      
    } catch (err) {
      console.error('Error loading documentation:', err);
      setError('Failed to load documentation');
      setLoading(false);
    }
  };

  // Auto-select first suggestion when suggestions change
  useEffect(() => {
    if (displaySuggestions.length > 0 && !selectedDoc && isVisible) {
      const firstSuggestion = displaySuggestions[0];
      fetchDocumentation(firstSuggestion.url);
    }
  }, [displaySuggestions, isVisible]);

  if (!isVisible) {
    return null;
  }

  return (
    <div className="w-1/2 border-l border-gray-700 bg-gray-900 flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-gray-700">
        <div className="flex items-center gap-2">
          <Book className="w-5 h-5 text-orange-500" />
          <h2 className="text-lg font-semibold text-white">Documentation</h2>
        </div>
        <Button 
          variant="ghost" 
          size="sm" 
          onClick={onToggle}
          className="text-gray-400 hover:text-white"
        >
          ×
        </Button>
      </div>

      <div className="flex-1 flex">
        {/* Content Area */}
        <div className="flex-1 flex flex-col">
          {loading && (
            <div className="flex-1 flex items-center justify-center">
              <div className="flex items-center gap-2 text-gray-400">
                <Loader2 className="w-5 h-5 animate-spin" />
                Loading documentation...
              </div>
            </div>
          )}

          {error && (
            <div className="flex-1 flex items-center justify-center">
              <div className="text-red-400 text-center">
                <p>{error}</p>
                <Button 
                  variant="outline" 
                  size="sm" 
                  className="mt-2"
                  onClick={() => setError(null)}
                >
                  Try Again
                </Button>
              </div>
            </div>
          )}

          {selectedDoc && !loading && !error && (
            <>
              <div className="p-4 border-b border-gray-700">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-semibold text-white">{selectedDoc.title}</h3>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => window.open(selectedDoc.url, '_blank')}
                    className="flex items-center gap-2"
                  >
                    <ExternalLink className="w-4 h-4" />
                    View Full Documentation
                  </Button>
                </div>
              </div>
              
              <div className="flex-1 relative">
                <iframe
                  src={selectedDoc.url}
                  className="w-full h-full border-0"
                  title={selectedDoc.title}
                  sandbox="allow-scripts allow-same-origin allow-popups allow-forms"
                  style={{
                    background: 'white',
                    minHeight: '100%'
                  }}
                />
              </div>
            </>
          )}

          {!selectedDoc && !loading && !error && (
            <div className="flex-1 flex items-center justify-center text-gray-500">
              <div className="text-center">
                <Book className="w-12 h-12 mx-auto mb-4 opacity-50" />
                <p>Select a topic to view documentation</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default DocumentationPanel;
