import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { MessageCircle, Share2, Clock, ImageIcon, Calendar, MapPin, Users, X, Loader2 } from "lucide-react";
import { useState, useEffect } from "react";
import { AuthApi, SavedMemory, Friend } from "@/lib/api";
import { toast } from "@/hooks/use-toast";

export interface Memory {
  id: string;
  user: {
    name: string;
    avatar?: string;
    username: string;
  };
  image: string;
  caption?: string;
  timestamp: string;
  comments: number;
}

const MemoryCard = ({ memory, user, token, friends, onUpdate }: { 
  memory: SavedMemory; 
  user: any; 
  token: string;
  friends: Friend[];
  onUpdate: () => void;
}) => {
  const [showDetails, setShowDetails] = useState(false);
  const [showShareDialog, setShowShareDialog] = useState(false);
  const [selectedFriends, setSelectedFriends] = useState<string[]>([]);
  const [isSharing, setIsSharing] = useState(false);

  const handleShare = async () => {
    if (selectedFriends.length === 0) {
      toast({
        title: "No friends selected",
        description: "Please select at least one friend to share with.",
        variant: "destructive",
      });
      return;
    }

    setIsSharing(true);
    try {
      const response = await AuthApi.shareMemory(token, {
        memory_id: memory.memory_id,
        share_with: selectedFriends
      });

      const successCount = response.success.length;
      const failedCount = response.failed.length;

      let message = `Memory shared with ${successCount} friend${successCount !== 1 ? 's' : ''}`;
      if (failedCount > 0) {
        message += `. Failed to share with ${failedCount} friend${failedCount !== 1 ? 's' : ''}`;
      }

      toast({
        title: "Memory shared!",
        description: message,
        variant: successCount > 0 ? "default" : "destructive",
      });

      setShowShareDialog(false);
      setSelectedFriends([]);
      onUpdate();
    } catch (error) {
      console.error('Failed to share memory:', error);
      toast({
        title: "Error",
        description: "Failed to share memory. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSharing(false);
    }
  };

  const handleFriendToggle = (friendEmail: string) => {
    setSelectedFriends(prev => 
      prev.includes(friendEmail) 
        ? prev.filter(email => email !== friendEmail)
        : [...prev, friendEmail]
    );
  };

  return (
    <Card className="mb-6 shadow-soft hover:shadow-medium transition-all">
      {/* Memory Header */}
      <div className="p-4 flex items-center space-x-3">
        <Avatar className="w-10 h-10">
          <AvatarFallback className="bg-primary-soft text-primary">
            {(user?.name || user?.email || "U").charAt(0).toUpperCase()}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <h3 className="font-semibold text-sm">{user?.name || user?.email?.split('@')[0] || "You"}</h3>
          <div className="flex items-center text-xs text-muted-foreground">
            <Clock className="w-3 h-3 mr-1" />
            {memory.created_at ? new Date(memory.created_at).toLocaleDateString() : memory.when}
          </div>
        </div>
      </div>

      {/* Memory Image */}
      <div className="relative aspect-square bg-muted rounded-lg mx-4 overflow-hidden">
        {memory.image_url ? (
          <img 
            src={memory.image_url} 
            alt={memory.summary || "Memory"} 
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center text-muted-foreground">
              <div className="w-16 h-16 bg-gradient-soft rounded-full flex items-center justify-center mb-2 mx-auto">
                <ImageIcon className="w-8 h-8" />
              </div>
              <p className="text-sm">Memory Photo</p>
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
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={() => setShowShareDialog(true)}
            className="text-muted-foreground hover:text-primary"
          >
            <Share2 className="w-4 h-4 mr-2" />
            Share
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
                      <span className="font-medium text-primary">You:</span> {msg.user}
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

      {/* Share Dialog */}
      <Dialog open={showShareDialog} onOpenChange={setShowShareDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Share2 className="w-5 h-5" />
              Share Memory with Friends
            </DialogTitle>
          </DialogHeader>
          <div className="py-4">
            {friends.length === 0 ? (
              <p className="text-muted-foreground text-center py-4">
                You need to add friends first to share memories.
              </p>
            ) : (
              <div className="space-y-3">
                <p className="text-sm text-muted-foreground mb-3">
                  Select friends to share this memory with:
                </p>
                {friends.map((friend) => (
                  <div key={friend.email} className="flex items-center space-x-3">
                    <Checkbox
                      id={friend.email}
                      checked={selectedFriends.includes(friend.email)}
                      onCheckedChange={() => handleFriendToggle(friend.email)}
                    />
                    <div className="flex items-center space-x-2 flex-1">
                      <Avatar className="w-8 h-8">
                        {friend.profile_picture_url ? (
                          <AvatarImage src={friend.profile_picture_url} />
                        ) : null}
                        <AvatarFallback className="bg-gradient-hero text-white text-xs">
                          {friend.first_name || friend.last_name 
                            ? `${friend.first_name?.charAt(0) || ''}${friend.last_name?.charAt(0) || ''}`.toUpperCase() || 'U'
                            : friend.email.charAt(0).toUpperCase()
                          }
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="text-sm font-medium">
                          {friend.first_name || friend.last_name 
                            ? `${friend.first_name || ''} ${friend.last_name || ''}`.trim()
                            : friend.email.split('@')[0]
                          }
                        </p>
                        <p className="text-xs text-muted-foreground">{friend.email}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowShareDialog(false)} disabled={isSharing}>
              Cancel
            </Button>
            <Button 
              onClick={handleShare} 
              disabled={isSharing || selectedFriends.length === 0 || friends.length === 0}
              className="bg-gradient-hero hover:opacity-90"
            >
              {isSharing ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Sharing...
                </>
              ) : (
                <>
                  <Share2 className="w-4 h-4 mr-2" />
                  Share Memory
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Card>
  );
};

interface MemoryFeedProps {
  token: string;
  user: any;
  memoriesUpdateTrigger?: number;
}

const MemoryFeed = ({ token, user, memoriesUpdateTrigger }: MemoryFeedProps) => {
  const [memories, setMemories] = useState<SavedMemory[]>([]);
  const [friends, setFriends] = useState<Friend[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  console.log("MemoryFeed: rendering with token:", token, "and user:", user);

  const fetchMemories = async () => {
    try {
      setIsLoading(true);
      const fetchedMemories = await AuthApi.getSavedMemories(token);
      setMemories(fetchedMemories);
    } catch (error) {
      console.error('Failed to fetch memories:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchFriends = async () => {
    try {
      const fetchedFriends = await AuthApi.getFriends(token);
      setFriends(fetchedFriends);
    } catch (error) {
      console.error('Failed to fetch friends:', error);
      setFriends([]);
    }
  };

  const fetchAllData = async () => {
    await Promise.all([fetchMemories(), fetchFriends()]);
  };

  useEffect(() => {
    if (token) {
      fetchAllData();
    }
  }, [token]);

  useEffect(() => {
    if (memoriesUpdateTrigger !== undefined && memoriesUpdateTrigger > 0) {
      fetchAllData();
    }
  }, [memoriesUpdateTrigger]);
  
  return (
    <div>
      <div className="mb-6">
        <h2 className="text-2xl font-bold mb-2">Memories</h2>
        <p className="text-muted-foreground">Your saved memories</p>
      </div>
      
      {isLoading ? (
        <Card className="p-8 text-center">
          <div className="text-muted-foreground">
            <div className="w-6 h-6 mx-auto mb-4 animate-spin">⚪</div>
            <p className="text-sm">Loading memories...</p>
          </div>
        </Card>
      ) : memories.length === 0 ? (
        <Card className="p-8 text-center">
          <div className="text-muted-foreground">
            <ImageIcon className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <h3 className="text-lg font-medium mb-2">No memories yet</h3>
            <p className="text-sm">Upload your first memory to get started!</p>
          </div>
        </Card>
      ) : (
        memories.map((memory) => (
          <MemoryCard 
            key={memory.memory_id} 
            memory={memory} 
            user={user} 
            token={token}
            friends={friends}
            onUpdate={fetchAllData}
          />
        ))
      )}
    </div>
  );
};

export default MemoryFeed;