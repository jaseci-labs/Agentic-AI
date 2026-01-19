"""Chat hook for managing chat state and interactions."""

import from react { useState, useEffect, useRef }
import from "@jac-client/utils" { jacIsLoggedIn }
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

    # Scroll to bottom when messages change
    useEffect(lambda -> None {
        if messagesEndRef.current {
            messagesEndRef.current.scrollIntoView({"behavior": "smooth"});
        }
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

        # Create user message
        userMessage = {
            "id": "msg_" + String(Date.now()),
            "content": content.trim(),
            "isUser": True,
            "timestamp": Date()
        };

        messages = messages.concat([userMessage]);
        lastUserMessage = content.trim();
        isLoading = True;

        # Increment message count for guests
        if not isAuthenticated {
            messageCount = messageCount + 1;
        }

        try {
            # Get response from backend
            userEmail = "";
            if isAuthenticated {
                userEmail = getUsernameFromToken();
            }

            result = await sendMessage(content.trim(), sessionId, userEmail);

            if result.success {
                # Create bot message
                botMessage = {
                    "id": "msg_" + String(Date.now()),
                    "content": result.response,
                    "isUser": False,
                    "timestamp": Date()
                };
                messages = messages.concat([botMessage]);

                # Update session title if first message
                updateSessionTitle(content.trim());

                # Get documentation suggestions
                fetchDocSuggestions(content.trim());
            } else {
                # Error message
                errorMessage = {
                    "id": "msg_" + String(Date.now()),
                    "content": "Sorry, I encountered an error. Please try again.",
                    "isUser": False,
                    "timestamp": Date()
                };
                messages = messages.concat([errorMessage]);
            }
        } except Exception as e {
            console.error("Send message error:", e);
            errorMessage = {
                "id": "msg_" + String(Date.now()),
                "content": "Sorry, something went wrong. Please try again.",
                "isUser": False,
                "timestamp": Date()
            };
            messages = messages.concat([errorMessage]);
        } finally {
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

    def updateSessionTitle(firstMessage: str) -> None {
        # Only update if this is the first user message
        userMessages = messages.filter(lambda m: any -> bool { return m.isUser; });
        if userMessages.length == 1 {
            title = firstMessage.substring(0, 50);
            if firstMessage.length > 50 {
                title = title + "...";
            }

            # Check if session exists
            existingIndex = -1;
            for i in range(chatSessions.length) {
                if chatSessions[i].id == sessionId {
                    existingIndex = i;
                    break;
                }
            }

            if existingIndex >= 0 {
                # Update existing session
                chatSessions[existingIndex].title = title;
            } else {
                # Add new session
                newSession = {
                    "id": sessionId,
                    "title": title,
                    "createdAt": Date().toISOString()
                };
                chatSessions = [newSession].concat(chatSessions);
            }

            # Save to localStorage
            localStorage.setItem("jac_gpt_sessions", JSON.stringify(chatSessions));
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
                messages = newMessages;
            }
        } except Exception as e {
            console.error("Error loading session:", e);
        } finally {
            isLoading = False;
        }
    }

    def handleDeleteSession(deleteSessionId: str) -> None {
        chatSessions = chatSessions.filter(lambda s: any -> bool { return s.id != deleteSessionId; });
        localStorage.setItem("jac_gpt_sessions", JSON.stringify(chatSessions));

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
