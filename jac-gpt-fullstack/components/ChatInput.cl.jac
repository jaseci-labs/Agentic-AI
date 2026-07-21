"""Chat input component: premium card composer + segmented mode toggle."""

import from react { useRef, useEffect }
import from "@tabler/icons-react" {
    IconSend,
    IconPlayerStop
}

"""Chat input with auto-expanding textarea and integrated send button."""
def:pub ChatInput(
    onSendMessage: any,
    disabled: bool = False,
    placeholder: str = "Ask about Jac syntax, functions, loops, classes, or request code examples...",
    isLoading: bool = False,
    onStop: any = None,
    mode: str = "rag",
    onModeChange: any = None
) -> JsxElement {
    has inputValue: str = "";
    textareaRef = useRef(None);

    # Auto-resize textarea (52px min, 200px max)
    useEffect(lambda () {
        if textareaRef.current {
            textareaRef.current.style.height = "auto";
            scrollHeight = textareaRef.current.scrollHeight;
            newHeight = Math.max(52, Math.min(scrollHeight, 200));
            textareaRef.current.style.height = String(newHeight) + "px";
        }
    }, [inputValue]);

    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if inputValue.trim() and not disabled and not isLoading {
            onSendMessage(inputValue.trim());
            inputValue = "";
            if textareaRef.current {
                textareaRef.current.style.height = "52px";
            }
        }
    }

    def handleKeyDown(e: any) -> None {
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleSubmit(e);
        }
    }

    def handleInputChange(e: any) -> None {
        inputValue = e.target.value;
    }

    canSend = inputValue.trim() and not disabled and not isLoading;

    # Send / stop button visuals
    sendClass = "jc-send-btn";
    if canSend {
        sendClass = "jc-send-btn ready";
    }
    buttonBg = "linear-gradient(135deg, #f97316 0%, #ea580c 100%)";
    buttonOpacity = "1";
    buttonIcon = <IconSend size={16} />;
    if isLoading {
        buttonBg = "#374151";
        buttonIcon = <IconPlayerStop size={16} />;
    } elif not canSend {
        buttonOpacity = "0.5";
    }

    return <div style={{
        "paddingTop": "8px",
        "paddingLeft": "12px",
        "paddingRight": "12px",
        "paddingBottom": "16px"
    }}>
        <form onSubmit={handleSubmit} style={{"maxWidth": "768px", "margin": "0 auto"}}>
            <div className="jc-composer">
                <textarea
                    ref={textareaRef}
                    value={inputValue}
                    onChange={handleInputChange}
                    onKeyDown={handleKeyDown}
                    placeholder={placeholder}
                    disabled={disabled and not isLoading}
                    style={{
                        "flex": "1",
                        "minHeight": "52px",
                        "maxHeight": "200px",
                        "padding": "14px 10px",
                        "fontSize": "16px",
                        "lineHeight": "1.55",
                        "background": "transparent",
                        "border": "none",
                        "color": "var(--text-primary)",
                        "resize": "none",
                        "outline": "none",
                        "fontFamily": "system-ui, -apple-system, sans-serif",
                        "overflow": "auto"
                    }}
                />
                <button
                    type={(("button" if isLoading else "submit"))}
                    onClick={(onStop if isLoading else None)}
                    disabled={not canSend and not isLoading}
                    className={sendClass}
                    style={{
                        "background": buttonBg,
                        "opacity": buttonOpacity,
                        "cursor": ((("pointer" if canSend or isLoading else "not-allowed"))),
                        "marginBottom": "2px"
                    }}
                >
                    {buttonIcon}
                </button>
            </div>
        </form>

        {<div style={{
            "maxWidth": "768px",
            "margin": "12px auto 0 auto",
            "display": "flex",
            "justifyContent": "center"
        }}>
            <div className="jc-mode-toggle">
                {[
                    {"value": "rag", "label": "RAG"},
                    {"value": "mcp", "label": "MCP"},
                    {"value": "both", "label": "Both"}
                ].map(lambda (opt: any) {
                    isActive = mode == opt.value;
                    btnClass = "jc-mode-btn";
                    if isActive {
                        btnClass = "jc-mode-btn active";
                    }
                    return <button
                        key={opt.value}
                        type="button"
                        disabled={isLoading}
                        className={btnClass}
                        onClick={lambda () { onModeChange(opt.value); }}
                    >
                        {opt.label}
                    </button>;
                })}
            </div>
        </div> if onModeChange else None}
    </div>;
}
