import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Send, Square } from 'lucide-react';

interface ChatInputProps {
  onSendMessage: (message: string) => void;
  disabled?: boolean;
  placeholder?: string;
  isLoading?: boolean;
  onStop?: () => void;
}

const ChatInput = ({ onSendMessage, disabled = false, placeholder, isLoading = false, onStop }: ChatInputProps) => {
  const [message, setMessage] = useState('');

  const defaultPlaceholder = "Ask about Jac syntax, functions, loops, classes, or request code examples...";

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (message.trim() && !disabled && !isLoading) {
      const messageToSend = message.trim();
      setMessage('');
      onSendMessage(messageToSend);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <div className="pt-2 px-3 pb-4">
      <form onSubmit={handleSubmit} className="max-w-3xl mx-auto">
        <div className="relative">
          <Textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={placeholder || defaultPlaceholder}
            className="min-h-[60px] max-h-[200px] resize-none bg-background border-border/50 hover:border-primary/50 focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300 rounded-[30px] text-base leading-relaxed px-5 py-4 pr-16"
            disabled={disabled && !isLoading}
          />
          {isLoading ? (
            <Button
              type="button"
              onClick={onStop}
              className="absolute right-3 bottom-[50%] translate-y-[50%] h-10 w-10 p-0 bg-gray-700 hover:bg-gray-600 hover:shadow-glow hover:scale-105 transition-all duration-300 rounded-full font-medium flex items-center justify-center"
            >
              <Square className="w-4 h-4" />
            </Button>
          ) : (
            <Button
              type="submit"
              disabled={!message.trim() || disabled}
              className="absolute right-3 bottom-[50%] translate-y-[50%] h-10 w-10 p-0 bg-gradient-primary hover:shadow-glow hover:scale-105 transition-all duration-300 disabled:opacity-50 disabled:scale-100 rounded-full font-medium flex items-center justify-center"
            >
              <Send className="w-4 h-4" />
            </Button>
          )}
        </div>
      </form>
    </div>
  );
};

export default ChatInput;