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
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

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

      // Now get the user profile to determine role
      const profileResponse = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_user_profile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      let userRole = 'user';
      if (profileResponse.ok) {
        const profileData = await profileResponse.json();
        if (profileData.reports && profileData.reports[0] && profileData.reports[0].user) {
          userRole = profileData.reports[0].user.role || 'user';
        }
      }

      const userData: User = {
        id: data.user?.id || email,
        email: data.user?.email || email,
        name: data.user?.name || data.name,
        role: userRole as 'user' | 'admin',
      };

      setUser(userData);
      localStorage.setItem('auth_token', token);
      localStorage.setItem('user_data', JSON.stringify(userData));
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };  const register = async (email: string, password: string, name?: string) => {
    setIsLoading(true);
    try {
      // Use the built-in register endpoint
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
      
      // Create user profile after successful registration
      await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/create_user_profile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, name: name || '' }),
      });
      
      // Handle case where registration is successful but we need to login separately
      if (data.message && data.message.includes('Successfully Registered')) {
        // After successful registration, attempt to login
        await login(email, password);
        return;
      }

      // Handle case where registration returns user data and token directly
      if (data.user && data.token) {
        const userData: User = {
          id: data.user.id,
          email: data.user.email,
          name: data.user.name,
          role: email === 'admin@jaseci.org' ? 'admin' : 'user',
        };

        setUser(userData);
        localStorage.setItem('auth_token', data.token);
        localStorage.setItem('user_data', JSON.stringify(userData));
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

  const logout = () => {
    setUser(null);
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
  };

  const value: AuthContextType = {
    user,
    login,
    register,
    logout,
    isLoading,
    isAuthenticated: !!user,
    isAdmin: user?.role === 'admin',
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
