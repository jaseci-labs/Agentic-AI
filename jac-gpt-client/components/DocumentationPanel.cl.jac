"""Documentation panel component for displaying doc suggestions."""

import from react { useState, useEffect }
import from ..utils.cn { cn }

"""Documentation panel with suggestions and iframe viewer."""
def:pub DocumentationPanel(
    message: str = "",
    suggestions: list = [],
    isVisible: bool = True,
    onToggle: any = None
) -> any {
    has currentSuggestions: list = [];
    has selectedDoc: any = None;
    has loading: bool = False;
    has error: str = "";

    # Default documentation suggestions
    defaultSuggestions = [
        {
            "url": "https://www.jac-lang.org/learn/introduction/",
            "title": "Introduction to Jac",
            "reason": "Perfect starting point for learning Jac programming language"
        },
        {
            "url": "https://www.jac-lang.org/learn/data_spatial/nodes_and_edges/",
            "title": "Nodes and Edges",
            "reason": "Learn about Object-Spatial Programming with nodes and edges"
        },
        {
            "url": "https://www.jac-lang.org/learn/jac-mtllm/quickstart/",
            "title": "AI Integration",
            "reason": "Discover how to integrate AI and LLM capabilities"
        }
    ];

    # Ensure HTTPS for jac-lang.org URLs
    def ensureHttpsUrl(url: str) -> str {
        if url.includes("jac-lang.org") and url.startsWith("http://") {
            return url.replace("http://", "https://");
        }
        return url;
    }

    # Update suggestions when props change
    useEffect(lambda -> None {
        if suggestions.length > 0 {
            currentSuggestions = suggestions;
        } else {
            currentSuggestions = defaultSuggestions;
        }
    }, [suggestions, isVisible]);

    def handleSuggestionClick(suggestion: any) -> None {
        loading = True;
        error = "";

        secureUrl = ensureHttpsUrl(suggestion.url);

        selectedDoc = {
            "content": "",
            "title": suggestion.title,
            "url": secureUrl
        };

        setTimeout(lambda -> None {
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

    # Icons
    bookIcon = <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
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

    chevronRightIcon = <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-text-muted">
        <path d="m9 18 6-6-6-6"></path>
    </svg>;

    loaderIcon = <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="animate-spin">
        <path d="M21 12a9 9 0 1 1-6.219-8.56"></path>
    </svg>;

    return <div className="w-1/2 border-l border-border bg-surface flex flex-col">
        
        <div className="flex items-center justify-between p-4 border-b border-border">
            <div className="flex items-center gap-2">
                {(
                    <button
                        onClick={handleBackToSuggestions}
                        className="p-1 text-text-muted hover:text-text-primary mr-2 transition-colors"
                    >
                        {arrowLeftIcon}
                    </button>
                    if selectedDoc else None
                )}
                {bookIcon}
                <h2 className="text-lg font-semibold text-text-primary">
                    {(selectedDoc.title if selectedDoc else "Documentation")}
                </h2>
            </div>
            <button
                onClick={onToggle}
                className="p-1 text-text-muted hover:text-text-primary text-xl transition-colors"
            >
                {"\u00D7"}
            </button>
        </div>

        <div className="flex-1 flex">
            
            <div className="flex-1 flex flex-col">
                
                {(
                    <div className="flex-1 flex items-center justify-center">
                        <div className="flex items-center gap-2 text-text-muted">
                            {loaderIcon}
                            {"Loading documentation..."}
                        </div>
                    </div>
                    if loading else None
                )}

                
                {(
                    <div className="flex-1 flex items-center justify-center">
                        <div className="text-error text-center">
                            <p>{error}</p>
                            <button
                                onClick={lambda -> None { error = ""; }}
                                className="mt-2 px-4 py-2 border border-border rounded-lg hover:bg-surface-hover transition-colors"
                            >
                                {"Try Again"}
                            </button>
                        </div>
                    </div>
                    if error else None
                )}

                
                {(
                    <>
                        <div className="p-4 border-b border-border">
                            <div className="flex items-center justify-end">
                                <button
                                    onClick={lambda -> None { window.open(ensureHttpsUrl(selectedDoc.url), "_blank"); }}
                                    className="flex items-center gap-2 px-4 py-2 border border-border rounded-lg hover:bg-surface-hover transition-colors text-sm"
                                >
                                    {externalLinkIcon}
                                    {"View Full Documentation"}
                                </button>
                            </div>
                        </div>

                        <div className="flex-1 relative">
                            <iframe
                                src={ensureHttpsUrl(selectedDoc.url)}
                                className="w-full h-full border-0"
                                title={selectedDoc.title}
                                sandbox="allow-scripts allow-same-origin allow-popups allow-forms"
                                style={{"background": "white", "minHeight": "100%"}}
                            />
                        </div>
                    </>
                    if selectedDoc and not loading and not error else None
                )}

                
                {(
                    <div className="flex-1 p-4 overflow-y-auto">
                        <div className="mb-4">
                            <h3 className="text-lg font-semibold text-text-primary mb-2">
                                {("Relevant Documentation" if suggestions.length > 0 else "Popular Topics")}
                            </h3>
                            <p className="text-text-muted text-sm mb-4">
                                {(
                                    "Here are the most relevant documentation pages for your query:"
                                    if suggestions.length > 0
                                    else "Explore these popular Jac documentation topics:"
                                )}
                            </p>
                        </div>

                        <div className="space-y-3">
                            {currentSuggestions.map(lambda suggestion: any, index: int -> any {
                                return <div
                                    key={index}
                                    className="p-4 bg-surface-hover border border-border rounded-lg cursor-pointer hover:bg-border transition-colors"
                                    onClick={lambda -> None { handleSuggestionClick(suggestion); }}
                                    title={"Click to view " + suggestion.title}
                                >
                                    <div className="flex items-start justify-between">
                                        <div className="flex-1">
                                            <h4 className="font-medium text-text-primary mb-2 flex items-center gap-2">
                                                {suggestion.title}
                                                {chevronRightIcon}
                                            </h4>
                                            <p className="text-sm text-text-muted mb-2">
                                                {suggestion.reason}
                                            </p>
                                            <p className="text-xs text-secondary hover:text-secondary-hover">
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
            </div>
        </div>
    </div>;
}
