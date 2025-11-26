import from react { useState }
cl import ".styles.css";


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
        result = root spawn translate_text(phrase=inputText, language=targetLang);
        setTranslation(result.reports[0]);
        setLoading(False);
    }

    return <div className="translator-container">
        <div className="translator-card">
            <div className="translator-header">
                <div className="translator-icon">
                    🌍
                </div>
                <h1 className="translator-title">
                    AI Translator
                </h1>
                <p className="translator-subtitle">
                    Powered by GPT-4o - Translate to any language instantly
                </p>
            </div>

            <div className="textarea-wrapper">
                <textarea
                    value={inputText}
                    onChange={lambda  e: any  -> None{ setInputText(e.target.value);} }
                    placeholder="✨ Enter your text here to translate..."
                    className="translator-textarea"
                />
            </div>

            <div className="translator-controls">
                <div className="language-selector-wrapper">
                    <label className="language-label">
                        🎯 Target Language
                    </label>
                    <select
                        value={targetLang}
                        onChange={lambda  e: any  -> None{ setTargetLang(e.target.value);} }
                        className="language-select"
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

                <div className="button-wrapper">
                    <button
                        onClick={handleTranslate}
                        disabled={loading}
                        className="translate-button"
                    >
                        {("⏳ Translating..." if loading else "✨ Translate")}
                    </button>
                </div>
            </div>

            {(
                <div className="result-wrapper">
                    <div className="result-content">
                        <div className="result-header">
                            <span className="result-icon">
                                ✅
                            </span>
                            <p className="result-title">
                                Translation to {translation.language}
                            </p>
                        </div>
                        <div className="translation-box">
                            <p className="translation-text">
                                {translation.translation}
                            </p>
                        </div>
                        <div className="original-text-box">
                            <p className="original-text">
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
                    <div className="empty-state">
                        <div className="empty-state-icon">
                            💬
                        </div>
                        <p className="empty-state-text">
                            Your translation will appear here
                        </p>
                    </div>
                )
            )}
        </div>

        <div className="translator-footer">
            <p className="footer-text">
                Made with ❤️ using Jaseci Stack
            </p>
        </div>
    </div>;
}