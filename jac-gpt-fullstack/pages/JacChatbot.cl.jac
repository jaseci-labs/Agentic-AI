# Main chatbot page component following complete specification

import from react { useState, useRef, useEffect, useLayoutEffect }
import from "@jac/runtime" { jacIsLoggedIn }
import from "@mantine/core" { ScrollArea }
import from "@tabler/icons-react" { IconBook, IconX, IconMenu2 }
import from ..hooks.useChat { useChat }
import from ..components.ChatMessage { ChatMessage }
import from ..components.ChatInput { ChatInput }
import from ..components.Sidebar { Sidebar }
import from ..components.DocumentationPanel { DocumentationPanel }
import from ..components.AgentReasoning { AgentReasoning }
import from ..components.ErrorAlert { ErrorAlert }

# Main Jac GPT Chatbot component (Complete Specification)
def:pub JacChatbot(theme: str = "dark", onSetTheme: any = None) -> JsxElement {
    has sidebarOpen: bool = False;
    has docPanelOpen: bool = False;

    # Color scheme from specification
    BG = "var(--background)";                  # main background (themeable)
    BORDER = "var(--border-light)";            # divider / panel border
    TEXT = "var(--text-primary)";
    TEXT_SECONDARY = "var(--text-secondary)";
    MUTED = "var(--text-muted)";
    ORANGE = "var(--primary)";                 # primary accent

    chat = useChat();
    isAuthenticated = jacIsLoggedIn();
    scrollAreaRef = useRef(None);
    viewportRef = useRef(None);
    spacerRef = useRef(None);

    # Resize spacer via DOM ref before paint — no state, no re-render, no vibration
    useLayoutEffect(lambda () {
        vp = viewportRef.current;
        ref = chat.latestUserMsgRef.current;
        spacer = spacerRef.current;
        if vp and ref and spacer {
            oldH = spacer.offsetHeight;
            contentH = vp.scrollHeight - oldH;
            belowMsg = contentH - (ref.offsetTop + ref.offsetHeight);
            needed = vp.clientHeight - belowMsg;
            if needed < 0 {
                needed = 0;
            }
            spacer.style.height = String(needed) + "px";
        }
    }, [chat.messages]);

    # Add CSS animations on mount
    useEffect(lambda () {
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
                @keyframes shimmer {
                    0% {
                        background-position: 200% center;
                    }
                    100% {
                        background-position: -200% center;
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

    # Find last user message ID for scroll-to-top ref
    lastUserMsgId = "";
    for msg in chat.messages {
        if msg.isUser {
            lastUserMsgId = msg.id;
        }
    }

    # Build message items — render both-mode RAG/MCP pairs side by side
    allMessageItems = [];
    idx = 0;
    while idx < chat.messages.length {
        msg = chat.messages[idx];

        hasPair = (
            (not msg.isUser) and
            msg.pairKey and
            (msg.source == "RAG" or msg.source == "MCP") and
            (idx + 1 < chat.messages.length) and
            (not chat.messages[idx + 1].isUser) and
            (chat.messages[idx + 1].pairKey == msg.pairKey)
        );

        if hasPair {
            nextMsg = chat.messages[idx + 1];

            ragMsg = (msg if msg.source == "RAG" else (nextMsg if nextMsg.source == "RAG" else None));
            mcpMsg = (msg if msg.source == "MCP" else (nextMsg if nextMsg.source == "MCP" else None));

            allMessageItems.push(<div key={"pair_" + msg.pairKey} style={{"animation": "fadeIn 0.3s ease", "scrollMarginTop": "16px"}}>
                <div style={{
                    "display": "flex",
                    "gap": "12px",
                    "flexWrap": "wrap",
                    "alignItems": "flex-start"
                }}>
                    {(
                        <div style={{"flex": "1 1 320px", "minWidth": "280px", "display": "flex", "flexDirection": "column", "gap": "8px"}}>
                            {(
                                <AgentReasoning
                                    steps={ragMsg.reasoningSteps or []}
                                    isActive={ragMsg.isReasoning or False}
                                    title="RAG Reasoning"
                                    elapsedMs={ragMsg.elapsedMs or 0}
                                />
                                if ((ragMsg.reasoningSteps and ragMsg.reasoningSteps.length > 0) or ragMsg.isReasoning)
                                else None
                            )}
                            <ChatMessage
                                message={ragMsg.content}
                                isUser={False}
                                timestamp={ragMsg.timestamp}
                                source={ragMsg.source or "RAG"}
                                theme={theme}
                            />
                        </div>
                        if ragMsg
                        else None
                    )}

                    {(
                        <div style={{"flex": "1 1 320px", "minWidth": "280px", "display": "flex", "flexDirection": "column", "gap": "8px"}}>
                            {(
                                <AgentReasoning
                                    steps={mcpMsg.reasoningSteps or []}
                                    isActive={mcpMsg.isReasoning or False}
                                    title="MCP Reasoning"
                                    elapsedMs={mcpMsg.elapsedMs or 0}
                                />
                                if ((mcpMsg.reasoningSteps and mcpMsg.reasoningSteps.length > 0) or mcpMsg.isReasoning)
                                else None
                            )}
                            <ChatMessage
                                message={mcpMsg.content}
                                isUser={False}
                                timestamp={mcpMsg.timestamp}
                                source={mcpMsg.source or "MCP"}
                                theme={theme}
                            />
                        </div>
                        if mcpMsg
                        else None
                    )}
                </div>
            </div>);

            idx = idx + 2;
            continue;
        }

        msgRef = (chat.latestUserMsgRef if msg.id == lastUserMsgId else None);

        if not msg.isUser and msg.source == "RAG" {
            hasRagReasoning = (msg.reasoningSteps and msg.reasoningSteps.length > 0) or msg.isReasoning;
            if hasRagReasoning {
                allMessageItems.push(<div key={msg.id + "_rag_reasoning"}>
                    <AgentReasoning
                        steps={msg.reasoningSteps or []}
                        isActive={msg.isReasoning or False}
                        title="RAG Reasoning"
                        elapsedMs={msg.elapsedMs or 0}
                    />
                </div>);
            }
        }

        if not msg.isUser and msg.source == "MCP" {
            hasMcpReasoning = (msg.reasoningSteps and msg.reasoningSteps.length > 0) or msg.isReasoning;
            if hasMcpReasoning {
                allMessageItems.push(<div key={msg.id + "_mcp_reasoning"}>
                    <AgentReasoning
                        steps={msg.reasoningSteps or []}
                        isActive={msg.isReasoning or False}
                        title="MCP Reasoning"
                        elapsedMs={msg.elapsedMs or 0}
                    />
                </div>);
            }
        }

        allMessageItems.push(<div key={msg.id} ref={msgRef} style={{"animation": "fadeIn 0.3s ease", "scrollMarginTop": "16px"}}>
            <ChatMessage
                message={msg.content}
                isUser={msg.isUser}
                timestamp={msg.timestamp}
                source={msg.source or ""}
                theme={theme}
            />
        </div>);

        idx = idx + 1;
    }

    # allMessageItems = [];
    # for msg in chat.messages {
    #     msgRef = None;
    #     if msg.id == lastUserMsgId {
    #         msgRef = chat.latestUserMsgRef;
    #     }
    #     allMessageItems.push(<div key={msg.id} ref={msgRef} style={{"animation": "fadeIn 0.3s ease", "scrollMarginTop": "16px"}}>
    #         <ChatMessage
    #             message={msg.content}
    #             isUser={msg.isUser}
    #             timestamp={msg.timestamp}
    #             source={msg.source or ""}
    #         />
    #     </div>);
    # }

    messageItems = allMessageItems;

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
                {[0, 1, 2].map(lambda (i: int) {
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
    showThinking = chat.isLoading and not chat.ragIsReasoning and not chat.mcpIsReasoning and chat.ragReasoningSteps.length == 0 and chat.mcpReasoningSteps.length == 0;
    if chat.mode == "rag" {
        showThinking = chat.isLoading and not chat.ragIsReasoning and chat.ragReasoningSteps.length == 0;
    } elif chat.mode == "mcp" {
        showThinking = chat.isLoading and not chat.mcpIsReasoning and chat.mcpReasoningSteps.length == 0;
    }
    if showThinking {
        loadingContent = loadingIndicator;
    }

    # Messages content or empty state
    mainContent = None;
    if hasMessages {
        # Active conversation - messages area (all modes share one centered 768px column;
        # both-mode RAG/MCP pairs render as two side-by-side columns inside it)
        mainContent = <ScrollArea ref={scrollAreaRef} viewportRef={viewportRef} style={{"flex": "1", "paddingLeft": "16px", "paddingRight": "16px"}} type="scroll">
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
                <div ref={spacerRef} />
            </div>
        </ScrollArea>;
    } else {
        # Empty state
        mainContent = <div style={{
            "position": "relative",
            "flex": "1",
            "display": "flex",
            "flexDirection": "column",
            "alignItems": "center",
            "justifyContent": "center",
            "paddingLeft": "16px",
            "paddingRight": "16px",
            "overflow": "hidden"
        }}>
            <div className="jc-home-glow" />
            <div className="jc-fade-in" style={{
                "position": "relative",
                "zIndex": "1",
                "maxWidth": "768px",
                "width": "100%",
                "margin": "0 auto",
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center",
                "justifyContent": "center"
            }}>
                <img
                    src="/logo.png"
                    alt="JacGPT"
                    className="jc-float"
                    style={{
                        "width": "64px",
                        "height": "64px",
                        "objectFit": "contain",
                        "marginBottom": "24px",
                        "filter": "drop-shadow(0 0 26px rgba(249,115,22,0.45))"
                    }}
                />
                <h1 style={{
                    "fontSize": "34px",
                    "color": TEXT,
                    "fontWeight": "700",
                    "letterSpacing": "-0.02em",
                    "marginBottom": "10px",
                    "textAlign": "center"
                }}>
                    How can I help you today?
                </h1>
                <p style={{
                    "fontSize": "15px",
                    "color": MUTED,
                    "marginBottom": "36px",
                    "textAlign": "center"
                }}>
                    Your AI companion for the Jac programming language
                </p>

                <div style={{"width": "100%"}}>
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask about Jac syntax, functions, loops, classes, or request code examples..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                        mode={chat.mode}
                        onModeChange={chat.setMode}
                    />
                    
                    <div style={{
                        "display": "flex",
                        "gap": "12px",
                        "marginTop": "14px",
                        "flexWrap": "wrap",
                        "justifyContent": "center"
                    }}>
                        {[
                            {"icon": "✦", "label": "What is by llm?"},
                            {"icon": "◈", "label": "What are walkers?"},
                            {"icon": "◉", "label": "What are nodes?"}
                        ].map(lambda (prompt: any) {
                            return <button
                                key={prompt.label}
                                className="jc-prompt-pill"
                                onClick={lambda () {
                                    chat.handleSendMessage(prompt.label);
                                }}
                            >
                                <span style={{"color": ORANGE, "fontSize": "13px"}}>{prompt.icon}</span>
                                <span>{prompt.label}</span>
                            </button>;
                        })}
                    </div>
                </div>
            </div>
        </div>;
    }

    # Layout widths when docs open
    chatContainerStyle = {
        "position": "relative",
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
            "background": "transparent"
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
    # Compute button text
    docButtonText = "Show Docs";
    if chat.isSearchingDocs {
        docButtonText = "Searching docs";
    } elif docPanelOpen {
        docButtonText = "Hide Docs";
    }

    # Create text span with shimmer effect when searching
    textSpan = None;
    if chat.isSearchingDocs {
        textSpan = <span className="jc-docs-shimmer">{docButtonText}</span>;
    } else {
        textSpan = <span>{docButtonText}</span>;
    }

    floatingDocsButton = <button
        onClick={toggleDocPanel}
        className="jc-header-docs-btn"
        style={{
            "position": "absolute",
            "top": "10px",
            "right": "16px",
            "zIndex": "20",
            "display": "flex",
            "alignItems": "center",
            "gap": "8px",
            "padding": "8px 16px",
            "border": (("1px solid " + ORANGE if docPanelOpen else "1px solid " + BORDER)),
            "borderRadius": "8px",
            "background": ((ORANGE if docPanelOpen else "var(--docs-btn-bg)")),
            "backdropFilter": "blur(8px)",
            "WebkitBackdropFilter": "blur(8px)",
            "color": (("#ffffff" if docPanelOpen else TEXT)),
            "cursor": "pointer",
            "fontSize": "14px",
            "transition": "all 0.22s cubic-bezier(0.4, 0, 0.2, 1)"
        }}
    >
        {((<IconX size={16} />) if docPanelOpen else (<IconBook size={16} />))}
        {textSpan}
    </button>;

    return <div className="jc-main-bg" style={{
        "display": "flex",
        "height": "100vh"
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
            theme={theme}
            onSetTheme={onSetTheme}
        />

        <div style={{"flex": "1", "display": "flex", "overflow": "hidden"}}>
            <div style={chatContainerStyle}>
                {mobileMenuButton}
                {(floatingDocsButton if not docPanelOpen else None)}

                {(
                    <div style={{"padding": "12px 16px 0 16px"}}>
                        <ErrorAlert
                            error={chat.uiError}
                            onClose={chat.clearUiError}
                            onRetry={chat.handleRetryLastMessage}
                        />
                    </div>
                    if chat.uiError
                    else None
                )}
                
                {mainContent}

                {(
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask about Jac syntax, functions, loops, classes, or request code examples..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                        mode={chat.mode}
                        onModeChange={chat.setMode}
                    />
                    if hasMessages else None
                )}
            </div>

            {docPanelElement}
        </div>
    </div>;
}
