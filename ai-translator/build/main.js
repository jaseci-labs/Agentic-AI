import React from "react";
import { createRoot } from "react-dom/client";
import { app as App } from "./app.js";
var root = createRoot(document.getElementById("root"));
root.render(/*#__PURE__*/React.createElement(App, null));