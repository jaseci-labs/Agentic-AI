// Logo path updated to use public folder
const jacLogo = "/logo.png";

const ChatHeader = () => {
  return (
    <header className="border-b border-border/50 bg-card/20 backdrop-blur-md sticky top-0 z-10">
      <div className="flex items-center justify-between p-6 max-w-6xl mx-auto">
        <div className="flex items-center gap-6">
          <div className="relative group">
            <div className="absolute -inset-2 bg-gradient-primary rounded-xl opacity-20 group-hover:opacity-30 transition-opacity blur-lg"></div>
            <img 
              src={jacLogo} 
              alt="Jaseci Logo" 
              className="relative w-14 h-14 object-contain hover:scale-110 transition-transform duration-300"
            />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-foreground mb-1">
              Jaseci Assistant
            </h1>
            <p className="text-muted-foreground">
              Your AI companion for mastering the Jac programming language
            </p>
          </div>
        </div>
        
        <div className="flex items-center gap-2 text-xs text-muted-foreground bg-muted/30 px-3 py-2 rounded-lg">
          <div className="w-2 h-2 bg-primary rounded-full animate-pulse"></div>
          Ready to help
        </div>
      </div>
    </header>
  );
};

export default ChatHeader;