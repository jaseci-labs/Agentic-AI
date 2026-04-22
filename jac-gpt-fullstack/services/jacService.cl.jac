"""Service layer for communicating with the Jac backend using root spawn."""

glob REQUEST_TIMEOUT_MS = 30000;

"""Build a normalized error object for consistent UI handling."""
def buildError(code: str, message: str, retryable: bool = False, statusCode: int = 0, details: str = "") -> dict {
    return {
        "code": code,
        "message": message,
        "retryable": retryable,
        "status_code": statusCode,
        "details": details,
        "timestamp": Date().toISOString()
    };
}

"""Create a standard failure response payload."""
def errorResponse(errorObj: dict, extra: dict = {}) -> dict {
    return {
        "success": False,
        "code": errorObj.code,
        "message": errorObj.message,
        "error": errorObj,
        **extra
    };
}

"""Convert unknown runtime errors into normalized error objects."""
def normalizeRuntimeError(err: any, fallbackCode: str = "ERR_UNKNOWN_FRONTEND") -> dict {
    errorName = err.name if err and err.name else "";
    details = String(err) if err else "Unknown error";

    if errorName == "AbortError" {
        return buildError("ERR_ABORTED", "Request was cancelled.", False, 0, details);
    }

    if details.toLowerCase().includes("timeout") {
        return buildError("ERR_TIMEOUT", "Request timed out. Please try again.", True, 408, details);
    }

    if details.toLowerCase().includes("network") or details.toLowerCase().includes("failed to fetch") {
        return buildError("ERR_NETWORK", "Network error. Check your connection and try again.", True, 0, details);
    }

    return buildError(fallbackCode, "Something went wrong. Please try again.", False, 0, details);
}

"""Merge an external abort signal with a timeout signal."""
def createTimedAbortSignal(externalSignal: any = None, timeoutMs: int = REQUEST_TIMEOUT_MS) -> any {
    controller = Reflect.construct(AbortController, []);
    timeoutId = setTimeout(lambda -> None {
        controller.abort("timeout");
    }, timeoutMs);

    if externalSignal {
        externalSignal.addEventListener("abort", lambda -> None {
            clearTimeout(timeoutId);
            controller.abort("external_abort");
        });
    }

    return {
        "signal": controller.signal,
        "clear": lambda -> None { clearTimeout(timeoutId); }
    };
}

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
        err = normalizeRuntimeError(e, "ERR_CREATE_SESSION");
        return errorResponse(err, {"session_id": sessionId, "chat_history": []});
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
        err = normalizeRuntimeError(e, "ERR_GET_SESSION");
        return errorResponse(err, {"chat_history": [], "found": False});
    }
}

"""Send a message and get a response from the chatbot (SSE streaming)."""
async def:pub sendMessage(message: str, sessionId: str, userEmail: str = "", onChunk: any = None, onEvent: any = None, abortSignal: any = None, mode: str = "", skipHistory: bool = False) -> any {
    timedAbort = createTimedAbortSignal(abortSignal, REQUEST_TIMEOUT_MS);

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
                    "user_email": userEmail,
                    "mode": mode,
                    "skip_history": skipHistory
                }),
                "signal": timedAbort.signal
            }
        );

        if response.status >= 400 {
            errorCode = "ERR_SERVER";
            friendlyMessage = "Server error. Please try again.";
            retryable = response.status >= 500 or response.status == 429;

            if response.status == 401 or response.status == 403 {
                errorCode = "ERR_AUTH";
                friendlyMessage = "Authentication failed. Please sign in again.";
            } elif response.status == 404 {
                errorCode = "ERR_NOT_FOUND";
                friendlyMessage = "Requested endpoint was not found.";
            } elif response.status == 429 {
                errorCode = "ERR_RATE_LIMIT";
                friendlyMessage = "Too many requests. Please wait and try again.";
            }

            return errorResponse(
                buildError(errorCode, friendlyMessage, retryable, response.status, "HTTP status " + String(response.status))
            );
        }
        
        if not response.body {
            return errorResponse(buildError("ERR_EMPTY_RESPONSE", "Empty response received from server.", True, response.status, "No response body"));
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
                    if onEvent {
                        onEvent({
                            "type": "parse_error",
                            "data": {
                                "code": "ERR_STREAM_PARSE",
                                "message": "Received malformed stream data.",
                                "raw": data
                            }
                        });
                    }
                }
            }
        }

        return {
            "success": True,
            "code": "OK",
            "message": "Response streamed successfully"
        };
    } except Exception as e {
        # Check if it's an abort error
        errorName = e.name if e.name else "";
        if errorName == "AbortError" {
            if timedAbort.signal and timedAbort.signal.reason == "timeout" {
                timedAbort.clear();
                return errorResponse(buildError("ERR_TIMEOUT", "Request timed out. Please try again.", True, 408, String(e)));
            }
            console.log("Request aborted by user");
            timedAbort.clear();
            return {
                "success": False,
                "aborted": True,
                "code": "ERR_ABORTED",
                "message": "Request was cancelled by user.",
                "error": buildError("ERR_ABORTED", "Request was cancelled by user.", False, 0, String(e))
            };
        }

        if String(e).toLowerCase().includes("timeout") {
            timedAbort.clear();
            return errorResponse(buildError("ERR_TIMEOUT", "Request timed out. Please try again.", True, 408, String(e)));
        }

        console.error("sendMessage error:", e);
        err = normalizeRuntimeError(e, "ERR_SEND_MESSAGE");
        return errorResponse(err);
    } finally {
        timedAbort.clear();
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
        err = normalizeRuntimeError(e, "ERR_GET_SUGGESTIONS");
        return errorResponse(err, {"suggestions": [], "total": 0});
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
        err = normalizeRuntimeError(e, "ERR_GET_USER_PROFILE");
        return errorResponse(err, {"user": {}, "isAdmin": False});
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
        err = normalizeRuntimeError(e, "ERR_GET_ALL_USERS");
        return errorResponse(err, {"users": [], "total": 0});
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
        err = normalizeRuntimeError(e, "ERR_GET_ALL_SESSIONS");
        return errorResponse(err, {"sessions": [], "total": 0});
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
        err = normalizeRuntimeError(e, "ERR_GET_SESSION_MESSAGES");
        return errorResponse(err, {"messages": [], "total_messages": 0});
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
        err = normalizeRuntimeError(e, "ERR_GET_DOC_CONTENT");
        return errorResponse(err, {"content": "", "title": "", "url": url});
    }
}
