"""This module contains tools for fetching stock data using the yfinance library."""

import json
from langchain.tools import StructuredTool
from langchain.tools import Tool

import yfinance as yf


def value_to_crores(value: int) -> float:
    """Convert a value to crores."""
    return round(value / 10**7, 2)


def get_stock_time_series(symbol: str, period: str = "1mo") -> str:
    """Returns a text summary (up to 10 rows) of historical stock time-series data for `symbol`."""
    try:
        stock = yf.Ticker(symbol)
        history = stock.history(period=period)
        if history.empty:
            return f"No data found for {symbol} over period: {period}."

        summary_lines = [f"📊 Stock Time Series for {symbol} (Period: {period})\n"]
        for date, row in history.iterrows():
            summary_lines.append(
                f"{date.strftime('%Y-%m-%d')}: "
                f"Open: ${row['Open']:.2f}, "
                f"High: ${row['High']:.2f}, "
                f"Low: ${row['Low']:.2f}, "
                f"Close: ${row['Close']:.2f}, "
                f"Volume: {int(row['Volume'])}"
            )
        return "\n".join(summary_lines[:10])
    except Exception as exc:
        return f"Error fetching stock data for {symbol}: {exc}"


def get_company_info(symbol: str) -> str:
    """Returns JSON containing company profile and overview for a given stock symbol."""
    try:
        company_info_full = yf.Ticker(symbol).info
        if not company_info_full:
            return f"Could not fetch company info for {symbol}"

        company_info_cleaned = {
            "Name": company_info_full.get("shortName"),
            "Symbol": company_info_full.get("symbol"),
            "Current Stock Price": company_info_full.get(
                "regularMarketPrice", company_info_full.get("currentPrice")
            ),
            "Market Cap": f"{value_to_crores(company_info_full.get('marketCap', 0))}+Crs",
            "Sector": company_info_full.get("sector"),
            "Industry": company_info_full.get("industry"),
            "Address": company_info_full.get("address1"),
            "City": company_info_full.get("city"),
            "State": company_info_full.get("state"),
            "Country": company_info_full.get("country"),
            "Phone": company_info_full.get("phone"),
            "Website": company_info_full.get("website"),
            "Description": company_info_full.get("longBusinessSummary"),
            "Employees": company_info_full.get("fullTimeEmployees"),
            "Founded": company_info_full.get("firstTradeDateEpochUtc"),
        }
        return json.dumps(company_info_cleaned, indent=2)
    except Exception as e:
        return f"Error fetching company profile for {symbol}: {e}"


def get_historical_stock_prices(
    symbol: str, period: str = "1mo", interval: str = "5d"
) -> str:
    """Returns JSON with historical price data for a given stock symbol."""
    try:
        stock = yf.Ticker(symbol)
        historical_price = stock.history(period=period, interval=interval)
        return historical_price.to_json(orient="index")
    except Exception as e:
        return f"Error fetching historical prices for {symbol}: {e}"


def get_stock_fundamentals(symbol: str) -> str:
    """Returns JSON containing fundamental data for a given stock symbol."""
    try:
        stock = yf.Ticker(symbol)
        info = stock.info
        fundamentals = {
            "Market Cap": info.get("marketCap"),
            "Enterprise Value": info.get("enterpriseValue"),
            "Trailing P/E": info.get("trailingPE"),
            "Forward P/E": info.get("forwardPE"),
            "PEG Ratio": info.get("pegRatio"),
            "Price to Book": info.get("priceToBook"),
            "Dividend Yield": info.get("dividendYield"),
            "Profit Margins": info.get("profitMargins"),
            "Operating Margins": info.get("operatingMargins"),
            "Return on Equity": info.get("returnOnEquity"),
            "Return on Assets": info.get("returnOnAssets"),
            "Revenue": info.get("totalRevenue"),
            "Revenue Growth": info.get("revenueGrowth"),
            "Gross Profits": info.get("grossProfits"),
            "Free Cash Flow": info.get("freeCashflow"),
            "Operating Cash Flow": info.get("operatingCashflow"),
        }
        return json.dumps(fundamentals, indent=2)
    except Exception as e:
        return f"Error getting fundamentals for {symbol}: {e}"


def get_income_statements(symbol: str) -> str:
    """Returns JSON containing income statements for a given stock symbol."""
    try:
        stock = yf.Ticker(symbol)
        financials = stock.financials
        return financials.to_json(orient="index")
    except Exception as e:
        return f"Error fetching income statements for {symbol}: {e}"


