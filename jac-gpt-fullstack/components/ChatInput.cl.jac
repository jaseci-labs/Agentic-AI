"""Chat input component with pill-shaped design (following specification)."""

import from react { useRef, useEffect }
import from "@tabler/icons-react" {
    IconSend,
    IconPlayerStop
}

"""Chat input with auto-expanding textarea and integrated button."""
def:pub ChatInput(
    onSendMessage: any,
    disabled: bool = False,
    placeholder: str = "Ask about Jac syntax, functions, loops, classes, or request code examples...",
    isLoading: bool = False,
    onStop: any = None
) -> any {
    has inputValue: str = "";
    has isFocused: bool = False;
    textareaRef = useRef(None);

    # Auto-resize textarea (60px min, 200px max)
    useEffect(lambda -> None {
        if textareaRef.current {
            textareaRef.current.style.height = "auto";
            scrollHeight = textareaRef.current.scrollHeight;
            newHeight = Math.max(60, Math.min(scrollHeight, 200));
            textareaRef.current.style.height = String(newHeight) + "px";
        }
    }, [inputValue]);

    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if inputValue.trim() and not disabled and not isLoading {
            onSendMessage(inputValue.trim());
            inputValue = "";
            if textareaRef.current {
                textareaRef.current.style.height = "60px";
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

    # Border color based on state (exact specification)
    borderColor = "rgba(55, 65, 81, 0.5)";  # gray-700 @ 50% (default)
    boxShadowValue = "none";
    
    if isFocused {
        borderColor = "#f97316";  # orange-500 full (focus)
        boxShadowValue = "0 0 0 2px rgba(249, 115, 22, 0.2)";  # 2px ring @ 20%
    }

    # Button icon and styles
    buttonBg = "linear-gradient(135deg, #f97316 0%, #ea580c 100%)";  # gradient-primary
    buttonShadow = "none";
    buttonIcon = <IconSend size={16} />;
    buttonOpacity = "1";
    
    if isLoading {
        buttonBg = "#374151";  # gray-700
        buttonShadow = "none";
        buttonIcon = <IconPlayerStop size={16} />;
    } elif not canSend {
        buttonBg = "linear-gradient(135deg, #f97316 0%, #ea580c 100%)";
        buttonShadow = "none";
        buttonOpacity = "0.5";  # 50% opacity for disabled
    }

    return <div style={{
        "paddingTop": "8px",
        "paddingLeft": "12px",
        "paddingRight": "12px",
        "paddingBottom": "16px"
    }}>
        <form onSubmit={handleSubmit} style={{
            "maxWidth": "768px",
            "margin": "0 auto"
        }}>
            <div style={{
                "position": "relative"
            }}>
                <textarea
                    ref={textareaRef}
                    value={inputValue}
                    onChange={handleInputChange}
                    onKeyDown={handleKeyDown}
                    onFocus={lambda -> None { isFocused = True; }}
                    onBlur={lambda -> None { isFocused = False; }}
                    placeholder={placeholder}
                    disabled={disabled and not isLoading}
                    style={{
                        "width": "100%",
                        "minHeight": "60px",
                        "maxHeight": "200px",
                        "borderRadius": "30px",
                        "padding": "16px 64px 16px 20px",
                        "fontSize": "16px",
                        "lineHeight": "1.625",
                        "background": "#09090b",
                        "border": "1px solid " + borderColor,
                        "color": "#fafafa",
                        "resize": "none",
                        "outline": "none",
                        "transition": "all 300ms ease",
                        "fontFamily": "system-ui, -apple-system, sans-serif",
                        "boxShadow": boxShadowValue,
                        "overflow": "auto"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        if not isFocused {
                            e.currentTarget.style.borderColor = "rgba(249, 115, 22, 0.5)";
                        }
                    }}
                    onMouseLeave={lambda e: any -> None {
                        if not isFocused {
                            e.currentTarget.style.borderColor = "rgba(55, 65, 81, 0.5)";
                        }
                    }}
                />
                
                <button
                    type={(("button" if isLoading else "submit"))}
                    onClick={(onStop if isLoading else None)}
                    disabled={not canSend and not isLoading}
                    style={{
                        "position": "absolute",
                        "right": "12px",
                        "bottom": "50%",
                        "transform": "translateY(50%)",
                        "width": "40px",
                        "height": "40px",
                        "borderRadius": "50%",
                        "border": "none",
                        "background": buttonBg,
                        "color": "#ffffff",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "cursor": ((("pointer" if canSend or isLoading else "not-allowed"))),
                        "transition": "all 300ms ease",
                        "boxShadow": buttonShadow,
                        "opacity": buttonOpacity,
                        "padding": "0"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        if canSend or isLoading {
                            e.currentTarget.style.transform = "translateY(50%) scale(1.05)";
                            # Orange glow shadow on hover
                            e.currentTarget.style.boxShadow = "0 0 20px rgba(249, 115, 22, 0.5), 0 0 40px rgba(249, 115, 22, 0.2)";
                            if isLoading {
                                e.currentTarget.style.background = "#4b5563";  # gray-600 on hover
                            }
                        }
                    }}
                    onMouseLeave={lambda e: any -> None {
                        e.currentTarget.style.transform = "translateY(50%) scale(1)";
                        e.currentTarget.style.boxShadow = "none";
                        if isLoading {
                            e.currentTarget.style.background = "#374151";  # gray-700 default
                        }
                    }}
                >
                    {buttonIcon}
                </button>
            </div>
        </form>
    </div>;
}