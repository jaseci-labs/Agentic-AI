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
  originalUrl?: string;
  fragment?: string;
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
  const [currentSuggestions, setCurrentSuggestions] = useState<DocumentationSuggestion[]>([]);
  const [iframeKey, setIframeKey] = useState(0); // Force iframe re-render
  const [iframeLoading, setIframeLoading] = useState(false); // Track iframe loading state
  const [loadTimeout, setLoadTimeout] = useState<NodeJS.Timeout | null>(null);

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
    
    // Reset selected doc when new suggestions come in to show the list first
    if (suggestions.length > 0 && isVisible) {
      setSelectedDoc(null);
    }
  }, [suggestions, isVisible]);

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (loadTimeout) {
        clearTimeout(loadTimeout);
      }
    };
  }, [loadTimeout]);

  const fetchDocumentation = async (url: string) => {
    setLoading(true);
    setIframeLoading(true);
    setError(null);
    
    // Clear any existing timeout
    if (loadTimeout) {
      clearTimeout(loadTimeout);
    }
    
    try {
      // Parse URL to handle fragments properly
      const urlObj = new URL(url);
      const baseUrl = urlObj.origin + urlObj.pathname + urlObj.search;
      const fragment = urlObj.hash;
      
      console.log('Loading documentation:', { url, baseUrl, fragment });
      
      // Set initial state with the full URL (including fragment)
      setSelectedDoc({
        content: "",
        title: "Loading Documentation...",
        url: url, // Use full URL with fragment
        originalUrl: url,
        fragment: fragment
      });
      
      // Set a timeout to catch cases where iframe never loads
      const timeout = setTimeout(() => {
        console.warn('Iframe loading timeout, offering fallback options');
        setIframeLoading(false);
        setError('The documentation is taking longer than expected to load. This might be due to network issues or security restrictions.');
      }, 15000); // 15 second timeout
      
      setLoadTimeout(timeout);
      
      // Simulate loading time for better UX and allow iframe to load
      setTimeout(() => {
        setSelectedDoc({
          content: "",
          title: url.includes('/introduction/') ? 'Introduction to Jac' : 
                 url.includes('/nodes_and_edges/') ? 'Nodes and Edges' :
                 url.includes('/quickstart/') ? 'AI Integration Quickstart' :
                 url.includes('/with_llm/') ? 'Working with LLMs - MTLLM' :
                 url.includes('/jac-cloud/') ? 'Jac Cloud Introduction' :
                 url.includes('/walkers/') ? 'Walkers Guide' :
                 url.includes('/rag_chatbot/') ? 'RAG Chatbot Example' :
                 url.includes('/deployment/') ? 'Deployment Guide' :
                 url.includes('/keywords/') ? 'Jac Keywords Reference' :
                 url.includes('/jac_ref/') ? 'Language Reference' :
                 url.includes('/getting_started/') ? 'Getting Started Guide' :
                 url.includes('/playground/') ? 'Jac Playground' :
                 url.includes('/cli/') ? 'CLI Tools' :
                 'Jac Documentation',
          url: url,
          originalUrl: url,
          fragment: fragment
        });
        setLoading(false);
      }, 500);
      
    } catch (err) {
      console.error('Error loading documentation:', err);
      setError('Failed to load documentation');
      setLoading(false);
      setIframeLoading(false);
    }
  };

  const handleSuggestionClick = (suggestion: DocumentationSuggestion) => {
    fetchDocumentation(suggestion.url);
  };

  const handleBackToSuggestions = () => {
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
              ← Back
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
              <div className="text-red-400 text-center max-w-md p-4">
                <p className="mb-4">{error}</p>
                <div className="flex flex-col gap-2">
                  <Button 
                    variant="outline" 
                    size="sm" 
                    onClick={() => {
                      setError(null);
                      setIframeKey(prev => prev + 1);
                      setIframeLoading(true);
                    }}
                  >
                    Retry Loading
                  </Button>
                  {selectedDoc && (
                    <Button 
                      variant="outline" 
                      size="sm" 
                      onClick={() => window.open(selectedDoc.originalUrl || selectedDoc.url, '_blank')}
                      className="flex items-center gap-2"
                    >
                      <ExternalLink className="w-4 h-4" />
                      Open in New Tab
                    </Button>
                  )}
                </div>
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
                    onClick={() => window.open(selectedDoc.originalUrl || selectedDoc.url, '_blank')}
                    className="flex items-center gap-2"
                  >
                    <ExternalLink className="w-4 h-4" />
                    View Full Documentation
                  </Button>
                </div>
              </div>
              
              <div className="flex-1 relative">
                {/* Loading overlay for iframe */}
                {(loading || iframeLoading) && (
                  <div className="absolute inset-0 bg-gray-900 bg-opacity-75 flex items-center justify-center z-10">
                    <div className="flex items-center gap-2 text-white">
                      <Loader2 className="w-5 h-5 animate-spin" />
                      Loading documentation...
                    </div>
                  </div>
                )}
                
                <iframe
                  key={`${selectedDoc.url}-${iframeKey}`} // Force re-render when URL changes
                  src={selectedDoc.url}
                  className="w-full h-full border-0"
                  title={selectedDoc.title}
                  sandbox="allow-scripts allow-same-origin allow-popups allow-forms allow-top-navigation"
                  onLoad={(e) => {
                    console.log('Iframe loaded successfully:', selectedDoc.url);
                    
                    // Clear timeout since iframe loaded successfully
                    if (loadTimeout) {
                      clearTimeout(loadTimeout);
                      setLoadTimeout(null);
                    }
                    
                    setIframeLoading(false);
                    setError(null);
                    
                    // Additional check to see if iframe content is actually visible
                    setTimeout(() => {
                      const iframe = e.target as HTMLIFrameElement;
                      try {
                        // Try to check if iframe has any content
                        const iframeDoc = iframe.contentDocument;
                        if (iframeDoc && iframeDoc.body && iframeDoc.body.innerHTML.trim() === '') {
                          console.warn('Iframe appears to be empty, this might be a loading issue');
                        }
                      } catch (corsError) {
                        // Expected if there are CORS restrictions
                        console.log('Cannot access iframe content due to CORS (this is normal)');
                      }
                    }, 2000);
                  }}
                  onError={(e) => {
                    console.error('Iframe loading error:', e);
                    
                    // Clear timeout
                    if (loadTimeout) {
                      clearTimeout(loadTimeout);
                      setLoadTimeout(null);
                    }
                    
                    setIframeLoading(false);
                    setError('Failed to load documentation page. This may be due to network issues or the page being temporarily unavailable.');
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
                  {currentSuggestions.map((suggestion, index) => (
                    <Card 
                      key={index} 
                      className="p-4 bg-gray-800 border-gray-700 cursor-pointer hover:bg-gray-750 transition-colors"
                      onClick={() => handleSuggestionClick(suggestion)}
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h4 className="font-medium text-white mb-2 flex items-center gap-2">
                            {suggestion.title}
                            <ChevronRight className="w-4 h-4 text-gray-400" />
                          </h4>
                          <p className="text-sm text-gray-400 mb-2">
                            {suggestion.reason}
                          </p>
                          <p className="text-xs text-blue-400 hover:text-blue-300">
                            {suggestion.url}
                          </p>
                        </div>
                      </div>
                    </Card>
                  ))}
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
