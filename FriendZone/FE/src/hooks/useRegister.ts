import { useMutation } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { AuthApi, RegisterRequest, RegisterResponse } from '@/lib/api';
import { toast } from '@/components/ui/use-toast';

export const useRegister = () => {
  const navigate = useNavigate();

  return useMutation<RegisterResponse, Error, RegisterRequest>({
    mutationFn: (userData) => AuthApi.register(userData),
    onSuccess: () => {
      toast({
        title: 'Success',
        description: 'Registration successful! Redirecting to login...',
      });
      setTimeout(() => navigate('/login'), 1500);
    },
    onError: (error) => {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: error.message || 'An unexpected error occurred',
      });
    },
  });
};