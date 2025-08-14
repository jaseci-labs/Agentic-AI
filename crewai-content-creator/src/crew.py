"""Marketing Crew."""

from crewai import Crew, Process

from src.agents import create_agents
from src.tasks import create_advise_on_investment_tasks


def create_investment_advisory_crew(
    session_id: str,
    risk_profile: str,
    amount_of_investment: str,
    amount_of_shares: str,
    day_trading: str,
    expected_roi: str,
) -> Crew:
    """Create a CrewAI setup for Market Research."""
    agents = create_agents(session_id, verbose=True)
    tasks = create_advise_on_investment_tasks(
        session_id,
        risk_profile,
        amount_of_investment,
        amount_of_shares,
        day_trading,
        expected_roi,
        agents,
    )

    return Crew(
        agents=list(agents.values()),
        tasks=list(tasks),
        verbose=True,
        # manager_llm=llm,
        process=Process.sequential,
        memory=False,
        cache=True,
        output_log_file=True,
    )
