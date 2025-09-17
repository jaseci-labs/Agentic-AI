import streamlit as st
import requests
import pandas as pd
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

JAC_SERVER_URL = "http://localhost:8000"
API_REGISTER_CANDIDATES = f"{JAC_SERVER_URL}/walker/RegisterCandidatesWalker"
API_START_INTERVIEW = f"{JAC_SERVER_URL}/walker/StartInterviewWalker"
API_SUBMIT_ANSWER = f"{JAC_SERVER_URL}/walker/SubmitAnswerWalker"

st.set_page_config(layout="wide", page_title="AI Interview Platform")

# Initialize session state
def init_session_state():
    # Admin state
    if 'created_sessions' not in st.session_state:
        st.session_state.created_sessions = []
    
    # Candidate state
    if 'candidate_id' not in st.session_state:
        st.session_state.candidate_id = None
    if 'interview_active' not in st.session_state:
        st.session_state.interview_active = False
    if 'current_question' not in st.session_state:
        st.session_state.current_question = ""
    if 'qa_transcript' not in st.session_state:
        st.session_state.qa_transcript = []
    if 'error_message' not in st.session_state:
        st.session_state.error_message = ""
    if 'token' not in st.session_state:
        st.session_state.token = None
    
    if 'selected_role' not in st.session_state:
        st.session_state.selected_role = None

init_session_state()

# Role Selection
def render_role_selection():
    st.title("🤖 AI Interview Platform")
    st.write("Welcome to the AI-powered interview platform. Please select your role to continue.")
    
    col1, col2 = st.columns(2)
    
    with col1:
        if st.button("🏢 Admin Portal", type="primary", use_container_width=True):
            st.session_state.selected_role = "admin"
            st.rerun()
        st.write("Create job postings and manage candidate interviews")
    
    with col2:
        if st.button("👤 Candidate Portal", type="primary", use_container_width=True):
            st.session_state.selected_role = "candidate"
            st.rerun()
        st.write("Take your AI-powered interview")

# Admin Portal Functions
def render_admin_portal():
    st.title("🏢 Admin Portal: Create Interview Sessions")
    st.write("Use this portal to define a job role and register candidates. Each registered candidate will receive a unique Session ID to take their interview.")
    
    # Back button
    if st.button("← Back to Role Selection"):
        st.session_state.selected_role = None
        st.rerun()
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.header("1. Define the Job")
        with st.form("job_details_form"):
            company_name = st.text_input("Company Name", "QuantumLeap AI")
            company_info = st.text_area("Company Info", "We build foundational AI models.", height=100)
            job_role = st.text_input("Job Role", "Research Scientist")
            job_description = st.text_area("Job Description", "Seeking a PhD-level Research Scientist...", height=150)
            number_of_questions = st.number_input("Number of Questions", min_value=3, max_value=10, value=5)
            job_form_submitted = st.form_submit_button("Lock Job Details")
            
            if job_form_submitted:
                # Store job details in session state to use with candidate form
                st.session_state.job_context = {
                    "company_name": company_name,
                    "company_info": company_info,
                    "job_role": job_role,
                    "job_description": job_description,
                    "number_of_questions": number_of_questions
                }
                st.success("Job details locked in. Now register candidates.")

    with col2:
        st.header("2. Register Candidates")
        if 'job_context' not in st.session_state:
            st.warning("Please define and lock the job details on the left first.")
        else:
            st.write(f"Registering candidates for: *{st.session_state.job_context['job_role']}*")
            
            # Number of candidates input
            num_candidates = st.number_input(
                "Number of Candidates", 
                min_value=1, 
                max_value=10, 
                value=1,
                help="Specify how many candidates you want to register"
            )
            
            with st.form("candidates_form"):
                candidates_data = []
                for i in range(num_candidates):
                    st.markdown(f"**Candidate {i+1}**")
                    name = st.text_input(f"Name", key=f"name_{i}")
                    email = st.text_input(f"Email", key=f"email_{i}")
                    password = st.text_input(f"Password", key=f"password_{i}", type="password")
                    if name and email and password:
                        candidates_data.append({"name": name, "email": email, "password": password})
                
                candidates_form_submitted = st.form_submit_button("Register Candidates and Generate IDs", type="primary")

                if candidates_form_submitted:
                    if not candidates_data:
                        st.error("Please enter details for at least one candidate.")
                    else:
                        with st.spinner("Registering candidates and creating secure sessions..."):
                            try:
                                # First, authenticate to get a token
                                auth_response = requests.post(
                                    f"{JAC_SERVER_URL}/user/login",
                                    json={"email": "admin@test.com", "password": "admin123"}
                                )
                                auth_response.raise_for_status()
                                auth_data = auth_response.json()
                                token = auth_data["token"]
                                
                                # Now make the authenticated API call
                                headers = {"Authorization": f"Bearer {token}"}
                                payload = {
                                    "job_context": st.session_state.job_context,
                                    "candidates": candidates_data
                                }
                                response = requests.post(API_REGISTER_CANDIDATES, json=payload, headers=headers)
                                response.raise_for_status()
                                data = response.json()
                                
                                # Extract from reports array
                                if data.get("reports") and len(data["reports"]) > 0:
                                    report_data = data["reports"][0]
                                    if report_data.get("status") == "success":
                                        st.session_state.created_sessions = report_data.get("created_sessions", [])
                                    else:
                                        st.error(report_data.get("message", "Registration failed"))
                                else:
                                    st.error("Invalid response format from server")

                            except Exception as e:
                                st.error(f"Failed to register candidates. Error: {e}")

    # Results
    if st.session_state.created_sessions:
        st.header("3. Generated Interview Sessions")
        st.success("The following interview sessions have been created. Please share the unique Session ID with each candidate.")
        
        df = pd.DataFrame(st.session_state.created_sessions)
        st.dataframe(df, use_container_width=True)

