import { HOST } from './config';

export interface User {
  id: string;
  email: string;
  name?: string;
}

export interface ApiResponse<T = any> {
  data?: T;
  message?: string;
  error?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  message?: string;
  user?: User;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}

export interface RegisterResponse {
  message: string;
}

class ApiError extends Error {
  constructor(message: string, public status?: number) {
    super(message);
    this.name = 'ApiError';
  }
}

export class AuthApi {
  private static getAuthHeaders(token: string) {
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  static async getUserProfile(token: string): Promise<User> {
    const response = await fetch(`${HOST}/walker/get_profile`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch user profile', response.status);
    }
    
    return data;
  }

  static async initializeUser(token: string): Promise<void> {
    const response = await fetch(`${HOST}/walker/init_user`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to initialize user', response.status);
    }
  }

  static async getUserProfileWithInit(token: string): Promise<User> {
    try {
      return await this.getUserProfile(token);
    } catch (error) {
      if (error instanceof ApiError && error.status) {
        // If profile fetch fails, try to initialize user first
        try {
          await this.initializeUser(token);
          // Retry getting profile after initialization
          return await this.getUserProfile(token);
        } catch (initError) {
          // If initialization also fails, throw the original error
          throw error;
        }
      }
      throw error;
    }
  }

  static async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await fetch(`${HOST}/user/login/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Invalid email or password', response.status);
    }
    
    return data;
  }

  static async register(userData: RegisterRequest): Promise<RegisterResponse> {
    const response = await fetch(`${HOST}/user/register/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: userData.name.trim(),
        email: userData.email.trim().toLowerCase(),
        password: userData.password,
      }),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Registration failed', response.status);
    }
    
    return data;
  }

  static async loginWithInit(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await this.login(credentials);
    
    // Try to initialize user with the backend
    if (response.token) {
      try {
        await this.initializeUser(response.token);
      } catch (error) {
        // Initialization failed, but login was successful - continue silently
      }
    }
    
    return response;
  }
}