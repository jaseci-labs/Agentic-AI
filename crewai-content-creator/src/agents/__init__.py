"""Agents for the marketing team."""

import base64
import os
from crewai import Agent
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI

import openlit

load_dotenv()

LANGFUSE_PUBLIC_KEY = os.getenv("LANGFUSE_PUBLIC_KEY")
LANGFUSE_SECRET_KEY = os.getenv("LANGFUSE_SECRET_KEY")
LANGFUSE_AUTH = base64.b64encode(
    f"{LANGFUSE_PUBLIC_KEY}:{LANGFUSE_SECRET_KEY}".encode()
).decode()

os.environ["OTEL_EXPORTER_OTLP_HEADERS"] = f"Authorization=Basic {LANGFUSE_AUTH}"
openlit.init(disable_metrics=True)

from src.tools.browser_tools import (  # noqa: E402
    ExaSearchTool,
    WebCrawlingTool,
    web_search_tool,
)
from src.tools.document_tools import FileTools  # noqa: E402
from src.tools.stock_tools import StockTools  # noqa: E402
from src.tools.time_s import (  # noqa: E402
    get_analyst_recommendations_tool,
    get_company_info_tool,
    # get_company_news_tool,
    get_income_statements_tool,
    get_key_financial_ratios_tool,
    get_stock_fundamentals_tool,
    get_stock_time_series_tool,
    # yfinance_tools,
)
from src.utils.logging import add_log_entry  # noqa: E402


# LLMs
openai_llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

# llm = openai_llm.with_fallbacks([deepseek_llm])

llm = openai_llm

# Tools
web_search_tool_2 = ExaSearchTool.search
web_scrap_tool = WebCrawlingTool.open_webpage
js_web_scrap_tool = WebCrawlingTool.open_js_webpage
web_query_tool = WebCrawlingTool.query_webpage
query_document = FileTools.query_existing_document
open_folder = FileTools.open_user_documents_folder

stock_quote_tool = StockTools.get_stock_quote
stock_profile_tool = StockTools.get_stock_profile
stock_historical_prices_tool = StockTools.get_stock_historical_prices
stock_news_tool = StockTools.get_stock_news
income_statement_tool = StockTools.get_income_statement



def create_agents(session_id: str, verbose: bool = True) -> dict[str, Agent]:
    """Create agents for the investment advisory team."""
    # competitor_analyst_tools = tools + [query_screenshot]
    # tools = [
    #     web_search_tool,
    #     web_search_tool_2,
    #     web_scrap_tool,
    #     js_web_scrap_tool,
    #     web_query_tool,
    # ] + yfinance_tools

    user_profiler = Agent(
        role="Investor Profile Analyst",
        goal="""
        Analyze the requirement of the user and extract the information about the user's profile.
        """,
        backstory="""
        Intuitive and skilled in extracting meaningful insights about
        the kind of investment the user is looking for.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[],
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "user_profiler", "output": step_result}
        ),
    )

    market_analyst = Agent(
        role="Industry & Market Analyst",
        goal="""
        Identify the best performing companies in the present market.
        """,
        backstory="""
        Skilled in evaluating financial benchmarks, industry trends, and competitive positioning.
        Expert in extracting the best companies given the type of industry the user is looking for
        and the nature of the share price based on how much he is willing to invest and the number
        of shares he is looking for.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[web_search_tool, get_stock_fundamentals_tool],
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "market_analyst", "output": step_result}
        ),
    )

    deep_research_agent = Agent(
        role="Expert Research Analyst",
        goal="""
        Take a list and check how each company aligns with the user's investment goals.
        Should be able to short list the best companies based on the user's investment
        and risk tolerance strategy.
        """,
        backstory="""
        Highly analytical and intuitive agent that can take a list of companies and
        shortlist the best companies based on the user's investment strategy. Renowned for
        being able to dig deep and find the best companies based on the user's investment strategy.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[get_company_info_tool, get_analyst_recommendations_tool],
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "deep_research_agent", "output": step_result}
        ),
    )

    financial_analyst = Agent(
        role="Financial Analyst",
        goal="""
        Analyze the financial statements of a given company and extract the key
        financial metrics and ratios.
        """,
        backstory="""
        Proficient in analyzing financial statements and financial ratios.
        Specializes in evaluating financial statements. Has a hawkeye in identifying
        what makes the company stand out in the face of their competitors.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[
            get_stock_time_series_tool,
            get_key_financial_ratios_tool,
            get_income_statements_tool,
        ],
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "financial_analyst", "output": step_result}
        ),
    )

    news_agent = Agent(
        role="News Aggregation & Insights Agent",
        goal="""
        Monitor and summarize the latest updates about any given company, track industry trends,
        and extract key insights from social media relevant to the company.
        """,
        backstory="""
        A well-informed and proactive agent that keeps track of financial reports,
        strategic decisions, key announcements, and industry trends.
        Skilled at analyzing sentiment trends and emerging discussions from
        financial social media platforms to identify opportunities and risks.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[stock_news_tool],  # get_company_news_tool
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "news_agent", "output": step_result}
        ),
    )

    decision_maker = Agent(
        role="Chief Investment Officer",
        goal="""
        Assess financial, credit, market, and sentiment risks for a portfolio of stocks.
        Make the best investment recommendations based on the risk and return analysis that aligns
        with the user's investment goals.
        """,
        backstory="""
        A highly analytical and data-driven agent skilled in financial stability assessment,
        debt analysis, liquidity risk evaluation, macroeconomic forecasting, and stock sentiment analysis.
        Able to interpret financial performance, assess stock volatility, and predict market trends
        based on economic indicators, news, and investor sentiment. Known for having an eye for identifying
        the best performing companies that align with the user's investment goals.
        """,
        verbose=verbose,
        allow_delegation=False,
        tools=[],
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "decision_maker", "output": step_result}
        ),
    )

    investment_advisor = Agent(
        role="Investment Report Compiler",
        goal="""
        Compile a comprehensive investment advisory report for the user based on
        the findings from the Chief Investment Officer. Should be able to structure the
        insights into clear, actionable advice for the user. Also generate figures and tables
        to support the investment recommendations using acquired information by the Financial Analyst,
        and the News Aggregation & Insights Agent.
        """,
        backstory="""
        Skilled in financial report writing, risk assessment summaries, and
        investment recommendations. Expert at structuring insights into clear,
        actionable advice for investors. Also skilled in generating tables.
        """,
        verbose=verbose,
        allow_delegation=False,
        llm=llm,
        step_callback=lambda step_result: add_log_entry(
            session_id, {"agent": "investment_advisor", "output": step_result}
        ),
    )

    return {
        "user_profiler": user_profiler,
        "market_analyst": market_analyst,
        "deep_research_agent": deep_research_agent,
        "financial_analyst": financial_analyst,
        "news_agent": news_agent,
        "decision_maker": decision_maker,
        "investment_advisor": investment_advisor,
    }
