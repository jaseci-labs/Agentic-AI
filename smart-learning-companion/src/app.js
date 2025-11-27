import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
import "./styles.css";
function app() {
  let [message, setMessage] = useState("");
  let [response, setResponse] = useState(null);
  let [loading, setLoading] = useState(false);
  async function handleChat() {
    if (!message.trim()) {
      return;
    }
    setLoading(true);
    let result = await __jacSpawn("chat_tutor", "", {"message": message, "context": []});
    setResponse(result.reports[0].response);
    setLoading(false);
  }
  return __jacJsx("div", {"className": "app-container"}, [__jacJsx("div", {"className": "header"}, [__jacJsx("h1", {"className": "title"}, ["🎓 Smart Learning Companion"]), __jacJsx("p", {"className": "subtitle"}, ["Your AI-powered personal tutor"])]), __jacJsx("div", {"className": "content-area"}, [__jacJsx("div", {"className": "chat-container"}, [__jacJsx("h2", {}, ["💬 Ask Your AI Tutor"]), __jacJsx("textarea", {"value": message, "onChange": e => {
    setMessage(e.target.value);
  }, "placeholder": "Ask me anything...", "className": "message-input"}, []), __jacJsx("button", {"onClick": handleChat, "disabled": loading, "className": "send-button"}, [loading ? "\u23f3 Thinking..." : "Ask \ud83d\ude80"]), response ? __jacJsx("div", {"className": "response-section"}, [__jacJsx("h3", {}, ["🤖 Response"]), __jacJsx("div", {"className": "response-content"}, [response])]) : null])])]);
}
export { app };
