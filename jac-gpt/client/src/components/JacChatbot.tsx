import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import Sidebar from './Sidebar';
import MobileMenuButton from './MobileMenuButton';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
import LimitReachedModal from './LimitReachedModal';
import { ScrollArea } from '@/components/ui/scroll-area';
import { jacServerService, ChatMessage as JacChatMessage } from '@/services/jacServer';
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

  const handleSendMessage = async (content: string) => {
    if (!sessionId) {
      console.error('No session ID available');
      return;
    }

    // Check if user can send message
    if (!canSendMessage) {
      setShowLimitModal(true);
      return;
    }

    const userMessage: Message = {
      id: Date.now().toString(),
      content,
      isUser: true,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setIsLoading(true);

    // Increment message count for non-authenticated users
    if (!isAuthenticated) {
      incrementMessageCount();
    }

    try {
      // Send message to JAC server with user email
      const jacResponse = await jacServerService.sendMessage(content, sessionId, user?.email);
      
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: jacResponse.response,
        isUser: false,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, aiMessage]);
    } catch (error) {
      console.error('Error getting AI response:', error);
      
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: 'I apologize, but I encountered an error while processing your request. Please check if the JAC server is running and try again.',
        isUser: false,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen bg-gray-900">
      {/* Sidebar */}
      <Sidebar 
        isOpen={sidebarOpen} 
        onToggle={() => setSidebarOpen(!sidebarOpen)}
        onNewChat={handleNewChat}
      />
      
      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col lg:ml-0">
        {/* Mobile Menu Button */}
        <MobileMenuButton onClick={() => setSidebarOpen(true)} />

        {/* Limit Reached Modal */}
        <LimitReachedModal
          isOpen={showLimitModal}
          onClose={() => setShowLimitModal(false)}
          messageCount={messageCount}
          maxFreeMessages={maxFreeMessages}
        />
        
        {/* Chat Messages */}
        <ScrollArea className="flex-1 p-4 lg:p-6">
          <div className="max-w-4xl mx-auto space-y-1 lg:pt-0 pt-16">
            {messages.length === 0 && !isLoading && (
              <div className="flex items-center justify-center min-h-[calc(100vh-200px)]">
                <div className="text-center">
                  <div className="w-16 h-16 mx-auto mb-4 bg-gray-700 rounded-full flex items-center justify-center">
                    <img src={jacLogo} alt="Jac Logo" className="w-10 h-10 object-contain opacity-60" />
                  </div>
                  <p className="text-xl text-gray-300 font-medium">Ask me anything about Jac</p>
                  <p className="text-sm text-gray-500 mt-2">Start a conversation about Jac programming language</p>
                </div>
              </div>
            )}
            
            {messages.map((message) => (
              <ChatMessage
                key={message.id}
                message={message.content}
                isUser={message.isUser}
                timestamp={message.timestamp}
              />
            ))}
            
            {isLoading && (
              <div className="flex gap-3 p-3 animate-fade-in">
                <div className="w-8 h-8 shrink-0 bg-gray-700 rounded-full animate-pulse flex items-center justify-center p-1.5">
                  <img src={jacLogo} alt="Typing" className="w-full h-full object-contain opacity-60" />
                </div>
                <div className="bg-gray-800 border border-gray-600 rounded-2xl px-4 py-3 shadow-sm">
                  <div className="flex gap-1">
                    <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.3s]" />
                    <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.15s]" />
                    <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce" />
                  </div>
                  <div className="text-xs text-gray-400 mt-1">Jaseci is thinking...</div>
                </div>
              </div>
            )}
          </div>
        </ScrollArea>
        
        {/* Chat Input */}
        <ChatInput 
          onSendMessage={handleSendMessage} 
          disabled={isLoading || !canSendMessage} 
          placeholder={
            !canSendMessage 
              ? "Sign up to continue chatting..." 
              : "Type your message..."
          }
        />
      </div>
    </div>
  );
};

export default JacChatbot;