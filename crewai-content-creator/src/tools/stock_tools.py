"""This tool fetches stock data, company profiles, historical prices, and stock news."""

# --------------------
# Standard Library
# --------------------
import datetime
import json
import os

# --------------------
# Third-Party Libraries
# --------------------
from dotenv import load_dotenv
from langchain.agents import tool
import requests
import yfinance as yf

# Load environment variables
load_dotenv()


class StockTools:
    """This tool fetches stock data, company profiles, historical prices, and stock news."""

    FMP_BASE_URL = "https://financialmodelingprep.com/api/v3"
    NEWS_API_URL = "https://newsapi.org/v2/everything"

    @staticmethod
    @tool
    def get_ticker_symbol(company_name: str) -> dict:
        """Fetch the stock ticker symbol for a given company name using the FMP API.

        :param company_name: Full company name (e.g., "Tesla").
        :return: Dictionary containing the ticker symbol or an error message.
        """
        api_key = os.getenv("FMP_API_KEY")
        if not api_key:
            return {"error": "FMP_API_KEY is missing. Set it in the .env file."}

        url = f"{StockTools.FMP_BASE_URL}/search?query={company_name}&limit=1&apikey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            if data:
                symbol = data[0]["symbol"]
                name = data[0]["name"]
                return {
                    "symbol": symbol,
                    "name": name,
                    "summary": f"Found Company: {name} with ticker symbol {symbol}.",
                }
            return {"error": "No matching company found."}
        except requests.exceptions.RequestException as exc:
            return {"error": f"Failed to fetch ticker symbol: {exc}"}

    @staticmethod
    @tool
    def get_stock_quote(symbol: str) -> str:
        """Fetch real-time stock price data using the FMP API.

        :param symbol: Stock ticker symbol (e.g., "TSLA").
        :return: A formatted stock quote summary as a string.
        """
        api_key = os.getenv("FMP_API_KEY")
        if not api_key:
            return "FMP_API_KEY is missing. Set it in the .env file."

        url = f"{StockTools.FMP_BASE_URL}/quote/{symbol}?apikey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            raw_data = data[0] if data else {"error": "No stock data found."}
            return StockTools.format_stock_quote(raw_data)
        except requests.exceptions.RequestException as exc:
            return f"Failed to fetch stock data: {exc}"

    @staticmethod
    def format_stock_quote(data: dict) -> str:
        """Format the raw stock quote data into a readable summary.

        :param data: Stock quote data dictionary.
        :return: A formatted quote summary.
        """
        if "error" in data:
            return data["error"]

        symbol = data.get("symbol", "N/A")
        price = data.get("price", "N/A")
        change = data.get("change", "N/A")
        changes_percentage = data.get("changesPercentage", "N/A")

        return (
            f"Ticker: {symbol}\n"
            f"Price: ${price}\n"
            f"Change: {change} ({changes_percentage}%)"
        )

    @staticmethod
    @tool
    def get_stock_profile(input_data: str) -> str:
        """Provide a comprehensive company profile.

        Accepts input_data as either:
         - A dictionary with a key "symbol" (e.g., {"input": {"symbol": "TSLA"}})
         - A JSON string with a key "symbol" (e.g., '{"symbol": "TSLA"}')

        :param input_data: JSON string or dictionary (serialized) with a 'symbol' key.
        :return: A formatted profile summary.
        """
        try:
            parsed = json.loads(input_data)
        except json.JSONDecodeError:
            # If parsing fails, maybe it's already a dict or invalid
            if isinstance(input_data, dict):
                parsed = input_data
            else:
                return 'Error: Invalid input. Expected JSON like {"input": {"symbol": "TSLA"}}.'

        if (
            isinstance(parsed, dict)
            and "input" in parsed
            and isinstance(parsed["input"], dict)
        ):
            parsed = parsed["input"]

        if not isinstance(parsed, dict) or "symbol" not in parsed:
            return "Error: Input must be a dictionary with a 'symbol' key."

        symbol = parsed["symbol"]
        if not symbol:
            return "Error: Symbol is required."

        api_key = os.getenv("FMP_API_KEY")
        if not api_key:
            return "Error: FMP_API_KEY is missing. Set it in the .env file."

        url = f"{StockTools.FMP_BASE_URL}/profile/{symbol}?apikey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            raw_data = data[0] if data else {"error": "No profile data found."}
            return StockTools.format_stock_profile(raw_data)
        except requests.exceptions.RequestException as exc:
            return f"Failed to fetch stock profile: {exc}"

    @staticmethod
    def format_stock_profile(data: dict) -> str:
        """Format the raw company profile data into a readable summary.

        :param data: Dictionary containing company profile data.
        :return: A formatted company profile summary.
        """
        if "error" in data:
            return data["error"]

        name = data.get("companyName", "N/A")
        industry = data.get("industry", "N/A")
        ceo = data.get("ceo", "N/A")
        website = data.get("website", "N/A")
        description = data.get("description", "No description available.").split(".")[0]

        return (
            f"Company: {name}\n"
            f"Industry: {industry}\n"
            f"CEO: {ceo}\n"
            f"Website: {website}\n"
            f"Description: {description}."
        )

    @staticmethod
    @tool
    def get_stock_historical_prices(input_data: str) -> str:
        """Fetch historical price data (6–8 months) and summarize key statistics.

        Accepts:
         - A dictionary with a "symbol" key (e.g., {"input": {"symbol": "TSLA"}})
         - A JSON string with a "symbol" key (e.g., '{"symbol": "TSLA"}')

        :param input_data: JSON string or dictionary (serialized) with 'symbol'.
        :return: A formatted historical data summary.
        """
        try:
            parsed = json.loads(input_data)
        except json.JSONDecodeError:
            # If parsing fails, maybe it's already a dict or invalid
            if isinstance(input_data, dict):
                parsed = input_data
            else:
                return 'Error: Invalid input. Expected JSON like {"input": {"symbol": "TSLA"}}.'

        if (
            isinstance(parsed, dict)
            and "input" in parsed
            and isinstance(parsed["input"], dict)
        ):
            parsed = parsed["input"]

        if not isinstance(parsed, dict) or "symbol" not in parsed:
            return "Error: Input must be a dictionary with a 'symbol' key."

        symbol = parsed["symbol"]
        if not symbol:
            return "Error: Symbol is required."

        api_key = os.getenv("FMP_API_KEY")
        if not api_key:
            return "Error: FMP_API_KEY is missing. Set it in the .env file."

        today = datetime.date.today()
        from_date = (today - datetime.timedelta(days=8 * 30)).strftime("%Y-%m-%d")
        to_date = today.strftime("%Y-%m-%d")

        url = f"{StockTools.FMP_BASE_URL}/historical-price-full/{symbol}?from={from_date}&to={to_date}&apikey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            historical_data = (
                data.get("historical", data) if isinstance(data, dict) else data
            )
            if not historical_data:
                return f"No historical data found for {symbol}."
            return StockTools.format_historical_prices(historical_data, symbol)
        except requests.exceptions.RequestException as exc:
            return f"Error fetching historical data: {exc}"

    @staticmethod
    def format_historical_prices(data: list, symbol: str) -> str:
        """Format historical stock prices into a comprehensive summary.

        :param data: List of historical records.
        :param symbol: Stock ticker symbol.
        :return: A formatted historical data summary.
        """
        if not data:
            return f"No historical data available for {symbol}."

        closes = [
            record.get("close") for record in data if record.get("close") is not None
        ]
        if not closes:
            return f"No closing price data available for {symbol}."

        min_price = min(closes)
        max_price = max(closes)
        avg_price = sum(closes) / len(closes)
        first_record = data[0]
        last_record = data[-1]

        return (
            f"Historical Prices for {symbol}:\n"
            f"From {first_record.get('date', 'N/A')} (Close: ${first_record.get('close', 'N/A')}) "
            f"to {last_record.get('date', 'N/A')} (Close: ${last_record.get('close', 'N/A')})\n"
            f"Records: {len(data)} | Min: ${min_price:.2f} | Max: ${max_price:.2f} | Avg: ${avg_price:.2f}"
        )

    @staticmethod
    @tool
    def get_stock_news(company: str) -> str:
        """Fetch recent news articles for a given company.

        :param company: Name of the company (e.g., "Tesla").
        :return: A formatted string of news articles.
        """
        api_key = os.getenv("NEWS_API_KEY")
        if not api_key:
            return "NEWS_API_KEY is missing. Set it in the .env file."

        url = f"{StockTools.NEWS_API_URL}?q={company}&apiKey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            articles = response.json().get("articles", [])
            return StockTools.format_stock_news(articles)
        except requests.exceptions.RequestException as exc:
            return f"Failed to fetch news: {exc}"

    @staticmethod
    def format_stock_news(articles: list) -> str:
        """Format news articles into a readable summary including URLs.

        :param articles: A list of news article dictionaries.
        :return: A formatted string of up to 5 articles.
        """
        if not articles:
            return "No news articles available."

        lines = []
        for article in articles[:5]:
            title = article.get("title", "No Title")
            source = article.get("source", {}).get("name", "Unknown Source")
            published = article.get("publishedAt", "Unknown Date")
            url = article.get("url", "No URL")
            lines.append(f"{title} (Source: {source}, Date: {published})\nURL: {url}")
        return "\n\n".join(lines)

    @staticmethod
    @tool
    def get_yfinance_data(input_data: str) -> str:
        """Use the yfinance library to retrieve historical trading data.

        Accepts a JSON string with:
         - "symbol": the ticker symbol (e.g., "TSLA")
         - "period": (optional) period string (e.g., "1d")

        :param input_data: JSON string specifying symbol & period.
        :return: A summary of the Yahoo Finance data.
        """
        try:
            params = json.loads(input_data)
        except (json.JSONDecodeError, TypeError) as exc:
            return f"Invalid input format: {exc}"

        symbol = params.get("symbol")
        period = params.get("period", "1d")

        if not symbol:
            return "Symbol is required."

        try:
            stock = yf.Ticker(symbol)
            history = stock.history(period=period)
            if history.empty:
                return "No data found for the given period."
            data_dict = history.to_dict()
            return StockTools.format_yfinance_data(data_dict)
        except Exception as exc:
            return f"Failed to fetch Yahoo Finance data: {exc}"

    @staticmethod
    def format_yfinance_data(data: dict) -> str:
        """Format Yahoo Finance data from history.to_dict() into a summary.

        :param data: Dictionary with keys like "Close" and optionally "Volume".
        :return: A formatted summary of the data.
        """
        if "Close" not in data or not data["Close"]:
            return "No closing price data available."

        try:
            dates = sorted(data["Close"].keys(), key=lambda d: str(d))
            first_date = dates[0]
            last_date = dates[-1]
            first_close = data["Close"][first_date]
            last_close = data["Close"][last_date]

            summary = (
                "🔹 Yahoo Finance Data Summary:\n"
                f"Period: {first_date} to {last_date}\n"
                f"First Close: {first_close}\n"
                f"Last Close: {last_close}\n"
            )
            if "Volume" in data and data["Volume"]:
                volumes = list(data["Volume"].values())
                avg_volume = sum(volumes) / len(volumes)
                summary += f"Average Volume: {avg_volume:.0f}\n"
            return summary
        except Exception as exc:
            return f"Error formatting data: {exc}"

    @staticmethod
    @tool
    def get_income_statement(symbol: str) -> str:
        """Fetch the latest income statement for a given stock using the FMP API.

        This includes details such as operating income, EBITDA, and EPS.
        :param symbol: Stock ticker symbol.
        :return: A formatted income statement summary.
        """
        api_key = os.getenv("FMP_API_KEY")
        if not api_key:
            return "FMP_API_KEY is missing. Set it in the .env file."

        url = f"{StockTools.FMP_BASE_URL}/income-statement/{symbol}?apikey={api_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            if data:
                statements = []
                for record in data[:3]:
                    date = record.get("date", "N/A")
                    revenue = record.get("revenue", "N/A")
                    net_income = record.get("netIncome", "N/A")
                    operating_income = record.get("operatingIncome", "N/A")
                    ebitda = record.get("ebitda", "N/A")
                    eps = record.get("eps", "N/A")
                    statements.append(
                        f"Date: {date} | Revenue: ${revenue} | Net Income: ${net_income} | "
                        f"Operating Income: ${operating_income} | EBITDA: {ebitda} | EPS: {eps}"
                    )
                return "\n".join(statements)
            return "No income statement found."
        except requests.exceptions.RequestException as exc:
            return f"Failed to fetch income statement: {exc}"

    @staticmethod
    def tools() -> list:
        """Return a list of available stock tools."""
        return [
            StockTools.get_ticker_symbol,
            StockTools.get_stock_quote,
            StockTools.get_stock_profile,
            StockTools.get_stock_historical_prices,
            StockTools.get_stock_news,
            StockTools.get_yfinance_data,
            StockTools.get_income_statement,
        ]


