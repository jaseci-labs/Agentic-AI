import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Send } from 'lucide-react';

interface ChatInputProps {
  onSendMessage: (message: string) => void;
  disabled?: boolean;
}

const ChatInput = ({ onSendMessage, disabled = false }: ChatInputProps) => {
  const [message, setMessage] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (message.trim() && !disabled) {
      onSendMessage(message.trim());
      setMessage('');
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <div className="border-t border-border/50 bg-card/30 backdrop-blur-md p-6">
      <form onSubmit={handleSubmit} className="flex gap-4 max-w-4xl mx-auto">
        <div className="flex-1 relative">
          <Textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Ask about Jac syntax, functions, loops, classes, or request code examples..."
            className="min-h-[70px] max-h-[200px] resize-none bg-background/80 border-border/50 hover:border-primary/50 focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300 rounded-xl text-base leading-relaxed"
            disabled={disabled}
          />
          <div className="absolute bottom-3 right-3 text-xs text-muted-foreground">
            Press Enter to send, Shift+Enter for new line
          </div>
        </div>
        
        <Button
          type="submit"
          disabled={!message.trim() || disabled}
          className="h-[70px] px-8 bg-gradient-primary hover:shadow-glow hover:scale-105 transition-all duration-300 disabled:opacity-50 disabled:scale-100 rounded-xl font-medium"
        >
          <Send className="w-5 h-5" />
          <span className="ml-2 hidden sm:inline">Send</span>
        </Button>
      </form>
      
      {/* Quick suggestions */}
      <div className="max-w-4xl mx-auto mt-4">
        <div className="flex flex-wrap gap-2 justify-center">
          {['How to define functions?', 'Show me loops', 'Class examples', 'Variables in Jac'].map((suggestion, index) => (
            <button
              key={index}
              onClick={() => setMessage(suggestion)}
              className="px-3 py-1 text-sm bg-muted/50 hover:bg-muted transition-colors rounded-full border border-border/30 hover:border-primary/50 text-muted-foreground hover:text-foreground"
            >
              {suggestion}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ChatInput;