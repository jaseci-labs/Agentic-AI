import React from 'react';
import { Avatar } from "@/components/ui/avatar";
import ReactMarkdown from 'react-markdown';
import rehypeHighlight from 'rehype-highlight';
import 'highlight.js/styles/github-dark.css';
import { highlightJacCode } from '@/lib/syntaxHighlighting';
import '@/styles/jacSyntax.css';

// Logo path updated to use public folder
const jacLogo = "/logo.png";

interface JacCodeBlockProps {
  code: string;
}

const JacCodeBlock = ({ code }: JacCodeBlockProps) => {
  const [highlightedCode, setHighlightedCode] = React.useState(code);

  React.useEffect(() => {
    highlightJacCode(code).then(setHighlightedCode);
  }, [code]);

  return (
    <div className="jac-code">
      <pre 
        className="text-sm font-mono overflow-x-auto leading-relaxed m-0"
        dangerouslySetInnerHTML={{ __html: highlightedCode }}
      />
    </div>
  );
};

interface ChatMessageProps {
  message: string;
  isUser: boolean;
  timestamp: Date;
}

const ChatMessage = ({ message, isUser, timestamp }: ChatMessageProps) => {
  return (
    <div className={`flex gap-3 p-3 animate-fade-in ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
      <Avatar className="w-8 h-8 shrink-0 hover:scale-110 transition-transform duration-200">
        {isUser ? (
          <div className="w-full h-full bg-gradient-primary rounded-full flex items-center justify-center text-white text-xs font-bold shadow-glow">
            You
          </div>
        ) : (
          <div className="w-full h-full bg-muted/50 rounded-full flex items-center justify-center p-1.5">
            <img 
              src={jacLogo} 
              alt="Jac GPT" 
              className="w-full h-full object-contain"
            />
          </div>
        )}
      </Avatar>
      
      <div className={`flex flex-col gap-2 max-w-[85%] ${isUser ? 'items-end' : 'items-start'}`}>
        <div 
          className={`rounded-2xl px-4 py-3 shadow-sm hover:shadow-md transition-all duration-200 text-sm ${
            isUser 
              ? 'bg-gradient-primary text-white shadow-glow/50' 
              : 'bg-card/80 border border-border/50 text-foreground hover:border-border'
          }`}
        >
          {isUser ? (
            <div className="whitespace-pre-wrap leading-relaxed text-sm">{message}</div>
          ) : (
            <div className="prose prose-sm max-w-none dark:prose-invert prose-headings:text-foreground prose-p:text-foreground prose-strong:text-foreground prose-em:text-foreground prose-code:text-primary prose-pre:bg-chat-code prose-pre:border prose-pre:border-border/30 prose-a:text-primary hover:prose-a:text-primary/80 prose-li:text-foreground">
              <ReactMarkdown
                rehypePlugins={[rehypeHighlight]}
                components={{
                  code({ node, className, children, ...props }: any) {
                    const inline = !className?.includes('language-');
                    const match = /language-(\w+)/.exec(className || '');
                    const language = match ? match[1] : '';
                    
                    return !inline && match ? (
                      <div className="bg-chat-code rounded-xl p-3 border border-border/30 hover:border-primary/20 transition-colors my-3">
                        <div className="text-sm text-primary font-mono mb-2 flex items-center gap-2">
                          <div className="w-2 h-2 rounded-full bg-primary/20"></div>
                          {language}
                        </div>
                        {language === 'jac' ? (
                          <JacCodeBlock code={String(children).replace(/\n$/, '')} />
                        ) : (
                          <pre className="text-sm font-mono overflow-x-auto leading-relaxed m-0">
                            <code className={`${className} text-primary-glow`} {...props}>
                              {children}
                            </code>
                          </pre>
                        )}
                      </div>
                    ) : (
                      <code className={`${className} bg-muted/50 text-primary px-1 py-0.5 rounded text-sm font-mono`} {...props}>
                        {children}
                      </code>
                    );
                  },
                  h1: ({ children }) => (
                    <h1 className="text-lg font-bold text-foreground mt-4 mb-2 border-b border-border/30 pb-1">
                      {children}
                    </h1>
                  ),
                  h2: ({ children }) => (
                    <h2 className="text-base font-bold text-foreground mt-3 mb-2">
                      {children}
                    </h2>
                  ),
                  h3: ({ children }) => (
                    <h3 className="text-sm font-bold text-foreground mt-3 mb-2">
                      {children}
                    </h3>
                  ),
                  ul: ({ children }) => (
                    <ul className="list-disc pl-4 space-y-1 my-2">
                      {children}
                    </ul>
                  ),
                  ol: ({ children }) => (
                    <ol className="list-decimal pl-4 space-y-1 my-2">
                      {children}
                    </ol>
                  ),
                  li: ({ children }) => (
                    <li className="text-foreground leading-relaxed">
                      {children}
                    </li>
                  ),
                  p: ({ children }) => {
                    // Check if paragraph contains code-like content
                    const textContent = React.Children.toArray(children).join('');
                    const hasCodePatterns = /(\bnode\s+\w+\s*\{|\bwith\s+entry\s*\{|\bdef\s+\w+|\bcalc\.\w+|\w+:\s*\w+\s*=|has\s+\w+:\s*\w+|\breturn\s+\w+)/.test(textContent);
                    const isCodeLine = textContent.trim().length > 0 && hasCodePatterns && !textContent.includes('http') && !textContent.includes('For more information');
                    
                    if (isCodeLine) {
                      return (
                        <div className="bg-chat-code rounded-xl p-3 border border-border/30 hover:border-primary/20 transition-colors my-3">
                          <div className="text-xs text-primary font-mono mb-2 flex items-center gap-2">
                            <div className="w-2 h-2 rounded-full bg-primary/20"></div>
                            jac
                          </div>
                          <JacCodeBlock code={textContent} />
                        </div>
                      );
                    }
                    
                    return (
                      <p className="text-foreground leading-relaxed my-2">
                        {children}
                      </p>
                    );
                  },
                  strong: ({ children }) => (
                    <strong className="font-bold text-foreground">
                      {children}
                    </strong>
                  ),
                  em: ({ children }) => (
                    <em className="italic text-foreground">
                      {children}
                    </em>
                  ),
                  a: ({ href, children }) => (
                    <a 
                      href={href} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="text-primary hover:text-primary/80 underline decoration-primary/50 hover:decoration-primary transition-colors"
                    >
                      {children}
                    </a>
                  ),
                }}
              >
                {message}
              </ReactMarkdown>
            </div>
          )}
        </div>
        
        <div className="text-xs text-muted-foreground/70 px-2 flex items-center gap-1">
          <div className="w-1 h-1 bg-muted-foreground/50 rounded-full"></div>
          {timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </div>
      </div>
    </div>
  );
};

export default ChatMessage;