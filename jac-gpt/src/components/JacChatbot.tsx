import { useState } from 'react';
import ChatHeader from './ChatHeader';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
import { ScrollArea } from '@/components/ui/scroll-area';
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

  const handleSendMessage = (content: string) => {
    const userMessage: Message = {
      id: Date.now().toString(),
      content,
      isUser: true,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setIsLoading(true);

    // Simple mock response for now - we'll add OpenAI back once basic app works
    setTimeout(() => {
      const aiResponse = `Thanks for your question about Jac! You asked: "${content}". I'm being configured to use GPT-4o-mini for intelligent responses. This is a temporary response while we troubleshoot the integration.`;
      
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: aiResponse,
        isUser: false,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, aiMessage]);
      setIsLoading(false);
    }, 1500);
  };

  return (
    <div className="flex flex-col h-screen bg-gray-900">
      <ChatHeader />
      
      <ScrollArea className="flex-1 p-2">
        <div className="max-w-5xl mx-auto space-y-2">
          {messages.map((message) => (
            <ChatMessage
              key={message.id}
              message={message.content}
              isUser={message.isUser}
              timestamp={message.timestamp}
            />
          ))}
          
          {isLoading && (
            <div className="flex gap-4 p-6 animate-fade-in">
              <div className="w-10 h-10 shrink-0 bg-gray-700 rounded-full animate-pulse flex items-center justify-center p-2">
                <img src={jacLogo} alt="Typing" className="w-full h-full object-contain opacity-60" />
              </div>
              <div className="bg-gray-800 border border-gray-600 rounded-2xl px-5 py-4 shadow-sm">
                <div className="flex gap-1">
                  <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.3s]" />
                  <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce [animation-delay:-0.15s]" />
                  <div className="w-2 h-2 bg-orange-500 rounded-full animate-bounce" />
                </div>
                <div className="text-xs text-gray-400 mt-2">Jaseci is thinking...</div>
              </div>
            </div>
          )}
        </div>
      </ScrollArea>
      
      <ChatInput onSendMessage={handleSendMessage} disabled={isLoading} />
    </div>
  );
};

export default JacChatbot;