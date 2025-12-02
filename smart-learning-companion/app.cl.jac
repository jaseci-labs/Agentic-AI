cl import from react { useState, useEffect, useRef }
cl import ".modern-styles.css";
cl import from '@mui/material' {
    Box,
    Stack,
    ThemeProvider,
    CssBaseline,
    Paper,
    Typography,
    createTheme
}
cl import from '@mui/icons-material' {
    Chat,
    Quiz,
    MenuBook,
    TrendingUp
}

cl import from .components.Sidebar { Sidebar }
cl import from .components.ChatTab { ChatTab }
cl import from .components.QuizTab { QuizTab }

cl let theme = createTheme(
    {
        "palette": {
            "mode": "dark",
            "primary": {"main": "#a78bfa", "light": "#c4b5fd", "dark": "#8b5cf6"},
            "secondary": {"main": "#f472b6", "light": "#f9a8d4", "dark": "#ec4899"},
            "background": {"default": "#0f172a", "paper": "rgba(30, 41, 59, 0.7)"},
            "text": {"primary": "#f8fafc", "secondary": "#cbd5e1"}
        },
        "typography": {
            "fontFamily": "'Outfit', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif",
            "h3": {"fontWeight": 800, "letterSpacing": "-0.02em"},
            "h5": {"fontWeight": 700},
            "h6": {"fontWeight": 600}
        },
        "shape": {"borderRadius": 0},
        "components": {
            "MuiButton": {
                "styleOverrides": {
                    "root": {
                        "textTransform": "none",
                        "fontWeight": 600,
                        "borderRadius": "0px"
                    }
                }
            },
            "MuiPaper": {
                "styleOverrides": {
                    "root": {"borderRadius": 0}
                }
            },
            "MuiAvatar": {
                "styleOverrides": {
                    "root": {"borderRadius": 0}
                }
            },
            "MuiOutlinedInput": {
                "styleOverrides": {
                    "root": {"borderRadius": 0}
                }
            },
            "MuiChip": {
                "styleOverrides": {
                    "root": {"borderRadius": 0}
                }
            }
        }
    }
);

