import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { User } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { loginCandidate, startInterview, APIError } from '@/services/api';

const CandidateLogin = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email.trim() || !password.trim()) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Please enter both email and password."
      });
      return;
    }

    setLoading(true);
    
    try {
      // Login candidate (matches Streamlit logic)
      const loginData = await loginCandidate(email, password);
      const userId = loginData.user.id;
      const token = loginData.token;

      // Start interview (matches Streamlit logic)
      const interviewData = await startInterview(userId, token);
      
      if (interviewData.status === "started") {
        // Store session data in sessionStorage for the interview component
        sessionStorage.setItem('candidateId', userId);
        sessionStorage.setItem('authToken', token);
        sessionStorage.setItem('currentQuestion', interviewData.question || '');
        sessionStorage.setItem('candidateName', interviewData.candidate_name || '');
        sessionStorage.setItem('jobRole', interviewData.job_role || '');
        
        toast({
          title: "Interview Started",
          description: "Welcome to your AI-powered interview!"
        });
        
        navigate('/candidate/interview');
      }
    } catch (error) {
      const errorMessage = error instanceof APIError ? error.message : 'Could not start interview, check your email and password';
      toast({
        variant: "destructive",
        title: "Login Failed",
        description: errorMessage
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Header showAuth={false} />
      
      <div className="flex min-h-[calc(100vh-4rem)] items-center justify-center px-6 py-12">
        <div className="w-full max-w-md">
          {/* Platform Logo */}
          <div className="mb-8 text-center">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary text-primary-foreground">
              <div className="font-bold text-xl">AI</div>
            </div>
            <h1 className="text-2xl font-bold text-foreground">Interview Platform</h1>
          </div>

          <Card className="card-shadow-lg border-0">
            <CardHeader className="space-y-1 pb-4">
              <div className="flex items-center justify-center space-x-2 mb-2">
                <User className="h-6 w-6 text-primary" />
                <h2 className="text-2xl font-semibold text-foreground">Candidate Interview Login</h2>
              </div>
              <p className="text-sm text-muted-foreground text-center">
                Enter your credentials to begin your interview
              </p>
            </CardHeader>
            <CardContent className="space-y-4">
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email" className="text-sm font-medium">
                    Email
                  </Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="candidate@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="h-12"
                    disabled={loading}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="password" className="text-sm font-medium">
                    Password
                  </Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="Enter your session password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="h-12"
                    disabled={loading}
                  />
                </div>
                <PlatformButton
                  type="submit"
                  className="w-full"
                  loading={loading}
                  size="lg"
                >
                  Login and Begin Interview
                </PlatformButton>
              </form>
              
              <div className="text-center">
                <button
                  type="button"
                  className="text-sm text-accent hover:text-accent-hover underline-offset-4 hover:underline"
                  onClick={() => navigate('/')}
                >
                  Back to Home
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default CandidateLogin;