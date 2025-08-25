import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import Navigation from "@/components/Navigation";
import MemoryFeed from "@/components/MemoryFeed";
import SharedMemoriesFeed from "@/components/SharedMemoriesFeed";
import FriendsSection from "@/components/FriendsSection";
import ProfileSection from "@/components/ProfileSection";
import { Heart, Users, Camera, Sparkles, Share2, User } from "lucide-react";
import heroImage from "@/assets/hero-image.jpg";

const Index = () => {
  const [activeTab, setActiveTab] = useState("memories");

  return (
    <div className="min-h-screen bg-gradient-soft">
      <Navigation />
      
      {/* Hero Section */}
      <section className="pt-24 pb-8 px-4">
        <div className="container mx-auto text-center">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-6xl font-bold mb-6">
              <span className="bg-gradient-hero bg-clip-text text-transparent">
                Share Memories
              </span>
              <br />
              <span className="text-foreground">Build Friendships</span>
            </h1>
            <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
              FriendZone is where authentic connections happen. Share your favorite memories, 
              connect with friends, and create lasting bonds through beautiful moments.
            </p>
            
            {/* Hero Image */}
            <div className="relative mb-8 rounded-2xl overflow-hidden shadow-strong max-w-4xl mx-auto">
              <img 
                src={heroImage} 
                alt="Friends sharing memories together" 
                className="w-full h-64 md:h-96 object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
            </div>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Button variant="hero" size="lg" className="text-lg px-8">
                <Camera className="w-5 h-5 mr-2" />
                Share Your Memory
              </Button>
              <Button variant="outline" size="lg" className="text-lg px-8">
                <Users className="w-5 h-5 mr-2" />
                Find Friends
              </Button>
            </div>
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
              <MemoryFeed />
            </TabsContent>

            <TabsContent value="shared" className="mt-6">
              <SharedMemoriesFeed />
            </TabsContent>

            <TabsContent value="friends" className="mt-6">
              <FriendsSection />
            </TabsContent>

            <TabsContent value="profile" className="mt-6">
              <div className="max-w-2xl mx-auto">
                <ProfileSection />
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </section>
    </div>
  );
};

export default Index;