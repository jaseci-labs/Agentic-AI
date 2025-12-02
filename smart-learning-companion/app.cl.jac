cl import from react { useState, useEffect, useRef }
cl import ".modern-styles.css";
cl import from '@mui/material' {
    Container,
    Box,
    Paper,
    TextField,
    Button,
    Typography,
    IconButton,
    Chip,
    Stack,
    Avatar,
    Divider,
    Fade,
    CircularProgress,
    ThemeProvider,
    createTheme,
    CssBaseline,
    Card,
    CardContent,
    Grow,
    Slide,
    Tooltip,
    Drawer,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Badge
}
cl import from '@mui/icons-material' {
    Send,
    School,
    Psychology,
    AutoAwesome,
    Clear,
    Lightbulb,
    MenuBook,
    Science,
    Calculate,
    EmojiObjects,
    Quiz,
    Explore,
    Chat,
    TrendingUp,
    CheckCircle,
    Cancel,
    Refresh
}

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

def app()  -> any {
    let [message, setMessage] = useState("");
    let [conversationHistory, setConversationHistory] = useState([]);
    let [loading, setLoading] = useState(False);
    let messagesEndRef = useRef(None);
    let [activeTab, setActiveTab] = useState("chat");

    let [quizTopic, setQuizTopic] = useState("");
    let [quizDifficulty, setQuizDifficulty] = useState("medium");
    let [quizData, setQuizData] = useState(None);
    let [quizLoading, setQuizLoading] = useState(False);
    let [currentQuestion, setCurrentQuestion] = useState(0);
    let [selectedAnswers, setSelectedAnswers] = useState([]);
    let [showResults, setShowResults] = useState(False);

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

    async def handleChat()  -> None {
        if not message.trim() {
            return;
        }

        messageText = message.trim();
        setMessage("");
        setLoading(True);

        newHistory = conversationHistory.concat(
            [{"role": "user", "content": messageText, "timestamp": Date.now()}]
        );
        setConversationHistory(newHistory);

        result = root spawn chat_tutor(message=messageText, context=[]);
        if result and result.reports and result.reports.length > 0 {
            aiResponse = result.reports[0]["response"];
            finalHistory = newHistory.concat(
                [{"role": "assistant", "content": aiResponse, "timestamp": Date.now()}]
            );
            setConversationHistory(finalHistory);
        }
        setLoading(False);
    }

    def handleKeyPress(e: any) -> None {
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleChat();
        }
    }

    def clearChat()  -> None {
        setConversationHistory([]);
        setMessage("");
    }

    async def handleGenerateQuiz()  -> None {
        if not quizTopic.trim() {
            return;
        }

        setQuizLoading(True);
        setQuizData(None);
        setCurrentQuestion(0);
        setSelectedAnswers([]);
        setShowResults(False);

        result = root spawn generate_quiz(
            topic=quizTopic.trim(),
            difficulty=quizDifficulty,
            num_questions=5
        );

        if result and result.reports and result.reports.length > 0 {
            let quizResponse = result.reports[0];
            console.log("Quiz Response:", JSON.stringify(quizResponse));
            setQuizData(quizResponse);
        }
        setQuizLoading(False);
    }
    
    def handleAnswerSelect(questionIndex: int, answerIndex: int) -> None {
        let newAnswers = selectedAnswers.slice();
        newAnswers[questionIndex] = answerIndex;
        setSelectedAnswers(newAnswers);
    }

    def handleSubmitQuiz() -> None {
        setShowResults(True);
    }

    def handleResetQuiz() -> None {
        setQuizData(None);
        setQuizTopic("");
        setCurrentQuestion(0);
        setSelectedAnswers([]);
        setShowResults(False);
    }

    let exampleQuestions = [
        "Explain photosynthesis in simple terms",
        "Help me understand quantum mechanics",
        "What's the difference between mitosis and meiosis?",
        "How do I solve quadratic equations?"
    ];

    return <ThemeProvider
        theme={theme}
    >
        <CssBaseline />
        <div className="animated-bg">
            <div className="particle particle-1"></div>
            <div className="particle particle-2"></div>
            <div className="particle particle-3"></div>
            <div className="particle particle-4"></div>
        </div>
        <Box
            sx={{"minHeight": "100vh", "display": "flex", "position": "relative"}}
        >
            <Drawer
                variant="permanent"
                sx={{
                    "width": 280,
                    "flexShrink": 0,
                    "& .MuiDrawer-paper": {
                        "width": 280,
                        "boxSizing": "border-box",
                        "background": "rgba(15, 23, 42, 0.95)",
                        "backdropFilter": "blur(20px)",
                        "borderRight": "1px solid rgba(167, 139, 250, 0.2)",
                        "pt": 3
                    }
                }}
            >
                <Box sx={{"px": 3, "mb": 4}}>
                    <Stack direction="row" spacing={2} alignItems="center">
                        <Avatar
                            sx={{
                                "width": 48,
                                "height": 48,
                                "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)"
                            }}
                        >
                            <School sx={{"fontSize": 28}} />
                        </Avatar>
                        <Box>
                            <Typography variant="h6" sx={{"fontWeight": 700, "lineHeight": 1.2}}>
                                {"Smart Learning"}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                                {"Companion"}
                            </Typography>
                        </Box>
                    </Stack>
                </Box>
                <Divider sx={{"borderColor": "rgba(167, 139, 250, 0.2)", "mb": 2}} />
                <List sx={{"px": 2}}>
                    {navigationItems.map(
                        lambda item: any -> any {
                            let isActive = activeTab == item["id"];
                            return <ListItem key={item["id"]} disablePadding sx={{"mb": 1}}>
                                <ListItemButton
                                    onClick={lambda -> None { setActiveTab(item["id"]); }}
                                    sx={{
                                        "borderRadius": 2,
                                        "py": 1.5,
                                        "background": (
                                            "linear-gradient(135deg, rgba(167, 139, 250, 0.2) 0%, rgba(244, 114, 182, 0.2) 100%)"
                                            if isActive
                                            else "transparent"
                                        ),
                                        "border": (
                                            "1px solid rgba(167, 139, 250, 0.4)"
                                            if isActive
                                            else "1px solid transparent"
                                        ),
                                        "&:hover": {
                                            "background": "rgba(167, 139, 250, 0.1)",
                                            "border": "1px solid rgba(167, 139, 250, 0.3)"
                                        }
                                    }}
                                >
                                    <ListItemIcon
                                        sx={{
                                            "color": (
                                                "primary.main"
                                                if isActive
                                                else "text.secondary"
                                            ),
                                            "minWidth": 40
                                        }}
                                    >
                                        {item["icon"]}
                                    </ListItemIcon>
                                    <ListItemText
                                        primary={item["label"]}
                                        primaryTypographyProps={{
                                            "fontWeight": (600 if isActive else 500),
                                            "color": (
                                                "primary.light"
                                                if isActive
                                                else "text.primary"
                                            )
                                        }}
                                    />
                                </ListItemButton>
                            </ListItem>;
                        }
                    )}
                </List>
                <Box sx={{"flexGrow": 1}} />
                <Box sx={{"p": 3, "pt": 2}}>
                    <Paper
                        sx={{
                            "p": 2,
                            "background": "rgba(167, 139, 250, 0.1)",
                            "border": "1px solid rgba(167, 139, 250, 0.2)"
                        }}
                    >
                        <Stack spacing={1}>
                            <Stack direction="row" spacing={1} alignItems="center">
                                <Lightbulb sx={{"fontSize": 20, "color": "primary.main"}} />
                                <Typography variant="caption" sx={{"fontWeight": 600}}>
                                    {"Quick Tip"}
                                </Typography>
                            </Stack>
                            <Typography variant="caption" color="text.secondary" sx={{"lineHeight": 1.4}}>
                                {"Ask follow-up questions to dive deeper into topics!"}
                            </Typography>
                        </Stack>
                    </Paper>
                </Box>
            </Drawer>
            <Box
                component="main"
                sx={{"flexGrow": 1, "py": 3, "px": 3, "width": "calc(100vw - 280px)"}}
            >
                <Stack
                    spacing={3}
                    sx={{"maxWidth": 1400, "mx": "auto"}}
                >
                    {(
                    <>
                    <Grow
                        in={True}
                        timeout={800}
                    >
                        <Paper
                            className="glass-card glow"
                            elevation={0}
                            sx={{"p": 4, "borderRadius": 0}}
                        >
                            <Stack
                                direction="row"
                                alignItems="center"
                                spacing={2}
                                justifyContent="center"
                            >
                                <Avatar
                                    sx={{
                                        "width": 64,
                                        "height": 64,
                                        "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                        "boxShadow": "0 8px 32px rgba(167, 139, 250, 0.4)"
                                    }}
                                >
                                    <School
                                        sx={{"fontSize": 36}}
                                    />
                                </Avatar>
                                <Box>
                                    <Typography
                                        variant="h3"
                                        sx={{
                                            "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)",
                                            "WebkitBackgroundClip": "text",
                                            "WebkitTextFillColor": "transparent",
                                            "backgroundClip": "text",
                                            "textShadow": "0 0 40px rgba(167, 139, 250, 0.3)"
                                        }}
                                    >
                                        {"Smart Learning Companion"}
                                    </Typography>
                                    <Stack
                                        direction="row"
                                        spacing={1}
                                        alignItems="center"
                                        sx={{"mt": 1}}
                                    >
                                        <Psychology
                                            sx={{
                                                "fontSize": 20,
                                                "color": "secondary.main"
                                            }}
                                        />
                                        <Typography
                                            variant="subtitle1"
                                            color="text.secondary"
                                            sx={{"fontWeight": 500}}
                                        >
                                            {"Your AI-Powered Study Assistant"}
                                        </Typography>
                                    </Stack>
                                </Box>
                            </Stack>
                        </Paper>
                    </Grow>
                    <Grow
                        in={True}
                        timeout={1000}
                    >
                        <Paper
                            className="glass-card"
                            elevation={0}
                            sx={{
                                "height": "calc(100vh - 300px)",
                                "minHeight": "600px",
                                "display": "flex",
                                "flexDirection": "column",
                                "overflow": "hidden",
                                "borderRadius": 0
                            }}
                        >
                            <Box
                                sx={{
                                    "p": 3,
                                    "borderBottom": "1px solid rgba(167, 139, 250, 0.2)",
                                    "background": "linear-gradient(90deg, rgba(167, 139, 250, 0.1) 0%, rgba(244, 114, 182, 0.1) 100%)",
                                    "backdropFilter": "blur(10px)"
                                }}
                            >
                                <Stack
                                    direction="row"
                                    justifyContent="space-between"
                                    alignItems="center"
                                >
                                    <Stack
                                        direction="row"
                                        spacing={1}
                                        alignItems="center"
                                    >
                                        <Psychology color="primary" />
                                        <Typography
                                            variant="h5"
                                            color="primary"
                                        >
                                            {"AI Tutor Chat"}
                                        </Typography>
                                    </Stack>
                                    {(
                                        <Button
                                            variant="outlined"
                                            color="error"
                                            startIcon={<Clear />}
                                            onClick={clearChat}
                                            sx={{"borderRadius": 0}}
                                        >
                                            {"Clear Chat"}
                                        </Button>
                                    )
                                    if conversationHistory.length > 0
                                    else None}
                                </Stack>
                            </Box>
                            <Box
                                sx={{
                                    "flex": 1,
                                    "overflowY": "auto",
                                    "p": 3,
                                    "background": "transparent"
                                }}
                            >
                                {(
                                    <Stack
                                        spacing={2}
                                    >
                                        {conversationHistory.map(
                                            lambda  msg: any  -> any{ isUser = msg[
                                                "role"
                                            ] == "user";return <Box
                                                sx={{
                                                    "display": "flex",
                                                    "justifyContent": (
                                                        "flex-end"
                                                        if isUser
                                                        else "flex-start"
                                                    ),
                                                    "mb": 2
                                                }}
                                                key={msg["timestamp"]}
                                            >
                                                <Fade
                                                    in={True}
                                                    timeout={300}
                                                >
                                                    <Card
                                                        className={(
                                                            "message-slide-right"
                                                            if isUser
                                                            else "message-slide-left"
                                                        )}
                                                        sx={{
                                                            "maxWidth": "75%",
                                                            "background": (
                                                                "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)"
                                                                if isUser
                                                                else "rgba(30, 41, 59, 0.8)"
                                                            ),
                                                            "color": "white",
                                                            "backdropFilter": "blur(20px)",
                                                            "border": (
                                                                "1px solid rgba(167, 139, 250, 0.3)"
                                                                if isUser
                                                                else "1px solid rgba(203, 213, 225, 0.2)"
                                                            ),
                                                            "boxShadow": (
                                                                "0 8px 32px rgba(167, 139, 250, 0.3)"
                                                                if isUser
                                                                else "0 8px 32px rgba(0, 0, 0, 0.2)"
                                                            ),
                                                            "borderRadius": "20px",
                                                            "borderBottomRightRadius": (
                                                                "4px" if isUser else "20px"
                                                            ),
                                                            "borderBottomLeftRadius": (
                                                                "20px" if isUser else "4px"
                                                            )
                                                        }}
                                                    >
                                                        <CardContent sx={{"p": 2, "&:last-child": {"pb": 2}}}>
                                                            <Stack
                                                                spacing={1}
                                                            >
                                                                <Stack
                                                                    direction="row"
                                                                    spacing={1}
                                                                    alignItems="center"
                                                                >
                                                                    <Avatar
                                                                        sx={{
                                                                            "width": 32,
                                                                            "height": 32,
                                                                            "bgcolor": (
                                                                                "rgba(255,255,255,0.2)"
                                                                                if isUser
                                                                                else "rgba(167, 139, 250, 0.3)"
                                                                            ),
                                                                            "border": "2px solid rgba(255,255,255,0.3)"
                                                                        }}
                                                                    >
                                                                        {(
                                                                            "You"
                                                                            if isUser
                                                                            else <AutoAwesome
                                                                                sx={{
                                                                                    "fontSize": 18
                                                                                }}
                                                                            />
                                                                        )}
                                                                    </Avatar>
                                                                    <Typography
                                                                        variant="caption"
                                                                        sx={{
                                                                            "fontWeight": 700,
                                                                            "textTransform": "uppercase",
                                                                            "letterSpacing": "0.05em",
                                                                            "opacity": 0.9
                                                                        }}
                                                                    >
                                                                        {(
                                                                            "You"
                                                                            if isUser
                                                                            else "AI Tutor"
                                                                        )}
                                                                    </Typography>
                                                                </Stack>
                                                                <Typography
                                                                    variant="body1"
                                                                    sx={{
                                                                        "whiteSpace": "pre-wrap",
                                                                        "wordWrap": "break-word",
                                                                        "lineHeight": 1.6
                                                                    }}
                                                                >
                                                                    {msg["content"]}
                                                                </Typography>
                                                            </Stack>
                                                        </CardContent>
                                                    </Card>
                                                </Fade>
                                            </Box>; }
                                        )}
                                        {(
                                            <Fade
                                                in={True}
                                                timeout={300}
                                            >
                                                <Box
                                                    sx={{
                                                        "display": "flex",
                                                        "justifyContent": "flex-start"
                                                    }}
                                                >
                                                    <Card
                                                        sx={{
                                                            "maxWidth": "75%",
                                                            "background": "#ffffff",
                                                            "boxShadow": 3,
                                                            "borderRadius": "20px"
                                                        }}
                                                    >
                                                        <CardContent sx={{"p": 2, "&:last-child": {"pb": 2}}}>
                                                            <Stack
                                                                direction="row"
                                                                spacing={2}
                                                                alignItems="center"
                                                            >
                                                                <CircularProgress
                                                                    size={24}
                                                                />
                                                                <Typography
                                                                    variant="body1"
                                                                    color="text.secondary"
                                                                >
                                                                    {"AI is thinking..."}
                                                                </Typography>
                                                            </Stack>
                                                        </CardContent>
                                                    </Card>
                                                </Box>
                                            </Fade>
                                        )
                                        if loading
                                        else None}
                                        <div
                                            ref={messagesEndRef}
                                        />
                                    </Stack>
                                )
                                if conversationHistory.length > 0
                                else (
                                    <Box
                                        sx={{
                                            "display": "flex",
                                            "flexDirection": "column",
                                            "alignItems": "center",
                                            "justifyContent": "center",
                                            "height": "100%",
                                            "textAlign": "center"
                                        }}
                                    >
                                        <Fade
                                            in={True}
                                            timeout={500}
                                        >
                                            <Box>
                                                <Psychology
                                                    className="pulse"
                                                    sx={{
                                                        "fontSize": 120,
                                                        "color": "primary.main",
                                                        "opacity": 0.3,
                                                        "mb": 3,
                                                        "filter": "drop-shadow(0 0 30px rgba(167, 139, 250, 0.3))"
                                                    }}
                                                />
                                                <Typography
                                                    variant="h4"
                                                    gutterBottom
                                                    sx={{
                                                        "fontWeight": 700,
                                                        "color": "primary.main"
                                                    }}
                                                >
                                                    {"Start a Conversation"}
                                                </Typography>
                                                <Typography
                                                    variant="body1"
                                                    color="text.secondary"
                                                    sx={{"mb": 4, "maxWidth": 500}}
                                                >
                                                    {"Ask me anything about your studies! I'm here to help you learn and understand complex topics."}
                                                </Typography>
                                                <Box
                                                    sx={{"maxWidth": 600, "mx": "auto"}}
                                                >
                                                    <Typography
                                                        variant="h6"
                                                        sx={{
                                                            "mb": 2,
                                                            "color": "primary.main",
                                                            "fontWeight": 600
                                                        }}
                                                    >
                                                        {"Try asking:"}
                                                    </Typography>
                                                    <Stack
                                                        spacing={1.5}
                                                    >
                                                        {exampleQuestions.map(
                                                            lambda  question: any  -> any{ return <Chip
                                                                key={question}
                                                                label={question}
                                                                icon={<AutoAwesome />}
                                                                onClick={lambda   -> None{ setMessage(
                                                                    question
                                                                );} }
                                                                sx={{
                                                                    "py": 2.5,
                                                                    "px": 1,
                                                                    "fontSize": "0.95rem",
                                                                    "cursor": "pointer",
                                                                    "transition": "all 0.2s",
                                                                    "&:hover": {
                                                                        "transform": "translateX(8px)",
                                                                        "boxShadow": 2
                                                                    }
                                                                }}
                                                                color="primary"
                                                                variant="outlined"
                                                            />; }
                                                        )}
                                                    </Stack>
                                                </Box>
                                            </Box>
                                        </Fade>
                                    </Box>
                                )}
                            </Box>
                            <Divider
                                sx={{"borderColor": "rgba(167, 139, 250, 0.2)"}}
                            />
                            <Box
                                sx={{
                                    "p": 3,
                                    "background": "rgba(15, 23, 42, 0.5)",
                                    "backdropFilter": "blur(10px)"
                                }}
                            >
                                <Stack
                                    spacing={2}
                                >
                                    <TextField
                                        fullWidth
                                        multiline
                                        rows={3}
                                        value={message}
                                        onChange={lambda  e: any  -> None{ setMessage(
                                            e.target.value
                                        );} }
                                        onKeyPress={handleKeyPress}
                                        placeholder="Type your question here... (Shift+Enter for new line, Enter to send)"
                                        disabled={loading}
                                        variant="outlined"
                                        sx={{
                                            "& .MuiOutlinedInput-root": {
                                                "borderRadius": 0,
                                                "fontSize": "1rem",
                                                "&:hover fieldset": {
                                                    "borderColor": "primary.main",
                                                    "borderWidth": 2
                                                },
                                                "&.Mui-focused fieldset": {
                                                    "borderWidth": 2
                                                }
                                            }
                                        }}
                                    />
                                    <Button
                                        fullWidth
                                        variant="contained"
                                        size="large"
                                        onClick={handleChat}
                                        disabled={loading or not message.trim()}
                                        startIcon={(
                                            <CircularProgress
                                                size={20}
                                                sx={{"color": "white"}}
                                            />
                                        )
                                        if loading
                                        else (<Send />)}
                                        sx={{
                                            "py": 1.5,
                                            "fontSize": "1.1rem",
                                            "fontWeight": 600,
                                            "borderRadius": 0,
                                            "textTransform": "none",
                                            "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                            "boxShadow": "0 8px 32px rgba(167, 139, 250, 0.4)",
                                            "&:hover": {
                                                "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)",
                                                "transform": "translateY(-2px)",
                                                "boxShadow": "0 12px 40px rgba(167, 139, 250, 0.5)"
                                            },
                                            "&:active": {"transform": "translateY(0)"},
                                            "transition": "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)"
                                        }}
                                    >
                                        {("Thinking..." if loading else "Ask Question")}
                                    </Button>
                                </Stack>
                            </Box>
                        </Paper>
                    </Fade>
                    <Typography
                        variant="body2"
                        align="center"
                        sx={{
                            "color": "rgba(248, 250, 252, 0.7)",
                            "fontWeight": 500,
                            "textShadow": "0 0 20px rgba(167, 139, 250, 0.3)"
                        }}
                    >
                        {"⚡ Powered by GPT-4o • Built with Jaclang & Material-UI"}
                    </Typography>
                    </>
                    )
                    if activeTab == "chat"
                    else (
                        <>
                        <Paper sx={{"p": 4}}>
                            <Stack direction="row" spacing={2} alignItems="center" sx={{"mb": 3}}>
                                <Quiz sx={{"fontSize": 40, "color": "primary.main"}} />
                                <Box>
                                    <Typography variant="h4" sx={{"fontWeight": 700}}>
                                        {"Practice Quiz"}
                                    </Typography>
                                    <Typography color="text.secondary">
                                        {"Test your knowledge with AI-generated quizzes"}
                                    </Typography>
                                </Box>
                            </Stack>
                        </Paper>

                        {(
                            <Paper sx={{"p": 4}}>
                                <Stack spacing={3}>
                                    <Typography variant="h6" sx={{"fontWeight": 600}}>
                                        {"Generate a Quiz"}
                                    </Typography>
                                    
                                    <TextField
                                        fullWidth
                                        label="Quiz Topic"
                                        placeholder="e.g., Photosynthesis, World War II, Calculus..."
                                        value={quizTopic}
                                        onChange={lambda e: any -> None { setQuizTopic(e.target.value); }}
                                        disabled={quizLoading}
                                    />

                                    <Box>
                                        <Typography variant="subtitle2" sx={{"mb": 1, "fontWeight": 600}}>
                                            {"Difficulty Level"}
                                        </Typography>
                                        <Stack direction="row" spacing={1}>
                                            <Chip
                                                label="Easy"
                                                onClick={lambda -> None { setQuizDifficulty("easy"); }}
                                                color={"primary" if (quizDifficulty == "easy") else "default"}
                                                variant={"filled" if (quizDifficulty == "easy") else "outlined"}
                                            />
                                            <Chip
                                                label="Medium"
                                                onClick={lambda -> None { setQuizDifficulty("medium"); }}
                                                color={"primary" if (quizDifficulty == "medium") else "default"}
                                                variant={"filled" if (quizDifficulty == "medium") else "outlined"}
                                            />
                                            <Chip
                                                label="Hard"
                                                onClick={lambda -> None { setQuizDifficulty("hard"); }}
                                                color={"primary" if (quizDifficulty == "hard") else "default"}
                                                variant={"filled" if (quizDifficulty == "hard") else "outlined"}
                                            />
                                        </Stack>
                                    </Box>

                                    <Button
                                        fullWidth
                                        variant="contained"
                                        size="large"
                                        onClick={handleGenerateQuiz}
                                        disabled={quizLoading or not quizTopic.trim()}
                                        startIcon={(
                                            <CircularProgress size={20} sx={{"color": "white"}} />
                                        ) if quizLoading else <AutoAwesome />}
                                        sx={{
                                            "py": 1.5,
                                            "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                            "&:hover": {
                                                "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"
                                            }
                                        }}
                                    >
                                        {"Generating Quiz..." if quizLoading else "Generate Quiz"}
                                    </Button>

                                    <Box sx={{"mt": 4}}>
                                        <Typography variant="subtitle2" sx={{"mb": 2, "fontWeight": 600}}>
                                            {"Popular Topics:"}
                                        </Typography>
                                        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                                            {["Python Programming", "World History", "Biology", "Mathematics", "Chemistry"].map(
                                                lambda topic: any -> any {
                                                    return <Chip
                                                        key={topic}
                                                        label={topic}
                                                        onClick={lambda -> None { setQuizTopic(topic); }}
                                                        variant="outlined"
                                                        sx={{"cursor": "pointer"}}
                                                    />;
                                                }
                                            )}
                                        </Stack>
                                    </Box>
                                </Stack>
                            </Paper>
                        )
                        if (quizData == null)
                        else (
                            <Paper sx={{"p": 4}}>
                                <Stack spacing={3}>
                                    <Box>
                                        <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{"mb": 2}}>
                                            <Typography variant="h6" sx={{"fontWeight": 600}}>
                                                {quizData["topic"]}
                                            </Typography>
                                            <Chip
                                                label="Quiz"
                                                color="primary"
                                                size="small"
                                            />
                                        </Stack>
                                        <Typography variant="body2" color="text.secondary">
                                            {"Question " + (currentQuestion + 1) + " of " + quizData["questions"].length}
                                        </Typography>
                                    </Box>

                                    <Divider />

                                    {quizData["questions"].map(
                                        lambda q: any, idx: int -> any {
                                            return (
                                                <Box key={idx}>
                                                    <Typography variant="h6" sx={{"mb": 3}}>
                                                        {q["question"]}
                                                    </Typography>
                                                    <Stack spacing={2}>
                                                        {q["options"].map(
                                                            lambda option: any, optIdx: int -> any {
                                                                let isSelected = selectedAnswers[idx] == optIdx;
                                                                return <Paper
                                                                    key={optIdx}
                                                                    onClick={lambda -> None { handleAnswerSelect(idx, optIdx); }}
                                                                    sx={{
                                                                        "p": 2,
                                                                        "cursor": "pointer",
                                                                        "border": "2px solid" if isSelected else "1px solid",
                                                                        "borderColor": "primary.main" if isSelected else "divider",
                                                                        "background": "rgba(167, 139, 250, 0.1)" if isSelected else "transparent",
                                                                        "&:hover": {
                                                                            "borderColor": "primary.main",
                                                                            "background": "rgba(167, 139, 250, 0.05)"
                                                                        }
                                                                    }}
                                                                >
                                                                    <Stack direction="row" spacing={2} alignItems="center">
                                                                        <Avatar
                                                                            sx={{
                                                                                "width": 32,
                                                                                "height": 32,
                                                                                "background": "primary.main" if isSelected else "transparent",
                                                                                "border": "2px solid",
                                                                                "borderColor": "primary.main" if isSelected else "text.secondary"
                                                                            }}
                                                                        >
                                                                            <Typography variant="body2" sx={{"fontWeight": 600}}>
                                                                                {["A", "B", "C", "D"][optIdx]}
                                                                            </Typography>
                                                                        </Avatar>
                                                                        <Typography>
                                                                            {option}
                                                                        </Typography>
                                                                    </Stack>
                                                                </Paper>;
                                                            }
                                                        )}
                                                    </Stack>
                                                </Box>
                                            )
                                            if idx == currentQuestion
                                            else null;
                                        }
                                    )}

                                    <Stack direction="row" spacing={2} justifyContent="space-between">
                                        <Button
                                            variant="outlined"
                                            onClick={lambda -> None { setCurrentQuestion(currentQuestion - 1); }}
                                            disabled={currentQuestion == 0}
                                        >
                                            {"Previous"}
                                        </Button>
                                        
                                        {(
                                            <Button
                                                variant="contained"
                                                onClick={lambda -> None { setCurrentQuestion(currentQuestion + 1); }}
                                                disabled={selectedAnswers[currentQuestion] == undefined}
                                            >
                                                {"Next"}
                                            </Button>
                                        )
                                        if currentQuestion < quizData["questions"].length - 1
                                        else (
                                            <Button
                                                variant="contained"
                                                onClick={handleSubmitQuiz}
                                                disabled={selectedAnswers.length != quizData["questions"].length}
                                                sx={{
                                                    "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                                    "&:hover": {
                                                        "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"
                                                    }
                                                }}
                                            >
                                                {"Submit Quiz"}
                                            </Button>
                                        )}
                                    </Stack>
                                </Stack>
                            </Paper>
                        )
                        if (showResults == false)
                        else (
                            <Paper sx={{"p": 4}}>
                                <Stack spacing={3}>
                                    <Box sx={{"textAlign": "center", "py": 3}}>
                                        <Typography variant="h4" sx={{"fontWeight": 700, "mb": 2}}>
                                            {"Quiz Results"}
                                        </Typography>
                                        <Typography variant="h2" color="primary.main" sx={{"fontWeight": 800}}>
                                            {selectedAnswers.filter(
                                                lambda ans: any, idx: int -> any {
                                                    return ans == quizData["questions"][idx]["correct"];
                                                }
                                            ).length + "/" + quizData["questions"].length}
                                        </Typography>
                                        <Typography color="text.secondary" sx={{"mt": 1}}>
                                            {Math.round((selectedAnswers.filter(
                                                lambda ans: any, idx: int -> any {
                                                    return ans == quizData["questions"][idx]["correct"];
                                                }
                                            ).length / quizData["questions"].length) * 100) + "% Correct"}
                                        </Typography>
                                    </Box>

                                    <Divider />

                                    <Stack spacing={2}>
                                        {quizData["questions"].map(
                                            lambda q: any, idx: int -> any {
                                                let isCorrect = selectedAnswers[idx] == q["correct"];
                                                return <Card key={idx} sx={{"border": "1px solid", "borderColor": "divider"}}>
                                                    <CardContent>
                                                        <Stack spacing={2}>
                                                            <Stack direction="row" spacing={1} alignItems="flex-start">
                                                                {(
                                                                    <CheckCircle sx={{"color": "success.main", "fontSize": 24}} />
                                                                )
                                                                if isCorrect
                                                                else (
                                                                    <Cancel sx={{"color": "error.main", "fontSize": 24}} />
                                                                )}
                                                                <Box sx={{"flex": 1}}>
                                                                    <Typography variant="subtitle1" sx={{"fontWeight": 600}}>
                                                                        {"Question " + (idx + 1)}
                                                                    </Typography>
                                                                    <Typography variant="body2">
                                                                        {q["question"]}
                                                                    </Typography>
                                                                </Box>
                                                            </Stack>
                                                            
                                                            <Box sx={{"pl": 4}}>
                                                                <Typography variant="body2" color="text.secondary">
                                                                    {"Your answer: " + q["options"][selectedAnswers[idx]]}
                                                                </Typography>
                                                                {(
                                                                    <Typography variant="body2" color="success.main" sx={{"mt": 0.5}}>
                                                                        {"Correct answer: " + q["options"][q["correct"]]}
                                                                    </Typography>
                                                                )
                                                                if (not isCorrect)
                                                                else null}
                                                            </Box>
                                                        </Stack>
                                                    </CardContent>
                                                </Card>;
                                            }
                                        )}
                                    </Stack>

                                    <Button
                                        fullWidth
                                        variant="contained"
                                        size="large"
                                        startIcon={<Refresh />}
                                        onClick={handleResetQuiz}
                                        sx={{
                                            "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                            "&:hover": {
                                                "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"
                                            }
                                        }}
                                    >
                                        {"Create New Quiz"}
                                    </Button>
                                </Stack>
                            </Paper>
                        )}
                        </>
                    )
                    if activeTab == "quiz"
                    else (
                        <Paper sx={{"p": 4, "textAlign": "center"}}>
                            <MenuBook sx={{"fontSize": 80, "color": "primary.main", "mb": 2}} />
                            <Typography variant="h4" gutterBottom>
                                {"Learn Topic"}
                            </Typography>
                            <Typography color="text.secondary">
                                {"Deep dive into any topic with structured lessons and explanations."}
                            </Typography>
                        </Paper>
                    )
                    if activeTab == "learn"
                    else (
                        <Paper sx={{"p": 4, "textAlign": "center"}}>
                            <TrendingUp sx={{"fontSize": 80, "color": "primary.main", "mb": 2}} />
                            <Typography variant="h4" gutterBottom>
                                {"Learning Path"}
                            </Typography>
                            <Typography color="text.secondary">
                                {"Get a personalized learning path tailored to your goals."}
                            </Typography>
                        </Paper>
                    )}
                </Stack>
            </Box>
        </Box>
    </ThemeProvider>;
}
