import React, { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { toast } from "@/components/ui/use-toast";
import Navigation from "@/components/Navigation";
import MemoryFeed from "@/components/MemoryFeed";
import SharedMemoriesFeed from "@/components/SharedMemoriesFeed";
import FriendsSection from "@/components/FriendsSection";
import ProfileSection from "@/components/ProfileSection";
import { Heart, Users, Camera, Share2, User } from "lucide-react";
import heroImage from "@/assets/hero-image.jpg";
import { HOST } from "@/lib/config";

interface User {
  id: string;
  email: string;
  name?: string;
}

const Index = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = React.useState("memories");
  // Log active tab changes
  React.useEffect(() => {
    console.log("Index.tsx: activeTab changed to", activeTab);
  }, [activeTab]);

  // Fetch user data to confirm authentication and display user info
  const { data: user, isLoading, error } = useQuery<User, Error>({
    queryKey: ["user"],
    queryFn: async () => {
      const token = localStorage.getItem("token");
      console.log("Index.tsx: Fetching user data with token:", token); // Debug: Log token
      if (!token) {
        throw new Error("No token found");
      }
      const response = await fetch(`${HOST}/walker/get_profile`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      });
      const data = await response.json();
      console.log("Index.tsx: User data response:", data); // Debug: Log user data
      if (!response.ok) {
        throw new Error(data.message || "Failed to fetch user data");
      }
      return data;
    },
    retry: false,
  });

  // Handle authentication errors
  useEffect(() => {
    if (error) {
      console.error("Index.tsx: User data fetch error:", error.message); // Debug: Log error
      toast({
        title: "Authentication Error",
        description: error.message || "Your session has expired. Please log in again.",
        variant: "destructive",
      });
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      navigate("/login", { replace: true });
    }
  }, [error, navigate]);

  // Logout handler
  const handleLogout = () => {
    console.log("Index.tsx: Logging out user"); // Debug: Log logout
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    toast({
      title: "Logged Out",
      description: "You have been logged out successfully.",
    });
    navigate("/login", { replace: true });
  };

  if (isLoading) {
    console.log("Index.tsx: Rendering loading state"); // Debug: Log loading
    return (
      <div className="min-h-screen flex items-center justify-center">
        <svg
          className="animate-spin h-8 w-8 text-primary"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      </div>
    );
  }

  console.log("Index.tsx: Rendering with user:", user); // Debug: Log user

  return (
    <div className="min-h-screen bg-gradient-soft">
      <Navigation onLogout={handleLogout} /> {/* Pass logout handler */}
      
      {/* Hero Section */}
      <section className="pt-24 pb-8 px-4">
        <div className="container mx-auto text-center">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-6xl font-bold mb-6">
              <span className="bg-gradient-hero bg-clip-text text-transparent">
                Welcome, {user?.name || user?.email || "User"}!
              </span>
              <br />
              <span className="text-foreground">Share Memories, Build Friendships</span>
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

export default Index;