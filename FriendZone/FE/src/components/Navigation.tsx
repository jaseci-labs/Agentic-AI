import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Heart, Users, User, Settings } from "lucide-react";

const Navigation = () => {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-card/95 backdrop-blur-sm border-b border-border">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        {/* Logo */}
        <div className="flex items-center space-x-2">
          <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
            <Heart className="w-5 h-5 text-white" />
          </div>
          <span className="text-xl font-bold bg-gradient-primary bg-clip-text text-transparent">
            FriendZone
          </span>
        </div>

        {/* Navigation Items */}
        <div className="hidden md:flex items-center space-x-6">
          <Button variant="ghost" size="sm" className="text-foreground hover:text-primary">
            <Heart className="w-4 h-4 mr-2" />
            Memories
          </Button>
          <Button variant="ghost" size="sm" className="text-foreground hover:text-primary">
            <Users className="w-4 h-4 mr-2" />
            Friends
          </Button>
          <Button variant="ghost" size="sm" className="text-foreground hover:text-primary">
            <User className="w-4 h-4 mr-2" />
            Profile
          </Button>
        </div>

        {/* User Avatar */}
        <div className="flex items-center space-x-3">
          <Button variant="hero" size="sm">
            Share Memory
          </Button>
          <Avatar className="w-8 h-8">
            <AvatarImage src="/placeholder-avatar.jpg" />
            <AvatarFallback className="bg-primary-soft text-primary">
              You
            </AvatarFallback>
          </Avatar>
        </div>
      </div>
    </nav>
  );
};

export default Navigation;