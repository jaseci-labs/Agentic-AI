import { useState, useEffect } from 'react';
import Sidebar from './Sidebar';
import MobileMenuButton from './MobileMenuButton';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
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
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      content: 'Hello! I am your Jaseci Assistant. I can help you with Jac programming language questions. What would you like to know about Jac?',
      isUser: false,
      timestamp: new Date(),
    },
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sessionId, setSessionId] = useState<string>('');

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
      
      setMessages([
        {
          id: '1',
          content: 'Hello! I am your Jaseci Assistant. I can help you with Jac programming language questions. What would you like to know about Jac?',
          isUser: false,
          timestamp: new Date(),
        },
      ]);
      setIsLoading(false);
      
      // Close sidebar on mobile after starting new chat
      if (window.innerWidth < 1024) {
        setSidebarOpen(false);
      }
    } catch (error) {
      console.error('Failed to create new session:', error);
      // Fallback to resetting messages without server interaction
      setMessages([
        {
          id: '1',
          content: 'Hello! I am your Jaseci Assistant. I can help you with Jac programming language questions. What would you like to know about Jac?',
          isUser: false,
          timestamp: new Date(),
        },
      ]);
    }
  };

  const handleSendMessage = async (content: string) => {
    if (!sessionId) {
      console.error('No session ID available');
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

    try {
      // Send message to JAC server
      const jacResponse = await jacServerService.sendMessage(content, sessionId);
      
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
        
        {/* Chat Messages */}
        <ScrollArea className="flex-1 p-4 lg:p-6">
          <div className="max-w-4xl mx-auto space-y-1 lg:pt-0 pt-16">
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
        <ChatInput onSendMessage={handleSendMessage} disabled={isLoading} />
      </div>
    </div>
  );
};

export default JacChatbot;