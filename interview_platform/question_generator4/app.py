import streamlit as st
import requests
import pandas as pd

JAC_SERVER_URL = "http://localhost:8000"
API_REGISTER_CANDIDATES = f"{JAC_SERVER_URL}/walker/RegisterCandidatesWalker"
API_START_INTERVIEW = f"{JAC_SERVER_URL}/walker/StartInterviewWalker"
API_SUBMIT_ANSWER = f"{JAC_SERVER_URL}/walker/SubmitAnswerWalker"

st.set_page_config(layout="wide", page_title="Interview Platform")
st.title("🎤 Interview Platform")

# Create tabs for Company and Candidate functionalities
tabs = st.tabs(["Company Functions", "Candidate Functions"])

# Company Functions Tab
with tabs[0]:
    st.header("🏢 Company Portal: Create Interview Sessions")
    st.write("Define a job role and register candidates for interviews.")

    # Session State for Company
    if 'created_sessions' not in st.session_state:
        st.session_state.created_sessions = []

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
            st.write(f"Registering candidates for: **{st.session_state.job_context['job_role']}**")
            with st.form("candidates_form"):
                candidates_data = []
                for i in range(5):  # Allow up to 5 candidates
                    st.markdown(f"**Candidate {i + 1}**")
                    name = st.text_input(f"Name", key=f"name_{i}")
                    email = st.text_input(f"Email", key=f"email_{i}")
                    if name and email:
                        candidates_data.append({"name": name, "email": email})

                candidates_form_submitted = st.form_submit_button("Register Candidates and Generate IDs", type="primary")

                if candidates_form_submitted:
                    if not candidates_data:
                        st.error("Please enter details for at least one candidate.")
                    else:
                        with st.spinner("Registering candidates and creating secure sessions..."):
                            try:
                                payload = {
                                    "job_context": st.session_state.job_context,
                                    "candidates": candidates_data
                                }
                                response = requests.post(API_REGISTER_CANDIDATES, json=payload)
                                response.raise_for_status()
                                data = response.json()

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

# Candidate Functions Tab
with tabs[1]:
    st.header("🤖 Candidate Portal: Join Your Interview")
    
    # Session State Management
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

    # Session ID Entry
    if not st.session_state.candidate_id:
        st.header("Please Enter Your Interview Session ID")
        candidate_id_input = st.text_input("Session ID", placeholder="Enter the ID provided by the company")

        if st.button("Begin Interview", type="primary"):
            if not candidate_id_input.strip():
                st.warning("Please enter a valid Session ID.")
            else:
                with st.spinner("Verifying your session and preparing the first question..."):
                    try:
                        payload = {"candidate_id": candidate_id_input.strip()}
                        response = requests.post(API_START_INTERVIEW, json=payload)
                        response.raise_for_status()
                        data = response.json()

                        if data.get("reports") and len(data["reports"]) > 0:
                            report_data = data["reports"][0]
                            if report_data.get("status") == "started":
                                st.session_state.candidate_id = candidate_id_input.strip()
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
                        st.error(f"Could not start interview. Error: {e}")

    # Interview Interface
    elif st.session_state.candidate_id and st.session_state.interview_active:
        st.success("Your session is active. Please answer the questions below.")
        for item in st.session_state.qa_transcript:
            st.chat_message("ai", avatar="🤖").write(item["question"])
            st.chat_message("human", avatar="👤").write(item["answer"])

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
                            payload = {"candidate_id": st.session_state.candidate_id, "answer": answer}
                            response = requests.post(API_SUBMIT_ANSWER, json=payload)
                            response.raise_for_status()
                            data = response.json()

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