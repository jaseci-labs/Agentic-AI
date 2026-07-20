"""Documentation panel component for displaying doc suggestions."""

import from react { useState, useEffect }

"""Documentation panel with suggestions and iframe viewer."""
def:pub DocumentationPanel(
    message: str = "",
    suggestions: list = [],
    isVisible: bool = True,
    onToggle: any = None
) -> JsxElement {
    has currentSuggestions: list = [];
    has selectedDoc: any = None;
    has loading: bool = False;
    has error: str = "";
    has defaultSuggestions: list = [];

    # Load default documentation suggestions from JSON.
    # NOTE: the explicit no-op cleanup return is required. Without a trailing
    # statement the Jac client compiler turns this single-expression body into an
    # implicit-return arrow (`() => fetch(...)`), so the effect returns the fetch
    # Promise. React stores that as the cleanup and calls it on unmount (closing
    # the panel) — crashing with "g is not a function". Returning a real function
    # gives React a valid, harmless cleanup.
    useEffect(lambda () {
        fetch("../services/docs_links/default_suggestion_links.json")
            .then(lambda (response: any) { return response.json(); })
            .then(lambda (data: any) { defaultSuggestions = data; })
            .catch(lambda (err: any) { console.log("Failed to load default suggestions:", err); });
        return lambda () { };
    }, []);

    # Ensure HTTPS for URLs
    def ensureHttpsUrl(url: str) -> str {
        if url.includes("jac-lang.org") and url.startsWith("http://") {
            return url.replace("http://", "https://");
        }
        return url;
    }

    # Update suggestions when props change
    useEffect(lambda () {
        if suggestions.length > 0 {
            currentSuggestions = suggestions;
        } else {
            currentSuggestions = defaultSuggestions;
        }
    }, [suggestions, isVisible, defaultSuggestions]);

    def handleSuggestionClick(suggestion: any) -> None {
        loading = True;
        error = "";
        
        secureUrl = ensureHttpsUrl(suggestion.url);
        
        selectedDoc = {
            "title": suggestion.title,
            "url": secureUrl
        };
        
        setTimeout(lambda () {
            loading = False;
        }, 500);
    }

    def handleBackToSuggestions() -> None {
        selectedDoc = None;
        error = "";
    }

    if not isVisible {
        return None;
    }

    # Icons (Lucide icon set)
    bookIcon = <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#f97316" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
    </svg>;

    arrowLeftIcon = <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="19" x2="5" y1="12" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
    </svg>;

    externalLinkIcon = <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
        <polyline points="15 3 21 3 21 9"></polyline>
        <line x1="10" x2="21" y1="14" y2="3"></line>
    </svg>;

    chevronRightIcon = <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="m9 18 6-6-6-6"></path>
    </svg>;

    closeIcon = <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="18" x2="6" y1="6" y2="18"></line>
        <line x1="6" x2="18" y1="6" y2="18"></line>
    </svg>;

    loaderIcon = <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{"animation": "spin 1s linear infinite"}}>
        <path d="M21 12a9 9 0 1 1-6.219-8.56"></path>
    </svg>;

    # Main container - full height and width
    return <div className="jc-docs-panel" style={{
        "display": "flex",
        "flexDirection": "column",
        "height": "100%",
        "width": "100%"
    }}>
        {(
            <div style={{
                "padding": "16px 20px",
                "borderBottom": "1px solid var(--border)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "space-between"
            }}>
                <div style={{
                    "display": "flex",
                    "alignItems": "center",
                    "gap": "10px"
                }}>
                    <span className="jc-icon-chip">{bookIcon}</span>
                    <span style={{
                        "fontSize": "16px",
                        "fontWeight": "700",
                        "color": "var(--text-primary)",
                        "letterSpacing": "-0.01em"
                    }}>
                        {"Documentation"}
                    </span>
                </div>
                <button
                    onClick={onToggle}
                    style={{
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "width": "32px",
                        "height": "32px",
                        "border": "none",
                        "borderRadius": "8px",
                        "backgroundColor": "transparent",
                        "cursor": "pointer",
                        "transition": "background-color 0.2s"
                    }}
                    onMouseEnter={lambda (e: any) { e.target.style.backgroundColor = "var(--hover-bg)"; }}
                    onMouseLeave={lambda (e: any) { e.target.style.backgroundColor = "transparent"; }}
                >
                    {closeIcon}
                </button>
            </div>
            if not selectedDoc and not loading and not error else None
        )}

        {(
            <div style={{
                "flex": "1",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "flexDirection": "column",
                "gap": "8px"
            }}>
                {loaderIcon}
                <span style={{"color": "var(--text-muted)", "fontSize": "14px"}}>
                    {"Loading documentation..."}
                </span>
            </div>
            if loading else None
        )}

        {(
            <div style={{
                "flex": "1",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center"
            }}>
                <div style={{"textAlign": "center"}}>
                    <p style={{"color": "var(--error)", "marginBottom": "8px"}}>{error}</p>
                    <button
                        onClick={lambda () { error = ""; }}
                        style={{
                            "padding": "8px 16px",
                            "border": "1px solid var(--border-light)",
                            "borderRadius": "8px",
                            "backgroundColor": "transparent",
                            "color": "var(--text-muted)",
                            "cursor": "pointer",
                            "transition": "background-color 0.2s"
                        }}
                    >
                        {"Try Again"}
                    </button>
                </div>
            </div>
            if error else None
        )}

        {(
            <div style={{
                "display": "flex",
                "flexDirection": "column",
                "height": "100%",
                "flex": "1"
            }}>
                <div style={{
                    "padding": "16px",
                    "borderBottom": "1px solid var(--border-light)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "space-between"
                }}>
                    <button
                        onClick={handleBackToSuggestions}
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "8px",
                            "padding": "8px 16px",
                            "border": "1px solid var(--border-light)",
                            "borderRadius": "9999px",
                            "backgroundColor": "transparent",
                            "color": "var(--text-muted)",
                            "cursor": "pointer",
                            "fontSize": "14px",
                            "transition": "all 0.2s"
                        }}
                    >
                        {arrowLeftIcon}
                        {"Back"}
                    </button>
                    <button
                        onClick={lambda () { window.open(ensureHttpsUrl(selectedDoc.url), "_blank"); }}
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "8px",
                            "padding": "8px 16px",
                            "border": "1px solid rgba(249, 115, 22, 0.2)",
                            "borderRadius": "9999px",
                            "backgroundColor": "rgba(249, 115, 22, 0.1)",
                            "color": "var(--primary)",
                            "cursor": "pointer",
                            "fontSize": "14px",
                            "transition": "all 0.2s"
                        }}
                    >
                        {externalLinkIcon}
                        {"View Full Documentation"}
                    </button>
                </div>
                
                <div style={{
                    "flex": "1",
                    "minHeight": "0",
                    "overflow": "hidden",
                    "position": "relative"
                }}>
                    <iframe
                        src={ensureHttpsUrl(selectedDoc.url)}
                        title={selectedDoc.title}
                        sandbox="allow-scripts allow-same-origin allow-popups allow-forms"
                        style={{
                            "width": "100%",
                            "height": "100%",
                            "border": "none",
                            "display": "block",
                            "backgroundColor": "#ffffff"
                        }}
                    />
                </div>
            </div>
            if selectedDoc and not loading and not error else None
        )}

        {(
            <div style={{
                "flex": "1",
                "padding": "16px",
                "overflowY": "auto"
            }}>
                {(
                    <h3 style={{
                        "fontSize": "18px",
                        "fontWeight": "700",
                        "color": "var(--text-primary)",
                        "marginBottom": "8px"
                    }}>
                        {"Relevant Documentation"}
                    </h3>
                    if suggestions.length > 0 else
                    <h3 style={{
                        "fontSize": "18px",
                        "fontWeight": "700",
                        "color": "var(--text-primary)",
                        "marginBottom": "8px"
                    }}>
                        {"Popular Topics"}
                    </h3>
                )}
                {(
                    <p style={{
                        "color": "var(--text-muted)",
                        "fontSize": "14px",
                        "lineHeight": "1.5",
                        "marginBottom": "16px"
                    }}>
                        {"Here are the most relevant documentation pages for your query:"}
                    </p>
                    if suggestions.length > 0 else
                    <p style={{
                        "color": "var(--text-muted)",
                        "fontSize": "14px",
                        "lineHeight": "1.5",
                        "marginBottom": "16px"
                    }}>
                        {"Explore these popular Jac documentation topics:"}
                    </p>
                )}

                <div style={{"display": "flex", "flexDirection": "column", "gap": "12px"}}>
                    {currentSuggestions.map(lambda (suggestion: any, index: int) {
                        return <div
                            key={index}
                            className="jc-doc-card"
                            onClick={lambda () { handleSuggestionClick(suggestion); }}
                            style={{"padding": "16px"}}
                        >
                            <div style={{
                                "display": "flex",
                                "alignItems": "flex-start",
                                "justifyContent": "space-between"
                            }}>
                                <div style={{"flex": "1"}}>
                                    <h4 className="jc-doc-title" style={{
                                        "fontWeight": "600",
                                        "color": "var(--text-primary)",
                                        "marginBottom": "8px",
                                        "fontSize": "16px",
                                        "display": "flex",
                                        "alignItems": "center",
                                        "gap": "8px"
                                    }}>
                                        <span style={{"fontSize": "inherit", "display": "flex", "alignItems": "center"}}>
                                            {suggestion.title.split("●").map(lambda (part: str, i: int) {
                                                if i == 0 {
                                                    return part;
                                                }
                                                return <span key={i} style={{"display": "flex", "alignItems": "center"}}>
                                                    <span style={{"fontSize": "8px", "margin": "0 4px", "verticalAlign": "middle", "color": "#d97706"}}>{"●"}</span>
                                                    {part}
                                                </span>;
                                            })}
                                        </span>
                                        <span className="jc-doc-chevron" style={{"display": "flex", "flexShrink": 0}}>{chevronRightIcon}</span>
                                    </h4>
                                    {(
                                        <p style={{
                                            "fontSize": "14px",
                                            "color": "var(--text-secondary)",
                                            "marginBottom": "8px",
                                            "lineHeight": "1.5"
                                        }}>
                                            {suggestion.reason}
                                        </p>
                                        if suggestion.reason else None
                                    )}
                                    <p style={{
                                        "fontSize": "11px",
                                        "color": "var(--doc-link)",
                                        "fontFamily": "monospace",
                                        "transition": "color 0.2s"
                                    }}
                                    onMouseEnter={lambda (e: any) { e.target.style.color = "var(--doc-link-hover)"; }}
                                    onMouseLeave={lambda (e: any) { e.target.style.color = "var(--doc-link)"; }}
                                    >
                                        {ensureHttpsUrl(suggestion.url)}
                                    </p>
                                </div>
                            </div>
                        </div>;
                    })}
                </div>
            </div>
            if not selectedDoc and not loading and not error else None
        )}
    </div>;
}