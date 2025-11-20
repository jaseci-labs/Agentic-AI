import streamlit as st
import time
import json
import requests

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
        st.title("Welcome to Travel Planner AI!")
        if st.button("Clear Conversation"):
            st.session_state.messages = []
            st.rerun()

def main():
    sidebar()
    st.title("✈️ Travel Planner AI")
    initialize_session_state()
    display_chat_messages()

    prompt = st.chat_input("What are your travel plans?")
    if prompt:
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        with st.chat_message("assistant"):
            message_placeholder = st.empty()
            
            with st.spinner("Thinking..."):
                payload = {"user_message": prompt}
                try:
                    response = requests.post(
                        "http://localhost:8000/walker/chat",
                        json=payload,
                        timeout=500
                    )
                    response.raise_for_status()
                    data = response.json()
                    agent_response = data.get("reports", [{}])[0].get("response", "Sorry, no response.")
                except Exception as e:
                    agent_response = f"Error: {e}"
            
            message_placeholder.markdown(agent_response)
            st.session_state.messages.append({"role": "assistant", "content": agent_response})
            
        

if __name__ == "__main__":
    main()