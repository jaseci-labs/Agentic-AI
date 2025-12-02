import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
import { Box, Paper, TextField, Button, Typography, Chip, Stack, Avatar, Divider, Card, CardContent, CircularProgress } from "@mui/material";
import { Quiz, AutoAwesome, CheckCircle, Cancel, Refresh } from "@mui/icons-material";
function QuizTab(props) {
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
  return __jacJsx(null, {}, [__jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center", "sx": {"mb": 3}}, [__jacJsx(Quiz, {"sx": {"fontSize": 40, "color": "primary.main"}}, []), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h4", "sx": {"fontWeight": 700}}, ["Practice Quiz"]), __jacJsx(Typography, {"color": "text.secondary"}, ["Test your knowledge with AI-generated quizzes"])])])]), quizData === null ? __jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Typography, {"variant": "h6", "sx": {"fontWeight": 600}}, ["Generate a Quiz"]), __jacJsx(TextField, {"fullWidth": true, "label": "Quiz Topic", "placeholder": "e.g., Photosynthesis, World War II, Calculus...", "value": quizTopic, "onChange": e => {
    setQuizTopic(e.target.value);
  }, "disabled": quizLoading}, []), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "subtitle2", "sx": {"mb": 1, "fontWeight": 600}}, ["Difficulty Level"]), __jacJsx(Stack, {"direction": "row", "spacing": 1}, [__jacJsx(Chip, {"label": "Easy", "onClick": () => {
    setQuizDifficulty("easy");
  }, "color": quizDifficulty === "easy" ? "primary" : "default", "variant": quizDifficulty === "easy" ? "filled" : "outlined"}, []), __jacJsx(Chip, {"label": "Medium", "onClick": () => {
    setQuizDifficulty("medium");
  }, "color": quizDifficulty === "medium" ? "primary" : "default", "variant": quizDifficulty === "medium" ? "filled" : "outlined"}, []), __jacJsx(Chip, {"label": "Hard", "onClick": () => {
    setQuizDifficulty("hard");
  }, "color": quizDifficulty === "hard" ? "primary" : "default", "variant": quizDifficulty === "hard" ? "filled" : "outlined"}, [])])]), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "onClick": handleGenerateQuiz, "disabled": quizLoading || !quizTopic.trim(), "startIcon": quizLoading ? __jacJsx(CircularProgress, {"size": 20, "sx": {"color": "white"}}, []) : __jacJsx(AutoAwesome, {}, []), "sx": {"py": 1.5, "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, [quizLoading ? "Generating Quiz..." : "Generate Quiz"]), __jacJsx(Box, {"sx": {"mt": 4}}, [__jacJsx(Typography, {"variant": "subtitle2", "sx": {"mb": 1, "fontWeight": 600, "color": "text.secondary"}}, ["Suggested Topics"]), __jacJsx(Stack, {"direction": "row", "spacing": 1, "flexWrap": "wrap", "gap": 1}, [suggestedTopics.map(topic => {
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
  }), __jacJsx(Stack, {"direction": "row", "spacing": 2, "justifyContent": "space-between"}, [__jacJsx(Button, {"variant": "outlined", "disabled": currentQuestion === 0, "onClick": () => {
    setCurrentQuestion(currentQuestion - 1);
  }}, ["Previous"]), currentQuestion < quizData["questions"].length - 1 ? __jacJsx(Button, {"variant": "contained", "onClick": () => {
    setCurrentQuestion(currentQuestion + 1);
  }}, ["Next"]) : __jacJsx(Button, {"variant": "contained", "onClick": handleSubmitQuiz, "disabled": selectedAnswers.length !== quizData["questions"].length, "sx": {"background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, ["Submit Quiz"])])])]) : __jacJsx(Paper, {"sx": {"p": 4}}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Box, {"sx": {"textAlign": "center", "py": 3}}, [__jacJsx(Typography, {"variant": "h4", "sx": {"fontWeight": 700, "mb": 2}}, ["Quiz Results"]), __jacJsx(Typography, {"variant": "h2", "color": "primary.main", "sx": {"fontWeight": 800}}, [selectedAnswers.filter((ans, idx) => {
    return ans === quizData["questions"][idx]["correct"];
  }).length + "/" + quizData["questions"].length]), __jacJsx(Typography, {"color": "text.secondary", "sx": {"mt": 1}}, [Math.round(selectedAnswers.filter((ans, idx) => {
    return ans === quizData["questions"][idx]["correct"];
  }).length / quizData["questions"].length * 100) + "% Correct"])]), __jacJsx(Divider, {}, []), __jacJsx(Stack, {"spacing": 2}, [quizData["questions"].map((q, idx) => {
    let isCorrect = selectedAnswers[idx] === q["correct"];
    return __jacJsx(Card, {"key": idx, "sx": {"border": "1px solid", "borderColor": "divider"}}, [__jacJsx(CardContent, {}, [__jacJsx(Stack, {"spacing": 2}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "flex-start"}, [isCorrect ? __jacJsx(CheckCircle, {"sx": {"color": "success.main", "fontSize": 24}}, []) : __jacJsx(Cancel, {"sx": {"color": "error.main", "fontSize": 24}}, []), __jacJsx(Box, {"sx": {"flex": 1}}, [__jacJsx(Typography, {"variant": "subtitle1", "sx": {"fontWeight": 600}}, ["Question " + idx + 1]), __jacJsx(Typography, {"variant": "body2"}, [q["question"]])])]), __jacJsx(Box, {"sx": {"pl": 4}}, [__jacJsx(Typography, {"variant": "body2", "color": "text.secondary"}, ["Your answer: " + q["options"][selectedAnswers[idx]]]), !isCorrect ? __jacJsx(Typography, {"variant": "body2", "color": "success.main", "sx": {"mt": 0.5}}, ["Correct answer: " + q["options"][q["correct"]]]) : null])])])]);
  })]), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "startIcon": __jacJsx(Refresh, {}, []), "onClick": handleResetQuiz, "sx": {"background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)", "&:hover": {"background": "linear-gradient(135deg, #c4b5fd 0%, #f9a8d4 100%)"}}}, ["Create New Quiz"])])])]);
}
export { QuizTab };
