"""Chat hook for managing chat state and interactions."""

import from react { useState, useEffect, useRef }
import from "@jac/runtime" { jacIsLoggedIn }
import from ..services.jacService { createSession, getSession, sendMessage, getSuggestions, generateSessionId }
import from ..hooks.useAuth { getUsernameFromToken }

"""Hook for managing chat state and interactions."""
def:pub useChat() -> any {
    UNSENT_MESSAGE_KEY = "jac_gpt_unsent_message";

    has messages: list = [];
    has sessionId: str = "";
    has isLoading: bool = False;
    has messageCount: int = 0;
    has maxFreeMessages: int = 30;
    has chatSessions: list = [];
    has docSuggestions: list = [];
    has lastUserMessage: str = "";
    has isSearchingDocs: bool = False;
    has ragReasoningSteps: list = [];
    has mcpReasoningSteps: list = [];
    has ragIsReasoning: bool = False;
    has mcpIsReasoning: bool = False;
    has ragElapsedMs: int = 0;
    has mcpElapsedMs: int = 0;
    has mode: str = "rag";
    has reasoningSteps: list = [];
    has isReasoning: bool = False;
    has streamDoneSignal: int = 0;
    has uiError: any = None;
    has pendingUnsentMessage: str = "";

    messagesEndRef = useRef(None);
    firstChunkRef = useRef(False);
    prevMessageCountRef = useRef(0);
    latestUserMsgRef = useRef(None);
    abortControllerRef = useRef(None);
    sendStartTimeRef = useRef(0);
    isAuthenticated = jacIsLoggedIn();

    def setUiErrorFrom(result: any, fallbackCode: str = "ERR_UNKNOWN_FRONTEND", fallbackMessage: str = "Something went wrong. Please try again.") -> None {
        errorObj = (result.error if result and result.error else None);
        code = fallbackCode;
        message = fallbackMessage;
        retryable = False;

        if errorObj {
            code = errorObj.code or result.code or fallbackCode;
            message = errorObj.message or result.message or fallbackMessage;
            retryable = errorObj.retryable or False;
        } else {
            code = result.code or fallbackCode;
            message = result.message or fallbackMessage;
            retryable = result.retryable or False;
        }

        uiError = {
            "code": code,
            "message": message,
            "retryable": retryable
        };
    }

    # Load message count from localStorage for guests
    useEffect(lambda -> None {
        if not isAuthenticated {
            savedCount = localStorage.getItem("jac_gpt_message_count");
            if savedCount {
                messageCount = parseInt(savedCount, 10) or 0;
            }
        }

        # Load chat sessions from localStorage
        savedSessions = localStorage.getItem("jac_gpt_sessions");
        if savedSessions {
            try {
                chatSessions = JSON.parse(savedSessions);
            } except Exception as e {
                console.error("Error loading sessions:", e);
                chatSessions = [];
                uiError = {
                    "code": "ERR_LOCAL_SESSIONS",
                    "message": "Could not restore saved chat sessions.",
                    "retryable": False
                };
            }
        }

        savedUnsent = localStorage.getItem(UNSENT_MESSAGE_KEY);
        if savedUnsent {
            pendingUnsentMessage = savedUnsent;
            uiError = {
                "code": "ERR_UNSENT_RECOVERED",
                "message": "Recovered an unsent message. You can retry sending it.",
                "retryable": True
            };
        }

        # Initialize first session
        initSession();
    }, []);

    # Save message count to localStorage
    useEffect(lambda -> None {
        if not isAuthenticated {
            localStorage.setItem("jac_gpt_message_count", String(messageCount));
        }
    }, [messageCount]);

    # Scroll latest user message to top when new messages are added
    useEffect(lambda -> None {
        currentCount = messages.length;
        # Only scroll if message count increased (new message added)
        if currentCount > prevMessageCountRef.current {
            setTimeout(lambda -> None {
                if latestUserMsgRef.current {
                    latestUserMsgRef.current.scrollIntoView({"behavior": "smooth", "block": "start"});
                }
            }, 100);
        }
        prevMessageCountRef.current = currentCount;
    }, [messages]);

    # Re-anchor scroll after full response stream completes
    # Use auto (no animation) to prevent visible flicker when reasoning collapses
    useEffect(lambda -> None {
        if streamDoneSignal > 0 {
            requestAnimationFrame(lambda -> None {
                if latestUserMsgRef.current {
                    latestUserMsgRef.current.scrollIntoView({"behavior": "auto", "block": "start"});
                }
            });
        }
    }, [streamDoneSignal]);

    async def initSession() -> None {
        newSessionId = generateSessionId();
        result = await createSession(newSessionId);
        if result.success {
            sessionId = result.session_id;
        } else {
            sessionId = newSessionId;
            setUiErrorFrom(result, "ERR_CREATE_SESSION", "Failed to initialize chat session.");
        }
    }

    def canSendMessage() -> bool {
        if isAuthenticated {
            return True;
        }
        return messageCount < maxFreeMessages;
    }

    async def handleSendMessage(content: str) -> None {
        if not content.trim() or isLoading {
            return;
        }

        if not canSendMessage() {
            return;
        }

        # Check if this is the first message BEFORE updating state
        isFirstMessage = messages.filter(lambda m: any -> bool { return m.isUser; }).length == 0;

        # Set loading immediately at the start
        isLoading = True;
        uiError = None;
        pendingUnsentMessage = content.trim();
        localStorage.setItem(UNSENT_MESSAGE_KEY, content.trim());

        # Create user message
        userMessage = {
            "id": "msg_" + String(Date.now()),
            "content": content.trim(),
            "isUser": True,
            "timestamp": Date()
        };

        messages = lambda prev: any -> any { return prev.concat([userMessage]); };
        lastUserMessage = content.trim();

        # Update session title immediately if first message
        if isFirstMessage {
            updateSessionTitle(content.trim(), True);
        }

        # Increment message count for guests
        if not isAuthenticated {
            messageCount = lambda prev: int -> int { return prev + 1; };
        }

        try {
            # Create two AbortControllers — one for each approach
            ragAbortController = Reflect.construct(AbortController, []);
            mcpAbortController = Reflect.construct(AbortController, []);
            # Store both so the stop button can cancel both
            abortControllerRef.current = {
                "abort": lambda -> None {
                    ragAbortController.abort();
                    mcpAbortController.abort();
                }
            };

            # Get response from backend
            userEmail = "";
            if isAuthenticated {
                userEmail = getUsernameFromToken();
            }

            # Create bot message placeholders based on mode
            ragBotMessageId = "msg_" + String(Date.now()) + "_" + String(Math.random()) + "_rag";
            mcpBotMessageId = "msg_" + String(Date.now()) + "_" + String(Math.random()) + "_mcp";

            ragBotMessage = {
                "id": ragBotMessageId,
                "content": "",
                "isUser": False,
                "source": "RAG",
                "timestamp": Date(),
                "reasoningSteps": [],
                "isReasoning": True,
                "elapsedMs": 0
            };
            mcpBotMessage = {
                "id": mcpBotMessageId,
                "content": "",
                "isUser": False,
                "source": "MCP",
                "timestamp": Date(),
                "reasoningSteps": [],
                "isReasoning": True,
                "elapsedMs": 0
            };

            if mode == "both" {
                messages = lambda prev: any -> any { return prev.concat([ragBotMessage, mcpBotMessage]); };
            } elif mode == "mcp" {
                messages = lambda prev: any -> any { return prev.concat([mcpBotMessage]); };
            } else {
                messages = lambda prev: any -> any { return prev.concat([ragBotMessage]); };
            }

            firstChunkRef.current = False;
            sendStartTimeRef.current = Date.now();

            # Reset reasoning state for new message based on mode
            ragReasoningSteps = [];
            mcpReasoningSteps = [];
            ragIsReasoning = mode == "rag" or mode == "both";
            mcpIsReasoning = mode == "mcp" or mode == "both";
            ragElapsedMs = 0;
            mcpElapsedMs = 0;

            # RAG chunk handler
            def onChunkRag(chunk: str) -> None {
                if not firstChunkRef.current {
                    firstChunkRef.current = True;
                    isLoading = False;
                }
                messages = lambda prev: any -> any {
                    updatedMessages = [];
                    for m in prev {
                        if m.id == ragBotMessageId {
                            updatedMessages.push({
                                "id": m.id,
                                "content": m.content + chunk,
                                "isUser": m.isUser,
                                "source": m.source,
                                "timestamp": m.timestamp,
                                "reasoningSteps": m.reasoningSteps or [],
                                "isReasoning": m.isReasoning or False,
                                "elapsedMs": m.elapsedMs or 0
                            });
                        } else {
                            updatedMessages.push(m);
                        }
                    }
                    return updatedMessages;
                };
            }

            # MCP chunk handler
            def onChunkMcp(chunk: str) -> None {
                if not firstChunkRef.current {
                    firstChunkRef.current = True;
                    isLoading = False;
                }
                messages = lambda prev: any -> any {
                    updatedMessages = [];
                    for m in prev {
                        if m.id == mcpBotMessageId {
                            updatedMessages.push({
                                "id": m.id,
                                "content": m.content + chunk,
                                "isUser": m.isUser,
                                "source": m.source,
                                "timestamp": m.timestamp,
                                "reasoningSteps": m.reasoningSteps or [],
                                "isReasoning": m.isReasoning or False,
                                "elapsedMs": m.elapsedMs or 0
                            });
                        } else {
                            updatedMessages.push(m);
                        }
                    }
                    return updatedMessages;
                };
            }

            # RAG event handler
            def onEventRag(event: any) -> None {
                eventType = event.type or "";
                eventData = event.data or {};
                if eventType == "error" or eventType == "parse_error" {
                    setUiErrorFrom({
                        "error": {
                            "code": eventData.code or "ERR_STREAM_RUNTIME",
                            "message": eventData.message or "Streaming failed while generating a response.",
                            "retryable": True
                        }
                    }, "ERR_STREAM_RUNTIME", "Streaming failed while generating a response.");
                    ragIsReasoning = False;
                }
                if eventType == "thought" or eventType == "tool_call" or eventType == "tool_result" or eventType == "steps_done" {
                    ragReasoningSteps = lambda prev: any -> any {
                        return prev.concat([{"type": eventType, "data": eventData}]);
                    };
                    messages = lambda prev: any -> any {
                        updatedMessages = [];
                        for m in prev {
                            if m.id == ragBotMessageId {
                                updatedMessages.push({
                                    "id": m.id,
                                    "content": m.content,
                                    "isUser": m.isUser,
                                    "source": m.source,
                                    "timestamp": m.timestamp,
                                    "reasoningSteps": (m.reasoningSteps or []).concat([{"type": eventType, "data": eventData}]),
                                    "isReasoning": m.isReasoning,
                                    "elapsedMs": m.elapsedMs
                                });
                            } else {
                                updatedMessages.push(m);
                            }
                        }
                        return updatedMessages;
                    };
                }
                if eventType == "steps_done" or eventType == "chunk" {
                    ragIsReasoning = False;
                    messages = lambda prev: any -> any {
                        updatedMessages = [];
                        for m in prev {
                            if m.id == ragBotMessageId {
                                updatedMessages.push({
                                    "id": m.id,
                                    "content": m.content,
                                    "isUser": m.isUser,
                                    "source": m.source,
                                    "timestamp": m.timestamp,
                                    "reasoningSteps": m.reasoningSteps or [],
                                    "isReasoning": False,
                                    "elapsedMs": Date.now() - sendStartTimeRef.current
                                });
                            } else {
                                updatedMessages.push(m);
                            }
                        }
                        return updatedMessages;
                    };
                }
            }

            # MCP event handler
            def onEventMcp(event: any) -> None {
                eventType = event.type or "";
                eventData = event.data or {};
                if eventType == "error" or eventType == "parse_error" {
                    setUiErrorFrom({
                        "error": {
                            "code": eventData.code or "ERR_STREAM_RUNTIME",
                            "message": eventData.message or "Streaming failed while generating a response.",
                            "retryable": True
                        }
                    }, "ERR_STREAM_RUNTIME", "Streaming failed while generating a response.");
                    mcpIsReasoning = False;
                }
                if eventType == "thought" or eventType == "tool_call" or eventType == "tool_result" or eventType == "steps_done" {
                    mcpReasoningSteps = lambda prev: any -> any {
                        return prev.concat([{"type": eventType, "data": eventData}]);
                    };
                    messages = lambda prev: any -> any {
                        updatedMessages = [];
                        for m in prev {
                            if m.id == mcpBotMessageId {
                                updatedMessages.push({
                                    "id": m.id,
                                    "content": m.content,
                                    "isUser": m.isUser,
                                    "source": m.source,
                                    "timestamp": m.timestamp,
                                    "reasoningSteps": (m.reasoningSteps or []).concat([{"type": eventType, "data": eventData}]),
                                    "isReasoning": m.isReasoning,
                                    "elapsedMs": m.elapsedMs
                                });
                            } else {
                                updatedMessages.push(m);
                            }
                        }
                        return updatedMessages;
                    };
                }
                if eventType == "steps_done" or eventType == "chunk" {
                    mcpIsReasoning = False;
                    messages = lambda prev: any -> any {
                        updatedMessages = [];
                        for m in prev {
                            if m.id == mcpBotMessageId {
                                updatedMessages.push({
                                    "id": m.id,
                                    "content": m.content,
                                    "isUser": m.isUser,
                                    "source": m.source,
                                    "timestamp": m.timestamp,
                                    "reasoningSteps": m.reasoningSteps or [],
                                    "isReasoning": False,
                                    "elapsedMs": Date.now() - sendStartTimeRef.current
                                });
                            } else {
                                updatedMessages.push(m);
                            }
                        }
                        return updatedMessages;
                    };
                }
            }

            # Handle suggestions independently (fire and forget)
            async def handleSuggestions() -> None {
                isSearchingDocs = True;
                try {
                    suggestResult = await getSuggestions(content.trim(), []);
                    if suggestResult.success and suggestResult.suggestions {
                        docSuggestions = suggestResult.suggestions;
                    } elif not suggestResult.success {
                        setUiErrorFrom(suggestResult, "ERR_GET_SUGGESTIONS", "Could not load documentation suggestions.");
                    }
                } except Exception as e {
                    console.error("Error fetching suggestions:", e);
                    setUiErrorFrom({"error": {"code": "ERR_GET_SUGGESTIONS", "message": "Could not load documentation suggestions.", "retryable": True}}, "ERR_GET_SUGGESTIONS", "Could not load documentation suggestions.");
                } finally {
                    setTimeout(lambda -> None {
                        isSearchingDocs = False;
                    }, 3000);
                }
            }
            handleSuggestions();

            # Helper to handle a failed result for a specific bot message id
            def handleFailedResult(result: any, botMsgId: str) -> None {
                if result.aborted {
                    messages = lambda prev: any -> any {
                        return prev.filter(lambda m: any -> bool { return m.id != botMsgId; });
                    };
                } else {
                    console.error("Error in sendMessage:", result.error);
                    setUiErrorFrom(result, "ERR_SEND_MESSAGE", "Failed to send message. Please try again.");
                    messages = lambda prev: any -> any {
                        return prev.map(lambda m: any -> any {
                            if m.id == botMsgId {
                                errCode = (result.code if result.code else (result.error.code if result.error and result.error.code else "ERR_SEND_MESSAGE"));
                                errMsg = (result.message if result.message else (result.error.message if result.error and result.error.message else "Failed to send message. Please try again."));
                                return {
                                    "id": m.id,
                                    "content": "[" + errCode + "] " + errMsg,
                                    "isUser": m.isUser,
                                    "source": m.source,
                                    "timestamp": m.timestamp,
                                    "reasoningSteps": m.reasoningSteps or [],
                                    "isReasoning": False,
                                    "elapsedMs": m.elapsedMs or 0
                                };
                            }
                            return m;
                        });
                    };
                }
            }

            # Wrap each call to capture individual elapsed time
            async def sendRag() -> any {
                result = await sendMessage(content.trim(), sessionId, userEmail, onChunkRag, onEventRag, ragAbortController.signal, "rag", False);
                ragElapsedMs = Date.now() - sendStartTimeRef.current;
                return result;
            }

            async def sendMcp() -> any {
                skipHist = mode == "both";
                result = await sendMessage(content.trim(), sessionId, userEmail, onChunkMcp, onEventMcp, mcpAbortController.signal, "mcp", skipHist);
                mcpElapsedMs = Date.now() - sendStartTimeRef.current;
                return result;
            }

            # Dispatch based on mode
            if mode == "both" {
                results = await Promise.all([sendRag(), sendMcp()]);
                ragResult = results[0];
                mcpResult = results[1];
                if not ragResult.success {
                    handleFailedResult(ragResult, ragBotMessageId);
                }
                if not mcpResult.success {
                    handleFailedResult(mcpResult, mcpBotMessageId);
                }
                if ragResult.success and mcpResult.success {
                    localStorage.removeItem(UNSENT_MESSAGE_KEY);
                    pendingUnsentMessage = "";
                }
            } elif mode == "mcp" {
                mcpResult = await sendMcp();
                if not mcpResult.success {
                    handleFailedResult(mcpResult, mcpBotMessageId);
                } else {
                    localStorage.removeItem(UNSENT_MESSAGE_KEY);
                    pendingUnsentMessage = "";
                }
            } else {
                ragResult = await sendRag();
                if not ragResult.success {
                    handleFailedResult(ragResult, ragBotMessageId);
                } else {
                    localStorage.removeItem(UNSENT_MESSAGE_KEY);
                    pendingUnsentMessage = "";
                }
            }

            # Clear abort controller after completion
            abortControllerRef.current = None;
        } except Exception as e {
            console.error("Send message error:", e);
            setUiErrorFrom({"error": {"code": "ERR_SEND_MESSAGE", "message": "Failed to send message. Please try again.", "retryable": True}}, "ERR_SEND_MESSAGE", "Failed to send message. Please try again.");
            errorMessage = {
                "id": "msg_" + String(Date.now()),
                "content": "[ERR_SEND_MESSAGE] Failed to send message. Please try again.",
                "isUser": False,
                "source": "",
                "timestamp": Date()
            };
            messages = lambda prev: any -> any { return prev.concat([errorMessage]); };
            isLoading = False;
        } finally {
            # Clear abort controller after completion
            abortControllerRef.current = None;
            isLoading = False;

            # Signal that streaming is fully done so scroll re-anchors
            streamDoneSignal = lambda prev: int -> int { return prev + 1; };
        }
    }

    async def fetchDocSuggestions(message: str) -> None {
        try {
            result = await getSuggestions(message, []);
            if result.success and result.suggestions {
                docSuggestions = result.suggestions;
            } elif not result.success {
                setUiErrorFrom(result, "ERR_GET_SUGGESTIONS", "Could not load documentation suggestions.");
            }
        } except Exception as e {
            console.error("Error fetching suggestions:", e);
            setUiErrorFrom({"error": {"code": "ERR_GET_SUGGESTIONS", "message": "Could not load documentation suggestions.", "retryable": True}}, "ERR_GET_SUGGESTIONS", "Could not load documentation suggestions.");
        }
    }

    def updateSessionTitle(firstMessage: str, isFirstMessage: bool) -> None {
        # Only update if this is the first user message
        if isFirstMessage {
            title = firstMessage.substring(0, 50);
            if firstMessage.length > 50 {
                title = title + "...";
            }

            # Check if session exists
            existingIndex = chatSessions.findIndex(lambda s: any -> bool { return s.id == sessionId; });

            if existingIndex >= 0 {
                # Update existing session
                chatSessions = lambda prev: any -> any {
                    updatedSessions = prev.map(lambda s: any, idx: int -> any {
                        if idx == existingIndex {
                            return {"id": s.id, "title": title, "createdAt": s.createdAt};
                        }
                        return s;
                    });
                    localStorage.setItem("jac_gpt_sessions", JSON.stringify(updatedSessions));
                    return updatedSessions;
                };
            } else {
                # Add new session
                newSession = {
                    "id": sessionId,
                    "title": title,
                    "createdAt": String(Date.now())
                };
                chatSessions = lambda prev: any -> any {
                    updated = [newSession].concat(prev);
                    localStorage.setItem("jac_gpt_sessions", JSON.stringify(updated));
                    return updated;
                };
            }
        }
    }

    async def handleNewChat() -> None {
        messages = [];
        docSuggestions = [];
        lastUserMessage = "";
        await initSession();
    }

    async def handleLoadSession(loadSessionId: str) -> None {
        isLoading = True;
        try {
            result = await getSession(loadSessionId);
            if result.success and result.found {
                sessionId = loadSessionId;
                # Convert chat history to messages format
                newMessages = [];
                for historyItem in result.chat_history {
                    msg = {
                        "id": "msg_" + String(Date.now()) + "_" + String(Math.random()),
                        "content": historyItem.content,
                        "isUser": historyItem.role == "user",
                        "timestamp": Date()
                    };
                    newMessages.push(msg);
                }
                messages = lambda prev: any -> any { return newMessages; };
            } elif not result.success {
                setUiErrorFrom(result, "ERR_GET_SESSION", "Failed to load the selected session.");
            }
        } except Exception as e {
            console.error("Error loading session:", e);
            setUiErrorFrom({"error": {"code": "ERR_GET_SESSION", "message": "Failed to load the selected session.", "retryable": True}}, "ERR_GET_SESSION", "Failed to load the selected session.");
        } finally {
            isLoading = False;
        }
    }

    def handleDeleteSession(deleteSessionId: str) -> None {
        chatSessions = lambda prev: any -> any {
            updated = prev.filter(lambda s: any -> bool { return s.id != deleteSessionId; });
            localStorage.setItem("jac_gpt_sessions", JSON.stringify(updated));
            return updated;
        };

        # If deleting current session, start new one
        if deleteSessionId == sessionId {
            handleNewChat();
        }
    }

    def handleStopGeneration() -> None {
        # Abort the ongoing request if exists
        if abortControllerRef.current {
            try {
                abortControllerRef.current.abort();
                console.log("Request aborted by user");
            } except Exception as e {
                console.error("Error aborting request:", e);
            }
            abortControllerRef.current = None;
        }
        isLoading = False;
    }

    async def handleRetryLastMessage() -> None {
        if pendingUnsentMessage and not isLoading {
            await handleSendMessage(pendingUnsentMessage);
        }
    }

    def clearUiError() -> None {
        uiError = None;
    }

    return {
        "messages": messages,
        "sessionId": sessionId,
        "isLoading": isLoading,
        "messageCount": messageCount,
        "maxFreeMessages": maxFreeMessages,
        "chatSessions": chatSessions,
        "docSuggestions": docSuggestions,
        "lastUserMessage": lastUserMessage,
        "isSearchingDocs": isSearchingDocs,
        "ragReasoningSteps": ragReasoningSteps,
        "mcpReasoningSteps": mcpReasoningSteps,
        "ragIsReasoning": ragIsReasoning,
        "mcpIsReasoning": mcpIsReasoning,
        "ragElapsedMs": ragElapsedMs,
        "mcpElapsedMs": mcpElapsedMs,
        "mode": mode,
        "uiError": uiError,
        "pendingUnsentMessage": pendingUnsentMessage,
        "messagesEndRef": messagesEndRef,
        "latestUserMsgRef": latestUserMsgRef,
        "canSendMessage": canSendMessage,
        "handleSendMessage": handleSendMessage,
        "handleRetryLastMessage": handleRetryLastMessage,
        "clearUiError": clearUiError,
        "handleNewChat": handleNewChat,
        "handleLoadSession": handleLoadSession,
        "handleDeleteSession": handleDeleteSession,
        "handleStopGeneration": handleStopGeneration,
        "setMode": setMode
    };
}