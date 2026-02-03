# Main chatbot page component following complete specification

import from react { useState, useRef, useEffect }
import from "@jac/runtime" { jacIsLoggedIn }
import from "@mantine/core" { ScrollArea }
import from "@tabler/icons-react" { IconBook, IconX, IconMenu2 }
import from ..hooks.useChat { useChat }
import from ..components.ChatMessage { ChatMessage }
import from ..components.ChatInput { ChatInput }
import from ..components.Sidebar { Sidebar }
import from ..components.DocumentationPanel { DocumentationPanel }

# Main Jac GPT Chatbot component (Complete Specification)
def:pub JacChatbot() -> any {
    has sidebarOpen: bool = False;
    has docPanelOpen: bool = False;

    # Color scheme from specification
    BG = "#141414";                  # main background
    BORDER = "#374151";              # gray-700
    TEXT = "#ffffff";
    TEXT_SECONDARY = "#d1d5db";      # gray-300
    MUTED = "#9ca3af";               # gray-400
    ORANGE = "#f97316";              # primary accent

    chat = useChat();
    isAuthenticated = jacIsLoggedIn();
    scrollAreaRef = useRef(None);

    # Add CSS animations on mount
    useEffect(lambda -> None {
        # Add keyframes for animations if not already present
        styleId = "chat-animations";
        if not document.getElementById(styleId) {
            style = document.createElement("style");
            style.id = styleId;
            style.textContent = """
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(10px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @keyframes dotBounce {
                    0%, 60%, 100% { 
                        transform: translateY(0);
                    }
                    30% { 
                        transform: translateY(-4px);
                    }
                }
            """;
            document.head.appendChild(style);
        }
    }, []);

    def toggleSidebar() -> None {
        sidebarOpen = not sidebarOpen;
    }

    def toggleDocPanel() -> None {
        docPanelOpen = not docPanelOpen;
    }

    # Build message items
    messageItems = [];
    for msg in chat.messages {
        messageItems.push(<div key={msg.id} style={{"animation": "fadeIn 0.3s ease"}}>
            <ChatMessage
                message={msg.content}
                isUser={msg.isUser}
                timestamp={msg.timestamp}
            />
        </div>);
    }

    # Loading indicator with bouncing dots (sequential bounce)
    loadingIndicator = <div style={{
        "paddingTop": "16px",
        "paddingBottom": "16px",
        "paddingLeft": "8px",
        "paddingRight": "8px",
        "animation": "fadeIn 0.3s ease"
    }}>
        <div style={{
            "display": "flex",
            "alignItems": "center",
            "gap": "8px"
        }}>
            <div style={{
                "display": "flex",
                "gap": "4px",
                "alignItems": "flex-end"
            }}>
                {[0, 1, 2].map(lambda i: int -> any {
                    delays = ["0s", "0.15s", "0.3s"];
                    return <div
                        key={i}
                        style={{
                            "width": "6px",
                            "height": "6px",
                            "borderRadius": "50%",
                            "backgroundColor": ORANGE,
                            "animation": "dotBounce 1.1s ease-in-out infinite",
                            "animationDelay": delays[i]
                        }}
                    />;
                })}
            </div>
            <span style={{
                "fontSize": "14px",
                "color": MUTED,
                "fontWeight": "400",
                "marginLeft": "8px"
            }}>
                Thinking...
            </span>
        </div>
    </div>;

    # Check if we have messages
    hasMessages = chat.messages.length > 0;

    loadingContent = None;
    if chat.isLoading {
        loadingContent = loadingIndicator;
    }

    # Messages content or empty state
    mainContent = None;
    if hasMessages {
        # Active conversation - messages area
        mainContent = <ScrollArea ref={scrollAreaRef} style={{"flex": "1", "paddingLeft": "16px", "paddingRight": "16px"}} type="scroll">
            <div style={{
                "maxWidth": "768px",
                "margin": "0 auto",
                "paddingTop": "16px",
                "paddingBottom": "16px",
                "minWidth": "0",
                "overflow": "hidden"
            }}>
                <div style={{
                    "display": "flex",
                    "flexDirection": "column",
                    "gap": "8px"
                }}>
                    {messageItems}
                    {loadingContent}
                </div>
                <div ref={chat.messagesEndRef} />
            </div>
        </ScrollArea>;
    } else {
        # Empty state
        mainContent = <div style={{
            "flex": "1",
            "display": "flex",
            "flexDirection": "column",
            "alignItems": "center",
            "justifyContent": "center",
            "paddingLeft": "16px",
            "paddingRight": "16px",
            "marginTop": "-96px"
        }}>
            <div style={{
                "maxWidth": "768px",
                "width": "100%",
                "margin": "0 auto",
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center",
                "justifyContent": "center"
            }}>
                <h1 style={{
                    "fontSize": "30px",
                    "color": TEXT_SECONDARY,
                    "fontWeight": "500",
                    "fontFamily": "'Inter, sans-serif'",
                    "marginBottom": "36px",
                    "textAlign": "center"
                }}>
                    How can I help you today?
                </h1>
                
                <div style={{"width": "100%"}}>
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask about Jac syntax, functions, loops, classes, or request code examples..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                    
                    <div style={{
                        "display": "flex",
                        "gap": "12px",
                        "marginTop": "2px",
                        "flexWrap": "wrap",
                        "justifyContent": "center"
                    }}>
                        {["What is by llm?", "What are walkers?", "What are nodes?"].map(lambda text: str -> any {
                            return <button
                                key={text}
                                onClick={lambda -> None {
                                    chat.handleSendMessage(text);
                                }}
                                style={{
                                    "padding": "10px 18px",
                                    "border": "none",
                                    "borderRadius": "24px",
                                    "background": "rgba(255, 255, 255, 0.05)",
                                    "color": TEXT_SECONDARY,
                                    "cursor": "pointer",
                                    "fontSize": "16px",
                                    "transition": "all 0.2s ease",
                                    "fontFamily": "Inter"
                                }}
                                onMouseEnter={lambda e: any -> None {
                                    e.target.style.background = "rgba(249, 115, 22, 0.15)";
                                }}
                                onMouseLeave={lambda e: any -> None {
                                    e.target.style.background = "rgba(255, 255, 255, 0.05)";
                                }}
                            >
                                {text}
                            </button>;
                        })}
                    </div>
                </div>
            </div>
        </div>;
    }

    # Layout widths when docs open
    chatContainerStyle = {
        "flex": "1",
        "display": "flex",
        "flexDirection": "column",
        "minWidth": "0",
        "transition": "all 0.3s ease"
    };
    if docPanelOpen {
        chatContainerStyle["width"] = "50%";
    }

    # Doc panel element
    docPanelElement = None;
    if docPanelOpen {
        docPanelElement = <div style={{
            "width": "50%",
            "borderLeft": "1px solid " + BORDER,
            "background": BG
        }}>
            <DocumentationPanel
                message={chat.lastUserMessage}
                suggestions={chat.docSuggestions}
                isVisible={docPanelOpen}
                onToggle={toggleDocPanel}
            />
        </div>;
    }

    # Mobile menu button (visible only on mobile)
    mobileMenuButton = <button
        onClick={toggleSidebar}
        style={{
            "position": "fixed",
            "top": "8px",
            "left": "8px",
            "zIndex": "40",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "width": "40px",
            "height": "40px",
            "border": "none",
            "borderRadius": "8px",
            "background": "rgba(55, 65, 81, 0.9)",
            "color": TEXT,
            "cursor": "pointer"
        }}
    >
        <IconMenu2 size={20} />
    </button>;

    # Header bar (desktop only - uses media query)
    headerBar = <div style={{
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "space-between",
        "padding": "8px",
        "borderBottom": "1px solid " + BORDER,
        "background": BG
    }}>
        <div style={{
            "display": "flex",
            "alignItems": "center",
            "gap": "12px"
        }}>
            <img
                src="/logo.png"
                style={{
                    "width": "32px",
                    "height": "32px",
                    "objectFit": "contain"
                }}
            />
            <h1 style={{
                "fontSize": "20px",
                "fontWeight": "600",
                "color": TEXT
            }}>
                Jac GPT
            </h1>
        </div>

        <button
            onClick={toggleDocPanel}
            style={{
                "display": "flex",
                "alignItems": "center",
                "gap": "8px",
                "padding": "8px 16px",
                "border": (("1px solid " + ORANGE if docPanelOpen else "1px solid " + BORDER)),
                "borderRadius": "8px",
                "background": ((ORANGE if docPanelOpen else "transparent")),
                "color": TEXT,
                "cursor": "pointer",
                "fontSize": "14px",
                "transition": "all 0.2s ease"
            }}
        >
            {((<IconX size={16} />) if docPanelOpen else (<IconBook size={16} />))}
            <span>{(("Hide Docs") if docPanelOpen else ("Show Docs"))}</span>
        </button>
    </div>;

    return <div style={{
        "display": "flex",
        "height": "100vh",
        "background": BG
    }}>
        <Sidebar
            isOpen={sidebarOpen}
            onToggle={toggleSidebar}
            onNewChat={chat.handleNewChat}
            chatSessions={chat.chatSessions}
            currentSessionId={chat.sessionId}
            onLoadSession={chat.handleLoadSession}
            onDeleteSession={chat.handleDeleteSession}
            isLoading={chat.isLoading}
            messageCount={chat.messageCount}
            maxFreeMessages={chat.maxFreeMessages}
        />

        <div style={{"flex": "1", "display": "flex", "overflow": "hidden"}}>
            <div style={chatContainerStyle}>
                {mobileMenuButton}
                {headerBar}
                
                {mainContent}

                {(
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask about Jac syntax, functions, loops, classes, or request code examples..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                    if hasMessages else None
                )}
            </div>

            {docPanelElement}
        </div>
    </div>;
}
