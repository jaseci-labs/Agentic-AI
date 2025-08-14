"""INVESTMENT ADVISORY Tasks Module."""

import os

# from typing import Optional
from crewai import Agent, Task

from src.config.report_paths import (
    DECISION_MAKING_FILE,
    DEEP_LEVEL_MARKET_ANALYSIS_FILE,
    FINANCIAL_ANALYSIS_FILE,
    INVESTMENT_ADVISORY_REPORT,
    NEWS_ANALYSIS_FILE,
    TOP_LEVEL_MARKET_ANALYSIS_FILE,
    USER_PROFILE_FILE,
)


def create_advise_on_investment_tasks(
    session_id: str,
    risk_profile: str,
    amount_of_investment: str,
    amount_of_shares: str,
    day_trading: str,
    expected_roi: str,
    agents: dict[str, Agent],
) -> list[Task]:
    """Analyze the environment surrounding the investment and advise the user."""

    def get_user_file_path(file_template: str) -> str:
        """Generate the file path for the user's report."""
        file_path = file_template.format(session_id=session_id)
        report_dir = os.path.dirname(file_path)
        os.makedirs(report_dir, exist_ok=True)
        return file_path

    # Task to analyze the financial health of the company
    analyze_user_profile = Task(
        description=f"""
        Conduct an in-depth analysis of the user based on the information provided by the user.

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Perform analysis on:
            1. Risk/Return profile of the user based on the risk profile and expected ROI.
            2. Class of the investor based on budget and day trader status.
            3. Nature of share price range based on budget and number of shares.
            4. Possible industries depending on the nature (eg. dynamic, stable, fast growing, etc.)
        """,
        expected_output="""
        A structured markdown report covering:
            1. Risk/Return profile of the user
            2. Class of the investor
            3. Nature of share price range
            4. Possible industries depending on the nature
        """,
        agent=agents["user_profiler"],
        output_file=get_user_file_path(USER_PROFILE_FILE),
    )

    # Task to understand the industry of interest
    top_level_market_analysis = Task(
        description=f"""
        Conduct a comprehensive analysis of the US Market. Identify the top 20 companies
        that are performing well in the market and compatible with the user's profile.
        Try to use the latest data wherever possible (as of 2025 March).

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Key areas of analysis:
            1. Identify top 25 companies in the US Market that are performing well.
            2. Identify top 25 companies in the industries overall, identified by the user profiler agent.
            3. From the list of companies, shortlist the top 20 companies.
        """,
        expected_output="""
        A structured markdown report covering:
            1. Short listed companies.

        """,
        agent=agents["market_analyst"],
        output_file=get_user_file_path(TOP_LEVEL_MARKET_ANALYSIS_FILE),
        context=[analyze_user_profile],
    )

    # Task to understand the stock market in the industry of interest
    deep_level_market_analysis = Task(
        description=f"""
        Perform an in-depth market analysis for the short listed companies and evaluate
        investment potential depending on the user's profile. Try to use the latest data
        wherever possible (as of 2025 March).

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Key areas of analysis:
            1. Analyze how each company potentially aligns with the user's profile.
            2. Further shortlist the companies based on compatibility with the user's profile to top 10.
            Keep in mind how much the share price will be approximately depending on the amount of investment
            and the number of shares the user is looking for. Flexibility can be offered as long as the share price
            is well within the user's budget.
        """,
        expected_output="""
        A structured markdown report covering:
            1. Top 10 high performing companies that match the user's investment profile.
        """,
        agent=agents["deep_research_agent"],
        output_file=get_user_file_path(DEEP_LEVEL_MARKET_ANALYSIS_FILE),
        context=[analyze_user_profile, top_level_market_analysis],
    )

    # Task to identify the biggest competitors to the target company
    financial_analysis = Task(
        description=f"""
        Analyze the financial statements of the short listed companies and extract the key
        financial metrics and ratios.

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Conduct research on:
            1. Revenue and profitability metrics for each company.
            2. Financial ratios and key performance indicators for each company.
            3. Market share and growth trends for each company.
            4. Cashflow and liquidity insights for each company.
            5. Debt exposure and risk analysis for each company.
        """,
        expected_output="""
        A structured markdown report covering:
            1. Key financial metrics and ratios for each company.
            2. Market share and growth trends for each company.
            3. Risk profile of each company.
            4. Rank the companies based on the financial metrics and ratios.
        """,
        agent=agents["financial_analyst"],
        output_file=get_user_file_path(FINANCIAL_ANALYSIS_FILE),
        context=[deep_level_market_analysis],
    )

    seek_information = Task(
        description=f"""
        Gather and analyze recent news and media coverage related to the companies
        to assess sentiment, trends, and potential investment risks.
        Try to use the latest data wherever possible (as of 2025 March).

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Key areas of analysis:
            1. Recent news articles, financial reports, and press releases of each company.
            2. Public sentiment and media perception of each company.
            3. Key events impacting the relevant industry (mergers, acquisitions, regulations, etc.)
            of each company.
            4. Emerging opportunities or risks highlighted in recent news of each company.
        """,
        expected_output="""
        A structured markdown report covering:
            1. Recent news and media coverage of each company.
            2. Public sentiment and media perception analysis of each company.
            3. Industry-impacting events and developments of each company.
            4. Emerging risks and investment opportunities of each company.
            5. Rank the companies based on the news and sentiment analysis.
        """,
        agent=agents["news_agent"],
        output_file=get_user_file_path(NEWS_ANALYSIS_FILE),
        context=[deep_level_market_analysis],
    )

    decision_making = Task(
        description=f"""
        Conduct a detailed assessment for investing in the shortlisted companies.
        Try to use the latest data wherever possible (as of 2025 March).

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        Key areas of analysis:
            1. Critically analyze and compare the financial analysis for the companies.
            2. Critically analyze and compare the market analysis for the companies.
            3. Critically analyze and compare the news analysis for the companies.
            4. Rank the companies based on the analysis.
        """,
        expected_output="""
        A structured markdown report covering:
            1. A comprehensive analysis of the companies.
            2. A well-structured recommendation report based on the analysis.
            3. Top 5 companies that are most suitable for investment based on the analysis.
        """,
        agent=agents["decision_maker"],
        output_file=get_user_file_path(DECISION_MAKING_FILE),
        context=[
            deep_level_market_analysis,
            financial_analysis,
            seek_information,
        ],
    )

    # Task to create the summary for the demand generation campaign plan
    advise_user = Task(
        description="""
        Compile a comprehensive investment advisory report for the user based on
        the findings from the Decision Maker. Try to use the latest data
        wherever possible (as of 2025 March).

        Consider the following information provided by the user:
            - Risk Profile: {risk_profile}
            - Budget: {amount_of_investment}
            - Number of shares: {amount_of_shares}
            - Day Trader (Yes/No): {day_trading}
            - Expected ROI: {expected_roi}

        The report should synthesize insights from:
            1. Decision making analysis.

        You must extract all of the relevant information that would be useful in terms of
        making an investment decision. Provide a well-structured elaborative investment
        recommendation report based on the findings.
        """,
        expected_output="""
        A structured markdown investment advisory report covering:
            1. Top 5 investable companies for the user.
            2. A well-structured recommendation report based on the analysis.
            3. A summary of the analysis.
        """,
        agent=agents["investment_advisor"],
        output_file=get_user_file_path(INVESTMENT_ADVISORY_REPORT),
        context=[decision_making],
    )

    tasks = [
        analyze_user_profile,
        top_level_market_analysis,
        deep_level_market_analysis,
        financial_analysis,
        seek_information,
        decision_making,
        advise_user,
    ]
    return tasks
