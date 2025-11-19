function _regenerator() { /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/babel/babel/blob/main/packages/babel-helpers/LICENSE */ var e, t, r = "function" == typeof Symbol ? Symbol : {}, n = r.iterator || "@@iterator", o = r.toStringTag || "@@toStringTag"; function i(r, n, o, i) { var c = n && n.prototype instanceof Generator ? n : Generator, u = Object.create(c.prototype); return _regeneratorDefine2(u, "_invoke", function (r, n, o) { var i, c, u, f = 0, p = o || [], y = !1, G = { p: 0, n: 0, v: e, a: d, f: d.bind(e, 4), d: function d(t, r) { return i = t, c = 0, u = e, G.n = r, a; } }; function d(r, n) { for (c = r, u = n, t = 0; !y && f && !o && t < p.length; t++) { var o, i = p[t], d = G.p, l = i[2]; r > 3 ? (o = l === n) && (u = i[(c = i[4]) ? 5 : (c = 3, 3)], i[4] = i[5] = e) : i[0] <= d && ((o = r < 2 && d < i[1]) ? (c = 0, G.v = n, G.n = i[1]) : d < l && (o = r < 3 || i[0] > n || n > l) && (i[4] = r, i[5] = n, G.n = l, c = 0)); } if (o || r > 1) return a; throw y = !0, n; } return function (o, p, l) { if (f > 1) throw TypeError("Generator is already running"); for (y && 1 === p && d(p, l), c = p, u = l; (t = c < 2 ? e : u) || !y;) { i || (c ? c < 3 ? (c > 1 && (G.n = -1), d(c, u)) : G.n = u : G.v = u); try { if (f = 2, i) { if (c || (o = "next"), t = i[o]) { if (!(t = t.call(i, u))) throw TypeError("iterator result is not an object"); if (!t.done) return t; u = t.value, c < 2 && (c = 0); } else 1 === c && (t = i["return"]) && t.call(i), c < 2 && (u = TypeError("The iterator does not provide a '" + o + "' method"), c = 1); i = e; } else if ((t = (y = G.n < 0) ? u : r.call(n, G)) !== a) break; } catch (t) { i = e, c = 1, u = t; } finally { f = 1; } } return { value: t, done: y }; }; }(r, o, i), !0), u; } var a = {}; function Generator() {} function GeneratorFunction() {} function GeneratorFunctionPrototype() {} t = Object.getPrototypeOf; var c = [][n] ? t(t([][n]())) : (_regeneratorDefine2(t = {}, n, function () { return this; }), t), u = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(c); function f(e) { return Object.setPrototypeOf ? Object.setPrototypeOf(e, GeneratorFunctionPrototype) : (e.__proto__ = GeneratorFunctionPrototype, _regeneratorDefine2(e, o, "GeneratorFunction")), e.prototype = Object.create(u), e; } return GeneratorFunction.prototype = GeneratorFunctionPrototype, _regeneratorDefine2(u, "constructor", GeneratorFunctionPrototype), _regeneratorDefine2(GeneratorFunctionPrototype, "constructor", GeneratorFunction), GeneratorFunction.displayName = "GeneratorFunction", _regeneratorDefine2(GeneratorFunctionPrototype, o, "GeneratorFunction"), _regeneratorDefine2(u), _regeneratorDefine2(u, o, "Generator"), _regeneratorDefine2(u, n, function () { return this; }), _regeneratorDefine2(u, "toString", function () { return "[object Generator]"; }), (_regenerator = function _regenerator() { return { w: i, m: f }; })(); }
function _regeneratorDefine2(e, r, n, t) { var i = Object.defineProperty; try { i({}, "", {}); } catch (e) { i = 0; } _regeneratorDefine2 = function _regeneratorDefine(e, r, n, t) { function o(r, n) { _regeneratorDefine2(e, r, function (e) { return this._invoke(r, n, e); }); } r ? i ? i(e, r, { value: n, enumerable: !t, configurable: !t, writable: !t }) : e[r] = n : (o("next", 0), o("throw", 1), o("return", 2)); }, _regeneratorDefine2(e, r, n, t); }
function asyncGeneratorStep(n, t, e, r, o, a, c) { try { var i = n[a](c), u = i.value; } catch (n) { return void e(n); } i.done ? t(u) : Promise.resolve(u).then(r, o); }
function _asyncToGenerator(n) { return function () { var t = this, e = arguments; return new Promise(function (r, o) { var a = n.apply(t, e); function _next(n) { asyncGeneratorStep(a, r, o, _next, _throw, "next", n); } function _throw(n) { asyncGeneratorStep(a, r, o, _next, _throw, "throw", n); } _next(void 0); }); }; }
function _slicedToArray(r, e) { return _arrayWithHoles(r) || _iterableToArrayLimit(r, e) || _unsupportedIterableToArray(r, e) || _nonIterableRest(); }
function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function _iterableToArrayLimit(r, l) { var t = null == r ? null : "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (null != t) { var e, n, i, u, a = [], f = !0, o = !1; try { if (i = (t = t.call(r)).next, 0 === l) { if (Object(t) !== t) return; f = !1; } else for (; !(f = (e = i.call(t)).done) && (a.push(e.value), a.length !== l); f = !0); } catch (r) { o = !0, n = r; } finally { try { if (!f && null != t["return"] && (u = t["return"](), Object(u) !== u)) return; } finally { if (o) throw n; } } return a; } }
function _arrayWithHoles(r) { if (Array.isArray(r)) return r; }
import { __jacJsx, __jacSpawn } from "@jac-client/utils";
import { useState } from "react";
import { jacSpawn } from "@jac-client/utils";
function app() {
  var _useState = useState(""),
    _useState2 = _slicedToArray(_useState, 2),
    inputText = _useState2[0],
    setInputText = _useState2[1];
  var _useState3 = useState("Spanish"),
    _useState4 = _slicedToArray(_useState3, 2),
    targetLang = _useState4[0],
    setTargetLang = _useState4[1];
  var _useState5 = useState(null),
    _useState6 = _slicedToArray(_useState5, 2),
    translation = _useState6[0],
    setTranslation = _useState6[1];
  var _useState7 = useState(false),
    _useState8 = _slicedToArray(_useState7, 2),
    loading = _useState8[0],
    setLoading = _useState8[1];
  function handleTranslate() {
    return _handleTranslate.apply(this, arguments);
  }
  function _handleTranslate() {
    _handleTranslate = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee() {
      var result;
      return _regenerator().w(function (_context) {
        while (1) switch (_context.n) {
          case 0:
            if (inputText.trim()) {
              _context.n = 1;
              break;
            }
            return _context.a(2);
          case 1:
            setLoading(true);
            _context.n = 2;
            return jacSpawn("translate_text", "", {
              "phrase": inputText,
              "language": targetLang
            });
          case 2:
            result = _context.v;
            setTranslation(result.reports[0]);
            setLoading(false);
          case 3:
            return _context.a(2);
        }
      }, _callee);
    }));
    return _handleTranslate.apply(this, arguments);
  }
  return __jacJsx("div", {
    "style": {
      "minHeight": "100vh",
      "background": "linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #4facfe 75%, #00f2fe 100%)",
      "padding": "40px 20px",
      "fontFamily": "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
    }
  }, [__jacJsx("div", {
    "style": {
      "maxWidth": "700px",
      "margin": "0 auto",
      "background": "rgba(255, 255, 255, 0.95)",
      "borderRadius": "24px",
      "padding": "40px",
      "boxShadow": "0 20px 60px rgba(0, 0, 0, 0.3), 0 0 100px rgba(102, 126, 234, 0.5)"
    }
  }, [__jacJsx("div", {
    "style": {
      "textAlign": "center",
      "marginBottom": "32px"
    }
  }, [__jacJsx("div", {
    "style": {
      "fontSize": "64px",
      "marginBottom": "16px",
      "animation": "bounce 2s infinite"
    }
  }, ["🌍"]), __jacJsx("h1", {
    "style": {
      "fontSize": "42px",
      "fontWeight": "800",
      "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
      "WebkitBackgroundClip": "text",
      "WebkitTextFillColor": "transparent",
      "backgroundClip": "text",
      "marginBottom": "8px"
    }
  }, ["AI Translator"]), __jacJsx("p", {
    "style": {
      "color": "#6b7280",
      "fontSize": "16px",
      "fontWeight": "500"
    }
  }, ["Powered by GPT-4o - Translate to any language instantly"])]), __jacJsx("div", {
    "style": {
      "background": "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
      "padding": "3px",
      "borderRadius": "16px",
      "marginBottom": "24px"
    }
  }, [__jacJsx("textarea", {
    "value": inputText,
    "onChange": function onChange(e) {
      setInputText(e.target.value);
    },
    "placeholder": "✨ Enter your text here to translate...",
    "style": {
      "width": "100%",
      "padding": "20px",
      "fontSize": "18px",
      "border": "none",
      "borderRadius": "14px",
      "fontFamily": "inherit",
      "resize": "vertical",
      "minHeight": "120px",
      "background": "#ffffff",
      "outline": "none"
    }
  }, [])]), __jacJsx("div", {
    "style": {
      "display": "flex",
      "gap": "16px",
      "marginBottom": "24px",
      "flexWrap": "wrap"
    }
  }, [__jacJsx("div", {
    "style": {
      "flex": "1",
      "minWidth": "200px"
    }
  }, [__jacJsx("label", {
    "style": {
      "display": "block",
      "fontSize": "14px",
      "fontWeight": "600",
      "color": "#374151",
      "marginBottom": "8px"
    }
  }, ["🎯 Target Language"]), __jacJsx("select", {
    "value": targetLang,
    "onChange": function onChange(e) {
      setTargetLang(e.target.value);
    },
    "style": {
      "width": "100%",
      "padding": "14px",
      "fontSize": "16px",
      "border": "2px solid #e5e7eb",
      "borderRadius": "12px",
      "background": "#ffffff",
      "fontWeight": "500",
      "cursor": "pointer",
      "outline": "none"
    }
  }, [__jacJsx("option", {
    "value": "Spanish"
  }, ["🇪🇸 Spanish"]), __jacJsx("option", {
    "value": "French"
  }, ["🇫🇷 French"]), __jacJsx("option", {
    "value": "German"
  }, ["🇩🇪 German"]), __jacJsx("option", {
    "value": "Welsh"
  }, ["🏴󠁧󠁢󠁷󠁬󠁳󠁿 Welsh"]), __jacJsx("option", {
    "value": "Japanese"
  }, ["🇯🇵 Japanese"]), __jacJsx("option", {
    "value": "Chinese"
  }, ["🇨🇳 Chinese"]), __jacJsx("option", {
    "value": "Italian"
  }, ["🇮🇹 Italian"]), __jacJsx("option", {
    "value": "Portuguese"
  }, ["🇵🇹 Portuguese"])])]), __jacJsx("div", {
    "style": {
      "display": "flex",
      "alignItems": "flex-end"
    }
  }, [__jacJsx("button", {
    "onClick": handleTranslate,
    "disabled": loading,
    "style": {
      "padding": "14px 32px",
      "background": loading ? "linear-gradient(135deg, #9ca3af 0%, #6b7280 100%)" : "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
      "color": "#ffffff",
      "border": "none",
      "borderRadius": "12px",
      "fontSize": "18px",
      "fontWeight": "700",
      "cursor": loading ? "not-allowed" : "pointer",
      "boxShadow": loading ? "none" : "0 4px 15px rgba(102, 126, 234, 0.4)",
      "transition": "all 0.3s ease",
      "minWidth": "160px"
    }
  }, [loading ? "\u23F3 Translating..." : "\u2728 Translate"])])]), translation ? __jacJsx("div", {
    "style": {
      "background": "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
      "padding": "3px",
      "borderRadius": "16px",
      "marginTop": "32px",
      "animation": "fadeIn 0.5s ease-in"
    }
  }, [__jacJsx("div", {
    "style": {
      "background": "#ffffff",
      "padding": "28px",
      "borderRadius": "14px"
    }
  }, [__jacJsx("div", {
    "style": {
      "display": "flex",
      "alignItems": "center",
      "gap": "8px",
      "marginBottom": "16px"
    }
  }, [__jacJsx("span", {
    "style": {
      "fontSize": "24px"
    }
  }, ["✅"]), __jacJsx("p", {
    "style": {
      "color": "#059669",
      "fontSize": "16px",
      "fontWeight": "700",
      "margin": "0"
    }
  }, ["Translation to ", translation.language])]), __jacJsx("div", {
    "style": {
      "background": "linear-gradient(135deg, #fef3c7 0%, #fde68a 100%)",
      "padding": "20px",
      "borderRadius": "12px",
      "border": "2px solid #fbbf24"
    }
  }, [__jacJsx("p", {
    "style": {
      "fontSize": "20px",
      "color": "#1f2937",
      "fontWeight": "600",
      "margin": "0",
      "lineHeight": "1.6"
    }
  }, [translation.translation])]), __jacJsx("div", {
    "style": {
      "marginTop": "16px",
      "padding": "12px",
      "background": "#f3f4f6",
      "borderRadius": "8px"
    }
  }, [__jacJsx("p", {
    "style": {
      "fontSize": "14px",
      "color": "#6b7280",
      "margin": "0",
      "fontStyle": "italic"
    }
  }, [__jacJsx("strong", {}, ["Original:"]), " ", translation.original])])])]) : null, translation ? null : __jacJsx("div", {
    "style": {
      "textAlign": "center",
      "padding": "40px",
      "color": "#9ca3af",
      "fontSize": "16px"
    }
  }, [__jacJsx("div", {
    "style": {
      "fontSize": "48px",
      "marginBottom": "16px"
    }
  }, ["💬"]), __jacJsx("p", {
    "style": {
      "margin": "0",
      "fontWeight": "500"
    }
  }, ["Your translation will appear here"])])]), __jacJsx("div", {
    "style": {
      "textAlign": "center",
      "marginTop": "32px",
      "color": "#ffffff",
      "fontSize": "14px",
      "fontWeight": "500",
      "textShadow": "0 2px 4px rgba(0, 0, 0, 0.2)"
    }
  }, [__jacJsx("p", {
    "style": {
      "margin": "0"
    }
  }, ["Made with ❤️ using Jac & GPT-4o"])])]);
}
export { app };