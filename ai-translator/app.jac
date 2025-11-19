import from byllm.lib { Model }
cl import from react { useState }
cl import from '@jac-client/utils' { jacSpawn }


glob llm = Model(model_name="gpt-4o");

# Backend
walker translate_text {
    has phrase: str;
    has language: str;

    def translate_to(language: str, phrase: str) -> str by llm();
    can translate with `root entry {
        result = self.translate_to(language=self.language, phrase=self.phrase);
        report {
            "translation": result,
            "original": self.phrase,
            "language": self.language
        } ;
    }
}



# Frontend
cl {
    def app()  -> any {
        let [inputText, setInputText] = useState("");
        let [targetLang, setTargetLang] = useState("Spanish");
        let [translation, setTranslation] = useState(None);
        let [loading, setLoading] = useState(False);

        async def handleTranslate()  -> None {
            if not inputText.trim() {
                return;
            }
            setLoading(True);
            result = await jacSpawn(
                "translate_text", "", {"phrase": inputText, "language": targetLang}
            );
            setTranslation(result.reports[0]);
            setLoading(False);
        }

        return <div
            style={{
                "minHeight": "100vh",
                "background": "linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #4facfe 75%, #00f2fe 100%)",
                "padding": "40px 20px",
                "fontFamily": "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
            }}
        >
            <div
                style={{
                    "maxWidth": "700px",
                    "margin": "0 auto",
                    "background": "rgba(255, 255, 255, 0.95)",
                    "borderRadius": "24px",
                    "padding": "40px",
                    "boxShadow": "0 20px 60px rgba(0, 0, 0, 0.3), 0 0 100px rgba(102, 126, 234, 0.5)"
                }}
            >
                <div
                    style={{
                        "textAlign": "center",
                        "marginBottom": "32px"
                    }}
                >
                    <div
                        style={{
                            "fontSize": "64px",
                            "marginBottom": "16px",
                            "animation": "bounce 2s infinite"
                        }}
                    >
                        🌍
                    </div>
                    <h1
                        style={{
                            "fontSize": "42px",
                            "fontWeight": "800",
                            "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
                            "WebkitBackgroundClip": "text",
                            "WebkitTextFillColor": "transparent",
                            "backgroundClip": "text",
                            "marginBottom": "8px"
                        }}
                    >
                        AI Translator
                    </h1>
                    <p
                        style={{
                            "color": "#6b7280",
                            "fontSize": "16px",
                            "fontWeight": "500"
                        }}
                    >
                        Powered by GPT-4o - Translate to any language instantly
                    </p>
                </div>

                <div
                    style={{
                        "background": "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
                        "padding": "3px",
                        "borderRadius": "16px",
                        "marginBottom": "24px"
                    }}
                >
                    <textarea
                        value={inputText}
                        onChange={lambda  e: any  -> None{ setInputText(e.target.value);} }
                        placeholder="✨ Enter your text here to translate..."
                        style={{
                            "width": "100%",
                            "padding": "20px",
                            "fontSize": "18px",
                            "border": "none",
                            "borderRadius": "14px",
                            "fontFamily": "inherit",
                            "resize": "vertical",
                            "minHeight": "120px",
                            "background": "#ffffff",
                            "outline": "none"
                        }}
                    />
                </div>

                <div
                    style={{
                        "display": "flex",
                        "gap": "16px",
                        "marginBottom": "24px",
                        "flexWrap": "wrap"
                    }}
                >
                    <div
                        style={{
                            "flex": "1",
                            "minWidth": "200px"
                        }}
                    >
                        <label
                            style={{
                                "display": "block",
                                "fontSize": "14px",
                                "fontWeight": "600",
                                "color": "#374151",
                                "marginBottom": "8px"
                            }}
                        >
                            🎯 Target Language
                        </label>
                        <select
                            value={targetLang}
                            onChange={lambda  e: any  -> None{ setTargetLang(e.target.value);} }
                            style={{
                                "width": "100%",
                                "padding": "14px",
                                "fontSize": "16px",
                                "border": "2px solid #e5e7eb",
                                "borderRadius": "12px",
                                "background": "#ffffff",
                                "fontWeight": "500",
                                "cursor": "pointer",
                                "outline": "none"
                            }}
                        >
                            <option value="Spanish">
                                🇪🇸 Spanish
                            </option>
                            <option value="French">
                                🇫🇷 French
                            </option>
                            <option value="German">
                                🇩🇪 German
                            </option>
                            <option value="Welsh">
                                🏴󠁧󠁢󠁷󠁬󠁳󠁿 Welsh
                            </option>
                            <option value="Japanese">
                                🇯🇵 Japanese
                            </option>
                            <option value="Chinese">
                                🇨🇳 Chinese
                            </option>
                            <option value="Italian">
                                🇮🇹 Italian
                            </option>
                            <option value="Portuguese">
                                🇵🇹 Portuguese
                            </option>
                        </select>
                    </div>

                    <div
                        style={{
                            "display": "flex",
                            "alignItems": "flex-end"
                        }}
                    >
                        <button
                            onClick={handleTranslate}
                            disabled={loading}
                            style={{
                                "padding": "14px 32px",
                                "background": (
                                    "linear-gradient(135deg, #9ca3af 0%, #6b7280 100%)" if loading
                                    else "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
                                ),
                                "color": "#ffffff",
                                "border": "none",
                                "borderRadius": "12px",
                                "fontSize": "18px",
                                "fontWeight": "700",
                                "cursor": ("not-allowed" if loading else "pointer"),
                                "boxShadow": (
                                    "none" if loading
                                    else "0 4px 15px rgba(102, 126, 234, 0.4)"
                                ),
                                "transition": "all 0.3s ease",
                                "minWidth": "160px"
                            }}
                        >
                            {("⏳ Translating..." if loading else "✨ Translate")}
                        </button>
                    </div>
                </div>

                {(
                    <div
                        style={{
                            "background": "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
                            "padding": "3px",
                            "borderRadius": "16px",
                            "marginTop": "32px",
                            "animation": "fadeIn 0.5s ease-in"
                        }}
                    >
                        <div
                            style={{
                                "background": "#ffffff",
                                "padding": "28px",
                                "borderRadius": "14px"
                            }}
                        >
                            <div
                                style={{
                                    "display": "flex",
                                    "alignItems": "center",
                                    "gap": "8px",
                                    "marginBottom": "16px"
                                }}
                            >
                                <span
                                    style={{
                                        "fontSize": "24px"
                                    }}
                                >
                                    ✅
                                </span>
                                <p
                                    style={{
                                        "color": "#059669",
                                        "fontSize": "16px",
                                        "fontWeight": "700",
                                        "margin": "0"
                                    }}
                                >
                                    Translation to {translation.language}
                                </p>
                            </div>
                            <div
                                style={{
                                    "background": "linear-gradient(135deg, #fef3c7 0%, #fde68a 100%)",
                                    "padding": "20px",
                                    "borderRadius": "12px",
                                    "border": "2px solid #fbbf24"
                                }}
                            >
                                <p
                                    style={{
                                        "fontSize": "20px",
                                        "color": "#1f2937",
                                        "fontWeight": "600",
                                        "margin": "0",
                                        "lineHeight": "1.6"
                                    }}
                                >
                                    {translation.translation}
                                </p>
                            </div>
                            <div
                                style={{
                                    "marginTop": "16px",
                                    "padding": "12px",
                                    "background": "#f3f4f6",
                                    "borderRadius": "8px"
                                }}
                            >
                                <p
                                    style={{
                                        "fontSize": "14px",
                                        "color": "#6b7280",
                                        "margin": "0",
                                        "fontStyle": "italic"
                                    }}
                                >
                                    <strong>Original:</strong> {translation.original}
                                </p>
                            </div>
                        </div>
                    </div>
                )
                if translation
                else None}

                {(
                    None if translation else (
                        <div
                            style={{
                                "textAlign": "center",
                                "padding": "40px",
                                "color": "#9ca3af",
                                "fontSize": "16px"
                            }}
                        >
                            <div
                                style={{
                                    "fontSize": "48px",
                                    "marginBottom": "16px"
                                }}
                            >
                                💬
                            </div>
                            <p
                                style={{
                                    "margin": "0",
                                    "fontWeight": "500"
                                }}
                            >
                                Your translation will appear here
                            </p>
                        </div>
                    )
                )}
            </div>

            <div
                style={{
                    "textAlign": "center",
                    "marginTop": "32px",
                    "color": "#ffffff",
                    "fontSize": "14px",
                    "fontWeight": "500",
                    "textShadow": "0 2px 4px rgba(0, 0, 0, 0.2)"
                }}
            >
                <p style={{"margin": "0"}}>
                    Made with ❤️ using Jaseci Stack
                </p>
            </div>
        </div>;
    }
}