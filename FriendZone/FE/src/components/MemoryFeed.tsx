import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { MessageCircle, Share2, Clock } from "lucide-react";
import { useState } from "react";

interface Memory {
  id: string;
  user: {
    name: string;
    avatar: string;
    username: string;
  };
  image: string;
  caption: string;
  timestamp: string;
  comments: number;
}

const mockMemories: Memory[] = [
  {
    id: "1",
    user: {
      name: "Sarah Chen",
      avatar: "/placeholder-avatar.jpg",
      username: "sarahc"
    },
    image: "/placeholder-memory.jpg",
    caption: "Beautiful sunset with my best friends! Missing these moments ✨",
    timestamp: "2 hours ago",
    comments: 12
  },
  {
    id: "2", 
    user: {
      name: "Alex Johnson",
      avatar: "/placeholder-avatar.jpg", 
      username: "alexj"
    },
    image: "/placeholder-memory.jpg",
    caption: "Coffee date memories that warm my heart ☕️",
    timestamp: "5 hours ago",
    comments: 8
  }
];

const MemoryCard = ({ memory }: { memory: Memory }) => {
  const [showComments, setShowComments] = useState(false);

  return (
    <Card className="mb-6 shadow-soft hover:shadow-medium transition-all">
      {/* Memory Header */}
      <div className="p-4 flex items-center space-x-3">
        <Avatar className="w-10 h-10">
          <AvatarImage src={memory.user.avatar} />
          <AvatarFallback className="bg-primary-soft text-primary">
            {memory.user.name.charAt(0)}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <h3 className="font-semibold text-sm">{memory.user.name}</h3>
          <div className="flex items-center text-xs text-muted-foreground">
            <Clock className="w-3 h-3 mr-1" />
            {memory.timestamp}
          </div>
        </div>
      </div>

      {/* Memory Image */}
      <div className="relative aspect-square bg-muted rounded-lg mx-4">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center text-muted-foreground">
            <div className="w-16 h-16 bg-gradient-soft rounded-full flex items-center justify-center mb-2 mx-auto">
              📸
            </div>
            <p className="text-sm">Memory Photo</p>
          </div>
        </div>
      </div>

      {/* Memory Content */}
      <CardContent className="p-4">
        <p className="text-sm mb-4">{memory.caption}</p>
        
        {/* Action Buttons */}
        <div className="flex items-center space-x-4">
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={() => setShowComments(!showComments)}
            className="text-muted-foreground hover:text-primary"
          >
            <MessageCircle className="w-4 h-4 mr-2" />
            {memory.comments} comments
          </Button>
          <Button 
            variant="ghost" 
            size="sm" 
            className="text-muted-foreground hover:text-primary"
          >
            <Share2 className="w-4 h-4 mr-2" />
            Share
          </Button>
        </div>

        {/* Comments Section */}
        {showComments && (
          <div className="mt-4 pt-4 border-t border-border">
            <p className="text-xs text-muted-foreground mb-2">Recent comments</p>
            <div className="space-y-2">
              <div className="flex items-start space-x-2">
                <Avatar className="w-6 h-6">
                  <AvatarFallback className="bg-accent text-accent-foreground text-xs">
                    M
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <p className="text-xs">
                    <span className="font-medium">Maya</span> This looks amazing! 💕
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

const MemoryFeed = ({ token, user }: { token: string; user: any }) => {
  console.log("MemoryFeed: rendering with token:", token, "and user:", user);
  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h2 className="text-2xl font-bold mb-2">Recent Memories</h2>
        <p className="text-muted-foreground">See what your friends have been sharing</p>
      </div>
      
      {mockMemories.map((memory) => (
        <MemoryCard key={memory.id} memory={memory} />
      ))}
    </div>
  );
};

export default MemoryFeed;