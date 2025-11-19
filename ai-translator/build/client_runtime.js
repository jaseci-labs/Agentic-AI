function _regenerator() { /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/babel/babel/blob/main/packages/babel-helpers/LICENSE */ var e, t, r = "function" == typeof Symbol ? Symbol : {}, n = r.iterator || "@@iterator", o = r.toStringTag || "@@toStringTag"; function i(r, n, o, i) { var c = n && n.prototype instanceof Generator ? n : Generator, u = Object.create(c.prototype); return _regeneratorDefine2(u, "_invoke", function (r, n, o) { var i, c, u, f = 0, p = o || [], y = !1, G = { p: 0, n: 0, v: e, a: d, f: d.bind(e, 4), d: function d(t, r) { return i = t, c = 0, u = e, G.n = r, a; } }; function d(r, n) { for (c = r, u = n, t = 0; !y && f && !o && t < p.length; t++) { var o, i = p[t], d = G.p, l = i[2]; r > 3 ? (o = l === n) && (u = i[(c = i[4]) ? 5 : (c = 3, 3)], i[4] = i[5] = e) : i[0] <= d && ((o = r < 2 && d < i[1]) ? (c = 0, G.v = n, G.n = i[1]) : d < l && (o = r < 3 || i[0] > n || n > l) && (i[4] = r, i[5] = n, G.n = l, c = 0)); } if (o || r > 1) return a; throw y = !0, n; } return function (o, p, l) { if (f > 1) throw TypeError("Generator is already running"); for (y && 1 === p && d(p, l), c = p, u = l; (t = c < 2 ? e : u) || !y;) { i || (c ? c < 3 ? (c > 1 && (G.n = -1), d(c, u)) : G.n = u : G.v = u); try { if (f = 2, i) { if (c || (o = "next"), t = i[o]) { if (!(t = t.call(i, u))) throw TypeError("iterator result is not an object"); if (!t.done) return t; u = t.value, c < 2 && (c = 0); } else 1 === c && (t = i["return"]) && t.call(i), c < 2 && (u = TypeError("The iterator does not provide a '" + o + "' method"), c = 1); i = e; } else if ((t = (y = G.n < 0) ? u : r.call(n, G)) !== a) break; } catch (t) { i = e, c = 1, u = t; } finally { f = 1; } } return { value: t, done: y }; }; }(r, o, i), !0), u; } var a = {}; function Generator() {} function GeneratorFunction() {} function GeneratorFunctionPrototype() {} t = Object.getPrototypeOf; var c = [][n] ? t(t([][n]())) : (_regeneratorDefine2(t = {}, n, function () { return this; }), t), u = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(c); function f(e) { return Object.setPrototypeOf ? Object.setPrototypeOf(e, GeneratorFunctionPrototype) : (e.__proto__ = GeneratorFunctionPrototype, _regeneratorDefine2(e, o, "GeneratorFunction")), e.prototype = Object.create(u), e; } return GeneratorFunction.prototype = GeneratorFunctionPrototype, _regeneratorDefine2(u, "constructor", GeneratorFunctionPrototype), _regeneratorDefine2(GeneratorFunctionPrototype, "constructor", GeneratorFunction), GeneratorFunction.displayName = "GeneratorFunction", _regeneratorDefine2(GeneratorFunctionPrototype, o, "GeneratorFunction"), _regeneratorDefine2(u), _regeneratorDefine2(u, o, "Generator"), _regeneratorDefine2(u, n, function () { return this; }), _regeneratorDefine2(u, "toString", function () { return "[object Generator]"; }), (_regenerator = function _regenerator() { return { w: i, m: f }; })(); }
function _regeneratorDefine2(e, r, n, t) { var i = Object.defineProperty; try { i({}, "", {}); } catch (e) { i = 0; } _regeneratorDefine2 = function _regeneratorDefine(e, r, n, t) { function o(r, n) { _regeneratorDefine2(e, r, function (e) { return this._invoke(r, n, e); }); } r ? i ? i(e, r, { value: n, enumerable: !t, configurable: !t, writable: !t }) : e[r] = n : (o("next", 0), o("throw", 1), o("return", 2)); }, _regeneratorDefine2(e, r, n, t); }
function asyncGeneratorStep(n, t, e, r, o, a, c) { try { var i = n[a](c), u = i.value; } catch (n) { return void e(n); } i.done ? t(u) : Promise.resolve(u).then(r, o); }
function _asyncToGenerator(n) { return function () { var t = this, e = arguments; return new Promise(function (r, o) { var a = n.apply(t, e); function _next(n) { asyncGeneratorStep(a, r, o, _next, _throw, "next", n); } function _throw(n) { asyncGeneratorStep(a, r, o, _next, _throw, "throw", n); } _next(void 0); }); }; }
function _createForOfIteratorHelper(r, e) { var t = "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (!t) { if (Array.isArray(r) || (t = _unsupportedIterableToArray(r)) || e && r && "number" == typeof r.length) { t && (r = t); var _n = 0, F = function F() {}; return { s: F, n: function n() { return _n >= r.length ? { done: !0 } : { done: !1, value: r[_n++] }; }, e: function e(r) { throw r; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var o, a = !0, u = !1; return { s: function s() { t = t.call(r); }, n: function n() { var r = t.next(); return a = r.done, r; }, e: function e(r) { u = !0, o = r; }, f: function f() { try { a || null == t["return"] || t["return"](); } finally { if (u) throw o; } } }; }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { HashRouter as ReactRouterHashRouter, Routes as ReactRouterRoutes, Route as ReactRouterRoute, Link as ReactRouterLink, Navigate as ReactRouterNavigate, useNavigate as reactRouterUseNavigate, useLocation as reactRouterUseLocation, useParams as reactRouterUseParams } from "react-router-dom";
function __jacJsx(tag, props, children) {
  if (tag === null) {
    tag = React.Fragment;
  }
  var childrenArray = [];
  if (children !== null) {
    if (Array.isArray(children)) {
      childrenArray = children;
    } else {
      childrenArray = [children];
    }
  }
  var reactChildren = [];
  var _iterator = _createForOfIteratorHelper(childrenArray),
    _step;
  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var _child = _step.value;
      if (_child !== null) {
        reactChildren.push(_child);
      }
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }
  if (reactChildren.length > 0) {
    var args = [tag, props];
    var _iterator2 = _createForOfIteratorHelper(reactChildren),
      _step2;
    try {
      for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
        var child = _step2.value;
        args.push(child);
      }
    } catch (err) {
      _iterator2.e(err);
    } finally {
      _iterator2.f();
    }
    return React.createElement.apply(React, args);
  } else {
    return /*#__PURE__*/React.createElement(tag, props);
  }
}
var Router = ReactRouterHashRouter;
var Routes = ReactRouterRoutes;
var Route = ReactRouterRoute;
var Link = ReactRouterLink;
var Navigate = ReactRouterNavigate;
var useNavigate = reactRouterUseNavigate;
var useLocation = reactRouterUseLocation;
var useParams = reactRouterUseParams;
function useRouter() {
  var navigate = reactRouterUseNavigate();
  var location = reactRouterUseLocation();
  var params = reactRouterUseParams();
  return {
    "navigate": navigate,
    "location": location,
    "params": params,
    "pathname": location.pathname,
    "search": location.search,
    "hash": location.hash
  };
}
function navigate(path) {
  window.location.hash = "#" + path;
}
function __jacSpawn(_x, _x2, _x3) {
  return _jacSpawn.apply(this, arguments);
}
function _jacSpawn() {
  _jacSpawn = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee(left, right, fields) {
    var token, url, response, error_text;
    return _regenerator().w(function (_context) {
      while (1) switch (_context.n) {
        case 0:
          token = __getLocalStorage("jac_token");
          url = "/walker/".concat(left);
          if (right !== "") {
            url = "/walker/".concat(left, "/").concat(right);
          }
          _context.n = 1;
          return fetch(url, {
            "method": "POST",
            "accept": "application/json",
            "headers": {
              "Content-Type": "application/json",
              "Authorization": token ? "Bearer ".concat(token) : ""
            },
            "body": JSON.stringify({
              "fields": fields
            })
          });
        case 1:
          response = _context.v;
          if (response.ok) {
            _context.n = 3;
            break;
          }
          _context.n = 2;
          return response.json();
        case 2:
          error_text = _context.v;
          throw new Error("Walker ".concat(walker, " failed: ").concat(error_text));
        case 3:
          _context.n = 4;
          return response.json();
        case 4:
          return _context.a(2, _context.v);
      }
    }, _callee);
  }));
  return _jacSpawn.apply(this, arguments);
}
function jacSpawn(left, right, fields) {
  return __jacSpawn(left, right, fields);
}
function __jacCallFunction(_x4, _x5) {
  return _jacCallFunction.apply(this, arguments);
}
function _jacCallFunction() {
  _jacCallFunction = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee2(function_name, args) {
    var token, response, error_text, data, _t;
    return _regenerator().w(function (_context2) {
      while (1) switch (_context2.n) {
        case 0:
          token = __getLocalStorage("jac_token");
          _context2.n = 1;
          return fetch("/function/".concat(function_name), {
            "method": "POST",
            "headers": {
              "Content-Type": "application/json",
              "Authorization": token ? "Bearer ".concat(token) : ""
            },
            "body": JSON.stringify({
              "args": args
            })
          });
        case 1:
          response = _context2.v;
          if (response.ok) {
            _context2.n = 3;
            break;
          }
          _context2.n = 2;
          return response.text();
        case 2:
          error_text = _context2.v;
          throw new Error("Function ".concat(function_name, " failed: ").concat(error_text));
        case 3:
          _t = JSON;
          _context2.n = 4;
          return response.text();
        case 4:
          data = _t.parse.call(_t, _context2.v);
          return _context2.a(2, data["result"]);
      }
    }, _callee2);
  }));
  return _jacCallFunction.apply(this, arguments);
}
function jacSignup(_x6, _x7) {
  return _jacSignup.apply(this, arguments);
}
function _jacSignup() {
  _jacSignup = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee3(username, password) {
    var response, data, token, error_text, error_data, _t2, _t3;
    return _regenerator().w(function (_context3) {
      while (1) switch (_context3.p = _context3.n) {
        case 0:
          _context3.n = 1;
          return fetch("/user/create", {
            "method": "POST",
            "headers": {
              "Content-Type": "application/json"
            },
            "body": JSON.stringify({
              "username": username,
              "password": password
            })
          });
        case 1:
          response = _context3.v;
          if (!response.ok) {
            _context3.n = 4;
            break;
          }
          _t2 = JSON;
          _context3.n = 2;
          return response.text();
        case 2:
          data = _t2.parse.call(_t2, _context3.v);
          token = data["token"];
          if (!token) {
            _context3.n = 3;
            break;
          }
          __setLocalStorage("jac_token", token);
          return _context3.a(2, {
            "success": true,
            "token": token,
            "username": username
          });
        case 3:
          return _context3.a(2, {
            "success": false,
            "error": "No token received"
          });
        case 4:
          _context3.n = 5;
          return response.text();
        case 5:
          error_text = _context3.v;
          _context3.p = 6;
          error_data = JSON.parse(error_text);
          return _context3.a(2, {
            "success": false,
            "error": error_data["error"] !== null ? error_data["error"] : "Signup failed"
          });
        case 7:
          _context3.p = 7;
          _t3 = _context3.v;
          return _context3.a(2, {
            "success": false,
            "error": error_text
          });
        case 8:
          return _context3.a(2);
      }
    }, _callee3, null, [[6, 7]]);
  }));
  return _jacSignup.apply(this, arguments);
}
function jacLogin(_x8, _x9) {
  return _jacLogin.apply(this, arguments);
}
function _jacLogin() {
  _jacLogin = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee4(username, password) {
    var response, data, token, _t4;
    return _regenerator().w(function (_context4) {
      while (1) switch (_context4.n) {
        case 0:
          _context4.n = 1;
          return fetch("/user/login", {
            "method": "POST",
            "headers": {
              "Content-Type": "application/json"
            },
            "body": JSON.stringify({
              "username": username,
              "password": password
            })
          });
        case 1:
          response = _context4.v;
          if (!response.ok) {
            _context4.n = 3;
            break;
          }
          _t4 = JSON;
          _context4.n = 2;
          return response.text();
        case 2:
          data = _t4.parse.call(_t4, _context4.v);
          token = data["token"];
          if (!token) {
            _context4.n = 3;
            break;
          }
          __setLocalStorage("jac_token", token);
          return _context4.a(2, true);
        case 3:
          return _context4.a(2, false);
      }
    }, _callee4);
  }));
  return _jacLogin.apply(this, arguments);
}
function jacLogout() {
  __removeLocalStorage("jac_token");
}
function jacIsLoggedIn() {
  var token = __getLocalStorage("jac_token");
  return token !== null && token !== "";
}
function __getLocalStorage(key) {
  var storage = globalThis.localStorage;
  return storage ? storage.getItem(key) : "";
}
function __setLocalStorage(key, value) {
  var storage = globalThis.localStorage;
  if (storage) {
    storage.setItem(key, value);
  }
}
function __removeLocalStorage(key) {
  var storage = globalThis.localStorage;
  if (storage) {
    storage.removeItem(key);
  }
}
export { Link, Navigate, Route, Router, Routes, __getLocalStorage, __jacCallFunction, __jacJsx, __jacSpawn, __removeLocalStorage, __setLocalStorage, jacIsLoggedIn, jacLogin, jacLogout, jacSignup, jacSpawn, navigate, useLocation, useNavigate, useParams, useRouter };