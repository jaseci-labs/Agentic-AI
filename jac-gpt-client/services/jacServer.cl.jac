"""Service layer for communicating with the Jac backend via HTTP."""

cl import from react { useState }

"""Generate a unique session ID."""
def:pub generateSessionId() -> str {
    timestamp = Date.now();
    randomStr = Math.random().toString(36).substring(2, 9);
    return "session_" + String(timestamp) + "_" + randomStr;
}

"""Helper function to call walker endpoints via HTTP."""
async def callWalker(walkerName: str, payload: any = {}) -> any {
    response = await fetch("/walker/" + walkerName, {
        "method": "POST",
        "headers": {
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(payload)
    });

    if not response.ok {
        errorText = await response.text();
        console.error("Walker " + walkerName + " failed:", errorText);
        return {"error": errorText};
    }

    data = await response.json();
    console.log("Walker " + walkerName + " response:", data);

    # Extract result from jac-cloud response format {data: {reports: [...]}}
    if data.data and data.data.reports and data.data.reports.length > 0 {
        return data.data.reports[data.data.reports.length - 1];
    }
    # Fallback for direct reports array
    if data.reports and data.reports.length > 0 {
        return data.reports[data.reports.length - 1];
    }
    return data;
}

"""Create a new chat session on the backend."""
async def:pub createSession(sessionId: str = "") -> any {
    if not sessionId {
        sessionId = generateSessionId();
    }

    try {
        result = await callWalker("new_session", {"session_id": sessionId});

        return {
            "success": True,
            "session_id": result.session_id or sessionId,
            "status": result.status or "created",
            "chat_history": result.chat_history or []
        };
    } except Exception as e {
        console.error("createSession error:", e);
        return {
            "success": False,
            "error": String(e),
            "session_id": sessionId
        };
    }
}

"""Get an existing session's chat history."""
async def:pub getSession(sessionId: str) -> any {
    try {
        result = await callWalker("get_session", {"session_id": sessionId});

        return {
            "success": True,
            "session_id": result.session_id or sessionId,
            "chat_history": result.chat_history or [],
            "found": result.found or False
        };
    } except Exception as e {
        console.error("getSession error:", e);
        return {
            "success": False,
            "error": String(e),
            "chat_history": [],
            "found": False
        };
    }
}

"""Send a message and get a response from the chatbot."""
async def:pub sendMessage(message: str, sessionId: str, userEmail: str = "") -> any {
    try {
        result = await callWalker("interact", {
            "message": message,
            "session_id": sessionId,
            "user_email": userEmail
        });

        return {
            "success": True,
            "response": result.response or "I couldn't generate a response.",
            "chat_history": result.chat_history or [],
            "session_id": result.session_id or sessionId
        };
    } except Exception as e {
        console.error("sendMessage error:", e);
        return {
            "success": False,
            "error": String(e),
            "response": "Sorry, an error occurred while processing your message."
        };
    }
}

"""Get documentation suggestions based on message."""
async def:pub getSuggestions(message: str, chatHistory: list = []) -> any {
    try {
        result = await callWalker("suggest_docs", {
            "message": message,
            "chat_history": chatHistory
        });

        return {
            "success": result.success or False,
            "suggestions": result.suggestions or [],
            "total": result.total or 0
        };
    } except Exception as e {
        console.error("getSuggestions error:", e);
        return {
            "success": False,
            "error": String(e),
            "suggestions": []
        };
    }
}

"""Get user profile."""
async def:pub getUserProfile(email: str) -> any {
    try {
        result = await callWalker("get_user_profile", {"email": email});

        return {
            "success": True,
            "user": result.user or {},
            "isAdmin": result.isAdmin or False
        };
    } except Exception as e {
        console.error("getUserProfile error:", e);
        return {
            "success": False,
            "error": String(e)
        };
    }
}

"""Get documentation content from URL."""
async def:pub getDocContent(url: str) -> any {
    try {
        result = await callWalker("get_doc_content", {"url": url});

        return {
            "success": result.success or False,
            "content": result.content or "",
            "title": result.title or "",
            "url": result.url or url,
            "error": result.error or ""
        };
    } except Exception as e {
        console.error("getDocContent error:", e);
        return {
            "success": False,
            "error": String(e)
        };
    }
}
