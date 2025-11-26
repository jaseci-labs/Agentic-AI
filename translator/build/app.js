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
import "./styles.css";
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
            return __jacSpawn("translate_text", "", {
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
    "className": "translator-container"
  }, [__jacJsx("div", {
    "className": "translator-card"
  }, [__jacJsx("div", {
    "className": "translator-header"
  }, [__jacJsx("div", {
    "className": "translator-icon"
  }, ["🌍"]), __jacJsx("h1", {
    "className": "translator-title"
  }, ["AI Translator"]), __jacJsx("p", {
    "className": "translator-subtitle"
  }, ["Powered by GPT-4o - Translate to any language instantly"])]), __jacJsx("div", {
    "className": "textarea-wrapper"
  }, [__jacJsx("textarea", {
    "value": inputText,
    "onChange": function onChange(e) {
      setInputText(e.target.value);
    },
    "placeholder": "✨ Enter your text here to translate...",
    "className": "translator-textarea"
  }, [])]), __jacJsx("div", {
    "className": "translator-controls"
  }, [__jacJsx("div", {
    "className": "language-selector-wrapper"
  }, [__jacJsx("label", {
    "className": "language-label"
  }, ["🎯 Target Language"]), __jacJsx("select", {
    "value": targetLang,
    "onChange": function onChange(e) {
      setTargetLang(e.target.value);
    },
    "className": "language-select"
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
    "className": "button-wrapper"
  }, [__jacJsx("button", {
    "onClick": handleTranslate,
    "disabled": loading,
    "className": "translate-button"
  }, [loading ? "\u23F3 Translating..." : "\u2728 Translate"])])]), translation ? __jacJsx("div", {
    "className": "result-wrapper"
  }, [__jacJsx("div", {
    "className": "result-content"
  }, [__jacJsx("div", {
    "className": "result-header"
  }, [__jacJsx("span", {
    "className": "result-icon"
  }, ["✅"]), __jacJsx("p", {
    "className": "result-title"
  }, ["Translation to ", translation.language])]), __jacJsx("div", {
    "className": "translation-box"
  }, [__jacJsx("p", {
    "className": "translation-text"
  }, [translation.translation])]), __jacJsx("div", {
    "className": "original-text-box"
  }, [__jacJsx("p", {
    "className": "original-text"
  }, [__jacJsx("strong", {}, ["Original:"]), " ", translation.original])])])]) : null, translation ? null : __jacJsx("div", {
    "className": "empty-state"
  }, [__jacJsx("div", {
    "className": "empty-state-icon"
  }, ["💬"]), __jacJsx("p", {
    "className": "empty-state-text"
  }, ["Your translation will appear here"])])]), __jacJsx("div", {
    "className": "translator-footer"
  }, [__jacJsx("p", {
    "className": "footer-text"
  }, ["Made with ❤️ using Jaseci Stack"])])]);
}
export { app };