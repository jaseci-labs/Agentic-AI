"""Custom LangChain Tool to fetch stock market-related news from Twitter."""

import os
from dotenv import load_dotenv
from langchain.tools import Tool

import tweepy


load_dotenv()
BEARER_TOKEN = os.getenv("TWITTER_BEARER_TOKEN")
client = tweepy.Client(bearer_token=BEARER_TOKEN)


class TwitterStockNewsTool:
    """Custom LangChain Tool to fetch stock market-related news from Twitter."""

    @staticmethod
    def get_stock_news(ticker: str, count: int = 5) -> str:
        """Fetches latest tweets related to the stock ticker."""
        try:
            query = f"{ticker} stock news -is:retweet lang:en"
            tweets = client.search_recent_tweets(
                query=query, max_results=count, tweet_fields=["created_at", "text"]
            )

            if not tweets.data:
                return f"No recent tweets found for {ticker}."

            news_list = "\n\n".join([f"- {tweet.text}" for tweet in tweets.data])
            return f"Latest {count} tweets about {ticker}:\n{news_list}"

        except Exception as e:
            return f"Error fetching Twitter news: {str(e)}"


# Creating LangChain Tool
get_twitter_news_tool = Tool(
    name="Twitter_StockNews",
    func=TwitterStockNewsTool.get_stock_news,
    description="Fetches latest tweets about a stock ticker symbol.",
)
