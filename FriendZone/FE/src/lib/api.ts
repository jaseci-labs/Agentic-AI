import { HOST } from './config';

export interface User {
  id: string;
  email: string;
  name?: string;
}

export interface ProfileData {
  email: string;
  first_name: string;
  last_name: string;
  profile_picture_url: string;
}

export interface UpdateProfileRequest {
  first_name: string;
  last_name: string;
  profile_picture_url: string;
}

export interface UpdateProfileResponse {
  message: string;
  profile: ProfileData;
}

export interface FriendRequestRequest {
  email: string;
}

export interface FriendRequestResponse {
  status: string;
  message: string;
  user_email: string;
}

export interface Friend {
  email: string;
  first_name: string;
  last_name: string;
  profile_picture_url: string;
}

export interface FriendRequest {
  email: string;
  first_name: string;
  last_name: string;
  profile_picture_url: string;
  status: string;
  created_at: string;
}

export interface UserProfile {
  email: string;
  first_name: string;
  last_name: string;
  profile_picture_url: string;
}

export interface ListUsersRequest {
  page: number;
  page_size: number;
}

export interface ListUsersResponse {
  users: UserProfile[];
  total_users: number;
  total_pages: number;
  current_page: number;
  page_size: number;
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

export interface PresignedUrlResponse {
  upload_url: string;
  public_url: string;
}

export interface InitSessionRequest {
  image_url: string;
  location?: {
    latitude: number;
    longitude: number;
  };
  date?: string;
}

export interface InitSessionResponse {
  session_id: string;
  follow_up_questions: string;
  summary: string;
  when: string;
  who: string[];
  where: string[];
  what: string;
  conversation: Array<{
    user?: string;
    assistant: string;
  }>;
  image_url: string;
  save_memory: boolean;
  show_summary: boolean;
}

export interface ContinueSessionRequest {
  session_id: string;
  utterance: string;
}

export interface ContinueSessionResponse {
  session_id: string;
  follow_up_questions: string;
  summary: string;
  when: string;
  who: string[];
  where: string[];
  what: string;
  conversation: Array<{
    user?: string;
    assistant: string;
  }>;
  image_url: string;
  save_memory: boolean;
  show_summary: boolean;
}

export interface SavedMemory {
  memory_id: string;
  session_id: string;
  summary: string;
  when: string;
  who: string[];
  where: string[];
  what: string;
  image_url: string;
  conversation: Array<{
    user?: string;
    assistant: string;
  }>;
  created_at: string;
  updated_at?: string;
  save_memory?: boolean;
  show_summary?: boolean;
  shared_with?: string[];
  owner_email?: string;
}

export interface ShareMemoryRequest {
  memory_id: string;
  share_with: string[];
}

export interface ShareMemoryResponse {
  success: string[];
  failed: string[];
}

export interface UnshareMemoryRequest {
  memory_id: string;
  unshare_with: string[];
}

export interface RejectMemoryRequest {
  memory_ids: string[];
}

export interface MemoryListResponse {
  memory: SavedMemory;
  comments: any[];
  comment_summary: string;
  povs: any[];
}

export class AuthApi {
  private static getAuthHeaders(token: string) {
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  static async generatePresignedUrl(token: string): Promise<PresignedUrlResponse> {
    const response = await fetch(`${HOST}/walker/generate_presigned_url`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to generate presigned URL', response.status);
    }

    return data.reports[0];
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

  static async initSession(token: string, request: InitSessionRequest): Promise<InitSessionResponse> {
    const response = await fetch(`${HOST}/walker/init_session`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to initialize session', response.status);
    }
    
    return data.reports[0];
  }

  static async continueSession(token: string, request: ContinueSessionRequest): Promise<ContinueSessionResponse> {
    const response = await fetch(`${HOST}/walker/continue_session`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to continue session', response.status);
    }
    
    return data.reports[0];
  }

  static async getSavedMemories(token: string): Promise<SavedMemory[]> {
    const response = await fetch(`${HOST}/walker/list_memories`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch memories', response.status);
    }
    
    // Extract the memory objects from the nested structure
    const memories = (data.reports || []).map((item: MemoryListResponse) => item.memory);
    return memories;
  }

  static async saveMemory(token: string, sessionId: string): Promise<SavedMemory> {
    const response = await fetch(`${HOST}/walker/save_memory`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({
        session_id: sessionId
      }),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to save memory', response.status);
    }
    
    return data.reports[0];
  }

  static async getProfile(token: string): Promise<ProfileData> {
    const response = await fetch(`${HOST}/walker/get_profile`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch profile', response.status);
    }
    
    return data.reports[0];
  }

  static async updateProfile(token: string, profileData: UpdateProfileRequest): Promise<UpdateProfileResponse> {
    const response = await fetch(`${HOST}/walker/update_profile`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(profileData),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to update profile', response.status);
    }
    
    return data.reports[0];
  }

  static async sendFriendRequest(token: string, email: string): Promise<FriendRequestResponse> {
    const response = await fetch(`${HOST}/walker/send_friend_request`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({ email }),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to send friend request', response.status);
    }
    
    return data.reports[0];
  }

  static async acceptFriendRequest(token: string, email: string): Promise<FriendRequestResponse> {
    const response = await fetch(`${HOST}/walker/accept_friend_request`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({ email }),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to accept friend request', response.status);
    }
    
    return data.reports[0];
  }

  static async rejectFriendRequest(token: string, email: string): Promise<FriendRequestResponse> {
    const response = await fetch(`${HOST}/walker/reject_friend_request`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({ email }),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to reject friend request', response.status);
    }
    
    return data.reports[0];
  }

  static async getFriends(token: string): Promise<Friend[]> {
    const response = await fetch(`${HOST}/walker/get_friends`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({}),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch friends', response.status);
    }
    
    return data.reports || [];
  }

  static async getSentFriendRequests(token: string): Promise<FriendRequest[]> {
    const response = await fetch(`${HOST}/walker/get_sent_friend_requests`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({}),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch sent friend requests', response.status);
    }
    
    return data.reports || [];
  }

  static async getReceivedFriendRequests(token: string): Promise<FriendRequest[]> {
    const response = await fetch(`${HOST}/walker/get_received_friend_requests`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({}),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch received friend requests', response.status);
    }
    
    return data.reports || [];
  }

  static async listUsers(token: string, request: ListUsersRequest): Promise<ListUsersResponse> {
    const response = await fetch(`${HOST}/walker/list_users`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch users', response.status);
    }
    
    return data.reports[0];
  }

  static async shareMemory(token: string, request: ShareMemoryRequest): Promise<ShareMemoryResponse> {
    const response = await fetch(`${HOST}/walker/share_memory`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to share memory', response.status);
    }
    
    return data.reports[0];
  }

  static async unshareMemory(token: string, request: UnshareMemoryRequest): Promise<ShareMemoryResponse> {
    const response = await fetch(`${HOST}/walker/unshare_memory`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to unshare memory', response.status);
    }
    
    return data.reports[0];
  }

  static async getSharedMemories(token: string): Promise<SavedMemory[]> {
    const response = await fetch(`${HOST}/walker/get_shared_memories`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify({}),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to fetch shared memories', response.status);
    }
    
    // Handle the nested array structure in the response
    if (data.reports && data.reports.length > 0 && Array.isArray(data.reports[0])) {
      return data.reports[0]; // Return the first array which contains the memories
    }
    
    return [];
  }

  static async rejectMemory(token: string, request: RejectMemoryRequest): Promise<void> {
    const response = await fetch(`${HOST}/walker/reject_memory`, {
      method: 'POST',
      headers: this.getAuthHeaders(token),
      body: JSON.stringify(request),
    });

    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.message || 'Failed to reject memory', response.status);
    }
  }
}