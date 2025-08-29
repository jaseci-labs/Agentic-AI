import { useMutation } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { AuthApi, LoginRequest, LoginResponse } from '@/lib/api';
import { toast } from '@/components/ui/use-toast';

export const useLogin = () => {
  const navigate = useNavigate();

  return useMutation<LoginResponse, Error, LoginRequest>({
    mutationFn: (credentials) => AuthApi.loginWithInit(credentials),
    onSuccess: (data) => {
      localStorage.setItem('token', data.token);
      if (data.user) {
        localStorage.setItem('user', JSON.stringify(data.user));
      }
      
      // Dispatch custom event to notify App.tsx of auth state change
      window.dispatchEvent(new Event('authStateChange'));
      
      toast({
        title: 'Login Successful',
        description: 'You have been logged in successfully.',
      });
      
      navigate('/', { replace: true });
    },
    onError: (error) => {
      toast({
        title: 'Login Failed',
        description: error.message,
        variant: 'destructive',
      });
    },
  });
};