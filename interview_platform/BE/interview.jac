import from dotenv { load_dotenv }
import os;
import requests;
import from mtllm.llm { Model }
import from PyPDF2 { PdfReader }
import from io { BytesIO }
import base64;

glob llm: Model = Model(model_name = "gemini/gemini-2.5-flash",api_key = os.getenv("GEMINI_API_KEY"));

node JobContext {
    has company_name: str;
    has company_info: str;
    has job_role: str;
    has job_description: str;
    has number_of_questions: int;
}

obj Candidate {
    has name: str;
    has email: str;
    has password: str;
    has cv_text: str;
}

obj Chat { has role: str; has content: str; }
obj QAPair { has question: str; has answer: str; }

node InterviewSession {
    has job_context: JobContext;
    has candidate: Candidate;
    has qa_pairs: list[QAPair] = [];
    has chat_history: list[Chat] = [];
    has is_active: bool = False;
    has interview_started: bool = False;
}

glob interview_sessions: dict[str, InterviewSession] = {};


def generate_next_question(
    company_name: str,
    job_role: str,
    job_description: str,
    cv_text: str,
    history_str: str
) -> str by llm();


sem generate_next_question = "Generate a list of interview questions for a candidate which will effectively assess the candidate's skills, experience, and cultural fit based on the provided context, who is applying for a job role, based on the provided company and job context.";
sem generate_next_question.company_name = "The name of the company where the candidate is applying.";
sem generate_next_question.job_role = "The specific job role the candidate is applying for.";
sem generate_next_question.job_description = "The detailed job description outlining responsibilities, required skills, and expectations for the role.";
sem generate_next_question.history_str = "The conversation history so far, formatted as a string with each entry labeled by role (Interviewer or Candidate) and content.";
sem generate_next_question.cv_text = "The full text content of the candidate's CV or resume.";


walker RegisterCandidatesWalker {
    has job_context: JobContext;
    has candidates: list[dict];

    obj __specs__ { static has auth: bool = False; }

    can execute with `root entry;
}

walker StartInterviewWalker {
    has candidate_id: str;

    obj _specs_ {
        static has auth: bool = False;
    }

    can execute with `root entry;
}

walker SubmitAnswerWalker {
    has candidate_id: str;
    has answer: str;
    obj __specs__ { static has auth: bool = False; }

    can execute with `root entry;
}
