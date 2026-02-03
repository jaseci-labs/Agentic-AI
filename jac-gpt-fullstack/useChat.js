import { useState, useEffect, useRef } from "react";
import { jacIsLoggedIn } from "@jac/runtime";
import { createSession, getSession, sendMessage, getSuggestions, generateSessionId } from "../services/jacService.js";
import { getUsernameFromToken } from "../hooks/useAuth.js";
function useChat() {
  const [messages, setMessages] = useState([]);
  const [sessionId, setSessionId] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [messageCount, setMessageCount] = useState(0);
  const [maxFreeMessages, setMaxFreeMessages] = useState(30);
  const [chatSessions, setChatSessions] = useState([]);
  const [docSuggestions, setDocSuggestions] = useState([]);
  const [lastUserMessage, setLastUserMessage] = useState("");
  let messagesEndRef = useRef(null);
  let firstChunkRef = useRef(false);
  let prevMessageCountRef = useRef(0);
  let isAuthenticated = jacIsLoggedIn();
  useEffect(() => {
    if (!isAuthenticated) {
      let savedCount = localStorage.getItem("jac_gpt_message_count");
      if (savedCount) {
        setMessageCount((parseInt(savedCount, 10) || 0));
      }
    }
    let savedSessions = localStorage.getItem("jac_gpt_sessions");
    if (savedSessions) {
      try {
        setChatSessions(JSON.parse(savedSessions));
      } catch (e) {
        console.error("Error loading sessions:", e);
        setChatSessions([]);
      }
    }
    initSession();
  }, []);
  useEffect(() => {
    if (!isAuthenticated) {
      localStorage.setItem("jac_gpt_message_count", String(messageCount));
    }
  }, [messageCount]);
  useEffect(() => {
    let currentCount = messages.length;
    if ((currentCount > prevMessageCountRef.current)) {
      if (messagesEndRef.current) {
        messagesEndRef.current.scrollIntoView({"behavior": "smooth"});
      }
    }
    prevMessageCountRef.current = currentCount;
  }, [messages]);
  async function initSession() {
    let newSessionId = generateSessionId();
    let result = await createSession(newSessionId);
    if (result.success) {
      setSessionId(result.session_id);
    } else {
      setSessionId(newSessionId);
    }
  }
  function canSendMessage() {
    if (isAuthenticated) {
      return true;
    }
    return (messageCount < maxFreeMessages);
  }
  async function handleSendMessage(content) {
    if ((!content.trim() || isLoading)) {
      return;
    }
    if (!canSendMessage()) {
      return;
    }
    setIsLoading(true);
    console.log("isLoading set to True at the beginning");
    let userMessage = {"id": ("msg_" + String(Date.now())), "content": content.trim(), "isUser": true, "timestamp": Date()};
    setMessages(prev => {
      return prev.concat([userMessage]);
    });
    setLastUserMessage(content.trim());
    if (!isAuthenticated) {
      setMessageCount(prev => {
        return (prev + 1);
      });
    }
    try {
      let userEmail = "";
      if (isAuthenticated) {
        userEmail = getUsernameFromToken();
      }
      let botMessageId = (((("msg_" + String(Date.now())) + "_") + String(Math.random())) + "_bot");
      let botMessage = {"id": botMessageId, "content": "", "isUser": false, "timestamp": Date()};
      setMessages(prev => {
        return prev.concat([botMessage]);
      });
      let userMessageContent = content.trim();
      firstChunkRef.current = false;
      function onChunk(chunk) {
        if (!firstChunkRef.current) {
          firstChunkRef.current = true;
          setIsLoading(false);
          console.log("Received first chunk, stopping loading state.");
        }
        setMessages(prev => {
          let updatedMessages = [];
          for (const m of prev) {
            if ((m.id === botMessageId)) {
              let newContent = (m.content + chunk);
              let updatedMessage = {"id": m.id, "content": newContent, "isUser": m.isUser, "timestamp": m.timestamp};
              updatedMessages.push(updatedMessage);
            } else {
              updatedMessages.push(m);
            }
          }
          return updatedMessages;
        });
      }
      let result = await sendMessage(content.trim(), sessionId, userEmail, onChunk);
      if (result.success) {
        let isFirstMessage = (messages.filter(m => {
          return m.isUser;
        }).length === 1);
        updateSessionTitle(content.trim(), isFirstMessage);
      } else {
        console.error("Error in sendMessage:", result.error);
        setMessages(prev => {
          return prev.map(m => {
            if ((m.id === botMessageId)) {
              return {"id": m.id, "content": "Sorry, I encountered an error. Please try again.", "isUser": m.isUser, "timestamp": m.timestamp};
            }
            return m;
          });
        });
      }
    } catch (e) {
      console.error("Send message error:", e);
      let errorMessage = {"id": ("msg_" + String(Date.now())), "content": "Sorry, something went wrong. Please try again.", "isUser": false, "timestamp": Date()};
      setMessages(prev => {
        return prev.concat([errorMessage]);
      });
      setIsLoading(false);
    }
  }
  async function fetchDocSuggestions(message) {
    try {
      let result = await getSuggestions(message, []);
      if ((result.success && result.suggestions)) {
        setDocSuggestions(result.suggestions);
      }
    } catch (e) {
      console.error("Error fetching suggestions:", e);
    }
  }
  function updateSessionTitle(firstMessage, isFirstMessage) {
    if (isFirstMessage) {
      let title = firstMessage.substring(0, 50);
      if ((firstMessage.length > 50)) {
        title = (title + "...");
      }
      let existingIndex = chatSessions.findIndex(s => {
        return (s.id === sessionId);
      });
      if ((existingIndex >= 0)) {
        setChatSessions(prev => {
          let updatedSessions = prev.map((s, idx) => {
            if ((idx === existingIndex)) {
              return {"id": s.id, "title": title, "createdAt": s.createdAt};
            }
            return s;
          });
          localStorage.setItem("jac_gpt_sessions", JSON.stringify(updatedSessions));
          return updatedSessions;
        });
      } else {
        let newSession = {"id": sessionId, "title": title, "createdAt": String(Date.now())};
        setChatSessions(prev => {
          let updated = [newSession].concat(prev);
          localStorage.setItem("jac_gpt_sessions", JSON.stringify(updated));
          return updated;
        });
      }
    }
  }
  async function handleNewChat() {
    setMessages([]);
    setDocSuggestions([]);
    setLastUserMessage("");
    await initSession();
  }
  async function handleLoadSession(loadSessionId) {
    setIsLoading(true);
    try {
      let result = await getSession(loadSessionId);
      if ((result.success && result.found)) {
        setSessionId(loadSessionId);
        let newMessages = [];
        for (const historyItem of result.chat_history) {
          let msg = {"id": ((("msg_" + String(Date.now())) + "_") + String(Math.random())), "content": historyItem.content, "isUser": (historyItem.role === "user"), "timestamp": Date()};
          newMessages.push(msg);
        }
        setMessages(prev => {
          return newMessages;
        });
      }
    } catch (e) {
      console.error("Error loading session:", e);
    } finally {
      setIsLoading(false);
    }
  }
  function handleDeleteSession(deleteSessionId) {
    setChatSessions(prev => {
      let updated = prev.filter(s => {
        return (s.id !== deleteSessionId);
      });
      localStorage.setItem("jac_gpt_sessions", JSON.stringify(updated));
      return updated;
    });
    if ((deleteSessionId === sessionId)) {
      handleNewChat();
    }
  }
  function handleStopGeneration() {
    setIsLoading(false);
  }
  return {"messages": messages, "sessionId": sessionId, "isLoading": isLoading, "messageCount": messageCount, "maxFreeMessages": maxFreeMessages, "chatSessions": chatSessions, "docSuggestions": docSuggestions, "lastUserMessage": lastUserMessage, "messagesEndRef": messagesEndRef, "canSendMessage": canSendMessage, "handleSendMessage": handleSendMessage, "handleNewChat": handleNewChat, "handleLoadSession": handleLoadSession, "handleDeleteSession": handleDeleteSession, "handleStopGeneration": handleStopGeneration};
}
export {useChat};
