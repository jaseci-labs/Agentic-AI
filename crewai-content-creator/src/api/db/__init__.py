"""Database module for storing session data."""

import json
import os
from typing import Any

DB_FILE_PATH = os.path.join(os.path.dirname(__file__), "db.json")
os.makedirs(os.path.dirname(DB_FILE_PATH), exist_ok=True)


def read_db() -> dict:
    """Reads the JSON database file (db.json) as a dictionary. If missing, returns an empty dict."""
    if os.path.exists(DB_FILE_PATH):
        with open(DB_FILE_PATH, "r") as file:
            try:
                data = json.load(file)
                return data if isinstance(data, dict) else {}
            except json.JSONDecodeError:
                return {}
    return {}


def write_db(data: dict) -> None:
    """Writes a dictionary to the JSON database file."""
    with open(DB_FILE_PATH, "w") as file:
        json.dump(data, file, indent=4)


def get_session(session_id: str) -> dict:
    """Get session details from db.json."""
    db_data = read_db()
    session_data = db_data.get(session_id, {})

    if not session_data:
        raise ValueError(f"No session data found for session ID: {session_id}")

    return session_data


def add_session_log(
    session_id: str, timestamp: float, structured_log_entry: dict[Any, Any]
) -> None:
    """Add a log entry to the session data, ensuring 'logs' exists for each session."""
    db_data = read_db()
    if session_id not in db_data:
        db_data[session_id] = {}
    db_data[session_id].setdefault("logs", [])

    log_entry = {"timestamp": timestamp, "log": structured_log_entry}
    db_data[session_id]["logs"].append(log_entry)
    write_db(db_data)
