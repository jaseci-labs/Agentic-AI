"""Generate a grouped bar chart comparing financial data across multiple companies."""

import math
import matplotlib
import matplotlib.pyplot as plt

import numpy as np
import pandas as pd

import yfinance as yf


matplotlib.use("Agg")  # Use non-GUI backend


class ChartData:
    """Class to generate a grouped bar chart comparing financial data across multiple companies."""

    @staticmethod
    def chart_data_generation(symbols: list) -> tuple:
        """Fetch and process financial data for multiple companies.

        Args:
            symbols (list): List of stock symbols.

        Returns:
            dict: Financial data for each company.
        """
        financial_data = {}
        features = ("Net Income", "Total Revenue", "Gross Profit", "Total Expenses")

        for symbol in symbols:
            try:
                data = yf.Ticker(symbol)
                df = data.financials
                financials = df.to_dict(orient="index")

                income = financials.get("Net Income", {})
                revenue = financials.get("Total Revenue", {})
                profit = financials.get("Gross Profit", {})
                expenses = financials.get("Total Expenses", {})

                # Convert timestamp keys to years
                total_income = {
                    pd.Timestamp(key).year: value
                    for key, value in income.items()
                    if pd.notna(value)
                }
                net_revenue = {
                    pd.Timestamp(key).year: value
                    for key, value in revenue.items()
                    if pd.notna(value)
                }
                gross_profit = {
                    pd.Timestamp(key).year: value
                    for key, value in profit.items()
                    if pd.notna(value)
                }
                total_expenses = {
                    pd.Timestamp(key).year: value
                    for key, value in expenses.items()
                    if pd.notna(value)
                }

                company_data = (total_income, net_revenue, gross_profit, total_expenses)
                company_graph_data = {}

                for year in company_data[0].keys():
                    company_graph_data[year] = [
                        company_data[i].get(year, 0) / 10**8
                        for i in range(len(company_data))
                    ]  # Convert to crores

                financial_data[symbol] = company_graph_data

            except Exception as e:
                print(f"Error fetching data for {symbol}: {e}")

        return financial_data, features

    @staticmethod
    def generate_comparison_chart(symbols: list) -> str:
        """Generate a grouped bar chart comparing financial data across multiple companies.

        Args:
            symbols (list): List of stock symbols.

        Returns:
            str: File path of the saved chart.
        """
        financial_data, financial_metric = ChartData.chart_data_generation(symbols)

        if not financial_data:
            return "Error: No financial data available."

        years = sorted(
            {year for company in financial_data.values() for year in company.keys()}
        )

        x = np.arange(len(years))
        width = 0.15  # Bar width for grouping
        fig, ax = plt.subplots(figsize=(12, 7))

        colors = plt.cm.viridis(np.linspace(0, 1, len(symbols)))

        for i, symbol in enumerate(symbols):
            company_data = financial_data.get(symbol, {})
            for j, feature in enumerate(financial_metric):
                values = [company_data.get(year, [0] * 4)[j] for year in years]
                ax.bar(
                    x + i * width + j * (width / len(symbols)),
                    values,
                    width / len(symbols),
                    label=f"{symbol} - {feature}",
                    color=colors[i],
                )

        ax.set_ylabel("Amount in Crores")
        ax.set_xlabel("Years")
        ax.set_title("Financial Comparison of Companies")
        ax.set_xticks(x + width)
        ax.set_xticklabels(years)
        ax.legend(loc="upper left", bbox_to_anchor=(1, 1))
        ax.set_ylim(
            0,
            math.ceil(
                max(
                    [
                        max(financial_data[symbol][year])
                        for symbol in financial_data
                        for year in financial_data[symbol]
                    ]
                )
                / 10
            )
            * 10,
        )

        # Save the figure
        file_path = "comparison_chart.png"
        fig.savefig(file_path, format="png", bbox_inches="tight")
        plt.close(fig)

        return file_path


# Example Usage: Compare Five Companies
stock_symbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA"]
comparison_chart = ChartData.generate_comparison_chart(stock_symbols)

print(f"Comparison Chart Saved at: {comparison_chart}")
