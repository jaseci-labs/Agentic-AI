import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState } from "react";
import "./styles.css";
function app() {
  let [inputText, setInputText] = useState("");
  let [targetLang, setTargetLang] = useState("Spanish");
  let [translation, setTranslation] = useState(null);
  let [loading, setLoading] = useState(false);
  async function handleTranslate() {
    if (!inputText.trim()) {
      return;
    }
    setLoading(true);
    let result = await __jacSpawn("translate_text", "", {"phrase": inputText, "language": targetLang});
    setTranslation(result.reports[0]);
    setLoading(false);
  }
  return __jacJsx("div", {"className": "translator-container"}, [__jacJsx("div", {"className": "translator-card"}, [__jacJsx("div", {"className": "translator-header"}, [__jacJsx("div", {"className": "translator-icon"}, ["🌍"]), __jacJsx("h1", {"className": "translator-title"}, ["AI Translator"]), __jacJsx("p", {"className": "translator-subtitle"}, ["Powered by GPT-4o - Translate to any language instantly"])]), __jacJsx("div", {"className": "textarea-wrapper"}, [__jacJsx("textarea", {"value": inputText, "onChange": e => {
    setInputText(e.target.value);
  }, "placeholder": "✨ Enter your text here to translate...", "className": "translator-textarea"}, [])]), __jacJsx("div", {"className": "translator-controls"}, [__jacJsx("div", {"className": "language-selector-wrapper"}, [__jacJsx("label", {"className": "language-label"}, ["🎯 Target Language"]), __jacJsx("select", {"value": targetLang, "onChange": e => {
    setTargetLang(e.target.value);
  }, "className": "language-select"}, [__jacJsx("option", {"value": "Spanish"}, ["🇪🇸 Spanish"]), __jacJsx("option", {"value": "French"}, ["🇫🇷 French"]), __jacJsx("option", {"value": "German"}, ["🇩🇪 German"]), __jacJsx("option", {"value": "Welsh"}, ["🏴󠁧󠁢󠁷󠁬󠁳󠁿 Welsh"]), __jacJsx("option", {"value": "Japanese"}, ["🇯🇵 Japanese"]), __jacJsx("option", {"value": "Chinese"}, ["🇨🇳 Chinese"]), __jacJsx("option", {"value": "Italian"}, ["🇮🇹 Italian"]), __jacJsx("option", {"value": "Portuguese"}, ["🇵🇹 Portuguese"])])]), __jacJsx("div", {"className": "button-wrapper"}, [__jacJsx("button", {"onClick": handleTranslate, "disabled": loading, "className": "translate-button"}, [loading ? "\u23f3 Translating..." : "\u2728 Translate"])])]), translation ? __jacJsx("div", {"className": "result-wrapper"}, [__jacJsx("div", {"className": "result-content"}, [__jacJsx("div", {"className": "result-header"}, [__jacJsx("span", {"className": "result-icon"}, ["✅"]), __jacJsx("p", {"className": "result-title"}, ["Translation to ", translation.language])]), __jacJsx("div", {"className": "translation-box"}, [__jacJsx("p", {"className": "translation-text"}, [translation.translation])]), __jacJsx("div", {"className": "original-text-box"}, [__jacJsx("p", {"className": "original-text"}, [__jacJsx("strong", {}, ["Original:"]), " ", translation.original])])])]) : null, translation ? null : __jacJsx("div", {"className": "empty-state"}, [__jacJsx("div", {"className": "empty-state-icon"}, ["💬"]), __jacJsx("p", {"className": "empty-state-text"}, ["Your translation will appear here"])])]), __jacJsx("div", {"className": "translator-footer"}, [__jacJsx("p", {"className": "footer-text"}, ["Made with ❤️ using Jaseci Stack"])])]);
}
export { app };
