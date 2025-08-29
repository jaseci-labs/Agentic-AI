import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Heart, Users, Camera, Share2, LogIn, UserPlus } from "lucide-react";
import heroImage from "@/assets/hero-image.jpg";

export const LandingPage = () => {
  return (
    <div className="min-h-screen bg-gradient-soft">
      {/* Navigation for non-authenticated users */}
      <nav className="fixed top-0 left-0 right-0 bg-background/80 backdrop-blur-lg border-b border-border z-50">
        <div className="container mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Heart className="w-8 h-8 text-primary" />
            <span className="text-xl font-bold bg-gradient-hero bg-clip-text text-transparent">
              FriendZone
            </span>
          </div>
          <div className="flex items-center space-x-4">
            <Button variant="ghost" asChild>
              <Link to="/login">
                <LogIn className="w-4 h-4 mr-2" />
                Log In
              </Link>
            </Button>
            <Button variant="hero" asChild>
              <Link to="/login">
                <UserPlus className="w-4 h-4 mr-2" />
                Sign Up
              </Link>
            </Button>
          </div>
        </div>
      </nav>
      
      {/* Hero Section */}
      <section className="pt-24 pb-16 px-4">
        <div className="container mx-auto text-center">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-7xl font-bold mb-6">
              <span className="bg-gradient-hero bg-clip-text text-transparent">
                FriendZone
              </span>
            </h1>
            <p className="text-2xl text-foreground mb-8 font-medium">
              Share Memories, Build Friendships
            </p>
            <p className="text-lg text-muted-foreground mb-12 max-w-2xl mx-auto">
              Where authentic connections happen through beautiful moments and shared experiences.
            </p>
            
            {/* Hero Image */}
            <div className="relative mb-12 rounded-3xl overflow-hidden shadow-strong max-w-5xl mx-auto">
              <img 
                src={heroImage} 
                alt="Friends sharing memories together" 
                className="w-full h-80 md:h-[500px] object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />
              <div className="absolute bottom-8 left-8 right-8 text-white text-left">
                <h3 className="text-2xl md:text-3xl font-bold mb-2">Create Beautiful Memories</h3>
                <p className="text-lg opacity-90">Capture and share your most precious moments with friends</p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Button variant="hero" size="lg" className="text-lg px-12 py-6" asChild>
                <Link to="/login">
                  <LogIn className="w-6 h-6 mr-2" />
                  Get Started
                </Link>
              </Button>
              <Button variant="outline" size="lg" className="text-lg px-12 py-6 border-2" asChild>
                <Link to="/login">
                  <UserPlus className="w-6 h-6 mr-2" />
                  Join FriendZone
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Share Your Memory Section */}
      <section className="py-16 px-4 bg-white/50">
        <div className="container mx-auto max-w-4xl text-center">
          <div className="mb-8">
            <Camera className="w-16 h-16 mx-auto mb-4 text-primary" />
            <h2 className="text-4xl font-bold mb-4 text-foreground">Share Your Memory</h2>
            <p className="text-lg text-muted-foreground mb-8 max-w-2xl mx-auto">
              Upload photos, add stories, and preserve your favorite moments. Every memory tells a story worth sharing.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8 mb-8">
            <Card className="p-6 border-2 hover:border-primary/50 transition-colors">
              <CardContent className="pt-4">
                <Camera className="w-8 h-8 mb-4 text-primary mx-auto" />
                <h3 className="font-semibold mb-2">Upload Photos</h3>
                <p className="text-sm text-muted-foreground">Share your beautiful moments with high-quality photos</p>
              </CardContent>
            </Card>
            <Card className="p-6 border-2 hover:border-primary/50 transition-colors">
              <CardContent className="pt-4">
                <Heart className="w-8 h-8 mb-4 text-primary mx-auto" />
                <h3 className="font-semibold mb-2">Add Stories</h3>
                <p className="text-sm text-muted-foreground">Tell the story behind each memory</p>
              </CardContent>
            </Card>
            <Card className="p-6 border-2 hover:border-primary/50 transition-colors">
              <CardContent className="pt-4">
                <Share2 className="w-8 h-8 mb-4 text-primary mx-auto" />
                <h3 className="font-semibold mb-2">Share & Connect</h3>
                <p className="text-sm text-muted-foreground">Connect with friends through shared experiences</p>
              </CardContent>
            </Card>
          </div>
          <Button variant="hero" size="lg" className="text-lg px-12 py-6 rounded-xl" asChild>
            <Link to="/login">
              <Camera className="w-6 h-6 mr-2" />
              Start Sharing Memories
            </Link>
          </Button>
        </div>
      </section>

      {/* Find Friends Section */}
      <section className="py-16 px-4">
        <div className="container mx-auto max-w-4xl text-center">
          <div className="mb-8">
            <Users className="w-16 h-16 mx-auto mb-4 text-primary" />
            <h2 className="text-4xl font-bold mb-4 text-foreground">Find Friends</h2>
            <p className="text-lg text-muted-foreground mb-8 max-w-2xl mx-auto">
              Connect with like-minded people, discover new friendships, and build meaningful relationships in our community.
            </p>
          </div>
          <div className="grid md:grid-cols-2 gap-8 mb-8">
            <Card className="p-8 border-2 hover:border-primary/50 transition-colors">
              <CardContent className="pt-4">
                <Users className="w-12 h-12 mb-4 text-primary mx-auto" />
                <h3 className="text-xl font-semibold mb-3">Discover People</h3>
                <p className="text-muted-foreground">Find people who share your interests and experiences</p>
              </CardContent>
            </Card>
            <Card className="p-8 border-2 hover:border-primary/50 transition-colors">
              <CardContent className="pt-4">
                <Heart className="w-12 h-12 mb-4 text-primary mx-auto" />
                <h3 className="text-xl font-semibold mb-3">Build Connections</h3>
                <p className="text-muted-foreground">Create lasting friendships through shared memories</p>
              </CardContent>
            </Card>
          </div>
          <Button variant="outline" size="lg" className="text-lg px-12 py-6 rounded-xl border-2 hover:bg-primary/10" asChild>
            <Link to="/login">
              <Users className="w-6 h-6 mr-2" />
              Explore Friends
            </Link>
          </Button>
        </div>
      </section>

      {/* Call to Action Section */}
      <section className="py-16 px-4 bg-gradient-to-r from-primary/10 to-purple-100/50">
        <div className="container mx-auto max-w-4xl text-center">
          <h2 className="text-4xl font-bold mb-4 text-foreground">Ready to Get Started?</h2>
          <p className="text-lg text-muted-foreground mb-8">
            Join thousands of people who are already sharing memories and building friendships on FriendZone.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button variant="hero" size="lg" className="text-lg px-12 py-6" asChild>
              <Link to="/login">
                <LogIn className="w-6 h-6 mr-2" />
                Sign In
              </Link>
            </Button>
            <Button variant="outline" size="lg" className="text-lg px-12 py-6 border-2" asChild>
              <Link to="/login">
                <UserPlus className="w-6 h-6 mr-2" />
                Create Account
              </Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
};