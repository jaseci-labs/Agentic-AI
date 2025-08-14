"""Crew Execution."""

import argparse
import traceback

from src.api.db import get_session
from src.crew import create_investment_advisory_crew


def market_analysis(session_id: str, all_answers: list) -> None:
    """Execute Market Analysis."""
    market_analysis_crew = create_investment_advisory_crew(session_id, *all_answers)
    market_analysis_crew.kickoff()
    # if hasattr(crew_result, "raw"):
    #     result = crew_result.raw
    # else:
    #     result = str(crew_result)


class CrewExecutor:
    """Crew Executor."""

    def __init__(self, session_id: str, task: str) -> None:
        """Init."""
        self.session_id = session_id
        self.task = task

    @property
    def session(self) -> dict:
        """Session."""
        onboard_qa = get_session(self.session_id)
        return onboard_qa

    def execute(self) -> None:
        """Execute."""
        try:
            session_data = self.session

            if not session_data:
                raise ValueError(f"No data found for session_id: {self.session_id}")

            # Extract relevant fields
            risk_profile = session_data.get("risk_profile", "Doesn't Matter")
            amount_of_investment = session_data.get("amount_of_investment", 0.0)
            amount_of_shares = session_data.get("amount_of_shares", 0)
            day_trading = session_data.get("day_trading", False)
            expected_roi = session_data.get("expected_roi", 0.0)

            # Prepare arguments for market_analysis
            all_answers = [
                risk_profile,
                amount_of_investment,
                amount_of_shares,
                day_trading,
                expected_roi,
            ]

            if self.task == "market_analysis":
                market_analysis(self.session_id, all_answers)
            else:
                raise ValueError(f"Task {self.task} not found.")

        except Exception as e:
            print(f"Error in executing task {self.task}\n{traceback.format_exc()}")
            print(f"Error: {str(e)}")
            traceback.print_exc()


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()

    parser = argparse.ArgumentParser(description="Crew Executor")
    parser.add_argument("session_id", type=str, help="Session ID")
    parser.add_argument(
        "task",
        type=str,
        choices=[
            "market_analysis",
        ],
        help="Task",
    )
    args = parser.parse_args()
    crew_executor = CrewExecutor(args.session_id, args.task)
    crew_executor.execute()
