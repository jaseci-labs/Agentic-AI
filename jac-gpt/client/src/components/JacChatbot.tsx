import { useState, useEffect, useRef } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import Sidebar from './Sidebar';
import MobileMenuButton from './MobileMenuButton';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
import LimitReachedModal from './LimitReachedModal';
import DocumentationPanel from './DocumentationPanel';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Button } from '@/components/ui/button';
import { jacServerService, ChatMessage as JacChatMessage } from '@/services/jacServer';
import { documentationService, DocumentationSuggestion } from '@/services/documentation';
import { Book, X } from 'lucide-react';
// Logo path updated to use public folder
const jacLogo = "/logo.png";

interface Message {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: Date;
}

const JacChatbot = () => {
  const { user, messageCount, incrementMessageCount, canSendMessage, maxFreeMessages, isAuthenticated } = useAuth();
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sessionId, setSessionId] = useState<string>('');
  const [showLimitModal, setShowLimitModal] = useState(false);
  const [docPanelOpen, setDocPanelOpen] = useState(false);
  const [docSuggestions, setDocSuggestions] = useState<DocumentationSuggestion[]>([]);
  const [lastUserMessage, setLastUserMessage] = useState<string>('');
  const userMessageRef = useRef<HTMLDivElement>(null);
  const scrollAreaRef = useRef<HTMLDivElement>(null);
  const [lastUserMessageId, setLastUserMessageId] = useState<string>('');

  // Auto-scroll to position user's query near the top of the viewport
  useEffect(() => {
    if (lastUserMessageId && isLoading && userMessageRef.current && scrollAreaRef.current) {
      setTimeout(() => {
        const scrollContainer = scrollAreaRef.current?.querySelector('[data-radix-scroll-area-viewport]');
        if (scrollContainer && userMessageRef.current) {
          const elementTop = userMessageRef.current.offsetTop;
          // Scroll to position the query near the top with a small offset
          scrollContainer.scrollTo({
            top: elementTop - 20,
            behavior: 'smooth'
          });
        }
      }, 100);
    }
  }, [lastUserMessageId, isLoading]);

  // Initialize session on component mount
  useEffect(() => {
    const initializeSession = async () => {
      try {
        const newSessionId = jacServerService.generateSessionId();
        await jacServerService.createSession(newSessionId);
        setSessionId(newSessionId);
        console.log('Session initialized:', newSessionId);
      } catch (error) {
        console.error('Failed to initialize session:', error);
        // Fallback to a simple session ID if server is not available
        setSessionId(jacServerService.generateSessionId());
      }
    };

    initializeSession();
  }, []);

  const handleNewChat = async () => {
    try {
      // Create a new session
      const newSessionId = jacServerService.generateSessionId();
      await jacServerService.createSession(newSessionId);
      setSessionId(newSessionId);
      
      setMessages([]);
      setIsLoading(false);
      
      // Close sidebar on mobile after starting new chat
      if (window.innerWidth < 1024) {
        setSidebarOpen(false);
      }
    } catch (error) {
      console.error('Failed to create new session:', error);
      // Fallback to resetting messages without server interaction
      setMessages([]);
    }
  };

    const handleSendMessage = async (message: string) => {
    if (!canSendMessage) {
      setShowLimitModal(true);
      return;
    }

    if (!sessionId) {
      console.error('No session ID available');
      return;
    }

    // Store the user message for documentation suggestions
    setLastUserMessage(message);

    const userMessageId = Date.now().toString();
    const userMessage: Message = {
      id: userMessageId,
      content: message,
      isUser: true,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setLastUserMessageId(userMessageId);
    setIsLoading(true);

    // Get documentation suggestions based on the message
    try {
      console.log('Fetching suggestions for message:', message);
      const suggestions = await documentationService.getSuggestions(message, messages.map(m => ({
        role: m.isUser ? 'user' : 'assistant',
        content: m.content
      })));
      console.log('Received suggestions:', suggestions);
      setDocSuggestions(suggestions);
      
      // Documentation panel auto-open disabled - users can manually open with Show Docs button
    } catch (error) {
      console.warn('Failed to get documentation suggestions:', error);
    }

    try {
      const userEmail = user?.email || '';
      const response = await jacServerService.sendMessage(message, sessionId, userEmail);
      
      const botMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: response.response,
        isUser: false,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, botMessage]);
      
      // Increment message count for guest users (non-authenticated users)
      if (!isAuthenticated) {
        incrementMessageCount();
      }
    } catch (error) {
      console.error('Error sending message:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen bg-[#141414]">
      {/* Sidebar */}
      <Sidebar 
        isOpen={sidebarOpen} 
        onToggle={() => setSidebarOpen(!sidebarOpen)}
        onNewChat={handleNewChat}
      />
      
      {/* Chat Interface */}
      <div className={`flex ${docPanelOpen ? 'w-1/2' : 'flex-1'} min-w-0`}>
        <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
          {/* Mobile Menu Button */}
          <MobileMenuButton onClick={() => setSidebarOpen(true)} />

          {/* Header with Docs Toggle */}
          <div className="hidden lg:flex items-center justify-between p-2 border-b border-gray-700 bg-[#141414]">
            <div className="flex items-center gap-3">
              <img src={jacLogo} alt="Jac Logo" className="w-8 h-8 object-contain" />
              <h1 className="text-xl font-semibold text-white">Jac GPT</h1>
            </div>
            
            <Button
              variant={docPanelOpen ? "default" : "outline"}
              size="sm"
              onClick={() => setDocPanelOpen(!docPanelOpen)}
              className="flex items-center gap-2"
            >
              {docPanelOpen ? <X className="w-4 h-4" /> : <Book className="w-4 h-4" />}
              {docPanelOpen ? 'Hide Docs' : 'Show Docs'}
            </Button>
          </div>

          {/* Limit Reached Modal */}
          <LimitReachedModal
            isOpen={showLimitModal}
            onClose={() => setShowLimitModal(false)}
            messageCount={messageCount}
            maxFreeMessages={maxFreeMessages}
          />
          
          {/* Chat Messages */}
          {messages.length === 0 && !isLoading ? (
            // Empty state - centered like ChatGPT
            <div className="flex-1 flex flex-col items-center justify-center px-4 lg:px-6 -mt-24">
              <div className="w-full max-w-3xl mx-auto flex flex-col items-center justify-center">
                <p className="text-3xl text-gray-300 font-medium mb-10" style={{ fontFamily: 'Inter, sans-serif' }}>How can <span className="text-orange-500">Jaseci</span> help you today?</p>
                
                {/* Centered Chat Input */}
                <div className="w-full">
                  <ChatInput 
                    onSendMessage={handleSendMessage} 
                    disabled={isLoading || !canSendMessage} 
                    placeholder={
                      !canSendMessage 
                        ? "Sign up to continue chatting..." 
                        : "Type your message"
                    }
                  />
                </div>
              </div>
            </div>
          ) : (
            <>
              <ScrollArea ref={scrollAreaRef} className="flex-1 px-4 lg:px-6">
                <div className="max-w-3xl mx-auto space-y-2 lg:pt-4 pt-16 min-w-0 overflow-hidden pb-4">
                  {messages.map((message) => (
                    <div 
                      key={message.id}
                      ref={message.id === lastUserMessageId ? userMessageRef : null}
                    >
                      <ChatMessage
                        message={message.content}
                        isUser={message.isUser}
                        timestamp={message.timestamp}
                      />
                    </div>
                  ))}
                  
                  {isLoading && (
                    <div className="py-4 px-2 animate-fade-in">
                      <div className="flex items-center gap-2">
                        <div className="flex gap-1">
                          <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.3s]" />
                          <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.15s]" />
                          <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce" />
                        </div>
                        <span className="text-sm text-gray-400 ml-2">Thinking...</span>
                      </div>
                    </div>
                  )}
                </div>
              </ScrollArea>
              
              {/* Chat Input for active conversation */}
              <ChatInput 
                onSendMessage={handleSendMessage} 
                disabled={isLoading || !canSendMessage} 
                placeholder={
                  !canSendMessage 
                    ? "Sign up to continue chatting..." 
                    : "Type your message"
                }
              />
            </>
          )}
        </div>
      </div>

      {/* Documentation Panel */}
      <DocumentationPanel
        message={lastUserMessage}
        suggestions={docSuggestions}
        isVisible={docPanelOpen}
        onToggle={() => setDocPanelOpen(false)}
      />
    </div>
  );
};

export default JacChatbot;