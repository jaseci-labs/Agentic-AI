import from react { useState, useEffect, useRef }
cl import from '@mui/material' {
    Container, Box, Paper, TextField, Button, Typography, 
    IconButton, Chip, Stack, Avatar, Divider, Fade, CircularProgress,
    ThemeProvider, createTheme, CssBaseline, Card, CardContent
}
cl import from '@mui/icons-material' {
    Send, School, Psychology, AutoAwesome, Clear
}

cl let theme = createTheme({
    "palette": {
        "mode": "light",
        "primary": {
            "main": "#6366f1",
            "light": "#818cf8",
            "dark": "#4f46e5"
        },
        "secondary": {
            "main": "#8b5cf6",
            "light": "#a78bfa",
            "dark": "#7c3aed"
        },
        "background": {
            "default": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
            "paper": "#ffffff"
        }
    },
    "typography": {
        "fontFamily": "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif",
        "h3": {
            "fontWeight": 800,
            "letterSpacing": "-0.02em"
        },
        "h5": {
            "fontWeight": 700
        },
        "h6": {
            "fontWeight": 600
        }
    },
    "shape": {
        "borderRadius": 16
    },
    "shadows": [
        "none",
        "0px 2px 4px rgba(0,0,0,0.05)",
        "0px 4px 8px rgba(0,0,0,0.08)",
        "0px 8px 16px rgba(0,0,0,0.1)",
        "0px 12px 24px rgba(0,0,0,0.12)",
        "0px 16px 32px rgba(0,0,0,0.15)"
    ]
});

