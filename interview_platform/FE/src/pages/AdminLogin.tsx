import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Header } from '@/components/Layout/Header';
import { PlatformButton } from '@/components/ui/platform-button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Building2 } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { loginAdmin, APIError } from '@/services/api';

const AdminLogin = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email || !password) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Please fill in all fields."
      });
      return;
    }

    setLoading(true);
    
    try {
      const response = await loginAdmin(email, password);
      
      // Store admin token in localStorage for session management
      localStorage.setItem('adminToken', response.token);
      localStorage.setItem('adminUser', JSON.stringify(response.user));
      
      toast({
        title: "Login Successful",
        description: "Welcome to the Admin Portal!"
      });
      navigate('/admin/portal');
    } catch (error) {
      toast({
        variant: "destructive",
        title: "Login Failed",
        description: error instanceof APIError ? error.message : "Invalid credentials. Please try again."
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
                <Building2 className="h-6 w-6 text-secondary" />
                <h2 className="text-2xl font-semibold text-foreground">Admin Portal Login</h2>
              </div>
              <p className="text-sm text-muted-foreground text-center">
                Enter your credentials to access the admin dashboard
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
                    placeholder="admin@company.com"
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
                    placeholder="Enter your password"
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
                  Login
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

export default AdminLogin;