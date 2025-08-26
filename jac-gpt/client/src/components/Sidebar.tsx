import { useState } from 'react';
import { Menu, X, Plus, MessageSquare, Settings, HelpCircle, ChevronLeft, ChevronRight, LogOut, User, UserPlus, LogIn } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/contexts/AuthContext';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Link } from 'react-router-dom';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
// Logo path updated to use public folder
const jacLogo = "/logo.png";

interface SidebarProps {
  isOpen: boolean;
  onToggle: () => void;
  onNewChat: () => void;
}

const Sidebar = ({ isOpen, onToggle, onNewChat }: SidebarProps) => {
  const [isExpanded, setIsExpanded] = useState(true);
  const { user, logout, isAuthenticated, messageCount, maxFreeMessages } = useAuth();

  const toggleExpanded = () => {
    setIsExpanded(!isExpanded);
  };

  const handleLogout = () => {
    logout();
  };

  const getUserInitials = (name?: string, email?: string) => {
    if (name) {
      return name.split(' ').map(part => part[0]).join('').toUpperCase().slice(0, 2);
    }
    if (email) {
      return email[0].toUpperCase();
    }
    return 'U';
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
              </div>
            </div>
          )}

          {/* Footer */}
          <div className="p-4 border-t border-gray-700 space-y-2">
            {/* Authenticated User Profile */}
            {isExpanded && isAuthenticated && user && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button 
                    variant="ghost" 
                    className="w-full justify-start gap-3 text-gray-300 hover:text-white hover:bg-gray-800 p-3"
                  >
                    <Avatar className="w-6 h-6">
                      <AvatarImage src="" />
                      <AvatarFallback className="text-xs bg-orange-500 text-white">
                        {getUserInitials(user.name, user.email)}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex flex-col items-start flex-1 min-w-0">
                      <span className="text-sm font-medium truncate">
                        {user.name || user.email}
                      </span>
                      {user.name && (
                        <span className="text-xs text-gray-400 truncate">
                          {user.email}
                        </span>
                      )}
                    </div>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent className="w-56" align="start" side="top">
                  <DropdownMenuLabel>My Account</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    <User className="mr-2 h-4 w-4" />
                    <span>Profile</span>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <Settings className="mr-2 h-4 w-4" />
                    <span>Settings</span>
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={handleLogout} className="text-red-600">
                    <LogOut className="mr-2 h-4 w-4" />
                    <span>Log out</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}

            {/* Guest User Actions */}
            {isExpanded && !isAuthenticated && (
              <div className="space-y-2">
                <div className="text-xs text-gray-400 bg-gray-800/50 px-3 py-2 rounded-lg">
                  Free messages: {messageCount}/{maxFreeMessages}
                </div>
                <Link to="/register">
                  <Button className="w-full bg-orange-600 hover:bg-orange-700 text-white">
                    <UserPlus className="w-4 h-4 mr-2" />
                    Sign Up
                  </Button>
                </Link>
                <Link to="/login">
                  <Button variant="outline" className="w-full text-orange-500 border-orange-500 hover:bg-orange-500 hover:text-white">
                    <LogIn className="w-4 h-4 mr-2" />
                    Sign In
                  </Button>
                </Link>
              </div>
            )}
            
            {!isExpanded && isAuthenticated && user && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button 
                    variant="ghost" 
                    className="w-full px-2 py-2 text-gray-300 hover:text-white hover:bg-gray-800"
                    title={user.name || user.email}
                  >
                    <Avatar className="w-6 h-6">
                      <AvatarImage src="" />
                      <AvatarFallback className="text-xs bg-orange-500 text-white">
                        {getUserInitials(user.name, user.email)}
                      </AvatarFallback>
                    </Avatar>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent className="w-56" align="start" side="right">
                  <DropdownMenuLabel>
                    <div className="flex flex-col">
                      <span>{user.name || user.email}</span>
                      {user.name && (
                        <span className="text-xs text-gray-400 font-normal">
                          {user.email}
                        </span>
                      )}
                    </div>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    <User className="mr-2 h-4 w-4" />
                    <span>Profile</span>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <Settings className="mr-2 h-4 w-4" />
                    <span>Settings</span>
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={handleLogout} className="text-red-600">
                    <LogOut className="mr-2 h-4 w-4" />
                    <span>Log out</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}

            {!isExpanded && !isAuthenticated && (
              <div className="space-y-1">
                <Link to="/register">
                  <Button 
                    variant="ghost" 
                    className="w-full px-2 py-2 text-orange-500 hover:text-white hover:bg-orange-600"
                    title="Sign Up"
                  >
                    <UserPlus className="w-4 h-4" />
                  </Button>
                </Link>
                <Link to="/login">
                  <Button 
                    variant="ghost" 
                    className="w-full px-2 py-2 text-gray-400 hover:text-white hover:bg-gray-800"
                    title="Sign In"
                  >
                    <LogIn className="w-4 h-4" />
                  </Button>
                </Link>
              </div>
            )}

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
                <div className={`w-2 h-2 rounded-full animate-pulse ${isAuthenticated ? 'bg-green-500' : 'bg-orange-500'}`}></div>
                {isAuthenticated ? 'Ready to help' : 'Guest mode'}
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
