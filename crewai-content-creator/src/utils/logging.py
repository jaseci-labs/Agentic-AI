"""Logging utility functions."""

import re
import time
from typing import Any, List

from crewai.agents.crew_agent_executor import ToolResult
from crewai.agents.parser import AgentAction, AgentFinish

from src.api.db import add_session_log

import streamlit as st


def add_log_entry(session_id: str, log_entry: Any) -> None:
    """Add log entry."""
    timestamp = time.time()
    structured_log = destruct_log_entry(log_entry)
    add_session_log(session_id, timestamp, structured_log)


def destruct_log_entry(log_entry: dict) -> dict:
    """Destruct log entry."""
    output = log_entry.get("output")
    if isinstance(output, list) and output:
        output = output[0]

    if isinstance(output, (AgentAction)):
        result = getattr(output, "result", None)
        text = getattr(output, "text", None)
        thought = getattr(output, "thought", None)
        tool = getattr(output, "tool", None)
        tool_input = getattr(output, "tool_input", None)
        return {
            "type": "AgentAction",
            "tool_name": tool,
            "tool_input": tool_input,
            "log": "".join(str(x) for x in [text, thought, result] if x),
        }

    if isinstance(output, AgentFinish):
        output_text = getattr(output, "output", None)
        thought = getattr(output, "thought", None)
        text = getattr(output, "text", None)
        return {
            "type": "AgentAction",
            "log": "".join(str(x) for x in [text, thought, output_text] if x),
        }
    if isinstance(output, ToolResult):
        return {
            "type": "AgentAction",
            "log": output.result,
        }

    if isinstance(output, str):
        if "AgentAction" in output:
            try:
                tool_name_match = re.match(r".*tool=(.*), tool_input.*", output)
                tool_input_match = re.match(r".*tool_input=(.*), log", output)
                log_match = re.match(r".*log=(.*)", output)
                return {
                    "type": "AgentAction",
                    "tool_name": (
                        eval(tool_name_match.group(1)) if tool_name_match else None
                    ),
                    "tool_input": (
                        eval(tool_input_match.group(1)) if tool_input_match else None
                    ),
                    "log": log_match.group(1) if log_match else None,
                }
            except Exception as e:
                return {"type": "error", "error": str(e)}

        elif "ToolResult" in output:
            try:
                tool_name_match = re.search(r"Tool Name:\s*([^\n]+)", output)
                tool_input_match = re.search(
                    r"Tool Arguments:\s*({.*?})", output, re.DOTALL
                )
                log_match = re.search(
                    r"ToolResult\(result=(['\"])(.*?)\1, result_as_answer=",
                    output,
                    re.DOTALL,
                )
                return {
                    "type": "AgentAction",
                    "tool_name": (
                        tool_name_match.group(1).strip() if tool_name_match else None
                    ),
                    "tool_input": (
                        tool_input_match.group(1).strip() if tool_input_match else None
                    ),
                    "log": log_match.group(2).strip() if log_match else None,
                }
            except Exception as e:
                return {"type": "error", "error": str(e)}

        elif "return_values" in output:
            try:
                return_values_match = re.match(
                    r"return_values={'output': (.*)}", output
                )
                log_match = re.match(r".*log=(.*)", output)
                return {
                    "type": "return_values",
                    "return_values": (
                        eval(return_values_match.group(1))
                        if return_values_match
                        else None
                    ),
                    "log": log_match.group(1) if log_match else None,
                }
            except Exception as e:
                return {"type": "error", "error": str(e)}


