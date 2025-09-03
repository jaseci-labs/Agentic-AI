import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { AuthApi, User } from '@/lib/api';
import { toast } from '@/components/ui/use-toast';

interface UseAuthReturn {
  user: User | undefined;
  isLoading: boolean;
  isAuthenticated: boolean;
  error: Error | null;
  logout: () => void;
}

export const useAuth = (): UseAuthReturn => {
  const token = localStorage.getItem('token');

  const { data: user, isLoading, error } = useQuery<User, Error>({
    queryKey: ['user', token],
    queryFn: () => {
      if (!token) {
        throw new Error('No authentication token found');
      }
      return AuthApi.getUserProfileWithInit(token);
    },
    enabled: !!token,
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    
    // Dispatch custom event to notify App.tsx of auth state change
    window.dispatchEvent(new Event('authStateChange'));
    
    toast({
      title: 'Logged Out',
      description: 'You have been logged out successfully.',
    });
  };

  const handleAuthError = () => {
    if (error && token) {
      // Clear invalid token
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      
      // Dispatch custom event to notify App.tsx of auth state change
      window.dispatchEvent(new Event('authStateChange'));
      
      toast({
        title: 'Session Expired',
        description: 'Your session has expired. Please log in to continue.',
        variant: 'destructive',
      });
    }
  };

  // Handle authentication errors
  React.useEffect(() => {
    handleAuthError();
  }, [error, token]);

  return {
    user,
    isLoading,
    isAuthenticated: !!token && !!user && !error,
    error,
    logout,
  };
};