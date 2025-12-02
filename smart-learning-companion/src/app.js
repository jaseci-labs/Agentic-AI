import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState, useEffect, useRef } from "react";
import "./modern-styles.css";
import { Box, Stack, ThemeProvider, CssBaseline, Paper, Typography, createTheme } from "@mui/material";
import { Chat, Quiz, MenuBook, TrendingUp } from "@mui/icons-material";
import { Sidebar } from "./components/Sidebar.js";
import { ChatTab } from "./components/ChatTab.js";
import { QuizTab } from "./components/QuizTab.js";
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
  return __jacJsx(ThemeProvider, {"theme": theme}, [__jacJsx(CssBaseline, {}, []), __jacJsx("div", {"className": "animated-bg"}, [__jacJsx("div", {"className": "particle particle-1"}, []), __jacJsx("div", {"className": "particle particle-2"}, []), __jacJsx("div", {"className": "particle particle-3"}, []), __jacJsx("div", {"className": "particle particle-4"}, [])]), __jacJsx(Box, {"sx": {"minHeight": "100vh", "display": "flex", "position": "relative"}}, [__jacJsx(Sidebar, {"activeTab": activeTab, "setActiveTab": setActiveTab, "navigationItems": navigationItems}, []), __jacJsx(Box, {"component": "main", "sx": {"flexGrow": 1, "py": 3, "px": 3, "width": "calc(100vw - 280px)"}}, [__jacJsx(Stack, {"spacing": 3, "sx": {"maxWidth": 1400, "mx": "auto"}}, [activeTab === "chat" ? __jacJsx(ChatTab, {"conversationHistory": conversationHistory, "message": message, "setMessage": setMessage, "loading": loading, "handleChat": handleChat, "handleKeyPress": handleKeyPress, "clearChat": clearChat, "messagesEndRef": messagesEndRef, "exampleQuestions": exampleQuestions}, []) : activeTab === "quiz" ? __jacJsx(QuizTab, {"quizTopic": quizTopic, "setQuizTopic": setQuizTopic, "quizDifficulty": quizDifficulty, "setQuizDifficulty": setQuizDifficulty, "quizData": quizData, "quizLoading": quizLoading, "currentQuestion": currentQuestion, "setCurrentQuestion": setCurrentQuestion, "selectedAnswers": selectedAnswers, "showResults": showResults, "handleGenerateQuiz": handleGenerateQuiz, "handleAnswerSelect": handleAnswerSelect, "handleSubmitQuiz": handleSubmitQuiz, "handleResetQuiz": handleResetQuiz}, []) : __jacJsx(Paper, {"sx": {"p": 4, "textAlign": "center"}}, [__jacJsx(MenuBook, {"sx": {"fontSize": 80, "color": "primary.main", "mb": 2}}, []), __jacJsx(Typography, {"variant": "h4", "gutterBottom": true}, [activeTab === "learn" ? "Learn Topic" : "Learning Path"]), __jacJsx(Typography, {"color": "text.secondary"}, ["Coming soon..."])])])])])]);
}
export { app };