def app() -> any {
    let [message, setMessage] = useState("");
    let [conversationHistory, setConversationHistory] = useState([]);
    let [loading, setLoading] = useState(False);
    let messagesEndRef = useRef(None);

    async def handleChat() -> None {
        if not message.trim() {
            return;
        }
        
        messageText = message.trim();
        setMessage("");
        setLoading(True);
        
        newHistory = conversationHistory.concat([{
            "role": "user",
            "content": messageText,
            "timestamp": Date.now()
        }]);
        setConversationHistory(newHistory);
        
        result = root spawn chat_tutor(message=messageText, context=[]);
        if result and result.reports and result.reports.length > 0 {
            aiResponse = result.reports[0]["response"];
            
            finalHistory = newHistory.concat([{
                "role": "assistant", 
                "content": aiResponse,
                "timestamp": Date.now()
            }]);
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
    
    def clearChat() -> None {
        setConversationHistory([]);
        setMessage("");
    }

    let exampleQuestions = [
        "Explain photosynthesis in simple terms",
        "Help me understand quantum mechanics",
        "What's the difference between mitosis and meiosis?",
        "How do I solve quadratic equations?"
    ];

    return <ThemeProvider theme={theme}>
        <CssBaseline />
        <Box sx={{
            "minHeight": "100vh",
            "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
            "py": 3
        }}>
            <Container maxWidth="lg">
                <Stack spacing={3}>
                    <Fade in={True} timeout={600}>
                        <Paper elevation={4} sx={{
                            "p": 4,
                            "background": "rgba(255, 255, 255, 0.98)",
                            "backdropFilter": "blur(20px)",
                            "borderRadius": 4
                        }}>
                            <Stack direction="row" alignItems="center" spacing={2} justifyContent="center">
                                <School sx={{"fontSize": 48, "color": "primary.main"}} />
                                <Box>
                                    <Typography variant="h3" sx={{
                                        "background": "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)",
                                        "WebkitBackgroundClip": "text",
                                        "WebkitTextFillColor": "transparent",
                                        "backgroundClip": "text"
                                    }}>
                                        {"Smart Learning Companion"}
                                    </Typography>
                                    <Typography variant="subtitle1" color="text.secondary" sx={{"fontWeight": 500}}>
                                        {"Your AI-Powered Study Assistant"}
                                    </Typography>
                                </Box>
                            </Stack>
                        </Paper>
                    </Fade>

                    <Fade in={True} timeout={800}>
                        <Paper elevation={4} sx={{
                            "height": "calc(100vh - 300px)",
                            "minHeight": "600px",
                            "display": "flex",
                            "flexDirection": "column",
                            "background": "rgba(255, 255, 255, 0.98)",
                            "backdropFilter": "blur(20px)",
                            "borderRadius": 4,
                            "overflow": "hidden"
                        }}>
                            <Box sx={{
                                "p": 3,
                                "borderBottom": 1,
                                "borderColor": "divider",
                                "background": "linear-gradient(90deg, rgba(99, 102, 241, 0.05) 0%, rgba(139, 92, 246, 0.05) 100%)"
                            }}>
                                <Stack direction="row" justifyContent="space-between" alignItems="center">
                                    <Stack direction="row" spacing={1} alignItems="center">
                                        <Psychology color="primary" />
                                        <Typography variant="h5" color="primary">
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
                                    ) if conversationHistory.length > 0 else None}
                                </Stack>
                            </Box>

                            <Box sx={{
                                "flex": 1,
                                "overflowY": "auto",
                                "p": 3,
                                "background": "linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%)"
                            }}>
                                {(
                                    <Stack spacing={2}>
                                        {conversationHistory.map(lambda msg: any -> any {
                                            isUser = msg["role"] == "user";
                                            return <Box sx={{
                                                "display": "flex",
                                                "justifyContent": ("flex-end" if isUser else "flex-start"),
                                                "mb": 2
                                            }}
                                            key={msg["timestamp"]}
                                            >
                                                <Fade in={True} timeout={300}>
                                                    <Card sx={{
                                                        "maxWidth": "75%",
                                                        "background": (
                                                            "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)"
                                                            if isUser
                                                            else "#ffffff"
                                                        ),
                                                        "color": ("white" if isUser else "text.primary"),
                                                        "boxShadow": 3,
                                                        "borderRadius": 3,
                                                        "borderBottomRightRadius": (1 if isUser else 3),
                                                        "borderBottomLeftRadius": (3 if isUser else 1)
                                                    }}>
                                                        <CardContent>
                                                            <Stack spacing={1}>
                                                                <Stack direction="row" spacing={1} alignItems="center">
                                                                    <Avatar sx={{
                                                                        "width": 32,
                                                                        "height": 32,
                                                                        "bgcolor": (
                                                                            "rgba(255,255,255,0.2)"
                                                                            if isUser
                                                                            else "primary.main"
                                                                        )
                                                                    }}>
                                                                        {("You" if isUser else <AutoAwesome sx={{"fontSize": 18}} />)}
                                                                    </Avatar>
                                                                    <Typography variant="caption" sx={{
                                                                        "fontWeight": 700,
                                                                        "textTransform": "uppercase",
                                                                        "letterSpacing": "0.05em",
                                                                        "opacity": 0.9
                                                                    }}>
                                                                        {("You" if isUser else "AI Tutor")}
                                                                    </Typography>
                                                                </Stack>
                                                                <Typography variant="body1" sx={{
                                                                    "whiteSpace": "pre-wrap",
                                                                    "wordWrap": "break-word",
                                                                    "lineHeight": 1.6
                                                                }}>
                                                                    {msg["content"]}
                                                                </Typography>
                                                            </Stack>
                                                        </CardContent>
                                                    </Card>
                                                </Fade>
                                            </Box>;
                                        })}
                                        
                                        {(
                                            <Fade in={True} timeout={300}>
                                                <Box sx={{"display": "flex", "justifyContent": "flex-start"}}>
                                                    <Card sx={{
                                                        "maxWidth": "75%",
                                                        "background": "#ffffff",
                                                        "boxShadow": 3,
                                                        "borderRadius": 3
                                                    }}>
                                                        <CardContent>
                                                            <Stack direction="row" spacing={2} alignItems="center">
                                                                <CircularProgress size={24} />
                                                                <Typography variant="body1" color="text.secondary">
                                                                    {"AI is thinking..."}
                                                                </Typography>
                                                            </Stack>
                                                        </CardContent>
                                                    </Card>
                                                </Box>
                                            </Fade>
                                        ) if loading else None}
                                        
                                        <div ref={messagesEndRef} />
                                    </Stack>
                                ) if conversationHistory.length > 0 else (
                                    <Box sx={{
                                        "display": "flex",
                                        "flexDirection": "column",
                                        "alignItems": "center",
                                        "justifyContent": "center",
                                        "height": "100%",
                                        "textAlign": "center"
                                    }}>
                                        <Fade in={True} timeout={500}>
                                            <Box>
                                                <Psychology sx={{
                                                    "fontSize": 120,
                                                    "color": "primary.main",
                                                    "opacity": 0.2,
                                                    "mb": 3
                                                }} />
                                                <Typography variant="h4" gutterBottom sx={{"fontWeight": 700, "color": "primary.main"}}>
                                                    {"Start a Conversation"}
                                                </Typography>
                                                <Typography variant="body1" color="text.secondary" sx={{"mb": 4, "maxWidth": 500}}>
                                                    {"Ask me anything about your studies! I'm here to help you learn and understand complex topics."}
                                                </Typography>
                                                
                                                <Box sx={{"maxWidth": 600, "mx": "auto"}}>
                                                    <Typography variant="h6" sx={{"mb": 2, "color": "primary.main", "fontWeight": 600}}>
                                                        {"Try asking:"}
                                                    </Typography>
                                                    <Stack spacing={1.5}>
                                                        {exampleQuestions.map(lambda question: any -> any {
                                                            return <Chip
                                                                key={question}
                                                                label={question}
                                                                icon={<AutoAwesome />}
                                                                onClick={lambda -> None { setMessage(question); }}
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
                                                            />;
                                                        })}
                                                    </Stack>
                                                </Box>
                                            </Box>
                                        </Fade>
                                    </Box>
                                )}
                            </Box>

                            <Divider />

                            <Box sx={{"p": 3, "background": "#ffffff"}}>
                                <Stack spacing={2}>
                                    <TextField
                                        fullWidth
                                        multiline
                                        rows={3}
                                        value={message}
                                        onChange={lambda e: any -> None { setMessage(e.target.value); }}
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
                                            <CircularProgress size={20} sx={{"color": "white"}} />
                                        ) if loading else (
                                            <Send />
                                        )}
                                        sx={{
                                            "py": 1.5,
                                            "fontSize": "1.1rem",
                                            "fontWeight": 600,
                                            "borderRadius": 3,
                                            "textTransform": "none",
                                            "background": "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)",
                                            "&:hover": {
                                                "background": "linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)",
                                                "transform": "translateY(-2px)",
                                                "boxShadow": 4
                                            },
                                            "&:active": {
                                                "transform": "translateY(0)"
                                            },
                                            "transition": "all 0.2s"
                                        }}
                                    >
                                        {("Thinking..." if loading else "Ask Question")}
                                    </Button>
                                </Stack>
                            </Box>
                        </Paper>
                    </Fade>

                    <Typography variant="body2" align="center" sx={{
                        "color": "rgba(255, 255, 255, 0.9)",
                        "fontWeight": 500
                    }}>
                        {"Powered by GPT-4o • Built with Jaclang & Material-UI"}
                    </Typography>
                </Stack>
            </Container>
        </Box>
    </ThemeProvider>;
}



