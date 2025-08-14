"""Report Paths Configuration."""

import os

# Base directory for reports
BASE_REPORT_DIR = "reports/{session_id}"

# Define paths for various analysis reports
USER_PROFILE_FILE = os.path.join(BASE_REPORT_DIR, "user_profile.md")
TOP_LEVEL_MARKET_ANALYSIS_FILE = os.path.join(
    BASE_REPORT_DIR, "top_level_market_analysis.md"
)
DEEP_LEVEL_MARKET_ANALYSIS_FILE = os.path.join(
    BASE_REPORT_DIR, "deep_level_market_analysis.md"
)
FINANCIAL_ANALYSIS_FILE = os.path.join(BASE_REPORT_DIR, "financial_analysis.md")
NEWS_ANALYSIS_FILE = os.path.join(BASE_REPORT_DIR, "news_analysis.md")
DECISION_MAKING_FILE = os.path.join(BASE_REPORT_DIR, "decision_making.md")
INVESTMENT_ADVISORY_REPORT = os.path.join(
    BASE_REPORT_DIR, "investment_advisory_report.md"
)
