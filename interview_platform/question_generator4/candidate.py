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

                    # Extract from reports array
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
                        payload = {"candidate_id": st.session_state.candidate_id, "answer": answer}
                        response = requests.post(API_SUBMIT_ANSWER, json=payload)
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