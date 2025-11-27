import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState, useEffect, useRef } from "react";
import { Container, Box, Paper, TextField, Button, Typography, IconButton, Chip, Stack, Avatar, Divider, Fade, CircularProgress, ThemeProvider, createTheme, CssBaseline, Card, CardContent } from "@mui/material";
import { Send, School, Psychology, AutoAwesome, Clear } from "@mui/icons-material";
const theme = createTheme({"palette": {"mode": "light", "primary": {"main": "#6366f1", "light": "#818cf8", "dark": "#4f46e5"}, "secondary": {"main": "#8b5cf6", "light": "#a78bfa", "dark": "#7c3aed"}, "background": {"default": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)", "paper": "#ffffff"}}, "typography": {"fontFamily": "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif", "h3": {"fontWeight": 800, "letterSpacing": "-0.02em"}, "h5": {"fontWeight": 700}, "h6": {"fontWeight": 600}}, "shape": {"borderRadius": 16}, "shadows": ["none", "0px 2px 4px rgba(0,0,0,0.05)", "0px 4px 8px rgba(0,0,0,0.08)", "0px 8px 16px rgba(0,0,0,0.1)", "0px 12px 24px rgba(0,0,0,0.12)", "0px 16px 32px rgba(0,0,0,0.15)"]});
function app() {
  let [message, setMessage] = useState("");
  let [conversationHistory, setConversationHistory] = useState([]);
  let [loading, setLoading] = useState(false);
  let messagesEndRef = useRef(null);
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
  let exampleQuestions = ["Explain photosynthesis in simple terms", "Help me understand quantum mechanics", "What's the difference between mitosis and meiosis?", "How do I solve quadratic equations?"];
  return __jacJsx(ThemeProvider, {"theme": theme}, [__jacJsx(CssBaseline, {}, []), __jacJsx(Box, {"sx": {"minHeight": "100vh", "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)", "py": 3}}, [__jacJsx(Container, {"maxWidth": "lg"}, [__jacJsx(Stack, {"spacing": 3}, [__jacJsx(Fade, {"in": true, "timeout": 600}, [__jacJsx(Paper, {"elevation": 4, "sx": {"p": 4, "background": "rgba(255, 255, 255, 0.98)", "backdropFilter": "blur(20px)", "borderRadius": 4}}, [__jacJsx(Stack, {"direction": "row", "alignItems": "center", "spacing": 2, "justifyContent": "center"}, [__jacJsx(School, {"sx": {"fontSize": 48, "color": "primary.main"}}, []), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h3", "sx": {"background": "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)", "WebkitBackgroundClip": "text", "WebkitTextFillColor": "transparent", "backgroundClip": "text"}}, ["Smart Learning Companion"]), __jacJsx(Typography, {"variant": "subtitle1", "color": "text.secondary", "sx": {"fontWeight": 500}}, ["Your AI-Powered Study Assistant"])])])])]), __jacJsx(Fade, {"in": true, "timeout": 800}, [__jacJsx(Paper, {"elevation": 4, "sx": {"height": "calc(100vh - 300px)", "minHeight": "600px", "display": "flex", "flexDirection": "column", "background": "rgba(255, 255, 255, 0.98)", "backdropFilter": "blur(20px)", "borderRadius": 4, "overflow": "hidden"}}, [__jacJsx(Box, {"sx": {"p": 3, "borderBottom": 1, "borderColor": "divider", "background": "linear-gradient(90deg, rgba(99, 102, 241, 0.05) 0%, rgba(139, 92, 246, 0.05) 100%)"}}, [__jacJsx(Stack, {"direction": "row", "justifyContent": "space-between", "alignItems": "center"}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Psychology, {"color": "primary"}, []), __jacJsx(Typography, {"variant": "h5", "color": "primary"}, ["AI Tutor Chat"])]), conversationHistory.length > 0 ? __jacJsx(Button, {"variant": "outlined", "color": "error", "startIcon": __jacJsx(Clear, {}, []), "onClick": clearChat, "sx": {"borderRadius": 2}}, ["Clear Chat"]) : null])]), __jacJsx(Box, {"sx": {"flex": 1, "overflowY": "auto", "p": 3, "background": "linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%)"}}, [conversationHistory.length > 0 ? __jacJsx(Stack, {"spacing": 2}, [conversationHistory.map(msg => {
    let isUser = msg["role"] === "user";
    return __jacJsx(Box, {"sx": {"display": "flex", "justifyContent": isUser ? "flex-end" : "flex-start", "mb": 2}, "key": msg["timestamp"]}, [__jacJsx(Fade, {"in": true, "timeout": 300}, [__jacJsx(Card, {"sx": {"maxWidth": "75%", "background": isUser ? "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)" : "#ffffff", "color": isUser ? "white" : "text.primary", "boxShadow": 3, "borderRadius": 3, "borderBottomRightRadius": isUser ? 1 : 3, "borderBottomLeftRadius": isUser ? 3 : 1}}, [__jacJsx(CardContent, {}, [__jacJsx(Stack, {"spacing": 1}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Avatar, {"sx": {"width": 32, "height": 32, "bgcolor": isUser ? "rgba(255,255,255,0.2)" : "primary.main"}}, [isUser ? "You" : __jacJsx(AutoAwesome, {"sx": {"fontSize": 18}}, [])]), __jacJsx(Typography, {"variant": "caption", "sx": {"fontWeight": 700, "textTransform": "uppercase", "letterSpacing": "0.05em", "opacity": 0.9}}, [isUser ? "You" : "AI Tutor"])]), __jacJsx(Typography, {"variant": "body1", "sx": {"whiteSpace": "pre-wrap", "wordWrap": "break-word", "lineHeight": 1.6}}, [msg["content"]])])])])])]);
  }), loading ? __jacJsx(Fade, {"in": true, "timeout": 300}, [__jacJsx(Box, {"sx": {"display": "flex", "justifyContent": "flex-start"}}, [__jacJsx(Card, {"sx": {"maxWidth": "75%", "background": "#ffffff", "boxShadow": 3, "borderRadius": 3}}, [__jacJsx(CardContent, {}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center"}, [__jacJsx(CircularProgress, {"size": 24}, []), __jacJsx(Typography, {"variant": "body1", "color": "text.secondary"}, ["AI is thinking..."])])])])])]) : null, __jacJsx("div", {"ref": messagesEndRef}, [])]) : __jacJsx(Box, {"sx": {"display": "flex", "flexDirection": "column", "alignItems": "center", "justifyContent": "center", "height": "100%", "textAlign": "center"}}, [__jacJsx(Fade, {"in": true, "timeout": 500}, [__jacJsx(Box, {}, [__jacJsx(Psychology, {"sx": {"fontSize": 120, "color": "primary.main", "opacity": 0.2, "mb": 3}}, []), __jacJsx(Typography, {"variant": "h4", "gutterBottom": true, "sx": {"fontWeight": 700, "color": "primary.main"}}, ["Start a Conversation"]), __jacJsx(Typography, {"variant": "body1", "color": "text.secondary", "sx": {"mb": 4, "maxWidth": 500}}, ["Ask me anything about your studies! I'm here to help you learn and understand complex topics."]), __jacJsx(Box, {"sx": {"maxWidth": 600, "mx": "auto"}}, [__jacJsx(Typography, {"variant": "h6", "sx": {"mb": 2, "color": "primary.main", "fontWeight": 600}}, ["Try asking:"]), __jacJsx(Stack, {"spacing": 1.5}, [exampleQuestions.map(question => {
    return __jacJsx(Chip, {"key": question, "label": question, "icon": __jacJsx(AutoAwesome, {}, []), "onClick": () => {
      setMessage(question);
    }, "sx": {"py": 2.5, "px": 1, "fontSize": "0.95rem", "cursor": "pointer", "transition": "all 0.2s", "&:hover": {"transform": "translateX(8px)", "boxShadow": 2}}, "color": "primary", "variant": "outlined"}, []);
  })])])])])])]), __jacJsx(Divider, {}, []), __jacJsx(Box, {"sx": {"p": 3, "background": "#ffffff"}}, [__jacJsx(Stack, {"spacing": 2}, [__jacJsx(TextField, {"fullWidth": true, "multiline": true, "rows": 3, "value": message, "onChange": e => {
    setMessage(e.target.value);
  }, "onKeyPress": handleKeyPress, "placeholder": "Type your question here... (Shift+Enter for new line, Enter to send)", "disabled": loading, "variant": "outlined", "sx": {"& .MuiOutlinedInput-root": {"borderRadius": 3, "fontSize": "1rem", "&:hover fieldset": {"borderColor": "primary.main", "borderWidth": 2}, "&.Mui-focused fieldset": {"borderWidth": 2}}}}, []), __jacJsx(Button, {"fullWidth": true, "variant": "contained", "size": "large", "onClick": handleChat, "disabled": loading || !message.trim(), "startIcon": loading ? __jacJsx(CircularProgress, {"size": 20, "sx": {"color": "white"}}, []) : __jacJsx(Send, {}, []), "sx": {"py": 1.5, "fontSize": "1.1rem", "fontWeight": 600, "borderRadius": 3, "textTransform": "none", "background": "linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)", "&:hover": {"background": "linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)", "transform": "translateY(-2px)", "boxShadow": 4}, "&:active": {"transform": "translateY(0)"}, "transition": "all 0.2s"}}, [loading ? "Thinking..." : "Ask Question"])])])])]), __jacJsx(Typography, {"variant": "body2", "align": "center", "sx": {"color": "rgba(255, 255, 255, 0.9)", "fontWeight": 500}}, ["Powered by GPT-4o \u2022 Built with Jaclang & Material-UI"])])])])]);
}
export { app };
