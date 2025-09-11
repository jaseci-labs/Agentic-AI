import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { MessageCircle, Share2, Clock, UserPlus, X, Calendar, MapPin, Users, ImageIcon, Loader2 } from "lucide-react";
import { useState, useEffect } from "react";
import { AuthApi, SharedMemoryItem } from "@/lib/api";
import { toast } from "@/hooks/use-toast";


const SharedMemoryCard = ({ sharedMemoryItem, token, user, onReject }: { 
  sharedMemoryItem: SharedMemoryItem; 
  token: string; 
  user: any;
  onReject: (memoryId: string) => void;
}) => {
  const { memory, shared_by } = sharedMemoryItem;
  const [showDetails, setShowDetails] = useState(false);
  const [isRejecting, setIsRejecting] = useState(false);

  const handleReject = async () => {
    setIsRejecting(true);
    try {
      await AuthApi.rejectMemory(token, { memory_ids: [memory.memory_id] });
      toast({
        title: "Memory rejected",
        description: "The shared memory has been removed from your feed.",
      });
      onReject(memory.memory_id);
    } catch (error) {
      console.error('Failed to reject memory:', error);
      toast({
        title: "Error",
        description: "Failed to reject memory. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsRejecting(false);
    }
  };

  const getDisplayName = () => {
    if (shared_by.first_name || shared_by.last_name) {
      return `${shared_by.first_name} ${shared_by.last_name}`.trim();
    }
    if (shared_by.email) {
      return shared_by.email.split('@')[0];
    }
    return "Unknown User";
  };

  const getInitials = () => {
    if (shared_by.first_name && shared_by.last_name) {
      return `${shared_by.first_name.charAt(0)}${shared_by.last_name.charAt(0)}`.toUpperCase();
    }
    if (shared_by.first_name) {
      return shared_by.first_name.charAt(0).toUpperCase();
    }
    if (shared_by.email) {
      return shared_by.email.charAt(0).toUpperCase();
    }
    return "U";
  };

  return (
    <Card className="mb-6 shadow-soft hover:shadow-medium transition-all">
      {/* Shared Memory Header */}
      <div className="p-4">
        {/* Shared by indicator */}
        <div className="flex items-center justify-between mb-3 p-2 bg-accent/50 rounded-lg">
          <div className="flex items-center space-x-2">
            <Share2 className="w-4 h-4 text-primary" />
            <span className="text-sm text-muted-foreground">
              Shared memory from <span className="font-medium text-foreground">{getDisplayName()}</span>
            </span>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={handleReject}
            disabled={isRejecting}
            className="text-muted-foreground hover:text-destructive w-6 h-6 p-0"
          >
            {isRejecting ? (
              <Loader2 className="w-3 h-3 animate-spin" />
            ) : (
              <X className="w-3 h-3" />
            )}
          </Button>
        </div>
        
        {/* Original poster */}
        <div className="flex items-center space-x-3">
          <Avatar className="w-10 h-10">
            {shared_by.profile_picture_url ? (
              <AvatarImage src={shared_by.profile_picture_url} alt={getDisplayName()} />
            ) : null}
            <AvatarFallback className="bg-primary-soft text-primary">
              {getInitials()}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1">
            <h3 className="font-semibold text-sm">{getDisplayName()}</h3>
            <div className="flex items-center text-xs text-muted-foreground">
              <Clock className="w-3 h-3 mr-1" />
              {memory.created_at ? new Date(memory.created_at).toLocaleDateString() : memory.when}
            </div>
          </div>
        </div>
      </div>

      {/* Memory Image */}
      <div className="relative aspect-square bg-muted rounded-lg mx-4 overflow-hidden">
        {memory.image_url ? (
          <img 
            src={memory.image_url} 
            alt={memory.summary || "Shared Memory"} 
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center text-muted-foreground">
              <div className="w-16 h-16 bg-gradient-soft rounded-full flex items-center justify-center mb-2 mx-auto">
                <ImageIcon className="w-8 h-8" />
              </div>
              <p className="text-sm">Shared Memory</p>
            </div>
          </div>
        )}
      </div>

      {/* Memory Content */}
      <CardContent className="p-4">
        {memory.summary && <p className="text-sm mb-4">{memory.summary}</p>}
        
        {/* Memory Details */}
        {memory.when && (
          <div className="flex items-center text-xs text-muted-foreground mb-2">
            <Calendar className="w-3 h-3 mr-2" />
            {memory.when}
          </div>
        )}
        {memory.where && memory.where.length > 0 && (
          <div className="flex items-center text-xs text-muted-foreground mb-2">
            <MapPin className="w-3 h-3 mr-2" />
            {memory.where.join(', ')}
          </div>
        )}
        {memory.who && memory.who.length > 0 && (
          <div className="flex items-center text-xs text-muted-foreground mb-4">
            <Users className="w-3 h-3 mr-2" />
            {memory.who.join(', ')}
          </div>
        )}
        
        {/* Action Buttons */}
        <div className="flex items-center space-x-4">
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={() => setShowDetails(!showDetails)}
            className="text-muted-foreground hover:text-primary"
          >
            <MessageCircle className="w-4 h-4 mr-2" />
            {showDetails ? 'Hide' : 'Show'} conversation
          </Button>
        </div>

        {/* Conversation Details */}
        {showDetails && memory.conversation && memory.conversation.length > 0 && (
          <div className="mt-4 pt-4 border-t border-border">
            <p className="text-xs text-muted-foreground mb-2">Conversation</p>
            <div className="space-y-2">
              {memory.conversation.map((msg, index) => (
                <div key={index} className="text-xs">
                  {msg.user && (
                    <div className="mb-1">
                      <span className="font-medium text-primary">{getDisplayName()}:</span> {msg.user}
                    </div>
                  )}
                  <div>
                    <span className="font-medium text-accent-foreground">Assistant:</span> {msg.assistant}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

const SharedMemoriesFeed = ({ token, user }: { token: string; user: any }) => {
  const [sharedMemories, setSharedMemories] = useState<SharedMemoryItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  console.log("SharedMemoriesFeed: rendering with token:", token, "and user:", user);

  const fetchSharedMemories = async () => {
    try {
      setIsLoading(true);
      const fetchedMemories = await AuthApi.getSharedMemories(token);
      setSharedMemories(fetchedMemories);
    } catch (error) {
      console.error('Failed to fetch shared memories:', error);
      setSharedMemories([]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleRejectMemory = (memoryId: string) => {
    setSharedMemories(prev => prev.filter(item => item.memory.memory_id !== memoryId));
  };

  useEffect(() => {
    if (token) {
      fetchSharedMemories();
    }
  }, [token]);

  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h2 className="text-2xl font-bold mb-2">Shared With You</h2>
        <p className="text-muted-foreground">Memories your friends have shared with you</p>
      </div>
      
      {isLoading ? (
        <Card className="p-8 text-center">
          <div className="text-muted-foreground">
            <div className="w-6 h-6 mx-auto mb-4 animate-spin">⚪</div>
            <p className="text-sm">Loading shared memories...</p>
          </div>
        </Card>
      ) : sharedMemories.length > 0 ? (
        sharedMemories.map((sharedMemoryItem) => (
          <SharedMemoryCard 
            key={sharedMemoryItem.memory.memory_id} 
            sharedMemoryItem={sharedMemoryItem} 
            token={token}
            user={user}
            onReject={handleRejectMemory}
          />
        ))
      ) : (
        <Card className="text-center p-8 shadow-soft">
          <div className="w-16 h-16 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-4">
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