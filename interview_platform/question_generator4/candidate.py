import streamlit as st
import requests

JAC_SERVER_URL = "http://localhost:8000"
API_START_INTERVIEW = f"{JAC_SERVER_URL}/walker/StartInterviewWalker"
API_SUBMIT_ANSWER = f"{JAC_SERVER_URL}/walker/SubmitAnswerWalker"

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


st.set_page_config(layout="centered", page_title="AI Interview")
st.title("🤖 Welcome to Your AI-Powered Interview")


if 'token' not in st.session_state:
    st.session_state.token = None

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