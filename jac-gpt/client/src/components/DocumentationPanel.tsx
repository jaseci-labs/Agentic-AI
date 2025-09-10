import { useState, useEffect } from 'react';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { ExternalLink, Book, ChevronRight, Loader2, ArrowLeft } from 'lucide-react';
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
  const [currentSuggestions, setCurrentSuggestions] = useState<DocumentationSuggestion[]>([]);
  const [selectedDoc, setSelectedDoc] = useState<DocumentationContent | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [iframeKey, setIframeKey] = useState(0); // Force iframe reload

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

  // Update current suggestions when props change
  useEffect(() => {
    console.log('DocumentationPanel received suggestions:', suggestions);
    const newSuggestions = suggestions.length > 0 ? suggestions : defaultSuggestions;
    console.log('Setting current suggestions:', newSuggestions);
    setCurrentSuggestions(newSuggestions);
  }, [suggestions, isVisible]);

  const handleSuggestionClick = (suggestion: DocumentationSuggestion) => {
    // Open all documentation links in a new tab
    window.open(suggestion.url, '_blank', 'noopener,noreferrer');
  };  const handleBackToSuggestions = () => {
    setSelectedDoc(null);
    setError(null);
  };

  if (!isVisible) {
    return null;
  }

  return (
    <div className="w-1/2 border-l border-gray-700 bg-gray-900 flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-gray-700">
        <div className="flex items-center gap-2">
          {selectedDoc && (
            <Button 
              variant="ghost" 
              size="sm"
              onClick={handleBackToSuggestions}
              className="text-gray-400 hover:text-white mr-2"
            >
              <ArrowLeft className="w-4 h-4" />
            </Button>
          )}
          <Book className="w-5 h-5 text-orange-500" />
          <h2 className="text-lg font-semibold text-white">
            {selectedDoc ? selectedDoc.title : "Documentation"}
          </h2>
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
                <div className="flex items-center justify-end">
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
                  key={iframeKey}
                  src={selectedDoc.url}
                  className="w-full h-full border-0"
                  title={selectedDoc.title}
                  sandbox="allow-scripts allow-same-origin allow-popups allow-forms allow-top-navigation"
                  onLoad={() => {
                    setLoading(false);
                    console.log('Iframe loaded:', selectedDoc.url);
                  }}
                  onError={() => {
                    setError('Failed to load documentation page');
                    setLoading(false);
                  }}
                  style={{
                    background: 'white',
                    minHeight: '100%'
                  }}
                />
              </div>
            </>
          )}

          {!selectedDoc && !loading && !error && (
            <div className="flex-1 p-4">
              <div className="mb-4">
                <h3 className="text-lg font-semibold text-white mb-2">
                  {suggestions.length > 0 ? "Relevant Documentation" : "Popular Topics"}
                </h3>
                <p className="text-gray-400 text-sm mb-4">
                  {suggestions.length > 0 
                    ? "Here are the most relevant documentation pages for your query:" 
                    : "Explore these popular Jac documentation topics:"
                  }
                </p>
              </div>
              
              <ScrollArea className="flex-1">
                <div className="space-y-3">
                  {currentSuggestions.map((suggestion, index) => {
                    return (
                      <Card 
                        key={index} 
                        className="p-4 bg-gray-800 border-gray-700 cursor-pointer hover:bg-gray-750 transition-colors"
                        onClick={() => handleSuggestionClick(suggestion)}
                        title={`Click to open ${suggestion.title} in a new tab`}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <h4 className="font-medium text-white mb-2 flex items-center gap-2">
                              {suggestion.title}
                              <ExternalLink className="w-4 h-4 text-gray-400" />
                            </h4>
                            <p className="text-sm text-gray-400 mb-2">
                              {suggestion.reason}
                            </p>
                            <div className="flex items-center gap-2">
                              <p className="text-xs text-blue-400 hover:text-blue-300">
                                {suggestion.url}
                              </p>
                            </div>
                          </div>
                        </div>
                      </Card>
                    );
                  })}
                </div>
              </ScrollArea>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default DocumentationPanel;
