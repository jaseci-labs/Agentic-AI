import streamlit as st
import requests
import pandas as pd

JAC_SERVER_URL = "http://localhost:8000"
API_REGISTER_CANDIDATES = f"{JAC_SERVER_URL}/walker/RegisterCandidatesWalker"

st.set_page_config(layout="wide", page_title="Admin: Create Interviews")
st.title("🏢 Admin Portal: Create Interview Sessions")
st.write("Use this portal to define a job role and register candidates. Each registered candidate will receive a unique Session ID to take their interview.")

# Session State for Admin App
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
        st.write(f"Registering candidates for: **{st.session_state.job_context['job_role']}**")
        with st.form("candidates_form"):
            candidates_data = []
            for i in range(5): # Allow up to 5 candidates
                st.markdown(f"**Candidate {i+1}**")
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