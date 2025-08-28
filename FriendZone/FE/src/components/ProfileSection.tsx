import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Camera, Users, Heart, Settings } from "lucide-react";

const ProfileSection = ({ token, user }: { token: string; user: any }) => {
  console.log("ProfileSection: rendering with token:", token, "and user:", user);
  return (
    <div className="space-y-6">
      {/* Profile Header Card */}
      <Card className="shadow-soft">
        <CardContent className="p-6">
          <div className="flex flex-col sm:flex-row items-center sm:items-start space-y-4 sm:space-y-0 sm:space-x-6">
            {/* Avatar */}
            <div className="relative">
              <Avatar className="w-24 h-24 border-4 border-primary-soft shadow-medium">
                <AvatarImage src="/placeholder-avatar.jpg" />
                <AvatarFallback className="bg-gradient-primary text-white text-2xl">
                  You
                </AvatarFallback>
              </Avatar>
              <Button
                size="sm"
                className="absolute -bottom-2 -right-2 w-8 h-8 rounded-full bg-secondary hover:bg-secondary/90 shadow-soft"
              >
                <Camera className="w-4 h-4" />
              </Button>
            </div>

            {/* Profile Info */}
            <div className="flex-1 text-center sm:text-left">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4">
                <div>
                  <h1 className="text-2xl font-bold mb-1">Your Name</h1>
                  <p className="text-muted-foreground">@username</p>
                </div>
                <Button variant="outline" size="sm" className="mt-2 sm:mt-0">
                  <Settings className="w-4 h-4 mr-2" />
                  Edit Profile
                </Button>
              </div>

              <p className="text-sm text-muted-foreground mb-4 max-w-md">
                Capturing life's beautiful moments with amazing friends. 
                Every memory tells a story worth sharing ✨
              </p>

              {/* Stats */}
              <div className="flex justify-center sm:justify-start space-x-6">
                <div className="text-center">
                  <p className="text-lg font-semibold">42</p>
                  <p className="text-xs text-muted-foreground">Memories</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-semibold">18</p>
                  <p className="text-xs text-muted-foreground">Friends</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-semibold">127</p>
                  <p className="text-xs text-muted-foreground">Shared</p>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-4">
        <Card className="hover:shadow-medium transition-shadow cursor-pointer">
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-primary rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="font-semibold">Friends</h3>
                <p className="text-xs text-muted-foreground">Manage connections</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-medium transition-shadow cursor-pointer">
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-secondary rounded-lg flex items-center justify-center">
                <Heart className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="font-semibold">Memories</h3>
                <p className="text-xs text-muted-foreground">Your collection</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Friend Requests */}
      <Card className="shadow-soft">
        <CardHeader>
          <h3 className="font-semibold flex items-center">
            <Users className="w-4 h-4 mr-2 text-primary" />
            Friend Requests
          </h3>
        </CardHeader>
        <CardContent className="space-y-3">
          {/* Sample friend request */}
          <div className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
            <div className="flex items-center space-x-3">
              <Avatar className="w-10 h-10">
                <AvatarFallback className="bg-accent text-accent-foreground">
                  JD
                </AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium text-sm">John Doe</p>
                <p className="text-xs text-muted-foreground">@johndoe</p>
              </div>
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

          <p className="text-center text-sm text-muted-foreground py-4">
            No new friend requests
          </p>
        </CardContent>
      </Card>
    </div>
  );
};

export default ProfileSection;