import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface User {
  id: string;
  email: string;
  name?: string;
  role?: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, name?: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
  isAuthenticated: boolean;
  isAdmin: boolean;
  messageCount: number;
  incrementMessageCount: () => void;
  resetMessageCount: () => void;
  canSendMessage: boolean;
  maxFreeMessages: number;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [messageCount, setMessageCount] = useState(0);
  const maxFreeMessages = 10;

  // For development/testing purposes - expose reset function globally
  useEffect(() => {
    if (import.meta.env.DEV) {
      (window as any).resetMessageCount = resetMessageCount;
      console.log('Development mode: Use window.resetMessageCount() to reset guest message count');
    }
  }, []);

  // Load message count from localStorage for non-authenticated users
  useEffect(() => {
    if (!user) {
      const storedCount = localStorage.getItem('guest_message_count');
      if (storedCount) {
        setMessageCount(parseInt(storedCount, 10));
      }
    }
  }, [user]);

  // Check for existing token on app start
  useEffect(() => {
    const checkExistingAuth = async () => {
      const token = localStorage.getItem('auth_token');
      const userData = localStorage.getItem('user_data');
      
      if (token && userData) {
        try {
          const parsedUser = JSON.parse(userData);
          
          // If user doesn't have role, fetch it from profile
          if (!parsedUser.role) {
            try {
              const profileResponse = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_user_profile`, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email: parsedUser.email }),
              });
              
              if (profileResponse.ok) {
                const profileData = await profileResponse.json();
                if (profileData.reports && profileData.reports[0] && profileData.reports[0].user) {
                  parsedUser.role = profileData.reports[0].user.role || 'user';
                  localStorage.setItem('user_data', JSON.stringify(parsedUser));
                }
              }
            } catch (error) {
              console.error('Error fetching user profile:', error);
              // Default to user role if profile fetch fails
              parsedUser.role = 'user';
            }
          }
          
          setUser(parsedUser);
        } catch (error) {
          console.error('Error parsing user data:', error);
          localStorage.removeItem('auth_token');
          localStorage.removeItem('user_data');
        }
      }
      setIsLoading(false);
    };

    checkExistingAuth();
  }, []);

    const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      // Use the built-in login endpoint
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Login failed');
      }

      const data = await response.json();
      
      // Handle different response formats
      let token = data.token || data.access_token;
      
      // If no token in response but login was successful, generate a temporary token
      if (!token && data.message && data.message.includes('success')) {
        token = `temp_${Date.now()}`; // Temporary token for demo purposes
      }

      if (!token) {
        throw new Error('No authentication token received');
      }

      // Use JAC Cloud's user data directly - no need for separate profile call
      const userData: User = {
        id: data.user?.id || email,
        email: data.user?.email || email,
        name: data.user?.name || '',
        role: data.user?.is_admin ? 'admin' : 'user',
      };

      setUser(userData);
      localStorage.setItem('auth_token', token);
      localStorage.setItem('user_data', JSON.stringify(userData));
      
      // Reset message count when user logs in
      resetMessageCount();
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };  const register = async (email: string, password: string, name?: string) => {
    setIsLoading(true);
    try {
      // Use JAC Cloud's built-in register endpoint
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password, name }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Registration failed');
      }

      const data = await response.json();
      
      // JAC Cloud handles user creation automatically
      // After successful registration, login to get the token and user data
      if (data.message && data.message.includes('Successfully Registered')) {
        await login(email, password);
        return;
      }

      // Handle case where registration returns user data and token directly
      if (data.user && data.token) {
        const userData: User = {
          id: data.user.id,
          email: data.user.email,
          name: data.user.name || name || '',
          role: data.user.is_admin ? 'admin' : 'user',
        };

        setUser(userData);
        localStorage.setItem('auth_token', data.token);
        localStorage.setItem('user_data', JSON.stringify(userData));
        
        // Reset message count when user registers
        resetMessageCount();
      } else {
        // Fallback: try to login after registration
        await login(email, password);
      }
    } catch (error) {
      console.error('Registration error:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const incrementMessageCount = () => {
    if (!user) {
      const newCount = messageCount + 1;
      setMessageCount(newCount);
      localStorage.setItem('guest_message_count', newCount.toString());
    }
  };

  const resetMessageCount = () => {
    setMessageCount(0);
    localStorage.removeItem('guest_message_count');
    console.log('Guest message count has been reset to 0');
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
    // Reset message count when logging out
    resetMessageCount();
  };

  const value: AuthContextType = {
    user,
    login,
    register,
    logout,
    isLoading,
    isAuthenticated: !!user,
    isAdmin: user?.role === 'admin',
    messageCount,
    incrementMessageCount,
    resetMessageCount,
    canSendMessage: !!user || messageCount < maxFreeMessages,
    maxFreeMessages,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
