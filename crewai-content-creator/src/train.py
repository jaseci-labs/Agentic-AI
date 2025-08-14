"""This module contains the training logic for the Investment Advisory Crew."""

# train_crew.py
from crew import create_investment_advisory_crew


def train_crew(n_iterations: int = 2) -> None:
    """Train the Investment Advisory Crew."""
    crew = create_investment_advisory_crew(
        session_id="training_session",
        target_company="Tesla",
        industry="Electric Vehicles",
        investment_type="Growth Investing",
        amount_of_investment="$1,000,000",
        holding_duration="5 years",
        strategy_keywords=["long-term", "market expansion"],
        risk_profile="moderate",
    )

    # 2. Train the Crew
    crew.train(n_iterations=n_iterations, filename="trained_agents.pkl")

    print("Training finished successfully. Model saved as trained_agents.pkl")


if __name__ == "__main__":
    train_crew(n_iterations=1)
