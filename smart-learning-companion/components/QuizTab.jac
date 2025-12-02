cl import from react { useState }
cl import from '@mui/material' {
    Box,
    Paper,
    TextField,
    Button,
    Typography,
    Chip,
    Stack,
    Avatar,
    Divider,
    Card,
    CardContent,
    CircularProgress
}
cl import from '@mui/icons-material' {
    Quiz,
    AutoAwesome,
    CheckCircle,
    Cancel,
    Refresh
}

cl def QuizTab(props: any) -> any {
    let quizTopic = props.quizTopic;
    let setQuizTopic = props.setQuizTopic;
    let quizDifficulty = props.quizDifficulty;
    let setQuizDifficulty = props.setQuizDifficulty;
    let quizData = props.quizData;
    let quizLoading = props.quizLoading;
    let currentQuestion = props.currentQuestion;
    let setCurrentQuestion = props.setCurrentQuestion;
    let selectedAnswers = props.selectedAnswers;
    let showResults = props.showResults;
    let handleGenerateQuiz = props.handleGenerateQuiz;
    let handleAnswerSelect = props.handleAnswerSelect;
    let handleSubmitQuiz = props.handleSubmitQuiz;
    let handleResetQuiz = props.handleResetQuiz;

    let suggestedTopics = ["Photosynthesis", "World War II", "Calculus Basics", "Python Programming"];

    return <>
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
                        {("Generating Quiz..." if quizLoading else "Generate Quiz")}
                    </Button>

                    <Box sx={{"mt": 4}}>
                        <Typography variant="subtitle2" sx={{"mb": 1, "fontWeight": 600, "color": "text.secondary"}}>
                            {"Suggested Topics"}
                        </Typography>
                        <Stack direction="row" spacing={1} flexWrap="wrap" gap={1}>
                            {suggestedTopics.map(
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
        ) if (quizData == null) else (
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
                                                        "border": ("2px solid" if isSelected else "1px solid"),
                                                        "borderColor": ("primary.main" if isSelected else "divider"),
                                                        "background": ("rgba(167, 139, 250, 0.1)" if isSelected else "transparent"),
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
                                                                "background": ("primary.main" if isSelected else "transparent"),
                                                                "border": "2px solid",
                                                                "borderColor": ("primary.main" if isSelected else "text.secondary")
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
                            ) if (idx == currentQuestion) else null;
                        }
                    )}

                    <Stack direction="row" spacing={2} justifyContent="space-between">
                        <Button
                            variant="outlined"
                            disabled={currentQuestion == 0}
                            onClick={lambda -> None { setCurrentQuestion(currentQuestion - 1); }}
                        >
                            {"Previous"}
                        </Button>
                        {(
                            <Button
                                variant="contained"
                                onClick={lambda -> None { setCurrentQuestion(currentQuestion + 1); }}
                            >
                                {"Next"}
                            </Button>
                        ) if (currentQuestion < quizData["questions"].length - 1) else (
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
        ) if (showResults == false) else (
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
                                                ) if isCorrect else (
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
                                                ) if (not isCorrect) else null}
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
    </>;
}
