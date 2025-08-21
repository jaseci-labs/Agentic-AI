import { useState, useEffect } from 'react';
import { Link, useSearchParams, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, CheckCircle, XCircle } from 'lucide-react';

const VerifyEmail = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(true);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const token = searchParams.get('token');

  useEffect(() => {
    if (!token) {
      setError('Invalid verification link');
      setIsLoading(false);
      return;
    }

    const verifyEmail = async () => {
      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/verify`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ token }),
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.message || 'Failed to verify email');
        }

        setIsSuccess(true);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Verification failed');
      } finally {
        setIsLoading(false);
      }
    };

    verifyEmail();
  }, [token]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
        <Card className="w-full max-w-md">
          <CardHeader className="space-y-1">
            <div className="flex justify-center mb-4">
              <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
            </div>
            <CardTitle className="text-2xl text-center">Verifying your email</CardTitle>
            <CardDescription className="text-center">
              Please wait while we verify your email address
            </CardDescription>
          </CardHeader>
          <CardContent className="flex justify-center">
            <Loader2 className="h-8 w-8 animate-spin" />
          </CardContent>
        </Card>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
        <Card className="w-full max-w-md">
          <CardHeader className="space-y-1">
            <div className="flex justify-center mb-4">
              <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
            </div>
            <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
              <CheckCircle className="h-6 w-6 text-green-500" />
              Email verified!
            </CardTitle>
            <CardDescription className="text-center">
              Your email has been successfully verified
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Alert>
              <AlertDescription>
                You can now sign in to your account and start using JAC GPT.
              </AlertDescription>
            </Alert>
          </CardContent>
          <CardFooter>
            <Button className="w-full" asChild>
              <Link to="/login">
                Sign in to your account
              </Link>
            </Button>
          </CardFooter>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className="flex justify-center mb-4">
            <img src="/logo.png" alt="JAC GPT" className="h-12 w-12" />
          </div>
          <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
            <XCircle className="h-6 w-6 text-red-500" />
            Verification failed
          </CardTitle>
          <CardDescription className="text-center">
            We couldn't verify your email address
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        </CardContent>
        <CardFooter className="flex flex-col space-y-2">
          <Button className="w-full" asChild>
            <Link to="/register">
              Try signing up again
            </Link>
          </Button>
          <Button variant="outline" className="w-full" asChild>
            <Link to="/login">
              Back to login
            </Link>
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
};

export default VerifyEmail;
