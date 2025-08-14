"""Custom LangChain Tool to fetch stock information from Yahoo Finance."""

from langchain.tools import Tool
import yfinance as yf


class YahooFinanceTool:
    """Custom LangChain Tool to fetch stock information from Yahoo Finance."""

    @staticmethod
    def get_stock_price(ticker: str) -> str:
        """Fetch current stock price."""
        try:
            stock = yf.Ticker(ticker)
            price = stock.history(period="1d")["Close"].iloc[-1]
            return f"The latest closing price of {ticker.upper()} is ${price:.2f}."
        except Exception as e:
            return f"Error fetching stock price: {str(e)}"

    @staticmethod
    def get_stock_info(ticker: str) -> str:
        """Fetch company details."""
        try:
            stock = yf.Ticker(ticker)
            info = stock.info
            return f"{info['shortName']} ({ticker.upper()}):\nSector: {info.get('sector', 'N/A')}\nIndustry: {info.get('industry', 'N/A')}\nMarket Cap: {info.get('marketCap', 'N/A')}"
        except Exception as e:
            return f"Error fetching stock info: {str(e)}"

    @staticmethod
    def get_stock_history(ticker: str, period: str = "1mo") -> str:
        """Fetch historical stock data."""
        try:
            stock = yf.Ticker(ticker)
            history = stock.history(period=period)
            return f"Historical data for {ticker.upper()} (last {period}):\n{history.tail(5)}"
        except Exception as e:
            return f"Error fetching historical data: {str(e)}"


# Creating LangChain tools
get_price_tool = Tool(
    name="YahooFinance_StockPrice",
    func=YahooFinanceTool.get_stock_price,
    description="Fetches the latest stock price for a given ticker symbol.",
)

get_info_tool = Tool(
    name="YahooFinance_StockInfo",
    func=YahooFinanceTool.get_stock_info,
    description="Fetches company information, sector, and market cap for a given ticker.",
)

get_history_tool = Tool(
    name="YahooFinance_StockHistory",
    func=YahooFinanceTool.get_stock_history,
    description="Fetches historical stock data for a given ticker.",
)

# List of tools
yahoo_finance_tools = [get_price_tool, get_info_tool, get_history_tool]
