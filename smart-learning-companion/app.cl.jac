import from react { useState }
cl import ".styles.css";

def app() -> any {
    let [message, setMessage] = useState("");
    let [response, setResponse] = useState(None);
    let [loading, setLoading] = useState(False);
    
    async def handleChat() -> None {
        if not message.trim() {
            return;
        }
        setLoading(True);
        result = root spawn chat_tutor(message=message, context=[]);
        setResponse(result.reports[0].response);
        setLoading(False);
    }
    
    return <div className="app-container">
        <div className="header">
            <h1 className="title">🎓 Smart Learning Companion</h1>
            <p className="subtitle">Your AI-powered personal tutor</p>
        </div>
        
        <div className="content-area">
            <div className="chat-container">
                <h2>💬 Ask Your AI Tutor</h2>
                <textarea
                    value={message}
                    onChange={lambda e: any -> None { setMessage(e.target.value); }}
                    placeholder="Ask me anything..."
                    className="message-input"
                />
                <button
                    onClick={handleChat}
                    disabled={loading}
                    className="send-button"
                >
                    {("⏳ Thinking..." if loading else "Ask 🚀")}
                </button>
                
                {(
                    <div className="response-section">
                        <h3>🤖 Response</h3>
                        <div className="response-content">
                            {response}
                        </div>
                    </div>
                    if response
                    else None
                )}
            </div>
        </div>
    </div>;
}