cl def app() -> any {
    let [message, setMessage] = useState("");
    let [conversationHistory, setConversationHistory] = useState([]);
    let [loading, setLoading] = useState(false);
    let messagesEndRef = useRef(null);
    let [activeTab, setActiveTab] = useState("chat");

    let [quizTopic, setQuizTopic] = useState("");
    let [quizDifficulty, setQuizDifficulty] = useState("medium");
    let [quizData, setQuizData] = useState(null);
    let [quizLoading, setQuizLoading] = useState(false);
    let [currentQuestion, setCurrentQuestion] = useState(0);
    let [selectedAnswers, setSelectedAnswers] = useState([]);
    let [showResults, setShowResults] = useState(false);

    let navigationItems = [
        {"id": "chat", "label": "AI Tutor Chat", "icon": <Chat />},
        {"id": "quiz", "label": "Practice Quiz", "icon": <Quiz />},
        {"id": "learn", "label": "Learn Topic", "icon": <MenuBook />},
        {"id": "path", "label": "Learning Path", "icon": <TrendingUp />}
    ];

    useEffect(
        lambda -> None {
            console.log("Active Tab:", activeTab);
            console.log("Quiz Data:", JSON.stringify(quizData));
        },
        [activeTab, quizData]
    );

    async def handleChat() -> None {
        if not message.trim() {
            return;
        }

        let messageText = message.trim();
        setMessage("");
        setLoading(true);

        let newHistory = conversationHistory.concat(
            [{"role": "user", "content": messageText, "timestamp": Date.now()}]
        );
        setConversationHistory(newHistory);

        let result = root spawn chat_tutor(message=messageText, context=[]);
        if result and result.reports and result.reports.length > 0 {
            let aiResponse = result.reports[0]["response"];
            let finalHistory = newHistory.concat(
                [{"role": "assistant", "content": aiResponse, "timestamp": Date.now()}]
            );
            setConversationHistory(finalHistory);
        }
        setLoading(false);
    }

    def handleKeyPress(e: any) -> None {
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleChat();
        }
    }

    def clearChat() -> None {
        setConversationHistory([]);
        setMessage("");
    }

    async def handleGenerateQuiz() -> None {
        if not quizTopic.trim() {
            return;
        }

        setQuizLoading(true);
        setQuizData(null);
        setCurrentQuestion(0);
        setSelectedAnswers([]);
        setShowResults(false);

        let result = root spawn generate_quiz(
            topic=quizTopic.trim(),
            difficulty=quizDifficulty,
            num_questions=5
        );

        if result and result.reports and result.reports.length > 0 {
            let quizResponse = result.reports[0];
            console.log("Quiz Response:", JSON.stringify(quizResponse));
            setQuizData(quizResponse);
        }
        setQuizLoading(false);
    }
    
    def handleAnswerSelect(questionIndex: int, answerIndex: int) -> None {
        let newAnswers = selectedAnswers.slice();
        newAnswers[questionIndex] = answerIndex;
        setSelectedAnswers(newAnswers);
    }

    def handleSubmitQuiz() -> None {
        setShowResults(true);
    }

    def handleResetQuiz() -> None {
        setQuizData(null);
        setQuizTopic("");
        setCurrentQuestion(0);
        setSelectedAnswers([]);
        setShowResults(false);
    }

    let exampleQuestions = [
        "Explain photosynthesis in simple terms",
        "Help me understand quantum mechanics",
        "What's the difference between mitosis and meiosis?",
        "How do I solve quadratic equations?"
    ];

    return <ThemeProvider theme={theme}>
        <CssBaseline />
        <div className="animated-bg">
            <div className="particle particle-1"></div>
            <div className="particle particle-2"></div>
            <div className="particle particle-3"></div>
            <div className="particle particle-4"></div>
        </div>
        <Box sx={{"minHeight": "100vh", "display": "flex", "position": "relative"}}>
            <Sidebar
                activeTab={activeTab}
                setActiveTab={setActiveTab}
                navigationItems={navigationItems}
            />
            <Box
                component="main"
                sx={{"flexGrow": 1, "py": 3, "px": 3, "width": "calc(100vw - 280px)"}}
            >
                <Stack spacing={3} sx={{"maxWidth": 1400, "mx": "auto"}}>
                    {(
                        <ChatTab
                            conversationHistory={conversationHistory}
                            message={message}
                            setMessage={setMessage}
                            loading={loading}
                            handleChat={handleChat}
                            handleKeyPress={handleKeyPress}
                            clearChat={clearChat}
                            messagesEndRef={messagesEndRef}
                            exampleQuestions={exampleQuestions}
                        />
                    ) if (activeTab == "chat") else (
                        (
                            <QuizTab
                                quizTopic={quizTopic}
                                setQuizTopic={setQuizTopic}
                                quizDifficulty={quizDifficulty}
                                setQuizDifficulty={setQuizDifficulty}
                                quizData={quizData}
                                quizLoading={quizLoading}
                                currentQuestion={currentQuestion}
                                setCurrentQuestion={setCurrentQuestion}
                                selectedAnswers={selectedAnswers}
                                showResults={showResults}
                                handleGenerateQuiz={handleGenerateQuiz}
                                handleAnswerSelect={handleAnswerSelect}
                                handleSubmitQuiz={handleSubmitQuiz}
                                handleResetQuiz={handleResetQuiz}
                            />
                        ) if (activeTab == "quiz") else (
                            <Paper sx={{"p": 4, "textAlign": "center"}}>
                                <MenuBook sx={{"fontSize": 80, "color": "primary.main", "mb": 2}} />
                                <Typography variant="h4" gutterBottom>
                                    {("Learn Topic" if (activeTab == "learn") else "Learning Path")}
                                </Typography>
                                <Typography color="text.secondary">
                                    {"Coming soon..."}
                                </Typography>
                            </Paper>
                        )
                    )}
                </Stack>
            </Box>
        </Box>
    </ThemeProvider>;
}
