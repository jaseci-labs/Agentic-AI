import { useState } from 'react';
import { Menu, X, Plus, MessageSquare, Settings, HelpCircle, ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
// Logo path updated to use public folder
const jacLogo = "/logo.png";

interface SidebarProps {
  isOpen: boolean;
  onToggle: () => void;
  onNewChat: () => void;
}

const Sidebar = ({ isOpen, onToggle, onNewChat }: SidebarProps) => {
  const [isExpanded, setIsExpanded] = useState(true);

  const toggleExpanded = () => {
    setIsExpanded(!isExpanded);
  };

  return (
    <>
      {/* Mobile backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={onToggle}
        />
      )}
      
      {/* Sidebar */}
      <div className={`
        fixed left-0 top-0 h-full bg-gray-900 border-r border-gray-700 z-50 transition-all duration-300
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        ${isExpanded ? 'w-70' : 'w-16'} lg:translate-x-0 lg:static lg:z-auto
      `}>
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="p-4 border-b border-gray-700">
            <div className="flex items-center justify-between">
              <div className={`flex items-center gap-3 transition-opacity duration-300 ${isExpanded ? 'opacity-100' : 'opacity-0'}`}>
                <div className="relative group">
                  <div className="absolute -inset-1 bg-gradient-to-r from-orange-500 to-red-500 rounded-lg opacity-20 group-hover:opacity-30 transition-opacity blur"></div>
                  <img 
                    src={jacLogo} 
                    alt="Jaseci Logo" 
                    className="relative w-10 h-10 object-contain"
                  />
                </div>
                {isExpanded && (
                  <div>
                    <h1 className="text-lg font-bold text-white">
                      Jaseci Assistant
                    </h1>
                    <p className="text-xs text-gray-400">
                      Jac programming companion
                    </p>
                  </div>
                )}
              </div>
              
              {!isExpanded && (
                <div className="relative group mx-auto">
                  <div className="absolute -inset-1 bg-gradient-to-r from-orange-500 to-red-500 rounded-lg opacity-20 group-hover:opacity-30 transition-opacity blur"></div>
                  <img 
                    src={jacLogo} 
                    alt="Jaseci Logo" 
                    className="relative w-8 h-8 object-contain"
                  />
                </div>
              )}

              <div className="flex items-center gap-2">
                {/* Expand/Collapse button - only on desktop */}
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={toggleExpanded}
                  className="hidden lg:flex text-gray-400 hover:text-white"
                >
                  {isExpanded ? <ChevronLeft className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                </Button>
                
                {/* Close button - only on mobile */}
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={onToggle}
                  className="lg:hidden text-gray-400 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </Button>
              </div>
            </div>
          </div>

          {/* New Chat Button */}
          <div className="p-4">
            <Button 
              onClick={onNewChat}
              className={`w-full justify-start gap-3 bg-gray-800 hover:bg-gray-700 text-white border-gray-600 ${!isExpanded ? 'px-2' : ''}`}
              variant="outline"
              title="New Chat"
            >
              <Plus className="w-4 h-4 shrink-0" />
              {isExpanded && "New Chat"}
            </Button>
          </div>

          {/* Chat History */}
          {isExpanded && (
            <div className="flex-1 overflow-y-auto px-4">
              <div className="space-y-2">
                <div className="text-xs font-medium text-gray-400 uppercase tracking-wider mb-3">
                  Recent Chats
                </div>
                
                {/* Current chat - active */}
                <div className="flex items-center gap-3 p-3 rounded-lg bg-gray-800 text-white cursor-pointer">
                  <MessageSquare className="w-4 h-4 text-orange-500" />
                  <span className="text-sm truncate">Jac Code Generation</span>
                </div>
                
                {/* Example previous chats */}
                {[
                  'Graph Traversal in Jac',
                  'Function Definitions',
                  'Class Structure Help',
                  'Loop Examples'
                ].map((chat, index) => (
                  <div 
                    key={index}
                    className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-800 text-gray-300 hover:text-white cursor-pointer transition-colors"
                  >
                    <MessageSquare className="w-4 h-4 text-gray-500" />
                    <span className="text-sm truncate">{chat}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Footer */}
          <div className="p-4 border-t border-gray-700 space-y-2">
            <Button 
              variant="ghost" 
              className={`w-full justify-start gap-3 text-gray-400 hover:text-white hover:bg-gray-800 ${!isExpanded ? 'px-2' : ''}`}
              size="sm"
              title="Settings"
            >
              <Settings className="w-4 h-4 shrink-0" />
              {isExpanded && "Settings"}
            </Button>
            <Button 
              variant="ghost" 
              className={`w-full justify-start gap-3 text-gray-400 hover:text-white hover:bg-gray-800 ${!isExpanded ? 'px-2' : ''}`}
              size="sm"
              title="Help & FAQ"
            >
              <HelpCircle className="w-4 h-4 shrink-0" />
              {isExpanded && "Help & FAQ"}
            </Button>
            
            {/* Status indicator */}
            {isExpanded && (
              <div className="flex items-center gap-2 text-xs text-gray-400 bg-gray-800/50 px-3 py-2 rounded-lg mt-3">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                Ready to help
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
