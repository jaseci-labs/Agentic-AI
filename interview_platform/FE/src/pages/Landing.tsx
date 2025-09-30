import React from 'react';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent } from '@/components/ui/card';
import { ArrowRight, Sparkles, Zap, TrendingUp } from 'lucide-react';
import aiBrainIcon from '@/assets/ai-brain-icon.png';
import userSuccessIcon from '@/assets/user-success-icon.png';
import dashboardIcon from '@/assets/dashboard-icon.png';

const Landing = () => {
  const scrollToFeatures = () => {
    document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      {/* Hero Section */}
      <section className="min-h-[90vh] flex items-center justify-center py-20">
        <div className="container mx-auto px-6 text-center">
          <div className="mb-6 flex justify-center">
            <div className="inline-flex items-center space-x-2 rounded-full border border-border bg-muted/50 px-4 py-2 text-sm font-medium">
              <Sparkles className="h-4 w-4 text-primary" />
              <span>Powered by Advanced AI Technology</span>
            </div>
          </div>

          <h1 className="mb-8 text-5xl sm:text-6xl lg:text-7xl font-bold leading-tight text-foreground">
            The Future of{' '}
            <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
              Interviewing
            </span>{' '}
            is Here
          </h1>

          <p className="mb-10 mx-auto max-w-3xl text-xl text-muted-foreground leading-relaxed">
            Transform your hiring process with AI-powered interviews that provide deep insights, 
            seamless candidate experiences, and powerful analytics.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-16">
            <PlatformButton 
              size="lg" 
              onClick={scrollToFeatures}
              className="group text-lg px-8 py-4"
            >
              Discover the Platform
              <ArrowRight className="ml-2 h-5 w-5 transition-transform group-hover:translate-x-1" />
            </PlatformButton>
            
            <PlatformButton 
              variant="outline"
              size="lg" 
              className="text-lg px-8 py-4"
            >
              Watch Demo
            </PlatformButton>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 max-w-2xl mx-auto">
            <div className="text-center">
              <div className="text-3xl font-bold text-primary mb-2">85%</div>
              <div className="text-sm text-muted-foreground">Faster Hiring</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-accent mb-2">92%</div>
              <div className="text-sm text-muted-foreground">Candidate Satisfaction</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-secondary mb-2">3x</div>
              <div className="text-sm text-muted-foreground">Better Quality Hires</div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-muted/30">
        <div className="container mx-auto px-6">
          <div className="mb-16 text-center">
            <div className="inline-flex items-center space-x-2 rounded-full border border-border bg-background px-4 py-2 text-sm font-medium mb-6">
              <Zap className="h-4 w-4 text-accent" />
              <span>Revolutionary Features</span>
            </div>
            <h2 className="mb-6 text-4xl font-bold text-foreground">
              Revolutionize Your Hiring Process
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-muted-foreground leading-relaxed">
              Our AI-powered platform combines cutting-edge technology with human insight 
              to deliver exceptional interview experiences.
            </p>
          </div>

          <div className="grid gap-8 md:grid-cols-3">
            {/* Feature 1: AI-Powered Analysis */}
            <Card className="border-0 bg-background transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
              <CardContent className="p-8 text-center">
                <div className="mb-6 flex justify-center">
                  <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
                    <img src={aiBrainIcon} alt="AI Brain" className="h-8 w-8 opacity-80" />
                  </div>
                </div>
                <h3 className="mb-4 text-xl font-semibold text-foreground">
                  AI-Powered Analysis
                </h3>
                <p className="text-muted-foreground leading-relaxed mb-4">
                  Advanced AI algorithms analyze candidate responses in real-time, 
                  providing deep insights into skills, communication, and cultural fit.
                </p>
                <div className="flex items-center justify-center text-sm text-primary font-medium">
                  <TrendingUp className="h-4 w-4 mr-2" />
                  95% Accuracy Rate
                </div>
              </CardContent>
            </Card>

            {/* Feature 2: Seamless Candidate Experience */}
            <Card className="border-0 bg-background transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
              <CardContent className="p-8 text-center">
                <div className="mb-6 flex justify-center">
                  <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-accent/10">
                    <img src={userSuccessIcon} alt="User Success" className="h-8 w-8 opacity-80" />
                  </div>
                </div>
                <h3 className="mb-4 text-xl font-semibold text-foreground">
                  Seamless Candidate Experience
                </h3>
                <p className="text-muted-foreground leading-relaxed mb-4">
                  Intuitive, conversational interface that puts candidates at ease 
                  while capturing authentic responses and reducing interview anxiety.
                </p>
                <div className="flex items-center justify-center text-sm text-accent font-medium">
                  <Sparkles className="h-4 w-4 mr-2" />
                  92% Satisfaction Score
                </div>
              </CardContent>
            </Card>

            {/* Feature 3: Powerful Admin Dashboard */}
            <Card className="border-0 bg-background transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
              <CardContent className="p-8 text-center">
                <div className="mb-6 flex justify-center">
                  <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-secondary/10">
                    <img src={dashboardIcon} alt="Dashboard" className="h-8 w-8 opacity-80" />
                  </div>
                </div>
                <h3 className="mb-4 text-xl font-semibold text-foreground">
                  Powerful Admin Dashboard
                </h3>
                <p className="text-muted-foreground leading-relaxed mb-4">
                  Comprehensive analytics, candidate management, and customizable 
                  interview workflows that streamline your entire hiring process.
                </p>
                <div className="flex items-center justify-center text-sm text-secondary font-medium">
                  <Zap className="h-4 w-4 mr-2" />
                  Enterprise Ready
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Call to Action Section */}
      <section className="py-20">
        <div className="container mx-auto px-6 text-center">
          <h2 className="mb-6 text-4xl font-bold text-foreground">
            Ready to Transform Your Hiring Process?
          </h2>
          <p className="mb-8 mx-auto max-w-2xl text-lg text-muted-foreground">
            Join thousands of companies already using AI to find the best talent faster and more efficiently.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <PlatformButton size="lg">
              Start Free Trial
            </PlatformButton>
            <PlatformButton variant="outline" size="lg">
              Schedule Demo
            </PlatformButton>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-border py-12">
        <div className="container mx-auto px-6 text-center">
          <div className="flex items-center justify-center space-x-2 mb-4">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground font-bold text-sm">
              AI
            </div>
            <span className="font-bold text-xl">Interview Platform</span>
          </div>
          <p className="text-muted-foreground mb-4">
            Transforming the future of hiring with intelligent technology.
          </p>
          <div className="flex justify-center space-x-6 text-sm text-muted-foreground">
            <a href="#" className="hover:text-primary transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-primary transition-colors">Terms of Service</a>
            <a href="#" className="hover:text-primary transition-colors">Contact</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Landing;