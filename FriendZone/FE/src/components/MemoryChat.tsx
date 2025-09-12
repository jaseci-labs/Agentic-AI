import React, { useState, useRef, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Send, X, MessageCircle, Image as ImageIcon, MapPin, Users, Save } from "lucide-react";
import { AuthApi, InitSessionResponse, ContinueSessionResponse } from "@/lib/api";
import { toast } from "@/hooks/use-toast";

interface MemoryChatProps {
  sessionData: InitSessionResponse;
  token: string;
  onClose: () => void;
  onMemorySaved?: () => void;
}

interface ChatMessage {
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp?: string;
}

export const MemoryChat: React.FC<MemoryChatProps> = ({ 
  sessionData, 
  token, 
  onClose, 
  onMemorySaved 
}) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputValue, setInputValue] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [currentSessionData, setCurrentSessionData] = useState(sessionData);
  const [showCloseDialog, setShowCloseDialog] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    // Initialize with the conversation history from session data
    const conversationMessages: ChatMessage[] = [];
    
    // Add system message if there's a summary
    if (currentSessionData.summary) {
      conversationMessages.push({
        type: 'system',
        content: `Memory session started! ${currentSessionData.summary}`,
        timestamp: new Date().toLocaleTimeString()
      });
    }
    
    // Add all conversation history
    if (currentSessionData.conversation && currentSessionData.conversation.length > 0) {
      currentSessionData.conversation.forEach((conv, index) => {
        if (conv.user) {
          conversationMessages.push({
            type: 'user',
            content: conv.user,
            timestamp: new Date().toLocaleTimeString()
          });
        }
        if (conv.assistant) {
          conversationMessages.push({
            type: 'assistant',
            content: conv.assistant,
            timestamp: new Date().toLocaleTimeString()
          });
        }
      });
    }
    
    setMessages(conversationMessages);
  }, [currentSessionData]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!inputValue.trim() || isLoading) return;

    const userInput = inputValue.trim();
    setInputValue("");
    setIsLoading(true);

    try {
      const response = await AuthApi.continueSession(token, {
        session_id: currentSessionData.session_id,
        utterance: userInput
      });

      // Update session data which will trigger useEffect to rebuild messages
      setCurrentSessionData(response);

      // Check if memory was saved
      if (response.save_memory && !currentSessionData.save_memory) {
        const savedMessage: ChatMessage = {
          type: 'system',
          content: "✅ Memory saved successfully!",
          timestamp: new Date().toLocaleTimeString()
        };
        setMessages(prev => [...prev, savedMessage]);
        
        toast({
          title: "Memory saved!",
          description: "Your memory has been saved to your collection.",
        });
        
        onMemorySaved?.();
      }

    } catch (error) {
      console.error('Failed to continue session:', error);
      const errorMessage: ChatMessage = {
        type: 'system',
        content: "Sorry, there was an error processing your message. Please try again.",
        timestamp: new Date().toLocaleTimeString()
      };
      setMessages(prev => [...prev, errorMessage]);
      
      toast({
        title: "Error",
        description: "Failed to send message. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const handleCloseClick = () => {
    // If memory is already saved, close directly
    if (currentSessionData.save_memory) {
      onClose();
      return;
    }
    
    // Otherwise, show confirmation dialog
    setShowCloseDialog(true);
  };

  const handleSaveMemory = async () => {
    setIsSaving(true);
    try {
      await AuthApi.saveMemory(token, currentSessionData.session_id);
      
      toast({
        title: "Memory saved!",
        description: "Your memory has been saved successfully.",
      });
      
      onMemorySaved?.();
      setShowCloseDialog(false);
      onClose();
      
    } catch (error) {
      console.error('Failed to save memory:', error);
      toast({
        title: "Error",
        description: "Failed to save memory. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleCloseWithoutSaving = () => {
    setShowCloseDialog(false);
    onClose();
  };

  const quickActions = [
    "Please save this memory",
    "Tell me more about this image",
    "What details are missing?",
    "I'm done with this memory"
  ];

  return (
    <Card className="fixed bottom-4 right-4 z-50 flex flex-col w-96 h-[600px] bg-gradient-soft shadow-xl border-0 rounded-2xl">
      <CardHeader className="flex-shrink-0 border-b border-border/50 bg-card/80 backdrop-blur-sm rounded-t-2xl p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-hero rounded-full flex items-center justify-center shadow-soft">
              <MessageCircle className="w-4 h-4 text-white" />
            </div>
            <div>
              <CardTitle className="text-sm text-foreground">Memory Assistant</CardTitle>
              <p className="text-xs text-muted-foreground">
                Capture your memory details
              </p>
            </div>
          </div>
          <Button variant="ghost" size="sm" onClick={handleCloseClick} className="hover:bg-muted/50 w-6 h-6 p-0">
            <X className="w-4 h-4" />
          </Button>
        </div>
      </CardHeader>

      {/* Memory Image */}
      <div className="flex-shrink-0 p-3 border-b border-border/50 bg-card/50">
        <div className="flex items-center space-x-3">
          <div className="relative w-12 h-12 rounded-lg overflow-hidden bg-muted shadow-soft">
            {currentSessionData.image_url ? (
              <img 
                src={currentSessionData.image_url} 
                alt="Memory" 
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <ImageIcon className="w-4 h-4 text-muted-foreground" />
              </div>
            )}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-medium text-foreground truncate">
              {currentSessionData.when}
            </p>
            {currentSessionData.where.length > 0 && (
              <p className="text-xs text-muted-foreground flex items-center truncate">
                <MapPin className="w-2.5 h-2.5 mr-1 flex-shrink-0" />
                <span className="truncate">{currentSessionData.where[0]}</span>
                {currentSessionData.where.length > 1 && <span className="ml-1">+{currentSessionData.where.length - 1}</span>}
              </p>
            )}
            {currentSessionData.who.length > 0 && (
              <p className="text-xs text-muted-foreground flex items-center truncate">
                <Users className="w-2.5 h-2.5 mr-1 flex-shrink-0" />
                <span className="truncate">{currentSessionData.who.join(', ')}</span>
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Chat Messages */}
      <CardContent className="flex-1 overflow-y-auto p-3 space-y-3 bg-gradient-soft">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[85%] rounded-lg px-3 py-2 shadow-soft ${
                message.type === 'user'
                  ? 'bg-gradient-hero text-white'
                  : message.type === 'system'
                  ? 'bg-accent/20 text-accent-foreground text-center text-xs border border-accent/30'
                  : 'bg-card/90 text-foreground border border-border/50'
              }`}
            >
              <p className="whitespace-pre-wrap text-xs leading-relaxed">{message.content}</p>
              {message.timestamp && (
                <p className={`text-xs mt-1 ${
                  message.type === 'user' ? 'text-white/70' : 'text-muted-foreground'
                }`}>
                  {message.timestamp}
                </p>
              )}
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-card/90 border border-border/50 rounded-lg px-3 py-2 shadow-soft">
              <div className="flex items-center space-x-1">
                <div className="w-1.5 h-1.5 bg-primary/60 rounded-full animate-pulse"></div>
                <div className="w-1.5 h-1.5 bg-primary/60 rounded-full animate-pulse" style={{ animationDelay: '0.2s' }}></div>
                <div className="w-1.5 h-1.5 bg-primary/60 rounded-full animate-pulse" style={{ animationDelay: '0.4s' }}></div>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </CardContent>

      {/* Quick Actions */}
      <div className="flex-shrink-0 p-2 border-t border-border/50 bg-card/50">
        <div className="flex flex-wrap gap-1">
          {quickActions.map((action, index) => (
            <Button
              key={index}
              variant="outline"
              size="sm"
              className="text-xs px-2 py-1 h-6 hover:bg-primary/10 hover:text-primary hover:border-primary/30"
              onClick={() => setInputValue(action)}
              disabled={isLoading}
            >
              {action}
            </Button>
          ))}
        </div>
      </div>

      {/* Input Area */}
      <div className="flex-shrink-0 p-3 border-t border-border/50 bg-card/80 backdrop-blur-sm rounded-b-2xl">
        <div className="flex space-x-2">
          <Input
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Type your response..."
            className="flex-1 text-xs bg-background/50 border-border/50 focus:bg-background focus:border-primary h-8"
            onKeyPress={handleKeyPress}
            disabled={isLoading}
          />
          <Button
            onClick={handleSendMessage}
            disabled={!inputValue.trim() || isLoading}
            size="sm"
            className="bg-gradient-hero hover:opacity-90 shadow-soft w-8 h-8 p-0"
          >
            <Send className="w-3 h-3" />
          </Button>
        </div>
      </div>

      {/* Close Confirmation Dialog */}
      <AlertDialog open={showCloseDialog} onOpenChange={setShowCloseDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <Save className="w-5 h-5" />
              Save Memory?
            </AlertDialogTitle>
            <AlertDialogDescription>
              Would you like to save this memory before closing? If you don't save it now, 
              the conversation and details will be lost.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel 
              onClick={handleCloseWithoutSaving}
              disabled={isSaving}
            >
              Close Without Saving
            </AlertDialogCancel>
            <AlertDialogAction 
              onClick={handleSaveMemory}
              disabled={isSaving}
              className="bg-gradient-hero hover:opacity-90"
            >
              {isSaving ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4 mr-2" />
                  Save Memory
                </>
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Card>
  );
};

export default MemoryChat;