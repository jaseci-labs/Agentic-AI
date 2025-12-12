import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4o");

# Quiz Question Type
obj QuizQuestion {
    has question: str;
    has options: list[str];
    has correct: int;
}

# Backend Walkers
walker learn_topic {
    has topic: str;
    has level: str = "beginner";

    def explain_topic(topic: str, level: str) -> str by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are an expert teacher. Explain the topic clearly and engagingly. ""Adjust the complexity based on the level (beginner, intermediate, advanced). ""Use analogies, examples, and break down complex concepts. ""Format your response with sections: Overview, Key Concepts, Examples, and Summary."
        )
    );

    can learn with `root entry {
        explanation = self.explain_topic(topic=self.topic, level=self.level);
        report {"topic": self.topic, "level": self.level, "explanation": explanation} ;
    }
}

walker generate_quiz {
    has topic: str;
    has difficulty: str = "medium";
    has num_questions: int = 5;

    def create_quiz(topic: str, difficulty: str, num_questions: int) -> list[QuizQuestion] by llm(
        method="Reason",
        temperature=0.8,
        incl_info=(
            "You are a quiz generator. Create multiple choice questions about the topic. ""Return ONLY a JSON array of questions with question, options (4 choices), and correct (index 0-3). ""Create exactly 5 questions at the given difficulty level."
        )
    );

    can generate with `root entry {
        quiz_data = self.create_quiz(
            topic=self.topic,
            difficulty=self.difficulty,
            num_questions=self.num_questions
        );
        report {
            "topic": self.topic,
            "difficulty": self.difficulty,
            "questions": quiz_data
        } ;
    }
}

walker chat_tutor {
    has message: str;
    has context: list[dict] = [];

    def respond_to_question(message: str, conversation_history: str) -> str by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are a friendly and knowledgeable AI tutor. Help students learn by: ""1. Answering questions clearly and accurately ""2. Encouraging critical thinking with follow-up questions ""3. Providing examples and analogies ""4. Being patient and supportive ""5. Breaking down complex topics into simpler parts. ""Previous conversation context is provided for continuity."
        )
    );

    can chat with `root entry {
        history_text = "\n".join(
            [f"{msg['role']}: {msg['content']}" for msg in self.context[-6:]]
        );
        response = self.respond_to_question(
            message=self.message, conversation_history=history_text
        );
        report {"message": self.message, "response": response} ;
    }
}

walker suggest_learning_path {
    has goal: str;
    has current_knowledge: str = "beginner";

    def create_learning_path(goal: str, knowledge_level: str) -> dict by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are a learning path advisor. Create a structured learning path to achieve the goal. ""Return a JSON object with path (array of steps with step number, title, description, duration), ""tips (array of strings), and resources (array of strings). ""Include 5-8 steps, practical tips, and resource suggestions."
        )
    );

    can suggest with `root entry {
        path_data = self.create_learning_path(
            goal=self.goal, knowledge_level=self.current_knowledge
        );
        report {"goal": self.goal, "learning_path": path_data} ;
    }
}


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


cl def app() -> any {
    theme = createTheme(
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

     [message, setMessage] = useState("");
     [conversationHistory, setConversationHistory] = useState([]);
     [loading, setLoading] = useState(false);
     messagesEndRef = useRef(null);
     [activeTab, setActiveTab] = useState("chat");

     [quizTopic, setQuizTopic] = useState("");
     [quizDifficulty, setQuizDifficulty] = useState("medium");
     [quizData, setQuizData] = useState(null);
     [quizLoading, setQuizLoading] = useState(false);
     [currentQuestion, setCurrentQuestion] = useState(0);
     [selectedAnswers, setSelectedAnswers] = useState([]);
     [showResults, setShowResults] = useState(false);

     navigationItems = [
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

         messageText = message.trim();
        setMessage("");
        setLoading(true);

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

         result = root spawn generate_quiz(
            topic=quizTopic.trim(),
            difficulty=quizDifficulty,
            num_questions=5
        );

        if result and result.reports and result.reports.length > 0 {
             quizResponse = result.reports[0];
            console.log("Quiz Response:", JSON.stringify(quizResponse));
            setQuizData(quizResponse);
        }
        setQuizLoading(false);
    }
    
    def handleAnswerSelect(questionIndex: int, answerIndex: int) -> None {
         newAnswers = selectedAnswers.slice();
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

     exampleQuestions = [
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
