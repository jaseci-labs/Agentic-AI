"""Streamlit application for the Investment Advisor."""

import os
import sys
import time
import uuid
from multiprocessing import Process, active_children

from src.api.db import read_db, write_db
from src.executor import CrewExecutor
from src.utils.logging import StreamToExpander
from src.utils.merge_reports import generate_pdf, merge_markdown_reports

import streamlit as st
from streamlit_option_menu import option_menu


if "investment_form_data" not in st.session_state:
    st.session_state.investment_form_data = {
        "session_id": str(uuid.uuid4()),
        "amount_of_investment": 0.0,
        "amount_of_shares": 0,
        "day_trading": False,
        "expected_roi": 0.0,
        "risk_profile": "Doesn't Matter",
    }

if "active_session_id" not in st.session_state:
    st.session_state.active_session_id = None


def run_crew_executor(session_id: str, task: str) -> None:
    """Runs CrewExecutor in a separate process."""
    executor = CrewExecutor(session_id, task)
    process = Process(target=executor.execute, name=session_id, daemon=True)
    process.start()


def stop_session(session_id: str) -> None:
    """Stop session."""
    try:
        for child in active_children():
            if child.name == session_id:
                child.kill()
                if child.is_alive():
                    time.sleep(3)
                assert not child.is_alive(), f"Failed to stop session {session_id}"
                break
        else:
            raise Exception(f"Session {session_id} not found")
    except Exception as e:
        print(str(e))


def tab_questionnaire() -> None:
    """Investment Questionnaire Tab."""
    st.subheader("Investment Questionnaire")
    st.write("Fill out the form below to receive personalized investment insights.")
    form_data = st.session_state.investment_form_data

    with st.form("investment_form"):
        risk_profile = st.selectbox(
            "Risk Profile",
            ["High Return", "Low Risk", "Doesn't Matter"],
            index=["High Return", "Low Risk", "Doesn't Matter"].index(
                form_data["risk_profile"]
            ),
        )
        amount_of_investment = st.number_input(
            "Investment Amount ($)",
            min_value=0.0,
            step=100.0,
            format="%.2f",
            value=form_data["amount_of_investment"],
        )
        amount_of_shares = st.number_input(
            "Amount of Shares",
            min_value=0,
            step=10,
            value=form_data["amount_of_shares"],
        )
        expected_roi = st.number_input(
            "Expected ROI (%)",
            min_value=0.0,
            step=0.5,
            format="%.2f",
            value=form_data["expected_roi"],
        )
        day_trading = st.checkbox(
            "Are you a day trader?", value=form_data["day_trading"]
        )

        submitted = st.form_submit_button("Submit")

    if submitted:
        session_id = str(uuid.uuid4())
        new_data = {
            "risk_profile": risk_profile,
            "amount_of_investment": amount_of_investment,
            "amount_of_shares": amount_of_shares,
            "day_trading": day_trading,
            "expected_roi": expected_roi,
        }
        existing_data = read_db()
        existing_data[session_id] = new_data
        write_db(existing_data)

        st.session_state.investment_form_data = {
            "session_id": str(uuid.uuid4()),
            "amount_of_investment": 0.0,
            "amount_of_shares": 0,
            "day_trading": False,
            "expected_roi": 0.0,
            "risk_profile": "Doesn't Matter",
        }

        try:
            st.success(
                f"Investment Analysis started successfully for Session ID: {session_id}"
            )
            with st.status(
                "🤖 **Agents at work...**", state="running", expanded=True
            ) as status:
                with st.container(height=500, border=False):
                    sys.stdout = StreamToExpander(st)
                    executor = CrewExecutor(session_id, "market_analysis")
                    st.session_state.active_session_id = session_id

                    start_time = time.time()
                    executor.execute()
                    end_time = time.time()

                    execution_time = end_time - start_time
                    # st.write(f"⏳ **Session Execution Time:** {execution_time:.2f} seconds")
                status.update(
                    label="✅ Investment Analysis is Ready! Time Taken (seconds): {:.2f}".format(
                        execution_time
                    ),
                    state="complete",
                    expanded=False,
                )
        except Exception as e:
            st.error(f"Error executing CrewExecutor: {str(e)}")


def tab_intro() -> None:
    """Intro Tab."""
    st.title("Welcome to the Investment Advisor App")
    st.write("This application provides personalized investment insights and tools.")


def tab_chat() -> None:
    """Chat Tab Placeholder."""
    st.subheader("Chat")
    st.write("Chat functionality coming soon!")


def tab_investment_report() -> None:
    """Investment Report Tab: Automatically retrieves the latest session ID and displays the report."""
    st.subheader("Comprehensive Investment Advisory Report")
    session_id = st.session_state.active_session_id
    if session_id:
        st.write(f"Using latest session ID: **{session_id}**")
        merge_markdown_reports(session_id)
        if st.button("Generate PDF"):
            generate_pdf(session_id)

        report_file = os.path.join(
            os.getcwd(), "reports", session_id, "comprehensive_report.md"
        )
        try:
            with open(report_file, "r", encoding="utf-8") as f:
                report_content = f.read()
            st.markdown(report_content, unsafe_allow_html=True)
        except FileNotFoundError:
            st.error(
                "The comprehensive report file was not found. Please ensure the session reports exist and generate the report first."
            )
    else:
        st.warning("No session ID found. Please complete the investment form first.")


def main() -> None:
    """Main Streamlit Application."""
    st.set_page_config(page_title="Investment Advisor", page_icon="💰", layout="wide")
    tabs = ["Intro", "Investment Form", "Chat", "Investment Report"]

    with st.sidebar:
        current_tab = option_menu("Navigation", tabs, menu_icon="cast", default_index=0)
        if st.session_state.active_session_id and st.button(
            "Stop Session", key="stop_session_button"
        ):
            stop_session(st.session_state.active_session_id)
            st.session_state.active_session_id = None
            st.success("Session has been stopped.")

    tab_functions = {
        "Intro": tab_intro,
        "Investment Form": tab_questionnaire,
        "Chat": tab_chat,
        "Investment Report": tab_investment_report,
    }

    if current_tab in tab_functions:
        tab_functions[current_tab]()


if __name__ == "__main__":
    main()
