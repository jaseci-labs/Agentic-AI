import from dotenv { load_dotenv }
import os;
import requests;
import from mtllm.llm { Model }


glob llm: Model = Model(model_name = "gemini/gemini-2.5-flash",api_key = os.getenv("GOOGLE_API_KEY"));

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
}

obj Chat { has role: str; has content: str; }
obj QAPair { has question: str; has answer: str; }

node InterviewSession {
    has job_context: JobContext;
    has candidate: Candidate;
    has qa_pairs: list[QAPair] = [];
    has chat_history: list[Chat] = [];
    has is_active: bool = False;
    has interview_started: bool = False; # To check if a candidate has started.
}

glob interview_sessions: dict[str, InterviewSession] = {};

"""
You are an expert AI hiring manager conducting a live, conversational interview.
Your goal is to have a natural, insightful conversation to assess a candidate for the role defined".

*YOUR TASK:*
Based on the entire conversation history, with special emphasis on the *candidate's most recent answer*, generate the single best question to ask next.

Your strategy should include both:
1.  Ask Follow-Up Questions where it's relevant: If the candidate's last answer introduced a new project, a key skill, or was vague, your top priority is to ask a probing follow-up question. This makes the conversation feel interactive and intelligent. (e.g., "You mentioned you improved performance by 30%. Could you walk me through the specific steps you took to achieve that?")
2.  Transition to a New Topic: If the previous topic feels concluded, or if you need to cover more ground, ask a fresh, open-ended question based on the job description to assess their skills. Ensure you do not repeat topics that have already been discussed in the history.

The conversation should flow naturally. Your question must be insightful and help you assess the candidate's fitness for the role.

Generate only the question text itself, without any introduction like "My next question is...".
"""
def generate_next_question(
    company_name: str,
    job_role: str,
    job_description: str,
    history_str: str
) -> str by llm();


sem generate_interview_questions = "Generate a list of interview questions for a candidate which will effectively assess the candidate's skills, experience, and cultural fit based on the provided context, who is applying for a job role, based on the provided company and job context.";
sem generate_interview_questions.company_name = "The name of the company where the candidate is applying.";
sem generate_interview_questions.job_role = "The specific job role the candidate is applying for.";
sem generate_interview_questions.job_description = "The detailed job description outlining responsibilities, required skills, and expectations for the role.";
sem generate_interview_questions.history_str = "The conversation history so far, formatted as a string with each entry labeled by role (Interviewer or Candidate) and content.";



# Walker for the Admin App to register candidates.
walker RegisterCandidatesWalker {
    has job_context: JobContext;
    has candidates: list[Candidate];

    obj _specs_ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        load_dotenv();
        created_sessions = [];
        for cand in self.candidates {
            # Register user via API
            user_response = requests.post(
                "http://127.0.0.1:8000/user/register",
                json={"email": cand.email, "password": cand.password}
            );
            login_response = requests.post(
                "http://127.0.0.1:8000/user/login",
                json={"email": cand.email, "password": cand.password}
            );
            login_data = login_response.json();
            candidate_id = login_data["user"]["id"];

            # Create the session node 
            session_node = (root ++> InterviewSession(
                job_context=self.job_context,
                candidate=cand,
                is_active=False,
                interview_started=False
            ))[0];

            interview_sessions[candidate_id] = session_node;
            created_sessions.append({
                "candidate_name": cand.name,
                "candidate_email": cand.email,
                "candidate_id": candidate_id
            });
            print(f"Registered session {candidate_id} for candidate {cand.name}.");
        }
        report {"status": "success", "created_sessions": created_sessions};
    }
}

walker StartInterviewWalker {
    has candidate_id: str;

    obj _specs_ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        load_dotenv();
        session_node = interview_sessions.get(self.candidate_id);

        if not session_node {
            report {"status": "error", "message": "Invalid Session ID."};
            disengage;
        }
        if session_node.interview_started {
            report {"status": "error", "message": "This interview has already been started."};
            disengage;
        }

        session_node.is_active = True;
        session_node.interview_started = True;

        initial_history_str = f"The interview is about to start for candidate {session_node.candidate.name}. Please provide an engaging opening question to welcome them and begin the assessment for the {session_node.job_context.job_role} role.";
        
        first_question = generate_next_question(
            company_name=session_node.job_context.company_name,
            job_role=session_node.job_context.job_role,
            job_description=session_node.job_context.job_description,
            history_str=initial_history_str
        );

        session_node.chat_history.append(Chat(role="Interviewer", content=first_question));

        report {
            "status": "started",
            "candidate_name": session_node.candidate.name,
            "job_role": session_node.job_context.job_role,
            "question": first_question
        };
    }
}

# SubmitAnswerWalker finds the session by ID and continues the conversation.
walker SubmitAnswerWalker {
    has candidate_id: str;
    has answer: str;

    obj _specs_ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        load_dotenv();
        session_node = interview_sessions.get(self.candidate_id);

        if not session_node or not session_node.is_active {
            report {"status": "error", "message": "Session not found or inactive."};
            disengage;
        }

        last_question = session_node.chat_history[-1].content;
        session_node.qa_pairs.append(QAPair(question=last_question, answer=self.answer));
        session_node.chat_history.append(Chat(role="Candidate", content=self.answer));

        if len(session_node.qa_pairs) >= session_node.job_context.number_of_questions {
            session_node.is_active = False;
            report {
                "status": "completed",
                "message": "Thank you! The interview is now complete.",
                "final_transcript": session_node.qa_pairs
            };
        } else {
            history_str = "\n".join([f"{chat.role}: {chat.content}" for chat in session_node.chat_history]);
            next_question = generate_next_question(
                company_name=session_node.job_context.company_name,
                job_role=session_node.job_context.job_role,
                job_description=session_node.job_context.job_description,
                history_str=history_str
            );
            session_node.chat_history.append(Chat(role="Interviewer", content=next_question));
            report {"status": "ongoing", "question": next_question};
        }
    }
}