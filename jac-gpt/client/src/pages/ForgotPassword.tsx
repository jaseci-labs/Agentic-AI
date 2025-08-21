import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, ArrowLeft } from 'lucide-react';

const ForgotPassword = () => {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/forgot_password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to send reset email');
      }

      setIsSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-900 px-4">
        <Card className="w-full max-w-md bg-gray-800 border-gray-700">
          <CardHeader className="space-y-1">
            <div className="flex justify-center mb-4">
              <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
            </div>
            <CardTitle className="text-2xl text-center text-white">Check your email</CardTitle>
            <CardDescription className="text-center text-gray-400">
              We've sent a password reset link to {email}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Alert>
              <AlertDescription>
                If you don't see the email in your inbox, please check your spam folder.
              </AlertDescription>
            </Alert>
          </CardContent>
          <CardFooter>
            <Button variant="outline" className="w-full bg-gray-700 border-gray-600 text-white hover:bg-gray-600" asChild>
              <Link to="/login">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back to login
              </Link>
            </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900 px-4">
      <Card className="w-full max-w-md bg-gray-800 border-gray-700">
        <CardHeader className="space-y-1">
          <div className="flex justify-center mb-4">
            <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
          </div>
          <CardTitle className="text-2xl text-center text-white">Forgot password?</CardTitle>
          <CardDescription className="text-center text-gray-400">
            Enter your email and we'll send you a reset link
          </CardDescription>
        </CardHeader>
        <form onSubmit={handleSubmit}>
          <CardContent className="space-y-4">
            {error && (
              <Alert variant="destructive">
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}
            <div className="space-y-2">
              <Label htmlFor="email" className="text-gray-300">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={isLoading}
                className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-4">
            <Button 
              type="submit" 
              className="w-full bg-orange-600 hover:bg-orange-700 text-white" 
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Sending reset link...
                </>
              ) : (
                'Send reset link'
              )}
            </Button>
            <Button variant="outline" className="w-full bg-gray-700 border-gray-600 text-white hover:bg-gray-600" asChild>
              <Link to="/login">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back to login
              </Link>
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
};

export default ForgotPassword;
