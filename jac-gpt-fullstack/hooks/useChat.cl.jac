"""Chat hook for managing chat state and interactions."""

import from react { useState, useEffect, useRef }
import from "@jac/runtime" { jacIsLoggedIn }
import from ..services.jacService { createSession, getSession, sendMessage, getSuggestions, generateSessionId }
import from ..hooks.useAuth { getUsernameFromToken }

"""Hook for managing chat state and interactions."""
def:pub useChat() -> any {
    has messages: list = [];
    has sessionId: str = "";
    has isLoading: bool = False;
    has messageCount: int = 0;
    has maxFreeMessages: int = 30;
    has chatSessions: list = [];
    has docSuggestions: list = [];
    has lastUserMessage: str = "";

    messagesEndRef = useRef(None);
    firstChunkRef = useRef(False);
    prevMessageCountRef = useRef(0);
    isAuthenticated = jacIsLoggedIn();

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
            }
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

    # Scroll to bottom only when new messages are added (not during streaming updates)
    useEffect(lambda -> None {
        currentCount = messages.length;
        # Only scroll if message count increased (new message added)
        if currentCount > prevMessageCountRef.current {
            if messagesEndRef.current {
                messagesEndRef.current.scrollIntoView({"behavior": "smooth"});
            }
        }
        prevMessageCountRef.current = currentCount;
    }, [messages]);

    async def initSession() -> None {
        newSessionId = generateSessionId();
        result = await createSession(newSessionId);
        if result.success {
            sessionId = result.session_id;
        } else {
            sessionId = newSessionId;
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

        # Set loading immediately at the start
        isLoading = True;
        console.log("isLoading set to True at the beginning");

        # Create user message
        userMessage = {
            "id": "msg_" + String(Date.now()),
            "content": content.trim(),
            "isUser": True,
            "timestamp": Date()
        };

        messages = lambda prev: any -> any { return prev.concat([userMessage]); };
        lastUserMessage = content.trim();

        # Increment message count for guests
        if not isAuthenticated {
            messageCount = lambda prev: int -> int { return prev + 1; };
        }

        try {
            # Get response from backend
            userEmail = "";
            if isAuthenticated {
                userEmail = getUsernameFromToken();
            }

            # Create empty bot message for SSE streaming
            botMessageId = "msg_" + String(Date.now()) + "_" + String(Math.random()) + "_bot";
            botMessage = {
                "id": botMessageId,
                "content": "",  # Explicitly empty - no user content
                "isUser": False,
                "timestamp": Date()
            };
            messages = lambda prev: any -> any { return prev.concat([botMessage]); };

            # Handle suggestions independently (fire and forget)
            # async def handleSuggestions() -> None {
            #     try {
            #         suggestResult = await getSuggestions(content.trim(), []);
            #         if suggestResult.success and suggestResult.suggestions {
            #             docSuggestions = suggestResult.suggestions;
            #         }
            #     } except Exception as e {
            #         console.error("Error fetching suggestions:", e);
            #     }
            # }
            # handleSuggestions();

            # SSE chunk handler - updates message content for each chunk
            userMessageContent = content.trim();  # Store user message for filtering
            firstChunkRef.current = False;  # Reset for this message
            
            def onChunk(chunk: str) -> None {
                # Stop loading animation on first chunk
                if not firstChunkRef.current {
                    firstChunkRef.current = True;
                    isLoading = False;
                    console.log("Received first chunk, stopping loading state.");
                }
                
                # Update message by finding and replacing with new content
                messages = lambda prev: any -> any {
                    updatedMessages = [];
                    for m in prev {
                        if m.id == botMessageId {
                            # Append chunk - backend should only send assistant response
                            newContent = m.content + chunk;
                            
                            updatedMessage = {
                                "id": m.id,
                                "content": newContent,
                                "isUser": m.isUser,
                                "timestamp": m.timestamp
                            };
                            updatedMessages.push(updatedMessage);
                        } else {
                            updatedMessages.push(m);
                        }
                    }
                    return updatedMessages;
                };
            }

            # Wait for SSE streaming to complete
            result = await sendMessage(content.trim(), sessionId, userEmail, onChunk);

            if result.success {
                # Update session title if first message (check before we added the user message)
                isFirstMessage = messages.filter(lambda m: any -> bool { return m.isUser; }).length == 1;
                updateSessionTitle(content.trim(), isFirstMessage);
            } else {
                # Update message with error
                console.error("Error in sendMessage:", result.error);
                messages = lambda prev: any -> any {
                    return prev.map(lambda m: any -> any {
                        if m.id == botMessageId {
                            return {
                                "id": m.id,
                                "content": "Sorry, I encountered an error. Please try again.",
                                "isUser": m.isUser,
                                "timestamp": m.timestamp
                            };
                        }
                        return m;
                    });
                };
            }
        } except Exception as e {
            console.error("Send message error:", e);
            errorMessage = {
                "id": "msg_" + String(Date.now()),
                "content": "Sorry, something went wrong. Please try again.",
                "isUser": False,
                "timestamp": Date()
            };
            messages = lambda prev: any -> any { return prev.concat([errorMessage]); };
            # Stop loading on error
            isLoading = False;
        }
    }

    async def fetchDocSuggestions(message: str) -> None {
        try {
            result = await getSuggestions(message, []);
            if result.success and result.suggestions {
                docSuggestions = result.suggestions;
            }
        } except Exception as e {
            console.error("Error fetching suggestions:", e);
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
            }
        } except Exception as e {
            console.error("Error loading session:", e);
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
        isLoading = False;
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
        "messagesEndRef": messagesEndRef,
        "canSendMessage": canSendMessage,
        "handleSendMessage": handleSendMessage,
        "handleNewChat": handleNewChat,
        "handleLoadSession": handleLoadSession,
        "handleDeleteSession": handleDeleteSession,
        "handleStopGeneration": handleStopGeneration
    };
}