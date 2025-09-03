import React from "react";
import { Button } from "@/components/ui/button";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import Navigation from "@/components/Navigation";
import MemoryFeed from "@/components/MemoryFeed";
import SharedMemoriesFeed from "@/components/SharedMemoriesFeed";
import FriendsSection from "@/components/FriendsSection";
import ProfileSection from "@/components/ProfileSection";
import { Heart, Users, Share2, User } from "lucide-react";
import { User as UserType } from "@/lib/api";

interface MainAppProps {
  user: UserType;
  onLogout: () => void;
}

export const MainApp = ({ user, onLogout }: MainAppProps) => {
  const [activeTab, setActiveTab] = React.useState("memories");

  return (
    <div className="min-h-screen bg-gradient-soft">
      <Navigation onLogout={onLogout} />
      
      {/* Welcome User Section */}
      <section className="pt-24 pb-8 px-4">
        <div className="container mx-auto max-w-4xl text-center">
          <div className="mb-8">
            <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-hero flex items-center justify-center">
              <span className="text-2xl font-bold text-white">
                {(user?.name || user?.email || "U").charAt(0).toUpperCase()}
              </span>
            </div>
            <h1 className="text-4xl font-bold mb-4 text-foreground">
              Welcome back, {user?.name || user?.email?.split('@')[0] || "User"}!
            </h1>
            <p className="text-lg text-muted-foreground mb-8">
              Ready to share more memories and connect with friends?
            </p>
          </div>
        </div>
      </section>

      {/* Main App Interface */}
      <section className="py-8 px-4">
        <div className="container mx-auto max-w-6xl">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-4 max-w-2xl mx-auto mb-8">
              <TabsTrigger value="memories">
                <Heart className="w-4 h-4 mr-2" />
                Memories
              </TabsTrigger>
              <TabsTrigger value="shared">
                <Share2 className="w-4 h-4 mr-2" />
                Shared
              </TabsTrigger>
              <TabsTrigger value="friends">
                <Users className="w-4 h-4 mr-2" />
                Friends
              </TabsTrigger>
              <TabsTrigger value="profile">
                <User className="w-4 h-4 mr-2" />
                Profile
              </TabsTrigger>
            </TabsList>

            <TabsContent value="memories" className="mt-6">
              <MemoryFeed token={localStorage.getItem("token") || ""} user={user} />
            </TabsContent>

            <TabsContent value="shared" className="mt-6">
              <SharedMemoriesFeed token={localStorage.getItem("token") || ""} user={user} />
            </TabsContent>

            <TabsContent value="friends" className="mt-6">
              <FriendsSection token={localStorage.getItem("token") || ""} user={user} />
            </TabsContent>

            <TabsContent value="profile" className="mt-6">
              <div className="max-w-2xl mx-auto">
                <ProfileSection token={localStorage.getItem("token") || ""} user={user} />
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </section>
    </div>
  );
};