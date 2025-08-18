import { Avatar } from "@/components/ui/avatar";
// Logo path updated to use public folder
const jacLogo = "/logo.png";

interface ChatMessageProps {
  message: string;
  isUser: boolean;
  timestamp: Date;
}

const ChatMessage = ({ message, isUser, timestamp }: ChatMessageProps) => {
  return (
    <div className={`flex gap-4 p-6 animate-fade-in ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
      <Avatar className="w-10 h-10 shrink-0 hover:scale-110 transition-transform duration-200">
        {isUser ? (
          <div className="w-full h-full bg-gradient-primary rounded-full flex items-center justify-center text-white text-sm font-bold shadow-glow">
            You
          </div>
        ) : (
          <div className="w-full h-full bg-muted/50 rounded-full flex items-center justify-center p-2">
            <img 
              src={jacLogo} 
              alt="Jaseci Assistant" 
              className="w-full h-full object-contain"
            />
          </div>
        )}
      </Avatar>
      
      <div className={`flex flex-col gap-3 max-w-[85%] ${isUser ? 'items-end' : 'items-start'}`}>
        <div 
          className={`rounded-2xl px-5 py-4 shadow-sm hover:shadow-md transition-all duration-200 ${
            isUser 
              ? 'bg-gradient-primary text-white shadow-glow/50' 
              : 'bg-card/80 border border-border/50 text-foreground hover:border-border'
          }`}
        >
          {message.includes('```') ? (
            <div className="space-y-3">
              {message.split('```').map((part, index) => {
                if (index % 2 === 1) {
                  // This is a code block
                  const [language, ...codeLines] = part.split('\n');
                  const code = codeLines.join('\n').trim();
                  
                  return (
                    <div key={index} className="bg-chat-code rounded-xl p-4 border border-border/30 hover:border-primary/20 transition-colors">
                      <div className="text-xs text-primary font-mono mb-3 flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-primary/20"></div>
                        {language || 'jac'}
                      </div>
                      <pre className="text-sm font-mono overflow-x-auto leading-relaxed">
                        <code className="text-primary-glow">{code}</code>
                      </pre>
                    </div>
                  );
                }
                return <div key={index} className="whitespace-pre-wrap leading-relaxed">{part}</div>;
              })}
            </div>
          ) : (
            <div className="whitespace-pre-wrap leading-relaxed">{message}</div>
          )}
        </div>
        
        <div className="text-xs text-muted-foreground/70 px-3 flex items-center gap-2">
          <div className="w-1 h-1 bg-muted-foreground/50 rounded-full"></div>
          {timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </div>
      </div>
    </div>
  );
};

export default ChatMessage;