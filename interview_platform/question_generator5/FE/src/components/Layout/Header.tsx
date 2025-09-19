import React from 'react';
import { Link } from 'react-router-dom';
import { Building2, User, LogOut } from 'lucide-react';
import { PlatformButton } from '@/components/ui/platform-button';
import { ThemeToggle } from '@/components/ui/theme-toggle';

interface HeaderProps {
  showAuth?: boolean;
  showLogout?: boolean;
  title?: string;
  onLogout?: () => void;
}

export const Header: React.FC<HeaderProps> = ({ 
  showAuth = true, 
  showLogout = false, 
  title, 
  onLogout 
}) => {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 max-w-screen-2xl items-center justify-between px-6">
        <Link to="/" className="flex items-center space-x-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground font-bold text-sm">
            AI
          </div>
          <span className="font-bold text-xl tracking-tight">
            {title || 'Interview Platform'}
          </span>
        </Link>

        <div className="flex items-center space-x-4">
          <ThemeToggle />
          {showAuth && (
            <nav className="flex items-center space-x-6">
              <Link 
                to="/admin/login" 
                className="group flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors"
                title="Admin Login"
              >
                <Building2 className="h-5 w-5" />
                <span className="hidden sm:inline">Admin</span>
              </Link>
              <Link 
                to="/candidate/login" 
                className="group flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors"
                title="Candidate Login"
              >
                <User className="h-5 w-5" />
                <span className="hidden sm:inline">Candidate</span>
              </Link>
            </nav>
          )}
        </div>

        {showLogout && (
          <div className="flex items-center space-x-4">
            <ThemeToggle />
            <PlatformButton variant="ghost" size="sm" onClick={onLogout}>
              <LogOut className="h-4 w-4 mr-2" />
              Logout
            </PlatformButton>
          </div>
        )}
      </div>
    </header>
  );
};