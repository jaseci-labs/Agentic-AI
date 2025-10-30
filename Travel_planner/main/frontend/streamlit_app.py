import streamlit as st
import time

st.set_page_config(
    page_title="Travel Planner AI",
    page_icon="✈️",
    layout="wide"
)

def initialize_session_state():
    if "messages" not in st.session_state:
        st.session_state.messages = []

def display_chat_messages():
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

def sidebar():
    with st.sidebar:
        st.title("🛠️ Settings")
        
        # Add travel preferences
        st.subheader("Travel Preferences")
        budget = st.slider("Budget ($)", 100, 10000, 1000, 100)
        duration = st.slider("Duration (days)", 1, 30, 7)
        
        # Travel style
        st.subheader("Travel Style")
        travel_style = st.multiselect(
            "Select your interests",
            ["Culture & History", "Nature & Adventure", "Food & Dining", 
             "Nightlife & Entertainment", "Shopping", "Relaxation"],
            default=["Culture & History"]
        )
        
        # Clear conversation button
        if st.button("Clear Conversation"):
            st.session_state.messages = []
            st.experimental_rerun()

def main():
    # Sidebar
    sidebar()
    
    # Main content
    st.title("✈️ Travel Planner AI")
    
    initialize_session_state()
    display_chat_messages()

    if prompt := st.chat_input("What are your travel plans?"):
        # Add user message to chat history
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        # Add assistant response to chat history
        with st.chat_message("assistant"):
            message_placeholder = st.empty()
            # Simulate stream of response with milliseconds delay
            full_response = "I'm your travel planning assistant! I can help you plan your trip. However, I'm currently in development mode."
            for chunk in full_response.split():
                time.sleep(0.05)
                message_placeholder.markdown(f"{chunk} ", unsafe_allow_html=True)
            
        st.session_state.messages.append({"role": "assistant", "content": full_response})

if __name__ == "__main__":
    main()