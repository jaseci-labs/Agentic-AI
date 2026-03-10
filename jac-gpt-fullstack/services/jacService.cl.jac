"""Service layer for communicating with the Jac backend using root spawn."""

"""Generate a unique session ID."""
def:pub generateSessionId() -> str {
    timestamp = Date.now();
    randomStr = Math.random().toString(36).substring(2, 9);
    return "session_" + String(timestamp) + "_" + randomStr;
}

"""Create a new chat session on the backend."""
async def:pub createSession(sessionId: str = "") -> any {
    if not sessionId {
        sessionId = generateSessionId();
    }

    try {
        response = root spawn new_session(session_id=sessionId);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

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
        response = root spawn get_session(session_id=sessionId);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

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

"""Send a message and get a response from the chatbot (SSE streaming)."""
async def:pub sendMessage(message: str, sessionId: str, userEmail: str = "", onChunk: any = None, onEvent: any = None, abortSignal: any = None) -> any {
    try {
        # Get token for authentication
        token = localStorage.getItem("jac_token");
        
        # Use fetch directly with streaming to handle SSE
        response = await fetch(
            "/walker/interact",
            {
                "method": "POST",
                "headers": {
                    "Content-Type": "application/json",
                    "Authorization": ("Bearer " + token if token else "")
                },
                "body": JSON.stringify({
                    "message": message,
                    "session_id": sessionId,
                    "user_email": userEmail
                }),
                "signal": abortSignal
            }
        );
        
        if not response.body {
            raise Exception("No response body") ;
        }

        reader = response.body.getReader();
        decoder = Reflect.construct(TextDecoder, ["utf-8"]);

        buffer = "";

        while True {
            read_result = await reader.read();
            value = read_result.value;
            done = read_result.done;
            
            if done {
                break;
            }

            buffer += decoder.decode(value, {"stream": True});
            
            # SSE messages are separated by double newlines
            # Split on actual newline characters (char code 10)
            doubleNewline = String.fromCharCode(10) + String.fromCharCode(10);
            
            events = buffer.split(doubleNewline);
            buffer = events.pop() or "";
            
            for event in events {
                if not event.startsWith("data:") {
                    continue;
                }

                data = event.replace("data:", "").trim();
                
                try {
                    parsed = JSON.parse(data);

                    if parsed.type == "chunk" {
                        if onChunk {
                            content = "";
                            if parsed.data {
                                content = parsed.data.content or "";
                            } elif parsed.content {
                                content = parsed.content;
                            }
                            onChunk(content);
                        }
                    }

                    # Forward all event types to onEvent callback
                    if onEvent {
                        onEvent(parsed);
                    }
                } except Exception as parseError {
                    console.error("JSON parse error:", parseError, "Data:", data);
                }
            }
        }

        return {
            "success": True
        };
    } except Exception as e {
        # Check if it's an abort error
        errorName = e.name if e.name else "";
        if errorName == "AbortError" {
            console.log("Request aborted by user");
            return {
                "success": False,
                "aborted": True
            };
        }
        console.error("sendMessage error:", e);
        return {
            "success": False,
            "error": String(e)
        };
    }
}

"""Get documentation suggestions based on message."""
async def:pub getSuggestions(message: str, chatHistory: list = []) -> any {
    try {
        response = root spawn suggest_docs(
            message=message,
            chat_history=chatHistory
        );
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

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
        response = root spawn get_user_profile(email=email);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

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

"""Get all users (admin)."""
async def:pub getAllUsers(requesterEmail: str = "") -> any {
    try {
        response = root spawn get_all_users(requester_email=requesterEmail);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

        return {
            "success": True,
            "users": result.users or [],
            "total": result.total or 0
        };
    } except Exception as e {
        console.error("getAllUsers error:", e);
        return {
            "success": False,
            "error": String(e),
            "users": [],
            "total": 0
        };
    }
}

"""Get all sessions (admin)."""
async def:pub getAllSessionsAdmin(requesterEmail: str = "") -> any {
    try {
        response = root spawn get_all_sessions_admin(requester_email=requesterEmail);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

        return {
            "success": True,
            "sessions": result.sessions or [],
            "total": result.total or 0
        };
    } except Exception as e {
        console.error("getAllSessionsAdmin error:", e);
        return {
            "success": False,
            "error": String(e),
            "sessions": [],
            "total": 0
        };
    }
}

"""Get session messages (admin)."""
async def:pub getSessionMessagesAdmin(sessionId: str, requesterEmail: str = "") -> any {
    try {
        response = root spawn get_session_messages_admin(session_id=sessionId, requester_email=requesterEmail);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

        return {
            "success": True,
            "session_id": result.session_id or sessionId,
            "messages": result.messages or [],
            "stats": result.stats or {},
            "total_messages": result.total_messages or 0
        };
    } except Exception as e {
        console.error("getSessionMessagesAdmin error:", e);
        return {
            "success": False,
            "error": String(e),
            "messages": [],
            "total_messages": 0
        };
    }
}

"""Get documentation content from URL."""
async def:pub getDocContent(url: str) -> any {
    try {
        response = root spawn get_doc_content(url=url);
        result = response.reports[response.reports.length - 1] if response.reports and response.reports.length > 0 else {};

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
