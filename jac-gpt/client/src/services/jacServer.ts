// JAC Server API Service
export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface JacResponse {
  response: string;
  chat_history: ChatMessage[];
  session_id: string;
}

export interface SessionResponse {
  session_id: string;
  status: string;
  chat_history: ChatMessage[];
  found?: boolean;
}

class JacServerService {
  private baseUrl: string;
  private defaultEmail: string;
  private defaultPassword: string;

  constructor() {
    this.baseUrl = import.meta.env.VITE_JAC_SERVER_URL || 'http://localhost:8000';
    this.defaultEmail = import.meta.env.VITE_JAC_USER_EMAIL || 'test@mail.com';
    this.defaultPassword = import.meta.env.VITE_JAC_USER_PASSWORD || 'password';
  }

  // Get authentication token from localStorage or authenticate
  private async getAuthToken(): Promise<string> {
    // First try to get token from localStorage (from auth context)
    const token = localStorage.getItem('auth_token');
    if (token) {
      return token;
    }

    // Fallback to default authentication for backwards compatibility
    return await this.authenticate();
  }

  // Authenticate with the JAC server (fallback method)
  async authenticate(email?: string, password?: string): Promise<string> {
    const authEmail = email || this.defaultEmail;
    const authPassword = password || this.defaultPassword;
    
    try {
      // Try to login first
      let response = await fetch(`${this.baseUrl}/user/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: authEmail, password: authPassword }),
      });

      // If login fails, try to register
      if (response.status !== 200) {
        await fetch(`${this.baseUrl}/user/register`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email: authEmail, password: authPassword }),
        });

        // Login after registration
        response = await fetch(`${this.baseUrl}/user/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email: authEmail, password: authPassword }),
        });
      }

      if (!response.ok) {
        throw new Error(`Authentication failed: ${response.statusText}`);
      }

      const data = await response.json();
      return data.token;
    } catch (error) {
      console.error('Authentication error:', error);
      throw error;
    }
  }

  // Ensure authentication before making requests
  private async ensureAuthenticated(): Promise<string> {
    return await this.getAuthToken();
  }

  // Create a new session
  async createSession(sessionId?: string): Promise<SessionResponse> {
    const token = await this.ensureAuthenticated();

    try {
      const response = await fetch(`${this.baseUrl}/walker/new_session`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          session_id: sessionId || '',
        }),
      });

      if (!response.ok) {
        throw new Error(`Failed to create session: ${response.statusText}`);
      }

      const data = await response.json();
      return data.reports[0];
    } catch (error) {
      console.error('Error creating session:', error);
      throw error;
    }
  }

  // Get existing session
  async getSession(sessionId: string): Promise<SessionResponse> {
    const token = await this.ensureAuthenticated();

    try {
      const response = await fetch(`${this.baseUrl}/walker/get_session`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          session_id: sessionId,
        }),
      });

      if (!response.ok) {
        throw new Error(`Failed to get session: ${response.statusText}`);
      }

      const data = await response.json();
      return data.reports[0];
    } catch (error) {
      console.error('Error getting session:', error);
      throw error;
    }
  }

  // Send a message and get response
  async sendMessage(message: string, sessionId: string, userEmail?: string): Promise<JacResponse> {
    const token = await this.ensureAuthenticated();

    try {
      const requestBody: any = {
        message,
        session_id: sessionId,
      };

      // Include user email if provided
      if (userEmail) {
        requestBody.user_email = userEmail;
      }

      const response = await fetch(`${this.baseUrl}/walker/interact`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        throw new Error(`Failed to send message: ${response.statusText}`);
      }

      const data = await response.json();
      return data.reports[0];
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  // Generate a unique session ID
  generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

export const jacServerService = new JacServerService();