if __name__ == "__main__":
    # Example usage/testing
    stock_tool = StockTools()
    company_name = "TESLA"

    print("\n🔹 Fetching Ticker Symbol:")
    ticker_data = stock_tool.get_ticker_symbol.invoke(company_name)
    if "summary" in ticker_data:
        print(ticker_data["summary"])
    else:
        print(ticker_data)

    if "symbol" in ticker_data:
        symbol = ticker_data["symbol"]
        print("\n🔹 Real-Time Stock Quote:")
        print(stock_tool.get_stock_quote.invoke(symbol))

        print("\n🔹 Stock Profile:")
        input_p = json.dumps({"symbol": symbol})
        print(stock_tool.get_stock_profile.invoke(input_p))

        print("\n🔹 Historical Prices (6 months):")
        historical_input = json.dumps({"symbol": symbol, "period": "6month"})
        print(stock_tool.get_stock_historical_prices.invoke(historical_input))

        print("\n🔹 Stock News:")
        print(stock_tool.get_stock_news.invoke(company_name))

        print("\n🔹 Yahoo Finance Data:")
        yfinance_input = json.dumps({"symbol": symbol, "period": "1d"})
        print(stock_tool.get_yfinance_data.invoke(yfinance_input))

        print("\n🔹 Latest Income Statement:")
        print(stock_tool.get_income_statement.invoke(symbol))
    else:
        print(f"❌ Error: {ticker_data.get('error', 'Unknown error')}")