class StreamToExpander:
    """Stream to Expander."""

    def __init__(self, expander: Any) -> None:
        """Initialize the StreamToExpander class."""
        self.expander = expander
        self.buffer: List[str] = []
        self.colors = ["red", "green", "blue", "orange"]  # Define a list of colors
        self.color_index = 0  # Initialize color index

    def write(self, data: str) -> None:
        """Write method to process the data and output it to the expander."""
        cleaned_data = re.sub(r"\x1B\[[0-9;]*[mK]", "", data)
        task_match_object = re.search(
            r"\"task\"\s*:\s*\"(.*?)\"", cleaned_data, re.IGNORECASE
        )
        task_match_input = re.search(
            r"task\s*:\s*([^\n]*)", cleaned_data, re.IGNORECASE
        )
        task_value = None
        if task_match_object:
            task_value = task_match_object.group(1)
        elif task_match_input:
            task_value = task_match_input.group(1).strip()

        if task_value:
            st.toast(":robot_face: " + task_value)

        if "Entering new CrewAgentExecutor chain" in cleaned_data:
            self.color_index = (self.color_index + 1) % len(self.colors)
            cleaned_data = cleaned_data.replace(
                "Entering new CrewAgentExecutor chain",
                f":{self.colors[self.color_index]}[Entering new CrewAgentExecutor chain]",
            )

        if "Investor Profile Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Investor Profile Analyst",
                f":{self.colors[self.color_index]}[Investor Profile Analyst]",
            )
        if "Industry & Market Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Industry & Market Analyst",
                f":{self.colors[self.color_index]}[Industry & Market Analyst]",
            )
        if "Expert Research Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Expert Research Analyst",
                f":{self.colors[self.color_index]}[Expert Research Analyst]",
            )
        if "Financial Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Financial Analyst",
                f":{self.colors[self.color_index]}[Financial Analyst]",
            )
        if "News Aggregation & Insights Agent" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "News Aggregation & Insights Agent",
                f":{self.colors[self.color_index]}[News Aggregation & Insights Agent]",
            )
        if "Chief Investment Officer" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Chief Investment Officer",
                f":{self.colors[self.color_index]}[Chief Investment Officer]",
            )
        if "Investment Report Compiler" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Investment Report Compiler",
                f":{self.colors[self.color_index]}[Investment Report Compiler]",
            )
        if "Finished chain." in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Finished chain.", f":{self.colors[self.color_index]}[Finished chain.]"
            )
        small_text = '<span style="font-size: 20px; color: black;">'
        small_bold_text = (
            '<span style="font-size: 20px; font-weight: bold; color: black;">'
        )
        if "Agent:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Agent:", f"{small_bold_text}Agent:</span>"
            )

        if "Thought:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Thought:", f"{small_bold_text}Thought:</span> {small_text}"
            )

        if "Tool Input:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Tool Input:", f"{small_bold_text}Tool Input:</span> {small_text}"
            )

        if "Tool Output:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Tool Output:", f"{small_bold_text}Tool Output:</span> {small_text}"
            )

        if "Task:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Task:", f"{small_bold_text}Task:</span> {small_text}"
            )

        if "Using tool:" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Using tool:", f"{small_bold_text}Using tool:</span> {small_text}"
            )

        if "Entering new CrewAgentExecutor chain" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Entering new CrewAgentExecutor chain",
                f"{small_bold_text}Entering new CrewAgentExecutor chain</span>",
            )

        if "Company Performance Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Company Performance Analyst",
                f"{small_bold_text}Company Performance Analyst</span>",
            )

        if "Industry & Market Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Industry & Market Analyst",
                f"{small_bold_text}Industry & Market Analyst</span>",
            )

        if "Stock Market & Investment Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Stock Market & Investment Analyst",
                f"{small_bold_text}Stock Market & Investment Analyst</span>",
            )

        if "Competitor Analysis Agent" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Competitor Analysis Agent",
                f"{small_bold_text}Competitor Analysis Agent</span>",
            )

        if "News Aggregation & Insights Agent" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "News Aggregation & Insights Agent",
                f"{small_bold_text}News Aggregation & Insights Agent</span>",
            )

        if "Comprehensive Risk & Market Analyst" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Comprehensive Risk & Market Analyst",
                f"{small_bold_text}Comprehensive Risk & Market Analyst</span>",
            )

        if "Investment Report Compiler" in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Investment Report Compiler",
                f"{small_bold_text}Investment Report Compiler</span>",
            )

        if "Finished chain." in cleaned_data:
            cleaned_data = cleaned_data.replace(
                "Finished chain.", f"{small_bold_text}Finished chain.</span>"
            )

        # Output the processed content
        self.buffer.append(cleaned_data)
        if "\n" in data:
            self.expander.markdown("".join(self.buffer), unsafe_allow_html=True)
            self.buffer = []
