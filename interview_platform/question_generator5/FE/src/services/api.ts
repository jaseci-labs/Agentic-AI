// API Service for Interview Platform
// Matches the exact functionality from Streamlit app

const JAC_SERVER_URL = "http://localhost:8000";
const API_REGISTER_CANDIDATES = `${JAC_SERVER_URL}/walker/RegisterCandidatesWalker`;
const API_START_INTERVIEW = `${JAC_SERVER_URL}/walker/StartInterviewWalker`;
const API_SUBMIT_ANSWER = `${JAC_SERVER_URL}/walker/SubmitAnswerWalker`;

export interface JobContext {
  company_name: string;
  company_info: string;
  job_role: string;
  job_description: string;
  number_of_questions: number;
}

export interface Candidate {
  name: string;
  email: string;
  password: string;
}

export interface RegisteredCandidate {
  candidate_name: string;
  candidate_email: string;
  candidate_id: string;
}

export interface APIResponse<T> {
  reports: Array<{
    status: string;
    message?: string;
    [key: string]: any;
  }>;
}

export interface LoginResponse {
  user: {
    id: string;
    email: string;
  };
  token: string;
}

export interface InterviewStartResponse {
  status: string;
  candidate_name?: string;
  job_role?: string;
  question?: string;
  message?: string;
}

export interface SubmitAnswerResponse {
  status: string;
  question?: string;
  message?: string;
  final_transcript?: Array<{
    question: string;
    answer: string;
  }>;
}

class APIError extends Error {
  constructor(message: string, public statusCode?: number) {
    super(message);
    this.name = 'APIError';
  }
}

/**
 * Authenticate admin user and get token
 * Uses the same approach as company.py
 */
export async function authenticateAdmin(): Promise<string> {
  try {
    const response = await fetch(`${JAC_SERVER_URL}/user/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: "admin@test.com",
        password: "admin123"
      }),
    });

    if (!response.ok) {
      throw new APIError(`Authentication failed: ${response.statusText}`, response.status);
    }

    const data: LoginResponse = await response.json();
    return data.token;
  } catch (error) {
    if (error instanceof APIError) throw error;
    throw new APIError(`Authentication error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Login admin with frontend validation only
 */
export async function loginAdmin(email: string, password: string): Promise<LoginResponse> {
  // Simple frontend validation
  if (email.trim() !== "admin@test.com" || password.trim() !== "admin123") {
    throw new APIError("Invalid admin credentials");
  }

  // Return mock success response
  return {
    user: {
      id: "admin_user",
      email: "admin@test.com"
    },
    token: "admin_authenticated_token"
  };
}

/**
 * Register candidates and create interview sessions
 * Matches the exact logic from Streamlit RegisterCandidatesWalker call
 */
export async function registerCandidates(
  jobContext: JobContext,
  candidates: Candidate[]
): Promise<RegisteredCandidate[]> {
  try {
    // First authenticate to get token (same as Streamlit)
    const token = await authenticateAdmin();

    // Make the authenticated API call
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };

    const payload = {
      job_context: jobContext,
      candidates: candidates
    };

    const response = await fetch(API_REGISTER_CANDIDATES, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new APIError(`Registration failed: ${response.statusText}`, response.status);
    }

    const data: APIResponse<any> = await response.json();

    // Extract from reports array (same logic as Streamlit)
    if (data.reports && data.reports.length > 0) {
      const reportData = data.reports[0];
      if (reportData.status === "success") {
        return reportData.created_sessions || [];
      } else {
        throw new APIError(reportData.message || "Registration failed");
      }
    } else {
      throw new APIError("Invalid response format from server");
    }
  } catch (error) {
    if (error instanceof APIError) throw error;
    throw new APIError(`Registration error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Login candidate and get user info
 * Matches the exact logic from Streamlit candidate login
 */
export async function loginCandidate(email: string, password: string): Promise<LoginResponse> {
  try {
    const payload = { 
      email: email.trim(), 
      password: password.trim() 
    };

    const response = await fetch(`${JAC_SERVER_URL}/user/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new APIError(`Login failed: ${response.statusText}`, response.status);
    }

    const data: LoginResponse = await response.json();
    return data;
  } catch (error) {
    if (error instanceof APIError) throw error;
    throw new APIError(`Login error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Start interview for a candidate
 * Matches the exact logic from Streamlit StartInterviewWalker call
 */
export async function startInterview(candidateId: string, token: string): Promise<InterviewStartResponse> {
  try {
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };

    const startPayload = { candidate_id: candidateId };

    const response = await fetch(API_START_INTERVIEW, {
      method: 'POST',
      headers,
      body: JSON.stringify(startPayload),
    });

    if (!response.ok) {
      throw new APIError(`Start interview failed: ${response.statusText}`, response.status);
    }

    const data: APIResponse<any> = await response.json();

    // Extract from reports array (same logic as Streamlit)
    if (data.reports && data.reports.length > 0) {
      const reportData = data.reports[0];
      if (reportData.status === "started") {
        return {
          status: "started",
          candidate_name: reportData.candidate_name,
          job_role: reportData.job_role,
          question: reportData.question
        };
      } else {
        throw new APIError(reportData.message || "An unknown error occurred.");
      }
    } else {
      throw new APIError("Invalid response format from server");
    }
  } catch (error) {
    if (error instanceof APIError) throw error;
    throw new APIError(`Start interview error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Submit answer and get next question or completion status
 * Matches the exact logic from Streamlit SubmitAnswerWalker call
 */
export async function submitAnswer(
  candidateId: string, 
  answer: string, 
  token: string
): Promise<SubmitAnswerResponse> {
  try {
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };

    const payload = { 
      candidate_id: candidateId, 
      answer: answer 
    };

    const response = await fetch(API_SUBMIT_ANSWER, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new APIError(`Submit answer failed: ${response.statusText}`, response.status);
    }

    const data: APIResponse<any> = await response.json();

    // Extract from reports array (same logic as Streamlit)
    if (data.reports && data.reports.length > 0) {
      const reportData = data.reports[0];
      
      if (reportData.status === "ongoing") {
        return {
          status: "ongoing",
          question: reportData.question
        };
      } else if (reportData.status === "completed") {
        return {
          status: "completed",
          message: reportData.message || "Thank you! The interview is now complete.",
          final_transcript: reportData.final_transcript
        };
      } else {
        throw new APIError(reportData.message || "An unknown error occurred.");
      }
    } else {
      throw new APIError("Invalid response format from server");
    }
  } catch (error) {
    if (error instanceof APIError) throw error;
    throw new APIError(`Submit answer error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

export { APIError };