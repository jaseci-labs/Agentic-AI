import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState, useEffect, useRef } from "react";
import "./modern-styles.css";
import { Container, Box, Paper, TextField, Button, Typography, IconButton, Chip, Stack, Avatar, Divider, Fade, CircularProgress, ThemeProvider, createTheme, CssBaseline, Card, CardContent, Grow, Slide, Tooltip, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Badge } from "@mui/material";
import { Send, School, Psychology, AutoAwesome, Clear, Lightbulb, MenuBook, Science, Calculate, EmojiObjects, Quiz, Explore, Chat, TrendingUp, CheckCircle, Cancel, Refresh } from "@mui/icons-material";
const theme = createTheme({"palette": {"mode": "dark", "primary": {"main": "#a78bfa", "light": "#c4b5fd", "dark": "#8b5cf6"}, "secondary": {"main": "#f472b6", "light": "#f9a8d4", "dark": "#ec4899"}, "background": {"default": "#0f172a", "paper": "rgba(30, 41, 59, 0.7)"}, "text": {"primary": "#f8fafc", "secondary": "#cbd5e1"}}, "typography": {"fontFamily": "'Outfit', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif", "h3": {"fontWeight": 800, "letterSpacing": "-0.02em"}, "h5": {"fontWeight": 700}, "h6": {"fontWeight": 600}}, "shape": {"borderRadius": 0}, "components": {"MuiButton": {"styleOverrides": {"root": {"textTransform": "none", "fontWeight": 600, "borderRadius": "0px"}}}, "MuiPaper": {"styleOverrides": {"root": {"borderRadius": 0}}}, "MuiAvatar": {"styleOverrides": {"root": {"borderRadius": 0}}}, "MuiOutlinedInput": {"styleOverrides": {"root": {"borderRadius": 0}}}, "MuiChip": {"styleOverrides": {"root": {"borderRadius": 0}}}}});
function app() {
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
  let navigationItems = [{"id": "chat", "label": "AI Tutor Chat", "icon": __jacJsx(Chat, {}, [])}, {"id": "quiz", "label": "Practice Quiz", "icon": __jacJsx(Quiz, {}, [])}, {"id": "learn", "label": "Learn Topic", "icon": __jacJsx(MenuBook, {}, [])}, {"id": "path", "label": "Learning Path", "icon": __jacJsx(TrendingUp, {}, [])}];
  useEffect(() => {
    console.log("Active Tab:", activeTab);
    console.log("Quiz Data:", JSON.stringify(quizData));
  }, [activeTab, quizData]);
  async function handleChat() {
    if (!message.trim()) {
      return;
    }
    let messageText = message.trim();
    setMessage("");
    setLoading(true);
    let newHistory = conversationHistory.concat([{"role": "user", "content": messageText, "timestamp": Date.now()}]);
    setConversationHistory(newHistory);
    let result = await __jacSpawn("chat_tutor", "", {"message": messageText, "context": []});
    if (result && result.reports && result.reports.length > 0) {
      let aiResponse = result.reports[0]["response"];
      let finalHistory = newHistory.concat([{"role": "assistant", "content": aiResponse, "timestamp": Date.now()}]);
      setConversationHistory(finalHistory);
    }
    setLoading(false);
  }
  function handleKeyPress(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleChat();
    }
  }
  function clearChat() {
    setConversationHistory([]);
    setMessage("");
  }
  async function handleGenerateQuiz() {
    if (!quizTopic.trim()) {
      return;
    }
    setQuizLoading(true);
    setQuizData(null);
    setCurrentQuestion(0);
    setSelectedAnswers([]);
    setShowResults(false);
    let result = await __jacSpawn("generate_quiz", "", {"topic": quizTopic.trim(), "difficulty": quizDifficulty, "num_questions": 5});
    if (result && result.reports && result.reports.length > 0) {
      let quizResponse = result.reports[0];
      console.log("Quiz Response:", JSON.stringify(quizResponse));
      setQuizData(quizResponse);
    }
    setQuizLoading(false);
  }
  function handleAnswerSelect(questionIndex, answerIndex) {
    let newAnswers = selectedAnswers.slice();
    newAnswers[questionIndex] = answerIndex;
    setSelectedAnswers(newAnswers);
  }
  function handleSubmitQuiz() {
    setShowResults(true);
  }
  function handleResetQuiz() {
    setQuizData(null);
    setQuizTopic("");
    setCurrentQuestion(0);
    setSelectedAnswers([]);
    setShowResults(false);
  }
  let exampleQuestions = ["Explain photosynthesis in simple terms", "Help me understand quantum mechanics", "What's the difference between mitosis and meiosis?", "How do I solve quadratic equations?"];
  return __jacJsx(ThemeProvider, {"theme": theme}, [__jacJsx(CssBaseline, {}, []), __jacJsx("div", {"className": "animated-bg"}, [__jacJsx("div", {"className": "particle particle-1"}, []), __jacJsx("div", {"className": "particle particle-2"}, []), __jacJsx("div", {"className": "particle particle-3"}, []), __jacJsx("div", {"className": "particle particle-4"}, [])]), __jacJsx(Box, {"sx": {"minHeight": "100vh", "display": "flex", "position": "relative"}}, [__jacJsx(Drawer, {"variant": "permanent", "sx": {"width": 280, "flexShrink": 0, "& .MuiDrawer-paper": {"width": 280, "boxSizing": "border-box", "background": "rgba(15, 23, 42, 0.95)", "backdropFilter": "blur(20px)", "borderRight": "1px solid rgba(167, 139, 250, 0.2)", "pt": 3}}}, [__jacJsx(Box, {"sx": {"px": 3, "mb": 4}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center"}, [__jacJsx(Avatar, {"sx": {"width": 48, "height": 48, "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)"}}, [__jacJsx(School, {"sx": {"fontSize": 28}}, [])]), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h6", "sx": {"fontWeight": 700, "lineHeight": 1.2}}, ["Smart Learning"]), __jacJsx(Typography, {"variant": "caption", "color": "text.secondary"}, ["Companion"])])])]), __jacJsx(Divider, {"sx": {"borderColor": "rgba(167, 139, 250, 0.2)", "mb": 2}}, []), __jacJsx(List, {"sx": {"px": 2}}, [navigationItems.map(item => {
    let isActive = activeTab === item["id"];
    return __jacJsx(ListItem, {"key": item["id"], "disablePadding": true, "sx": {"mb": 1}}, [__jacJsx(ListItemButton, {"onClick": () => {
      setActiveTab(item["id"]);
    }, "sx": {"borderRadius": 2, "py": 1.5, "background": isActive ? "linear-gradient(135deg, rgba(167, 139, 250, 0.2) 0%, rgba(244, 114, 182, 0.2) 100%)" : "transparent", "border": isActive ? "1px solid rgba(167, 139, 250, 0.4)" : "1px solid transparent", "&:hover": {"background": "rgba(167, 139, 250, 0.1)", "border": "1px solid rgba(167, 139, 250, 0.3)"}}}, [__jacJsx(ListItemIcon, {"sx": {"color": isActive ? "primary.main" : "text.secondary", "minWidth": 40}}, [item["icon"]]), __jacJsx(ListItemText, {"primary": item["label"], "primaryTypographyProps": {"fontWeight": isActive ? 600 : 500, "color": isActive ? "primary.light" : "text.primary"}}, [])])]);
  })]), __jacJsx(Box, {"sx": {"flexGrow": 1}}, []), __jacJsx(Box, {"sx": {"p": 3, "pt": 2}}, [__jacJsx(Paper, {"sx": {"p": 2, "background": "rgba(167, 139, 250, 0.1)", "border": "1px solid rgba(167, 139, 250, 0.2)"}}, [__jacJsx(Stack, {"spacing": 1}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Lightbulb, {"sx": {"fontSize": 20, "color": "primary.main"}}, []), __jacJsx(Typography, {"variant": "caption", "sx": {"fontWeight": 600}}, ["Quick Tip"])]), __jacJsx(Typography, {"variant": "caption", "color": "text.secondary", "sx": {"lineHeight": 1.4}}, ["Ask follow-up questions to dive deeper into topics!"])])])])]), __jacJsx(Box, {"component": "main", "sx": {"flexGrow": 1, "py": 3, "px": 3, "width": "calc(100vw - 280px)"}}, [__jacJsx(Stack, {"spacing": 3, "sx": {"maxWidth": 1400, "mx": "auto"}}, [activeTab === "chat" ? __jacJsx(null, {}, [__jacJsx(Grow, {"in": true, "timeout": 800}, [__jacJsx(Paper, {"className": "glass-card glow", "elevation": 0, "sx": {"p": 4, "borderRadius": 0}}, [__jacJsx(Stack, {"direction": "row", "alignItems": "center", "spacing": 2, "justifyContent": "center"}, [__jacJsx(Avatar, {"sx": {"width": 64, "height": 64, "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "boxShadow": "0 8px 32px rgba(167, 139, 250, 0.4)"}}, [__jacJsx(School, {"sx": {"fontSize": 36}}, [])]), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h3", "sx": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)", "WebkitBackgroundClip": "text", "WebkitTextFillColor": "transparent", "backgroundClip": "text", "textShadow": "0 0 40px rgba(167, 139, 250, 0.3)"}}, ["Smart Learning Companion"]), __jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center", "sx": {"mt": 1}}, [__jacJsx(Psychology, {"sx": {"fontSize": 20, "color": "secondary.main"}}, []), __jacJsx(Typography, {"variant": "subtitle1", "color": "text.secondary", "sx": {"fontWeight": 500}}, ["Your AI-Powered Study Assistant"])])])])])]), __jacJsx(Grow, {"in": true, "timeout": 1000}, [__jacJsx(Paper, {"className": "glass-card", "elevation": 0, "sx": {"height": "calc(100vh - 300px)", "minHeight": "600px", "display": "flex", "flexDirection": "column", "overflow": "hidden", "borderRadius": 0}}, [__jacJsx(Box, {"sx": {"p": 3, "borderBottom": "1px solid rgba(167, 139, 250, 0.2)", "background": "linear-gradient(90deg, rgba(167, 139, 250, 0.1) 0%, rgba(244, 114, 182, 0.1) 100%)", "backdropFilter": "blur(10px)"}}, [__jacJsx(Stack, {"direction": "row", "justifyContent": "space-between", "alignItems": "center"}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Psychology, {"color": "primary"}, []), __jacJsx(Typography, {"variant": "h5", "color": "primary"}, ["AI Tutor Chat"])]), conversationHistory.length > 0 ? __jacJsx(Button, {"variant": "outlined", "color": "error", "startIcon": __jacJsx(Clear, {}, []), "onClick": clearChat, "sx": {"borderRadius": 0}}, ["Clear Chat"]) : null])]), __jacJsx(Box, {"sx": {"flex": 1, "overflowY": "auto", "p": 3, "background": "transparent"}}, [conversationHistory.length > 0 ? __jacJsx(Stack, {"spacing": 2}, [conversationHistory.map(msg => {
    let isUser = msg["role"] === "user";
    return __jacJsx(Box, {"sx": {"display": "flex", "justifyContent": isUser ? "flex-end" : "flex-start", "mb": 2}, "key": msg["timestamp"]}, [__jacJsx(Fade, {"in": true, "timeout": 300}, [__jacJsx(Card, {"className": isUser ? "message-slide-right" : "message-slide-left", "sx": {"maxWidth": "75%", "background": isUser ? "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)" : "rgba(30, 41, 59, 0.8)", "color": "white", "backdropFilter": "blur(20px)", "border": isUser ? "1px solid rgba(167, 139, 250, 0.3)" : "1px solid rgba(203, 213, 225, 0.2)", "boxShadow": isUser ? "0 8px 32px rgba(167, 139, 250, 0.3)" : "0 8px 32px rgba(0, 0, 0, 0.2)", "borderRadius": "20px", "borderBottomRightRadius": isUser ? "4px" : "20px", "borderBottomLeftRadius": isUser ? "20px" : "4px"}}, [__jacJsx(CardContent, {"sx": {"p": 2, "&:last-child": {"pb": 2}}}, [__jacJsx(Stack, {"spacing": 1}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Avatar, {"sx": {"width": 32, "height": 32, "bgcolor": isUser ? "rgba(255,255,255,0.2)" : "rgba(167, 139, 250, 0.3)", "border": "2px solid rgba(255,255,255,0.3)"}}, [isUser ? "You" : __jacJsx(AutoAwesome, {"sx": {"fontSize": 18}}, [])]), __jacJsx(Typography, {"variant": "caption", "sx": {"fontWeight": 700, "textTransform": "uppercase", "letterSpacing": "0.05em", "opacity": 0.9}}, [isUser ? "You" : "AI Tutor"])]), __jacJsx(Typography, {"variant": "body1", "sx": {"whiteSpace": "pre-wrap", "wordWrap": "break-word", "lineHeight": 1.6}}, [msg["content"]])])])])])]);
  }), loading ? __jacJsx(Fade, {"in": true, "timeout": 300}, [__jacJsx(Box, {"sx": {"display": "flex", "justifyContent": "flex-start"}}, [__jacJsx(Card, {"sx": {"maxWidth": "75%", "background": "#ffffff", "boxShadow": 3, "borderRadius": "20px"}}, [__jacJsx(CardContent, {"sx": {"p": 2, "&:last-child": {"pb": 2}}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center"}, [__jacJsx(CircularProgress, {"size": 24}, []), __jacJsx(Typography, {"variant": "body1", "color": "text.secondary"}, ["AI is thinking..."])])])])])]) : null, __jacJsx("div", {"ref": messagesEndRef}, [])]) : __jacJsx(Box, {"sx": {"display": "flex", "flexDirection": "column", "alignItems": "center", "justifyContent": "center", "height": "100%", "textAlign": "center"}}, [__jacJsx(Fade, {"in": true, "timeout": 500}, [__jacJsx(Box, {}, [__jacJsx(Psychology, {"className": "pulse", "sx": {"fontSize": 120, "color": "primary.main", "opacity": 0.3, "mb": 3, "filter": "drop-shadow(0 0 30px rgba(167, 139, 250, 0.3))"}}, []), __jacJsx(Typography, {"variant": "h4", "gutterBottom": true, "sx": {"fontWeight": 700, "color": "primary.main"}}, ["Start a Conversation"]), __jacJsx(Typography, {"variant": "body1", "color": "text.secondary", "sx": {"mb": 4, "maxWidth": 500}}, ["Ask me anything about your studies! I'm here to help you learn and understand complex topics."]), __jacJsx(Box, {"sx": {"maxWidth": 600, "mx": "auto"}}, [__jacJsx(Typography, {"variant": "h6", "sx": {"mb": 2, "color": "primary.main", "fontWeight": 600}}, ["Try asking:"]), __jacJsx(Stack, {"spacing": 1.5}, [exampleQuestions.map(question => {
    return __jacJsx(Chip, {"key": question, "label": question, "icon": __jacJsx(AutoAwesome, {}, []), "onClick": () => {
      setMessage(question);
    }, "sx": {"py": 2.5, "px": 1, "fontSize": "0.95rem", "cursor": "pointer", "transition": "all 0.2s", "&:hover": {"transform": "translateX(8px)", "boxShadow": 2}}, "color": "primary", "variant": "outlined"}, []);
  })])])])])])]), __jacJsx(Divider, {"sx": {"borderColor": "rgba(167, 139, 250, 0.2)"}}, []), __jacJsx(Box, {"sx": {"p": 3, "background": "rgba(15, 23, 42, 0.5)", "backdropFilter": "blur(10px)"}}, [__jacJsx(Stack, {"spacing": 2}, [__jacJsx(TextField, {"fullWidth": true, "multiline": true, "rows": 3, "value": message, "onChange": e => {
    setMessage(e.target.value);
  }, "onKeyPress": handleKeyPress, "placeholder": "Type your question here... (Shift+Enter for new line, Enter to send)", "disabled": loading, "variant": "outlined", "sx": {"& .MuiOutlinedInput-root": {"borderRadius": 0, "fontSize": "1rem", "&:hover fieldset": {"borderColor": "primary.main", "borderWidth": 2}, "&.Mui-focused fieldset": {"borderWidth": 2}}}}, []), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "onClick": handleChat, "disabled": loading || !message.trim(), "startIcon": loading ? __jacJsx(CircularProgress, {"size": 20, "sx": {"color": "white"}}, []) : __jacJsx(Send, {}, []), "sx": {"py": 1.5, "fontSize": "1.1rem", "fontWeight": 600, "borderRadius": 0, "textTransform": "none", "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "boxShadow": "0 8px 32px rgba(167, 139, 250, 0.4)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)", "transform": "translateY(-2px)", "boxShadow": "0 12px 40px rgba(167, 139, 250, 0.5)"}, "&:active": {"transform": "translateY(0)"}, "transition": "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)"}}, [loading ? "Thinking..." : "Ask Question"])])])])]), __jacJsx(Typography, {"variant": "body2", "align": "center", "sx": {"color": "rgba(248, 250, 252, 0.7)", "fontWeight": 500, "textShadow": "0 0 20px rgba(167, 139, 250, 0.3)"}}, ["\u26a1 Powered by GPT-4o \u2022 Built with Jaclang & Material-UI"])]) : activeTab === "quiz" ? __jacJsx(null, {}, [__jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center", "sx": {"mb": 3}}, [__jacJsx(Quiz, {"sx": {"fontSize": 40, "color": "primary.main"}}, []), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h4", "sx": {"fontWeight": 700}}, ["Practice Quiz"]), __jacJsx(Typography, {"color": "text.secondary"}, ["Test your knowledge with AI-generated quizzes"])])])]), quizData === null ? __jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Typography, {"variant": "h6", "sx": {"fontWeight": 600}}, ["Generate a Quiz"]), __jacJsx(TextField, {"fullWidth": true, "label": "Quiz Topic", "placeholder": "e.g., Photosynthesis, World War II, Calculus...", "value": quizTopic, "onChange": e => {
    setQuizTopic(e.target.value);
  }, "disabled": quizLoading}, []), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "subtitle2", "sx": {"mb": 1, "fontWeight": 600}}, ["Difficulty Level"]), __jacJsx(Stack, {"direction": "row", "spacing": 1}, [__jacJsx(Chip, {"label": "Easy", "onClick": () => {
    setQuizDifficulty("easy");
  }, "color": quizDifficulty === "easy" ? "primary" : "default", "variant": quizDifficulty === "easy" ? "filled" : "outlined"}, []), __jacJsx(Chip, {"label": "Medium", "onClick": () => {
    setQuizDifficulty("medium");
  }, "color": quizDifficulty === "medium" ? "primary" : "default", "variant": quizDifficulty === "medium" ? "filled" : "outlined"}, []), __jacJsx(Chip, {"label": "Hard", "onClick": () => {
    setQuizDifficulty("hard");
  }, "color": quizDifficulty === "hard" ? "primary" : "default", "variant": quizDifficulty === "hard" ? "filled" : "outlined"}, [])])]), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "onClick": handleGenerateQuiz, "disabled": quizLoading || !quizTopic.trim(), "startIcon": quizLoading ? __jacJsx(CircularProgress, {"size": 20, "sx": {"color": "white"}}, []) : __jacJsx(AutoAwesome, {}, []), "sx": {"py": 1.5, "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, [quizLoading ? "Generating Quiz..." : "Generate Quiz"]), __jacJsx(Box, {"sx": {"mt": 4}}, [__jacJsx(Typography, {"variant": "subtitle2", "sx": {"mb": 2, "fontWeight": 600}}, ["Popular Topics:"]), __jacJsx(Stack, {"direction": "row", "spacing": 1, "flexWrap": "wrap", "useFlexGap": true}, [["Python Programming", "World History", "Biology", "Mathematics", "Chemistry"].map(topic => {
    return __jacJsx(Chip, {"key": topic, "label": topic, "onClick": () => {
      setQuizTopic(topic);
    }, "variant": "outlined", "sx": {"cursor": "pointer"}}, []);
  })])])])]) : showResults === false ? __jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Box, {}, [__jacJsx(Stack, {"direction": "row", "justifyContent": "space-between", "alignItems": "center", "sx": {"mb": 2}}, [__jacJsx(Typography, {"variant": "h6", "sx": {"fontWeight": 600}}, [quizData["topic"]]), __jacJsx(Chip, {"label": "Quiz", "color": "primary", "size": "small"}, [])]), __jacJsx(Typography, {"variant": "body2", "color": "text.secondary"}, ["Question " + currentQuestion + 1 + " of " + quizData["questions"].length])]), __jacJsx(Divider, {}, []), quizData["questions"].map((q, idx) => {
    return idx === currentQuestion ? __jacJsx(Box, {"key": idx}, [__jacJsx(Typography, {"variant": "h6", "sx": {"mb": 3}}, [q["question"]]), __jacJsx(Stack, {"spacing": 2}, [q["options"].map((option, optIdx) => {
      let isSelected = selectedAnswers[idx] === optIdx;
      return __jacJsx(Paper, {"key": optIdx, "onClick": () => {
        handleAnswerSelect(idx, optIdx);
      }, "sx": {"p": 2, "cursor": "pointer", "border": isSelected ? "2px solid" : "1px solid", "borderColor": isSelected ? "primary.main" : "divider", "background": isSelected ? "rgba(167, 139, 250, 0.1)" : "transparent", "&:hover": {"borderColor": "primary.main", "background": "rgba(167, 139, 250, 0.05)"}}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center"}, [__jacJsx(Avatar, {"sx": {"width": 32, "height": 32, "background": isSelected ? "primary.main" : "transparent", "border": "2px solid", "borderColor": isSelected ? "primary.main" : "text.secondary"}}, [__jacJsx(Typography, {"variant": "body2", "sx": {"fontWeight": 600}}, [["A", "B", "C", "D"][optIdx]])]), __jacJsx(Typography, {}, [option])])]);
    })])]) : null;
  }), __jacJsx(Stack, {"direction": "row", "spacing": 2, "justifyContent": "space-between"}, [__jacJsx(Button, {"variant": "outlined", "onClick": () => {
    setCurrentQuestion(currentQuestion - 1);
  }, "disabled": currentQuestion === 0}, ["Previous"]), currentQuestion < quizData["questions"].length - 1 ? __jacJsx(Button, {"variant": "contained", "onClick": () => {
    setCurrentQuestion(currentQuestion + 1);
  }, "disabled": selectedAnswers[currentQuestion] === undefined}, ["Next"]) : __jacJsx(Button, {"variant": "contained", "onClick": handleSubmitQuiz, "disabled": selectedAnswers.length !== quizData["questions"].length, "sx": {"background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, ["Submit Quiz"])])])]) : __jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Box, {"sx": {"textAlign": "center", "py": 3}}, [__jacJsx(Typography, {"variant": "h4", "sx": {"fontWeight": 700, "mb": 2}}, ["Quiz Results"]), __jacJsx(Typography, {"variant": "h2", "color": "primary.main", "sx": {"fontWeight": 800}}, [selectedAnswers.filter((ans, idx) => {
    return ans === quizData["questions"][idx]["correct"];
  }).length + "/" + quizData["questions"].length]), __jacJsx(Typography, {"color": "text.secondary", "sx": {"mt": 1}}, [Math.round(selectedAnswers.filter((ans, idx) => {
    return ans === quizData["questions"][idx]["correct"];
  }).length / quizData["questions"].length * 100) + "% Correct"])]), __jacJsx(Divider, {}, []), __jacJsx(Stack, {"spacing": 2}, [quizData["questions"].map((q, idx) => {
    let isCorrect = selectedAnswers[idx] === q["correct"];
    return __jacJsx(Card, {"key": idx, "sx": {"border": "1px solid", "borderColor": "divider"}}, [__jacJsx(CardContent, {}, [__jacJsx(Stack, {"spacing": 2}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "flex-start"}, [isCorrect ? __jacJsx(CheckCircle, {"sx": {"color": "success.main", "fontSize": 24}}, []) : __jacJsx(Cancel, {"sx": {"color": "error.main", "fontSize": 24}}, []), __jacJsx(Box, {"sx": {"flex": 1}}, [__jacJsx(Typography, {"variant": "subtitle1", "sx": {"fontWeight": 600}}, ["Question " + idx + 1]), __jacJsx(Typography, {"variant": "body2"}, [q["question"]])])]), __jacJsx(Box, {"sx": {"pl": 4}}, [__jacJsx(Typography, {"variant": "body2", "color": "text.secondary"}, ["Your answer: " + q["options"][selectedAnswers[idx]]]), !isCorrect ? __jacJsx(Typography, {"variant": "body2", "color": "success.main", "sx": {"mt": 0.5}}, ["Correct answer: " + q["options"][q["correct"]]]) : null])])])]);
  })]), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "startIcon": __jacJsx(Refresh, {}, []), "onClick": handleResetQuiz, "sx": {"background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, ["Create New Quiz"])])])]) : activeTab === "learn" ? __jacJsx(Paper, {"sx": {"p": 4, "textAlign": "center"}}, [__jacJsx(MenuBook, {"sx": {"fontSize": 80, "color": "primary.main", "mb": 2}}, []), __jacJsx(Typography, {"variant": "h4", "gutterBottom": true}, ["Learn Topic"]), __jacJsx(Typography, {"color": "text.secondary"}, ["Deep dive into any topic with structured lessons and explanations."])]) : __jacJsx(Paper, {"sx": {"p": 4, "textAlign": "center"}}, [__jacJsx(TrendingUp, {"sx": {"fontSize": 80, "color": "primary.main", "mb": 2}}, []), __jacJsx(Typography, {"variant": "h4", "gutterBottom": true}, ["Learning Path"]), __jacJsx(Typography, {"color": "text.secondary"}, ["Get a personalized learning path tailored to your goals."])])])])])]);
}
export { app };
