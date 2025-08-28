import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { MessageCircle, Share2, Clock, UserPlus } from "lucide-react";
import { useState } from "react";

interface SharedMemory {
  id: string;
  user: {
    name: string;
    avatar: string;
    username: string;
  };
  sharedBy: {
    name: string;
    avatar: string;
    username: string;
  };
  image: string;
  caption: string;
  timestamp: string;
  comments: number;
}

const mockSharedMemories: SharedMemory[] = [
  {
    id: "1",
    user: {
      name: "Maya Rodriguez",
      avatar: "/placeholder-avatar.jpg",
      username: "mayar"
    },
    sharedBy: {
      name: "Alex Johnson",
      avatar: "/placeholder-avatar.jpg",
      username: "alexj"
    },
    image: "/placeholder-memory.jpg",
    caption: "That amazing trip to the mountains last summer! 🏔️",
    timestamp: "1 hour ago",
    comments: 15
  },
  {
    id: "2",
    user: {
      name: "David Kim", 
      avatar: "/placeholder-avatar.jpg",
      username: "davidk"
    },
    sharedBy: {
      name: "Sarah Chen",
      avatar: "/placeholder-avatar.jpg",
      username: "sarahc"
    },
    image: "/placeholder-memory.jpg",
    caption: "Graduation day memories with the squad 🎓",
    timestamp: "3 hours ago",
    comments: 22
  }
];

const SharedMemoryCard = ({ memory }: { memory: SharedMemory }) => {
  const [showComments, setShowComments] = useState(false);

  return (
    <Card className="mb-6 shadow-soft hover:shadow-medium transition-all">
      {/* Shared Memory Header */}
      <div className="p-4">
        {/* Shared by indicator */}
        <div className="flex items-center space-x-2 mb-3 p-2 bg-accent/50 rounded-lg">
          <Share2 className="w-4 h-4 text-primary" />
          <span className="text-sm text-muted-foreground">
            Shared by <span className="font-medium text-foreground">{memory.sharedBy.name}</span>
          </span>
        </div>
        
        {/* Original poster */}
        <div className="flex items-center space-x-3">
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
      </div>

      {/* Memory Image */}
      <div className="relative aspect-square bg-muted rounded-lg mx-4">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center text-muted-foreground">
            <div className="w-16 h-16 bg-gradient-soft rounded-full flex items-center justify-center mb-2 mx-auto">
              📷
            </div>
            <p className="text-sm">Shared Memory</p>
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
                  <AvatarFallback className="bg-secondary-soft text-secondary text-xs">
                    {memory.sharedBy.name.charAt(0)}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <p className="text-xs">
                    <span className="font-medium">{memory.sharedBy.name}</span> Love this memory! 💕
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

const SharedMemoriesFeed = ({ token, user }: { token: string; user: any }) => {
  console.log("SharedMemoriesFeed: rendering with token:", token, "and user:", user);
  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h2 className="text-2xl font-bold mb-2">Shared With You</h2>
        <p className="text-muted-foreground">Memories your friends have shared with you</p>
      </div>
      
      {mockSharedMemories.length > 0 ? (
        mockSharedMemories.map((memory) => (
          <SharedMemoryCard key={memory.id} memory={memory} />
        ))
      ) : (
        <Card className="text-center p-8 shadow-soft">
          <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center mx-auto mb-4">
            <Share2 className="w-8 h-8 text-white" />
          </div>
          <h3 className="font-semibold mb-2">No shared memories yet</h3>
          <p className="text-muted-foreground text-sm mb-4">
            When friends share memories with you, they'll appear here
          </p>
          <Button variant="outline" size="sm">
            <UserPlus className="w-4 h-4 mr-2" />
            Find Friends
          </Button>
        </Card>
      )}
    </div>
  );
};

export default SharedMemoriesFeed;