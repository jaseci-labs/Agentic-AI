cl {
    import from react { useRef }
    import from '@mui/material' {
        Box,
        Paper,
        TextField,
        Button,
        Typography,
        Stack,
        Avatar,
        Divider,
        Fade,
        CircularProgress,
        Card,
        CardContent,
        Grow
    }
    import from '@mui/icons-material' {
        Send,
        School,
        Psychology,
        AutoAwesome,
        Clear,
        Person
    }
}

cl def ChatTab(props: any) -> any {
    let conversationHistory = props.conversationHistory;
    let message = props.message;
    let setMessage = props.setMessage;
    let loading = props.loading;
    let handleChat = props.handleChat;
    let handleKeyPress = props.handleKeyPress;
    let clearChat = props.clearChat;
    let messagesEndRef = props.messagesEndRef;
    let exampleQuestions = props.exampleQuestions;

    return <>
        <Grow in={true} timeout={800}>
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
                        <School sx={{"fontSize": 36}} />
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
                            <Psychology sx={{"fontSize": 20, "color": "secondary.main"}} />
                            <Typography variant="subtitle1" color="text.secondary" sx={{"fontWeight": 500}}>
                                {"Your AI-Powered Study Assistant"}
                            </Typography>
                        </Stack>
                    </Box>
                </Stack>
            </Paper>
        </Grow>
        <Grow in={true} timeout={1000}>
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
                                sx={{"borderRadius": 0}}
                            >
                                {"Clear Chat"}
                            </Button>
                        ) if (conversationHistory.length > 0) else null}
                    </Stack>
                </Box>
                <Box sx={{"flex": 1, "overflowY": "auto", "p": 3, "background": "transparent"}}>
                    {(
                        <Stack spacing={2}>
                            {conversationHistory.map(
                                lambda msg: any -> any {
                                    let isUser = msg["role"] == "user";
                                    return <Box
                                        sx={{
                                            "display": "flex",
                                            "justifyContent": ("flex-end" if isUser else "flex-start"),
                                            "mb": 2
                                        }}
                                        key={msg["timestamp"]}
                                    >
                                        <Fade in={true} timeout={300}>
                                            <Card
                                                className={("message-slide-right" if isUser else "message-slide-left")}
                                                sx={{
                                                    "maxWidth": "75%",
                                                    "background": ("linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)" if isUser else "rgba(30, 41, 59, 0.8)"),
                                                    "color": "white",
                                                    "backdropFilter": "blur(20px)",
                                                    "border": ("1px solid rgba(167, 139, 250, 0.3)" if isUser else "1px solid rgba(203, 213, 225, 0.2)"),
                                                    "boxShadow": ("0 8px 32px rgba(167, 139, 250, 0.3)" if isUser else "0 8px 32px rgba(0, 0, 0, 0.2)"),
                                                    "borderRadius": "20px",
                                                    "borderBottomRightRadius": ("4px" if isUser else "20px"),
                                                    "borderBottomLeftRadius": ("20px" if isUser else "4px")
                                                }}
                                            >
                                                <CardContent sx={{"p": 2, "&:last-child": {"pb": 2}}}>
                                                    <Stack spacing={1}>
                                                        <Stack direction="row" spacing={1} alignItems="center">
                                                            <Avatar
                                                                sx={{
                                                                    "width": 28,
                                                                    "height": 28,
                                                                    "background": ("rgba(255, 255, 255, 0.2)" if isUser else "rgba(167, 139, 250, 0.3)")
                                                                }}
                                                            >
                                                                {(<Person sx={{"fontSize": 18}} />) if isUser else (<Psychology sx={{"fontSize": 18}} />)}
                                                            </Avatar>
                                                            <Typography variant="caption" sx={{"fontWeight": 600, "opacity": 0.9}}>
                                                                {("You" if isUser else "AI Tutor")}
                                                            </Typography>
                                                        </Stack>
                                                        <Typography
                                                            variant="body1"
                                                            sx={{
                                                                "lineHeight": 1.6,
                                                                "whiteSpace": "pre-wrap",
                                                                "wordBreak": "break-word"
                                                            }}
                                                        >
                                                            {msg["content"]}
                                                        </Typography>
                                                    </Stack>
                                                </CardContent>
                                            </Card>
                                        </Fade>
                                    </Box>;
                                }
                            )}
                            {(
                                <Fade in={true} timeout={300}>
                                    <Box sx={{"display": "flex", "justifyContent": "flex-start"}}>
                                        <Card sx={{"maxWidth": "75%", "background": "#ffffff", "borderRadius": "20px"}}>
                                            <CardContent sx={{"p": 2, "&:last-child": {"pb": 2}}}>
                                                <Stack direction="row" spacing={1} alignItems="center">
                                                    <CircularProgress size={20} />
                                                    <Typography color="text.primary">
                                                        {"AI is thinking..."}
                                                    </Typography>
                                                </Stack>
                                            </CardContent>
                                        </Card>
                                    </Box>
                                </Fade>
                            ) if loading else null}
                            <div ref={messagesEndRef} />
                        </Stack>
                    ) if (conversationHistory.length > 0) else (
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
                            <Fade in={true} timeout={500}>
                                <Box>
                                    <Psychology
                                        className="pulse"
                                        sx={{
                                            "fontSize": 120,
                                            "color": "primary.main",
                                            "mb": 3,
                                            "filter": "drop-shadow(0 0 30px rgba(167, 139, 250, 0.3))"
                                        }}
                                    />
                                    <Typography variant="h4" gutterBottom sx={{"fontWeight": 700, "color": "primary.main"}}>
                                        {"Start a Conversation"}
                                    </Typography>
                                    <Typography color="text.secondary" sx={{"mb": 4, "maxWidth": 500}}>
                                        {"Ask me anything! I'm here to help you learn and understand complex topics."}
                                    </Typography>
                                    <Box sx={{"maxWidth": 600, "mx": "auto"}}>
                                        <Typography variant="subtitle2" sx={{"mb": 2, "fontWeight": 600, "color": "primary.light"}}>
                                            {"Try these examples:"}
                                        </Typography>
                                        <Stack spacing={1}>
                                            {exampleQuestions.map(
                                                lambda question: any -> any {
                                                    return <Paper
                                                        key={question}
                                                        onClick={lambda -> None { setMessage(question); }}
                                                        sx={{
                                                            "p": 2,
                                                            "cursor": "pointer",
                                                            "border": "1px solid rgba(167, 139, 250, 0.2)",
                                                            "background": "rgba(167, 139, 250, 0.05)",
                                                            "&:hover": {
                                                                "background": "rgba(167, 139, 250, 0.1)",
                                                                "borderColor": "primary.main"
                                                            }
                                                        }}
                                                    >
                                                        <Typography variant="body2">
                                                            {question}
                                                        </Typography>
                                                    </Paper>;
                                                }
                                            )}
                                        </Stack>
                                    </Box>
                                </Box>
                            </Fade>
                        </Box>
                    )}
                </Box>
                <Divider sx={{"borderColor": "rgba(167, 139, 250, 0.2)"}} />
                <Box
                    sx={{
                        "p": 3,
                        "background": "rgba(15, 23, 42, 0.5)",
                        "backdropFilter": "blur(10px)"
                    }}
                >
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
                        />
                        <Button
                            fullWidth
                            variant="contained"
                            size="large"
                            onClick={handleChat}
                            disabled={loading or not message.trim()}
                            startIcon={(
                                <CircularProgress size={20} sx={{"color": "white"}} />
                            ) if loading else <Send />}
                            sx={{
                                "py": 1.5,
                                "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)",
                                "&:hover": {
                                    "background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"
                                }
                            }}
                        >
                            {("Sending..." if loading else "Send Message")}
                        </Button>
                    </Stack>
                </Box>
            </Paper>
        </Grow>
        <Typography
            variant="body2"
            align="center"
            sx={{
                "color": "rgba(248, 250, 252, 0.7)",
                "fontWeight": 500,
                "textShadow": "0 0 20px rgba(167, 139, 250, 0.3)"
            }}
        >
            {"⚡ Built with Jaseci Stack"}
        </Typography>
    </>;
}
