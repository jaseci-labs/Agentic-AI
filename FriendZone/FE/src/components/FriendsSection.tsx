import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { UserPlus, Users, MessageCircle, UserMinus, Loader2, Mail, Check, X, Search } from "lucide-react";
import { useState, useEffect } from "react";
import { AuthApi, Friend, FriendRequest, UserProfile, ListUsersResponse } from "@/lib/api";
import { toast } from "@/hooks/use-toast";

const FriendsSection = ({ token }: { token: string; user: any }) => {
  const [emailInput, setEmailInput] = useState("");
  const [isSendingRequest, setIsSendingRequest] = useState(false);
  const [friends, setFriends] = useState<Friend[]>([]);
  const [sentRequests, setSentRequests] = useState<FriendRequest[]>([]);
  const [receivedRequests, setReceivedRequests] = useState<FriendRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [usersLoading, setUsersLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchAllData = async () => {
    setIsLoading(true);
    
    // Fetch each endpoint individually with error handling
    try {
      const friendsData = await AuthApi.getFriends(token);
      setFriends(friendsData);
      console.log("Friends data:", friendsData);
    } catch (error) {
      console.error('Failed to fetch friends:', error);
      setFriends([]);
    }
    
    try {
      const sentData = await AuthApi.getSentFriendRequests(token);
      setSentRequests(sentData);
      console.log("Sent requests:", sentData);
    } catch (error) {
      console.error('Failed to fetch sent requests:', error);
      setSentRequests([]);
    }
    
    try {
      const receivedData = await AuthApi.getReceivedFriendRequests(token);
      setReceivedRequests(receivedData);
      console.log("Received requests:", receivedData);
    } catch (error) {
      console.error('Failed to fetch received requests:', error);
      setReceivedRequests([]);
    }
    
    setIsLoading(false);
  };

  useEffect(() => {
    if (token) {
      fetchAllData();
    }
  }, [token]);

  const fetchUsers = async (page: number = 1) => {
    try {
      setUsersLoading(true);
      const response = await AuthApi.listUsers(token, {
        page,
        page_size: 10
      });
      setUsers(response.users);
      setCurrentPage(response.current_page);
      setTotalPages(response.total_pages);
    } catch (error) {
      console.error('Failed to fetch users:', error);
      toast({
        title: "Error",
        description: "Failed to load users.",
        variant: "destructive",
      });
    } finally {
      setUsersLoading(false);
    }
  };

  const handleSendFriendRequestToUser = async (email: string) => {
    setActionLoading(email);
    try {
      const response = await AuthApi.sendFriendRequest(token, email);
      
      toast({
        title: "Friend request sent!",
        description: response.message,
      });
      
      // Refresh data to show the new sent request
      fetchAllData();
    } catch (error) {
      console.error('Failed to send friend request:', error);
      toast({
        title: "Error",
        description: "Failed to send friend request. Please try again.",
        variant: "destructive",
      });
    } finally {
      setActionLoading(null);
    }
  };

  const handleSendFriendRequest = async () => {
    if (!emailInput.trim()) {
      toast({
        title: "Email required",
        description: "Please enter an email address.",
        variant: "destructive",
      });
      return;
    }

    setIsSendingRequest(true);
    try {
      const response = await AuthApi.sendFriendRequest(token, emailInput.trim());
      
      toast({
        title: "Friend request sent!",
        description: response.message,
      });
      
      setEmailInput("");
      // Refresh data to show the new sent request
      fetchAllData();
    } catch (error) {
      console.error('Failed to send friend request:', error);
      toast({
        title: "Error",
        description: "Failed to send friend request. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSendingRequest(false);
    }
  };

  const handleAcceptRequest = async (email: string) => {
    setActionLoading(email);
    try {
      const response = await AuthApi.acceptFriendRequest(token, email);
      
      toast({
        title: "Friend request accepted!",
        description: response.message,
      });
      
      // Refresh data to show updated friends/requests
      fetchAllData();
    } catch (error) {
      console.error('Failed to accept friend request:', error);
      toast({
        title: "Error",
        description: "Failed to accept friend request. Please try again.",
        variant: "destructive",
      });
    } finally {
      setActionLoading(null);
    }
  };

  const handleRejectRequest = async (email: string) => {
    setActionLoading(email);
    try {
      const response = await AuthApi.rejectFriendRequest(token, email);
      
      toast({
        title: "Friend request rejected",
        description: response.message,
      });
      
      // Refresh data to remove the rejected request
      fetchAllData();
    } catch (error) {
      console.error('Failed to reject friend request:', error);
      toast({
        title: "Error",
        description: "Failed to reject friend request. Please try again.",
        variant: "destructive",
      });
    } finally {
      setActionLoading(null);
    }
  };

  const getDisplayName = (person: Friend | FriendRequest) => {
    if (person.first_name || person.last_name) {
      return `${person.first_name} ${person.last_name}`.trim();
    }
    return person.email.split('@')[0];
  };

  const getInitials = (person: Friend | FriendRequest) => {
    if (person.first_name || person.last_name) {
      const firstInitial = person.first_name?.charAt(0) || "";
      const lastInitial = person.last_name?.charAt(0) || "";
      return `${firstInitial}${lastInitial}`.toUpperCase() || "U";
    }
    return person.email.charAt(0).toUpperCase();
  };

  if (isLoading) {
    return (
      <div className="max-w-2xl mx-auto">
        <Card className="shadow-soft">
          <CardContent className="p-8 text-center">
            <Loader2 className="w-8 h-8 animate-spin text-primary mx-auto mb-4" />
            <p className="text-muted-foreground">Loading friends data...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Send Friend Request Card */}
      <Card className="shadow-soft">
        <CardHeader className="pb-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-hero rounded-full flex items-center justify-center">
              <UserPlus className="w-5 h-5 text-white" />
            </div>
            <div>
              <h3 className="text-lg font-semibold">Add Friend</h3>
              <p className="text-sm text-muted-foreground">Send a friend request by email</p>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex space-x-2">
            <Input
              type="email"
              placeholder="friend@example.com"
              value={emailInput}
              onChange={(e) => setEmailInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSendFriendRequest()}
              className="flex-1"
            />
            <Button 
              onClick={handleSendFriendRequest}
              disabled={isSendingRequest || !emailInput.trim()}
              className="bg-gradient-hero hover:opacity-90 px-6"
            >
              {isSendingRequest ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <>
                  <Mail className="w-4 h-4 mr-2" />
                  Send
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Friends Tabs */}
      <Tabs defaultValue="friends" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="friends">
            <Users className="w-4 h-4 mr-2" />
            Friends ({friends.length})
          </TabsTrigger>
          <TabsTrigger value="received">
            <UserPlus className="w-4 h-4 mr-2" />
            Received ({receivedRequests.length})
          </TabsTrigger>
          <TabsTrigger value="sent">
            <Mail className="w-4 h-4 mr-2" />
            Sent ({sentRequests.length})
          </TabsTrigger>
          <TabsTrigger value="find" onClick={() => users.length === 0 && fetchUsers()}>
            <Search className="w-4 h-4 mr-2" />
            Find Users
          </TabsTrigger>
        </TabsList>

        <TabsContent value="friends" className="mt-4">
          <div className="space-y-3">
            {friends.length === 0 ? (
              <Card className="text-center p-6 shadow-soft">
                <div className="w-12 h-12 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-3">
                  <Users className="w-6 h-6 text-white" />
                </div>
                <h3 className="font-semibold mb-1">No friends yet</h3>
                <p className="text-muted-foreground text-sm">
                  Send friend requests to start building your network
                </p>
              </Card>
            ) : (
              friends.map((friend) => (
                <Card key={friend.email} className="shadow-soft">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-3">
                      <Avatar className="w-12 h-12">
                        {friend.profile_picture_url ? (
                          <AvatarImage src={friend.profile_picture_url} />
                        ) : null}
                        <AvatarFallback className="bg-gradient-hero text-white">
                          {getInitials(friend)}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <h3 className="font-semibold">{getDisplayName(friend)}</h3>
                        <p className="text-sm text-muted-foreground">{friend.email}</p>
                      </div>
                      <div className="flex space-x-2">
                        <Button variant="ghost" size="sm">
                          <MessageCircle className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </TabsContent>

        <TabsContent value="received" className="mt-4">
          <div className="space-y-3">
            {receivedRequests.length === 0 ? (
              <Card className="text-center p-6 shadow-soft">
                <div className="w-12 h-12 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-3">
                  <UserPlus className="w-6 h-6 text-white" />
                </div>
                <h3 className="font-semibold mb-1">No friend requests</h3>
                <p className="text-muted-foreground text-sm">
                  Friend requests will appear here
                </p>
              </Card>
            ) : (
              receivedRequests.map((request) => (
                <Card key={request.email} className="shadow-soft">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-3">
                      <Avatar className="w-12 h-12">
                        {request.profile_picture_url ? (
                          <AvatarImage src={request.profile_picture_url} />
                        ) : null}
                        <AvatarFallback className="bg-gradient-hero text-white">
                          {getInitials(request)}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <h3 className="font-semibold">{getDisplayName(request)}</h3>
                        <p className="text-sm text-muted-foreground">{request.email}</p>
                        <p className="text-xs text-muted-foreground">
                          {request.status} • {new Date(request.created_at).toLocaleDateString()}
                        </p>
                      </div>
                      <div className="flex space-x-2">
                        <Button 
                          variant="default"
                          size="sm"
                          onClick={() => handleAcceptRequest(request.email)}
                          disabled={actionLoading === request.email}
                          className="bg-gradient-hero hover:opacity-90"
                        >
                          {actionLoading === request.email ? (
                            <Loader2 className="w-3 h-3 animate-spin" />
                          ) : (
                            <Check className="w-3 h-3" />
                          )}
                        </Button>
                        <Button 
                          variant="outline" 
                          size="sm"
                          onClick={() => handleRejectRequest(request.email)}
                          disabled={actionLoading === request.email}
                        >
                          <X className="w-3 h-3" />
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </TabsContent>

        <TabsContent value="sent" className="mt-4">
          <div className="space-y-3">
            {sentRequests.length === 0 ? (
              <Card className="text-center p-6 shadow-soft">
                <div className="w-12 h-12 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-3">
                  <Mail className="w-6 h-6 text-white" />
                </div>
                <h3 className="font-semibold mb-1">No sent requests</h3>
                <p className="text-muted-foreground text-sm">
                  Friend requests you send will appear here
                </p>
              </Card>
            ) : (
              sentRequests.map((request) => (
                <Card key={request.email} className="shadow-soft">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-3">
                      <Avatar className="w-12 h-12">
                        {request.profile_picture_url ? (
                          <AvatarImage src={request.profile_picture_url} />
                        ) : null}
                        <AvatarFallback className="bg-gradient-hero text-white">
                          {getInitials(request)}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <h3 className="font-semibold">{getDisplayName(request)}</h3>
                        <p className="text-sm text-muted-foreground">{request.email}</p>
                      </div>
                      <div className="flex items-center space-x-2">
                        <span className="text-xs text-muted-foreground bg-muted px-2 py-1 rounded">
                          Pending
                        </span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </TabsContent>

        <TabsContent value="find" className="mt-4">
          <div className="space-y-3">
            {usersLoading ? (
              <Card className="text-center p-6 shadow-soft">
                <div className="w-12 h-12 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-3">
                  <Loader2 className="w-6 h-6 text-white animate-spin" />
                </div>
                <h3 className="font-semibold mb-1">Loading users...</h3>
                <p className="text-muted-foreground text-sm">
                  Finding people you can connect with
                </p>
              </Card>
            ) : users.length === 0 ? (
              <Card className="text-center p-6 shadow-soft">
                <div className="w-12 h-12 bg-gradient-hero rounded-full flex items-center justify-center mx-auto mb-3">
                  <Search className="w-6 h-6 text-white" />
                </div>
                <h3 className="font-semibold mb-1">No users found</h3>
                <p className="text-muted-foreground text-sm">
                  Try refreshing or check back later
                </p>
                <Button 
                  onClick={() => fetchUsers()} 
                  className="mt-3 bg-gradient-hero hover:opacity-90"
                  size="sm"
                >
                  Refresh
                </Button>
              </Card>
            ) : (
              <>
                {users.map((user) => (
                  <Card key={user.email} className="shadow-soft">
                    <CardContent className="p-4">
                      <div className="flex items-center space-x-3">
                        <Avatar className="w-12 h-12">
                          {user.profile_picture_url ? (
                            <AvatarImage src={user.profile_picture_url} />
                          ) : null}
                          <AvatarFallback className="bg-gradient-hero text-white">
                            {user.first_name || user.last_name 
                              ? `${user.first_name?.charAt(0) || ''}${user.last_name?.charAt(0) || ''}`.toUpperCase() || 'U'
                              : user.email.charAt(0).toUpperCase()
                            }
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                          <h3 className="font-semibold">
                            {user.first_name || user.last_name 
                              ? `${user.first_name} ${user.last_name}`.trim()
                              : user.email.split('@')[0]
                            }
                          </h3>
                          <p className="text-sm text-muted-foreground">{user.email}</p>
                        </div>
                        <div className="flex space-x-2">
                          <Button 
                            variant="default"
                            size="sm"
                            onClick={() => handleSendFriendRequestToUser(user.email)}
                            disabled={actionLoading === user.email}
                            className="bg-gradient-hero hover:opacity-90"
                          >
                            {actionLoading === user.email ? (
                              <Loader2 className="w-3 h-3 animate-spin" />
                            ) : (
                              <>
                                <UserPlus className="w-3 h-3 mr-1" />
                                Add
                              </>
                            )}
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
                
                {/* Pagination */}
                {totalPages > 1 && (
                  <div className="flex justify-center space-x-2 pt-4">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => fetchUsers(currentPage - 1)}
                      disabled={currentPage === 1 || usersLoading}
                    >
                      Previous
                    </Button>
                    <span className="flex items-center px-3 text-sm text-muted-foreground">
                      Page {currentPage} of {totalPages}
                    </span>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => fetchUsers(currentPage + 1)}
                      disabled={currentPage === totalPages || usersLoading}
                    >
                      Next
                    </Button>
                  </div>
                )}
              </>
            )}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default FriendsSection;