# Candidate Portal Functions
def render_candidate_portal():
    st.title("🤖 Welcome to Your AI-Powered Interview")
    
    # Back button
    if st.button("← Back to Role Selection"):
        st.session_state.selected_role = None
        # Reset candidate state
        st.session_state.candidate_id = None
        st.session_state.interview_active = False
        st.session_state.current_question = ""
        st.session_state.qa_transcript = []
        st.session_state.error_message = ""
        st.session_state.token = None
        st.rerun()
    
    # Login Form
    if not st.session_state.candidate_id:
        st.header("Login to Your Interview")
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        if st.button("Login and Begin Interview", type="primary"):
            if not email.strip() or not password.strip():
                st.warning("Please enter both email and password.")
            else:
                with st.spinner("Logging in and preparing your interview..."):
                    try:
                        payload = {"email": email.strip(), "password": password.strip()}
                        response = requests.post("http://127.0.0.1:8000/user/login", json=payload)
                        response.raise_for_status()
                        data = response.json()
                        user_id = data["user"]["id"]
                        token = data["token"]
                        # Start interview
                        headers = {"Authorization": f"Bearer {token}"}
                        start_payload = {"candidate_id": user_id}
                        start_response = requests.post(API_START_INTERVIEW, json=start_payload, headers=headers)
                        start_response.raise_for_status()
                        start_data = start_response.json()
                        if start_data.get("reports") and len(start_data["reports"]) > 0:
                            report_data = start_data["reports"][0]
                            if report_data.get("status") == "started":
                                st.session_state.candidate_id = user_id
                                st.session_state.token = token
                                st.session_state.current_question = report_data["question"]
                                st.session_state.interview_active = True
                                st.session_state.qa_transcript = []
                                st.session_state.error_message = ""
                                st.rerun()
                            else:
                                st.error(report_data.get("message", "An unknown error occurred."))
                        else:
                            st.error("Invalid response format from server")
                    except Exception as e:
                        st.error(f"Could not start interview, check your email and password: {e}")

    # Interview Interface
    elif st.session_state.candidate_id and st.session_state.interview_active:
        st.success("Your session is active. Please answer the questions below.")
        # Display chat history
        for item in st.session_state.qa_transcript:
            st.chat_message("ai", avatar="🤖").write(item["question"])
            st.chat_message("human", avatar="👤").write(item["answer"])

        # Display current question and answer form
        st.chat_message("ai", avatar="🤖").write(st.session_state.current_question)
        with st.form("answer_form", clear_on_submit=True):
            answer = st.text_area("Your Answer:", height=150, key="answer_input")
            submit_answer = st.form_submit_button("Submit Answer")

            if submit_answer:
                if not answer.strip():
                    st.warning("Please provide an answer.")
                else:
                    with st.spinner("AI is analyzing your answer..."):
                        st.session_state.qa_transcript.append({"question": st.session_state.current_question, "answer": answer})
                        try:
                            headers = {"Authorization": f"Bearer {st.session_state.token}"}
                            payload = {"candidate_id": st.session_state.candidate_id, "answer": answer}
                            response = requests.post(API_SUBMIT_ANSWER, json=payload, headers=headers)
                            response.raise_for_status()
                            data = response.json()

                            # Extract from reports array
                            if data.get("reports") and len(data["reports"]) > 0:
                                report_data = data["reports"][0]
                                if report_data["status"] == "ongoing":
                                    st.session_state.current_question = report_data["question"]
                                elif report_data["status"] == "completed":
                                    st.session_state.interview_active = False
                                    st.session_state.qa_transcript = report_data.get("final_transcript", [])
                                st.rerun()
                            else:
                                st.error("Invalid response format from server")

                        except Exception as e:
                            st.error(f"Error submitting answer: {e}")
                            st.session_state.qa_transcript.pop()

    # End Screen
    elif st.session_state.candidate_id and not st.session_state.interview_active:
        st.success("Thank you! Your interview is now complete.")
        st.header("Final Interview Transcript")
        st.json(st.session_state.qa_transcript)
        if st.button("End Session"):
            st.session_state.candidate_id = None
            st.rerun()

# Main App Logic
def main():
    if st.session_state.selected_role is None:
        render_role_selection()
    elif st.session_state.selected_role == "admin":
        render_admin_portal()
    elif st.session_state.selected_role == "candidate":
        render_candidate_portal()

if __name__ == "__main__":
    main()