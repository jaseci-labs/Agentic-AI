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
  cv_file?: File;
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


export async function loginAdmin(email: string, password: string): Promise<LoginResponse> {
  try {
    const response = await fetch(`${JAC_SERVER_URL}/user/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
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

async function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const result = reader.result as string;
      // Remove the data:application/pdf;base64, prefix
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = error => reject(error);
  });
}


export async function registerCandidates(
  jobContext: JobContext,
  candidates: Candidate[]
): Promise<RegisteredCandidate[]> {
  try {
    const token = await authenticateAdmin();

    const candidatesWithCvs = await Promise.all(
      candidates.map(async (candidate) => {
        let cvBase64 = '';
        if (candidate.cv_file) {
          cvBase64 = await fileToBase64(candidate.cv_file);
        }
        
        return {
          name: candidate.name,
          email: candidate.email,
          password: candidate.password,
          cv_bytes: cvBase64
        };
      })
    );

    // Make the authenticated API call
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    };

    const payload = {
      job_context: jobContext,
      candidates: candidatesWithCvs
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