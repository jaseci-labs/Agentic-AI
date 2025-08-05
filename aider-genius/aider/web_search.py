#!/usr/bin/env python

import os
import requests
from typing import Optional, List, Dict, Any
import jaclang


class WebSearcher:
    """
    Web search functionality using Serper API for enhanced context gathering.
    """
    
    def __init__(self, api_key: Optional[str] = None, print_error=None):
        """
        Initialize the WebSearcher.
        
        Args:
            api_key (str, optional): Serper API key. If None, will try to get from environment.
            print_error: Function to call for error logging. Defaults to print.
        """
        self.api_key = api_key or os.getenv("SERPER_API_KEY")
        if print_error:
            self.print_error = print_error
        else:
            self.print_error = print
            
        self.base_url = "https://google.serper.dev/search"
        
    def is_available(self) -> bool:
        """Check if web search is available (API key is configured)."""
        return bool(self.api_key)
    
    def search(self, query: str, num_results: int = 3) -> str:
        """
        Perform a web search using Serper API and return a summarized result.

        Args:
            query (str): The search query.
            num_results (int): Number of results to include in summary (default: 3).

        Returns:
            str: A formatted summary of search results or an error message.
        """
        if not self.is_available():
            return "Web search unavailable: SERPER_API_KEY not configured"
            
        headers = {
            "X-API-KEY": self.api_key,
            "Content-Type": "application/json"
        }
        payload = {"q": query}

        try:
            response = requests.post(self.base_url, headers=headers, json=payload, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                return self._format_search_results(data, num_results)
            else:
                error_msg = f"Serper API request failed with status {response.status_code}"
                if response.status_code == 401:
                    error_msg += " (Invalid API key)"
                elif response.status_code == 429:
                    error_msg += " (Rate limit exceeded)"
                    
                self.print_error(error_msg)
                return error_msg
                
        except requests.exceptions.Timeout:
            error_msg = "Web search request timed out"
            self.print_error(error_msg)
            return error_msg
        except requests.exceptions.RequestException as e:
            error_msg = f"Web search request failed: {str(e)}"
            self.print_error(error_msg)
            return error_msg
        except Exception as e:
            error_msg = f"Unexpected error during web search: {str(e)}"
            self.print_error(error_msg)
            return error_msg

    def _format_search_results(self, data: Dict[str, Any], num_results: int) -> str:
        """
        Format search results into a readable summary.
        
        Args:
            data (dict): Raw response data from Serper API.
            num_results (int): Number of results to include.
            
        Returns:
            str: Formatted summary of search results.
        """
        if not isinstance(data, dict):
            return "Invalid search response format"
            
        # Extract organic search results
        organic_results = data.get("organic", [])
        
        if not organic_results:
            return "No search results found"
            
        summary_parts = []
        
        # Add answer box if available
        if "answerBox" in data:
            answer_box = data["answerBox"]
            if "answer" in answer_box:
                summary_parts.append(f"**Answer:** {answer_box['answer']}")
            elif "snippet" in answer_box:
                summary_parts.append(f"**Answer:** {answer_box['snippet']}")
                
        # Add top organic results
        summary_parts.append("**Search Results:**")
        
        for i, result in enumerate(organic_results[:num_results], 1):
            title = result.get("title", "No title")
            link = result.get("link", "")
            snippet = result.get("snippet", "")
            
            result_text = f"{i}. **{title}**"
            if link:
                result_text += f"\n   URL: {link}"
            if snippet:
                result_text += f"\n   {snippet}"
                
            summary_parts.append(result_text)
            
        # Add related searches if available
        if "relatedSearches" in data and data["relatedSearches"]:
            related = [search.get("query", "") for search in data["relatedSearches"][:3]]
            if related:
                summary_parts.append(f"**Related searches:** {', '.join(related)}")
        
        return "\n\n".join(summary_parts)
    
    def search_multiple_queries(self, queries: List[str], max_results_per_query: int = 2) -> str:
        """
        Search multiple queries and combine results.
        
        Args:
            queries (List[str]): List of search queries.
            max_results_per_query (int): Maximum results per query.
            
        Returns:
            str: Combined formatted search results.
        """
        if not queries:
            return "No search queries provided"
            
        all_results = []
        
        for i, query in enumerate(queries, 1):
            result = self.search(query, max_results_per_query)
            if result and not result.startswith("Web search") and not result.startswith("Serper"):
                all_results.append(f"### Query {i}: {query}\n{result}")
                
        if not all_results:
            return "No successful search results obtained"
            
        return "\n\n" + "="*50 + "\n\n".join(all_results)


def create_web_searcher(print_error=None) -> WebSearcher:
    """
    Factory function to create a WebSearcher instance.
    
    Args:
        print_error: Function for error logging.
        
    Returns:
        WebSearcher: Configured web searcher instance.
    """
    return WebSearcher(print_error=print_error)


# For backwards compatibility and standalone usage
def web_search(query: str, api_key: str = None) -> str:
    """
    Simple function interface for web search.
    
    Args:
        query (str): The search query.
        api_key (str, optional): Serper API key.
        
    Returns:
        str: Formatted search results.
    """
    searcher = WebSearcher(api_key=api_key)
    return searcher.search(query)
