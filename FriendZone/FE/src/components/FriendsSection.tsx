import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { UserPlus, Users, Search, MessageCircle, UserMinus } from "lucide-react";
import { useState } from "react";

interface Friend {
  id: string;
  name: string;
  username: string;
  avatar: string;
  mutualFriends: number;
  isOnline: boolean;
}

interface FriendRequest {
  id: string;
  name: string;
  username: string;
  avatar: string;
  mutualFriends: number;
  timestamp: string;
}

const mockFriends: Friend[] = [
  {
    id: "1",
    name: "Sarah Chen",
    username: "sarahc",
    avatar: "/placeholder-avatar.jpg",
    mutualFriends: 8,
    isOnline: true
  },
  {
    id: "2", 
    name: "Alex Johnson",
    username: "alexj",
    avatar: "/placeholder-avatar.jpg",
    mutualFriends: 12,
    isOnline: false
  },
  {
    id: "3",
    name: "Maya Rodriguez", 
    username: "mayar",
    avatar: "/placeholder-avatar.jpg",
    mutualFriends: 5,
    isOnline: true
  }
];

const mockRequests: FriendRequest[] = [
  {
    id: "1",
    name: "John Doe",
    username: "johndoe",
    avatar: "/placeholder-avatar.jpg", 
    mutualFriends: 3,
    timestamp: "2 hours ago"
  },
  {
    id: "2",
    name: "Emma Wilson",
    username: "emmaw",
    avatar: "/placeholder-avatar.jpg",
    mutualFriends: 7,
    timestamp: "1 day ago" 
  }
];

const FriendCard = ({ friend }: { friend: Friend }) => {
  return (
    <Card className="hover:shadow-medium transition-all">
      <CardContent className="p-4">
        <div className="flex items-center space-x-3">
          <div className="relative">
            <Avatar className="w-12 h-12">
              <AvatarImage src={friend.avatar} />
              <AvatarFallback className="bg-primary-soft text-primary">
                {friend.name.charAt(0)}
              </AvatarFallback>
            </Avatar>
            {friend.isOnline && (
              <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 rounded-full border-2 border-card"></div>
            )}
          </div>
          
          <div className="flex-1">
            <h3 className="font-semibold">{friend.name}</h3>
            <p className="text-sm text-muted-foreground">@{friend.username}</p>
            <p className="text-xs text-muted-foreground">{friend.mutualFriends} mutual friends</p>
          </div>
          
          <div className="flex space-x-2">
            <Button variant="ghost" size="sm">
              <MessageCircle className="w-4 h-4" />
            </Button>
            <Button variant="outline" size="sm">
              <UserMinus className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

const RequestCard = ({ request }: { request: FriendRequest }) => {
  return (
    <Card className="hover:shadow-medium transition-all">
      <CardContent className="p-4">
        <div className="flex items-center space-x-3">
          <Avatar className="w-12 h-12">
            <AvatarImage src={request.avatar} />
            <AvatarFallback className="bg-accent text-accent-foreground">
              {request.name.charAt(0)}
            </AvatarFallback>
          </Avatar>
          
          <div className="flex-1">
            <h3 className="font-semibold">{request.name}</h3>
            <p className="text-sm text-muted-foreground">@{request.username}</p>
            <p className="text-xs text-muted-foreground">{request.mutualFriends} mutual friends • {request.timestamp}</p>
          </div>
          
          <div className="flex space-x-2">
            <Button variant="hero" size="sm">
              Accept
            </Button>
            <Button variant="outline" size="sm">
              Decline
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

const FriendsSection = ({ token, user }: { token: string; user: any }) => {
  console.log("FriendsSection: rendering with token:", token, "and user:", user);
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-6">
        <h2 className="text-2xl font-bold mb-2">Friends</h2>
        <p className="text-muted-foreground">Manage your connections and find new friends</p>
      </div>

      <Tabs defaultValue="friends" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="friends">
            <Users className="w-4 h-4 mr-2" />
            My Friends ({mockFriends.length})
          </TabsTrigger>
          <TabsTrigger value="requests">
            <UserPlus className="w-4 h-4 mr-2" />
            Requests ({mockRequests.length})
          </TabsTrigger>
          <TabsTrigger value="search">
            <Search className="w-4 h-4 mr-2" />
            Find Friends
          </TabsTrigger>
        </TabsList>

        <TabsContent value="friends" className="mt-6">
          <div className="space-y-4">
            {mockFriends.map((friend) => (
              <FriendCard key={friend.id} friend={friend} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="requests" className="mt-6">
          <div className="space-y-4">
            {mockRequests.length > 0 ? (
              mockRequests.map((request) => (
                <RequestCard key={request.id} request={request} />
              ))
            ) : (
              <Card className="text-center p-8 shadow-soft">
                <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center mx-auto mb-4">
                  <UserPlus className="w-8 h-8 text-white" />
                </div>
                <h3 className="font-semibold mb-2">No friend requests</h3>
                <p className="text-muted-foreground text-sm">
                  New friend requests will appear here
                </p>
              </Card>
            )}
          </div>
        </TabsContent>

        <TabsContent value="search" className="mt-6">
          <Card className="shadow-soft">
            <CardHeader>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input
                  placeholder="Search for friends by name or username..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10"
                />
              </div>
            </CardHeader>
            <CardContent>
              {searchQuery ? (
                <div className="text-center py-8">
                  <p className="text-muted-foreground">
                    Search results for "{searchQuery}" will appear here
                  </p>
                </div>
              ) : (
                <div className="text-center py-8">
                  <div className="w-16 h-16 bg-gradient-secondary rounded-full flex items-center justify-center mx-auto mb-4">
                    <Search className="w-8 h-8 text-white" />
                  </div>
                  <h3 className="font-semibold mb-2">Discover New Friends</h3>
                  <p className="text-muted-foreground text-sm">
                    Start typing to search for people you may know
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default FriendsSection;