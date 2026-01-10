import React from 'react';
import { Avatar } from "@/components/ui/avatar";
import ReactMarkdown from 'react-markdown';
import rehypeHighlight from 'rehype-highlight';
import 'highlight.js/styles/github-dark.css';
import { highlightJacCode } from '@/lib/syntaxHighlighting';
import '@/styles/jacSyntax.css';
import { Check, Copy } from 'lucide-react';

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
    <pre 
      className="text-sm overflow-x-auto leading-relaxed m-0 p-0 whitespace-pre-wrap break-words"
      style={{ fontFamily: '"SF Mono", SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace' }}
      dangerouslySetInnerHTML={{ __html: highlightedCode }}
    />
  );
};

interface CodeBlockProps {
  language: string;
  code: string;
  className?: string;
  children?: React.ReactNode;
}

const CodeBlock = ({ language, code, className, children }: CodeBlockProps) => {
  const [copied, setCopied] = React.useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div style={{ margin: '8px 0', marginLeft: 0, marginRight: 0 }}>
      <div className="bg-[#1e1e1e] rounded-lg overflow-hidden border border-gray-700/50">
        {/* Header bar */}
        <div className="flex items-center justify-between px-4 py-2 border-b border-gray-700/30">
          <span className="text-xs text-gray-400" style={{ fontFamily: '"SF Mono", SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace' }}>{language || 'code'}</span>
          <button
            onClick={handleCopy}
            className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-gray-200 transition-colors"
          >
            {copied ? (
              <>
                <Check className="w-3.5 h-3.5" />
                <span>Copied!</span>
              </>
            ) : (
              <>
                <Copy className="w-3.5 h-3.5" />
                <span>Copy code</span>
              </>
            )}
          </button>
        </div>
        {/* Code content */}
        <div className="px-4 py-3">
          {language === 'jac' ? (
            <JacCodeBlock code={code} />
          ) : (
            <pre 
              className="text-sm overflow-x-auto leading-relaxed m-0 p-0"
              style={{ fontFamily: '"SF Mono", SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace' }}
            >
              <code className={className}>
                {children}
              </code>
            </pre>
          )}
        </div>
      </div>
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
    <div className={`animate-fade-in ${isUser ? 'flex justify-end py-3 px-2' : 'py-4 px-2'}`}>
      {isUser ? (
        // User message - right aligned with bubble
        <div className="max-w-[80%]">
          <div className="bg-gray-700/80 text-white shadow-sm hover:shadow-md transition-all duration-200 px-4 py-3 rounded-2xl">
            <div className="whitespace-pre-wrap leading-relaxed text-base">{message}</div>
          </div>
        </div>
      ) : (
        // Bot message - full width, left aligned like Streamlit
        <div className="w-full">
          <div className="prose prose-base max-w-none dark:prose-invert prose-headings:text-gray-100 prose-p:text-gray-200 prose-strong:text-gray-100 prose-em:text-gray-200 prose-code:text-primary prose-pre:bg-transparent prose-pre:border-0 prose-pre:m-0 prose-pre:p-0 prose-a:text-primary hover:prose-a:text-primary/80 prose-li:text-gray-200 break-words overflow-wrap-anywhere">
              <ReactMarkdown
                rehypePlugins={[rehypeHighlight]}
                components={{
                  code({ node, className, children, ...props }: any) {
                    const inline = !className?.includes('language-');
                    const match = /language-(\w+)/.exec(className || '');
                    const language = match ? match[1] : '';
                    const codeContent = String(children).replace(/\n$/, '');
                    
                    return !inline && match ? (
                      <CodeBlock 
                        language={language} 
                        code={codeContent} 
                        className={className}
                      >
                        {children}
                      </CodeBlock>
                    ) : (
                      <code className={`bg-muted/50 text-orange-300/80 px-1 py-0.5 rounded text-sm font-mono`} {...props}>
                        {children}
                      </code>
                    );
                  },
                  h1: ({ children }) => (
                    <h1 className="text-lg font-bold text-gray-100 mt-4 mb-2 border-b border-border/30 pb-1">
                      {children}
                    </h1>
                  ),
                  h2: ({ children }) => (
                    <h2 className="text-base font-bold text-gray-100 mt-3 mb-2">
                      {children}
                    </h2>
                  ),
                  h3: ({ children }) => (
                    <h3 className="text-sm font-bold text-gray-100 mt-3 mb-2">
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
                    <li className="text-gray-200 leading-relaxed">
                      {children}
                    </li>
                  ),
                  p: ({ children }) => (
                    <p className="text-gray-200 leading-relaxed my-2">
                      {children}
                    </p>
                  ),
                  strong: ({ children }) => (
                    <strong className="font-bold text-gray-100">
                      {children}
                    </strong>
                  ),
                  em: ({ children }) => (
                    <em className="italic text-gray-200">
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
                  hr: () => (
                    <hr className="border-0 border-t border-white/20 my-4" />
                  ),
                }}
              >
                {message}
              </ReactMarkdown>
            </div>
        </div>
      )}
    </div>
  );
};

export default ChatMessage;