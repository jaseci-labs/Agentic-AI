import streamlit as st
import requests

# --- PAGE CONFIG ---
st.set_page_config(
    page_title="Jivas Assistant",
    layout="wide",  # This will make the central part wider
)

# --- CSS STYLING ---
st.markdown("""
    <style>
        /* Make the chat container wider and centered */
        .main > div {
            max-width: 1000px;
            padding-left: 50px;
            padding-right: 50px;
        }

        /* Push chat input to the bottom */
        .block-container {
            display: flex;
            flex-direction: column;
            height: 95vh;
        }

        .chat-container {
            flex-grow: 1;
            overflow-y: auto;
            margin-bottom: 1rem;
        }

        .chat-input {
            margin-top: auto;
        }

        /* Optional: slightly reduce margins for better space */
        .stChatInput {
            margin-bottom: 10px !important;
        }
    </style>
""", unsafe_allow_html=True)

# --- CONSTANTS ---
BASE_URL = "http://localhost:8000"
LOGIN_ENDPOINT = f"{BASE_URL}/user/login"
CHAT_ENDPOINT = f"{BASE_URL}/interact"

# --- SESSION STATE INIT ---
if 'token' not in st.session_state:
    st.session_state.token = None
if 'session_id' not in st.session_state:
    st.session_state.session_id = ""
if 'agent_id' not in st.session_state:
    st.session_state.agent_id = "n:Agent:688361e9c59dc3acab815526"
if 'chat_history' not in st.session_state:
    st.session_state.chat_history = []

# --- SIDEBAR LOGIN ---
with st.sidebar:
    st.title("🔐 Login")
    email = st.text_input("Email", value="admin@jivas.com")
    password = st.text_input("Password", type="password", value="password")
    if st.button("Login"):
        res = requests.post(LOGIN_ENDPOINT, json={"email": email, "password": password})
        if res.status_code == 200:
            st.session_state.token = res.json().get("token")
            st.success("Logged in successfully!")
        else:
            st.error("Login failed")

# --- TITLE ---
st.title("🤖 Jivas Assistant")

# --- TABS ---
tab1, tab2 = st.tabs(["💬 Chat", "📅 Scheduled Tasks"])

# ========================
#       CHAT INTERFACE
# ========================
with tab1:
    if not st.session_state.token:
        st.warning("Please login first using the sidebar.")
    else:
        # Layout container
        st.markdown('<div class="chat-container">', unsafe_allow_html=True)

        # Chat history first (top area)
        for entry in st.session_state.chat_history:
            with st.chat_message(entry["role"]):
                st.markdown(entry["content"], unsafe_allow_html=True)

        st.markdown('</div>', unsafe_allow_html=True)  # End chat-container

        # Chat input at the bottom
        prompt = st.chat_input("Ask me anything...")
        if prompt:
            st.chat_message("user").markdown(prompt)
            st.session_state.chat_history.append({"role": "user", "content": prompt})

            # Backend request
            headers = {"Authorization": f"Bearer {st.session_state.token}"}
            payload = {
                "utterance": prompt,
                "session_id": st.session_state.session_id,
                "agent_id": st.session_state.agent_id,
                "tts": "false",
                "data": {},
                "verbose": "false",
                "streaming": "false"
            }

            res = requests.post(CHAT_ENDPOINT, headers=headers, json=payload)

            if res.status_code == 200:
                try:
                    reports = res.json().get("reports", [])
                    if reports:
                        message = reports[0]["response"]["message"]["content"]
                        session_id = reports[0]["response"]["session_id"]
                        st.session_state.session_id = session_id  # Save session
                        st.chat_message("assistant").markdown(message)
                        st.session_state.chat_history.append({"role": "assistant", "content": message})
                    else:
                        st.error("No response from assistant.")
                except Exception as e:
                    st.error(f"Error parsing response: {e}")
            else:
                st.error(f"Error: {res.status_code}")

# ========================
#    SCHEDULED TASKS
# ========================
with tab2:
    st.header("📋 All Scheduled Tasks")
    st.info("This is a sample placeholder. Replace it once your API is ready.")

    sample_tasks = """
    ### 🗓️ Upcoming Tasks:
    - **October 26, 2023**
        - 📝 Finish marking all the papers by **11:59 PM**
    - **October 30, 2023**
        - 👬 Meet best friend at **8:00 AM**
        - 📄 Submit EE1234 first draft by **11:59 PM**
    - **November 2, 2023**
        - 📚 Finish all homework by **11:59 PM**
    """
    st.markdown(sample_tasks, unsafe_allow_html=True)