def get_key_financial_ratios(symbol: str) -> str:
    """Returns JSON containing key financial ratios for a given stock symbol."""
    try:
        stock = yf.Ticker(symbol)
        key_ratios = stock.info
        return json.dumps(key_ratios, indent=2)
    except Exception as e:
        return f"Error fetching key financial ratios for {symbol}: {e}"


def get_analyst_recommendations(symbol: str) -> str:
    """Returns JSON containing analyst recommendations for a given stock symbol."""
    try:
        stock = yf.Ticker(symbol)
        recommendations = stock.recommendations
        return recommendations.to_json(orient="index")
    except Exception as e:
        return f"Error fetching analyst recommendations for {symbol}: {e}"


def get_company_news(symbol: str, num_stories: int = 3) -> str:
    """Returns JSON containing recent news/press releases for a given stock symbol."""
    try:
        news = yf.Ticker(symbol).news
        return json.dumps(news[:num_stories], indent=2)
    except Exception as e:
        return f"Error fetching company news for {symbol}: {e}"


def get_technical_indicators(symbol: str, period: str = "5d") -> str:
    """Returns JSON containing technical indicators for a given stock symbol over a specified period."""
    try:
        indicators = yf.Ticker(symbol).history(period=period)
        return indicators.to_json(orient="index")
    except Exception as e:
        return f"Error fetching technical indicators for {symbol}: {e}"


# Create LangChain Tool objects
get_stock_time_series_tool = StructuredTool.from_function(
    name="get_stock_time_series",
    func=get_stock_time_series,
    description="Fetches historical stock time-series data for a given symbol over a specified period.",
)

get_company_info_tool = Tool(
    name="get_company_info",
    func=get_company_info,
    description="Fetches company profile and overview information for a given stock symbol.",
)

get_historical_stock_prices_tool = StructuredTool.from_function(
    name="get_historical_stock_prices",
    func=get_historical_stock_prices,
    description="Fetches historical price data for a given stock symbol over a specified period and interval.",
)

get_stock_fundamentals_tool = Tool(
    name="get_stock_fundamentals",
    func=get_stock_fundamentals,
    description="Fetches fundamental data for a given stock symbol including market cap, P/E ratios, etc.",
)

get_income_statements_tool = Tool(
    name="get_income_statements",
    func=get_income_statements,
    description="Fetches income statements for a given stock symbol.",
)

get_key_financial_ratios_tool = Tool(
    name="get_key_financial_ratios",
    func=get_key_financial_ratios,
    description="Fetches key financial ratios for a given stock symbol.",
)

get_analyst_recommendations_tool = Tool(
    name="get_analyst_recommendations",
    func=get_analyst_recommendations,
    description="Fetches analyst recommendations for a given stock symbol.",
)

get_company_news_tool = StructuredTool.from_function(
    name="get_company_news",
    func=get_company_news,
    description="Fetches recent news and press releases for a given stock symbol.",
)

get_technical_indicators_tool = StructuredTool.from_function(
    name="get_technical_indicators",
    func=get_technical_indicators,
    description="Fetches technical indicators for a given stock symbol over a specified period.",
)

# List of all tools
yfinance_tools = [
    get_stock_time_series_tool,
    get_company_info_tool,
    get_historical_stock_prices_tool,
    get_stock_fundamentals_tool,
    get_income_statements_tool,
    get_key_financial_ratios_tool,
    get_analyst_recommendations_tool,
    get_company_news_tool,
    get_technical_indicators_tool,
]

if __name__ == "__main__":
    sample_symbol = "AAPL"

    # Inputs for tools that require multiple parameters
    sample_inputs = {
        "get_stock_time_series": {"symbol": sample_symbol, "period": "1mo"},
        "get_historical_stock_prices": {
            "symbol": sample_symbol,
            "period": "1mo",
            "interval": "5d",
        },
        "get_company_news": {"symbol": sample_symbol, "num_stories": 3},
        "get_technical_indicators": {"symbol": sample_symbol, "period": "5d"},
    }

    # Running all tools
    for tool in yfinance_tools:
        print(f"\n🔹 Running tool: {tool.name} 🔹")

        # Get the correct input from `sample_inputs`, defaulting to just {"symbol": sample_symbol}
        tool_input = sample_inputs.get(tool.name, {"symbol": sample_symbol})

        try:
            # Run the tool and print output
            result = tool.run(tool_input)
            print(result)
        except Exception as e:
            print(f"❌ Error running {tool.name}: {e}")
