import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface User {
  id: string;
  email: string;
  name?: string;
  role?: string;
}

interface LocationData {
  latitude: number;
  longitude: number;
  city?: string;
  country?: string;
  ip?: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, name?: string, location?: LocationData | null) => Promise<void>;
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
          
          // Always fetch the latest user profile to ensure correct role
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
                const userProfile = profileData.reports[0].user;
                parsedUser.role = userProfile.role || 'user';
                parsedUser.name = userProfile.name || parsedUser.name || '';
                localStorage.setItem('user_data', JSON.stringify(parsedUser));
              }
            }
          } catch (error) {
            console.error('Error fetching user profile:', error);
            // Use existing role if profile fetch fails
            if (!parsedUser.role) {
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
      let response;
      let data;
      let token;
      let userData: User;

      // First, try the built-in JAC Cloud login endpoint
      try {
        response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email, password }),
        });

        if (response.ok) {
          data = await response.json();
          
          // Handle different response formats
          token = data.token || data.access_token;
          
          // If no token in response but login was successful, generate a temporary token
          if (!token && data.message && data.message.includes('success')) {
            token = `temp_${Date.now()}`; // Temporary token for demo purposes
          }

          if (token) {
            // Fetch the complete user profile from our custom endpoint to get correct role
            try {
              const profileResponse = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/get_user_profile`, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email: data.user?.email || email }),
              });
              
              if (profileResponse.ok) {
                const profileData = await profileResponse.json();
                if (profileData.reports && profileData.reports[0] && profileData.reports[0].user) {
                  const userProfile = profileData.reports[0].user;
                  userData = {
                    id: data.user?.id || email,
                    email: userProfile.email,
                    name: userProfile.name || data.user?.name || '',
                    role: userProfile.role || 'user',
                  };
                } else {
                  // Fallback to JAC Cloud data if profile fetch fails
                  userData = {
                    id: data.user?.id || email,
                    email: data.user?.email || email,
                    name: data.user?.name || '',
                    role: data.user?.is_admin ? 'admin' : 'user',
                  };
                }
              } else {
                // Fallback to JAC Cloud data if profile fetch fails
                userData = {
                  id: data.user?.id || email,
                  email: data.user?.email || email,
                  name: data.user?.name || '',
                  role: data.user?.is_admin ? 'admin' : 'user',
                };
              }
            } catch (profileError) {
              console.error('Error fetching user profile:', profileError);
              // Fallback to JAC Cloud data if profile fetch fails
              userData = {
                id: data.user?.id || email,
                email: data.user?.email || email,
                name: data.user?.name || '',
                role: data.user?.is_admin ? 'admin' : 'user',
              };
            }

            setUser(userData);
            localStorage.setItem('auth_token', token);
            localStorage.setItem('user_data', JSON.stringify(userData));
            
            // Reset message count when user logs in
            resetMessageCount();
            return; // Success with JAC Cloud login
          }
        }
      } catch (jacCloudError) {
        console.warn('JAC Cloud login failed, trying custom login:', jacCloudError);
      }

      // If JAC Cloud login fails (due to location field issue), try our custom login
      try {
        response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/custom_login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email, password }),
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.message || 'Custom login failed');
        }

        data = await response.json();
        
        // Check if custom login was successful
        if (data.reports && data.reports[0] && data.reports[0].success) {
          const loginData = data.reports[0];
          token = loginData.token;
          
          userData = {
            id: loginData.user?.email || email,
            email: loginData.user?.email || email,
            name: loginData.user?.name || '',
            role: loginData.user?.role || 'user',
          };

          setUser(userData);
          localStorage.setItem('auth_token', token);
          localStorage.setItem('user_data', JSON.stringify(userData));
          
          // Reset message count when user logs in
          resetMessageCount();
          return; // Success with custom login
        } else {
          const loginData = data.reports?.[0] || {};
          throw new Error(loginData?.error || 'Custom login failed');
        }
      } catch (customLoginError) {
        console.error('Custom login also failed:', customLoginError);
        throw new Error('Login failed. Please check your credentials.');
      }

    } catch (error) {
      console.error('Login error:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };  const register = async (email: string, password: string, name?: string, location?: LocationData | null) => {
    setIsLoading(true);
    try {
      // Prepare registration data with location if available
      const registrationData = {
        email,
        password,
        name: name || '',
        ...(location && {
          location: {
            latitude: location.latitude,
            longitude: location.longitude,
            city: location.city || '',
            country: location.country || '',
            ip: location.ip || ''
          }
        })
      };

      // Use JAC Cloud's built-in register endpoint
      const response = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/user/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(registrationData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Registration failed');
      }

      const data = await response.json();
      
      // JAC Cloud handles user creation automatically
      // After successful registration, login to get the token and user data
      if (data.message && data.message.includes('Successfully Registered')) {
        // Save location data if available
        if (location) {
          try {
            await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/walker/save_user_location`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({ 
                email, 
                location: {
                  latitude: location.latitude,
                  longitude: location.longitude,
                  city: location.city || '',
                  country: location.country || '',
                  ip: location.ip || ''
                }
              }),
            });
          } catch (locationError) {
            console.warn('Failed to save location data:', locationError);
          }
        }
        
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
