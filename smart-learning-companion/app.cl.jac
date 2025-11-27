import from react { useState, useEffect, useRef }
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
    Tooltip
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
    EmojiObjects
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
        "shape": {"borderRadius": 20},
        "components": {
            "MuiButton": {
                "styleOverrides": {
                    "root": {
                        "textTransform": "none",
                        "fontWeight": 600,
                        "borderRadius": "16px"
                    }
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
            sx={{"minHeight": "100vh", "py": 3, "position": "relative"}}
        >
            <Container maxWidth="lg">
                <Stack
                    spacing={3}
                >
                    <Grow
                        in={True}
                        timeout={800}
                    >
                        <Paper
                            className="glass-card glow"
                            elevation={0}
                            sx={{"p": 4, "borderRadius": 4}}
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
                                "borderRadius": 4
                            }}
                        >
                            <Stack
                                direction="row"
                                alignItems="center"
                                spacing={2}
                                justifyContent="center"
                            >
                                <School
                                    sx={{"fontSize": 48, "color": "primary.main"}}
                                />
                                <Box>
                                    <Typography
                                        variant="h3"
                                        sx={{
                                            "background": "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)",
                                            "WebkitBackgroundClip": "text",
                                            "WebkitTextFillColor": "transparent",
                                            "backgroundClip": "text"
                                        }}
                                    >
                                        {"Smart Learning Companion"}
                                    </Typography>
                                    <Typography
                                        variant="subtitle1"
                                        color="text.secondary"
                                        sx={{"fontWeight": 500}}
                                    >
                                        {"Your AI-Powered Study Assistant"}
                                    </Typography>
                                </Box>
                            </Stack>
                        </Paper>
                    </Fade>
                    <Fade
                        in={True}
                        timeout={800}
                    >
                        <Paper
                            elevation={4}
                            sx={{
                                "height": "calc(100vh - 300px)",
                                "minHeight": "600px",
                                "display": "flex",
                                "flexDirection": "column",
                                "background": "rgba(255, 255, 255, 0.98)",
                                "backdropFilter": "blur(20px)",
                                "borderRadius": 4,
                                "overflow": "hidden"
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
                                            sx={{"borderRadius": 2}}
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
                                                            "borderRadius": 4,
                                                            "borderBottomRightRadius": (
                                                                1 if isUser else 4
                                                            ),
                                                            "borderBottomLeftRadius": (
                                                                4 if isUser else 1
                                                            )
                                                        }}
                                                    >
                                                        <CardContent>
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
                                                            "borderRadius": 3
                                                        }}
                                                    >
                                                        <CardContent>
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
                                                "borderRadius": 3,
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
                                            "borderRadius": 3,
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
                </Stack>
            </Container>
        </Box>
    </ThemeProvider>;
}
