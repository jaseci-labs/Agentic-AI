"""CodeMirror 6 syntax highlighting for the Jac language."""

import from "@codemirror/language" { StreamLanguage, HighlightStyle, syntaxHighlighting }
import from "@lezer/highlight" { tags, Tag }
import from "@codemirror/view" { EditorView }

# Custom highlight tags — defined explicitly rather than relying on the
# tags.* hierarchy, which avoids guessing at sub-tag availability.
glob arrowTag = Tag.define();
glob controlFlowTag = Tag.define();
glob functionNameTag = Tag.define();


# Keyword / identifier classification lists (same sets as the old tokenizer)
glob KEYWORDS = [
    "node", "edge", "walker", "can", "with", "entry", "exit", "def", "class", "obj",
    "enum", "has", "ability", "visit", "disengage", "yield", "try", "except", "finally", "assert",
    "include", "as", "global", "async", "await", "lambda",
    "here", "self", "root", "super", "init", "postinit", "visitor", "impl",
    "and", "or", "not", "in", "is", "True", "False", "None",
    "pass", "del", "raise", "test", "check", "glob"
];

glob CONTROL_FLOW = [
    "if", "else", "elif", "for", "while", "return", "break", "continue", "spawn", "from", "import"
];

glob TYPES = ["str", "int", "float", "bool", "list", "dict", "tuple", "set", "any", "type"];

# Pre-created RegExp objects.
glob RE_NUMBER = Reflect.construct(RegExp, ["^(0[xX][0-9a-fA-F]+|0[oO][0-7]+|0[bB][01]+|[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?)"]);
glob RE_SINGLE_OP = Reflect.construct(RegExp, ["^[=+*/%<>!&|^~-]"]);
glob RE_IDENTIFIER = Reflect.construct(RegExp, ["^[a-zA-Z_][a-zA-Z0-9_]*"]);
glob RE_PUNCTUATION = Reflect.construct(RegExp, ["^[.:;,@?]"]);
# Backslash via charCode — the Jac compiler doubles backslashes in string
# literals, so "\\" does NOT produce a single backslash at runtime.
glob BACKSLASH = String.fromCharCode(92);


# Token table: maps token-name strings (returned by tokenJac) to tags.
glob JAC_TOKEN_TABLE = {
    "comment":     tags.comment,
    "string":      tags.string,
    "number":      tags.number,
    "keyword":     tags.keyword,
    "controlFlow": controlFlowTag,
    "type":        tags.typeName,
    "className":   tags.className,
    "function":    functionNameTag,
    "variable":    tags.variableName,
    "operator":    tags.operator,
    "arrow":       arrowTag,
    "punctuation": tags.punctuation
};

glob jacHighlightStyle = syntaxHighlighting(HighlightStyle.define([
    { "tag": tags.comment,      "color": "#6a9955", "fontStyle": "italic" },
    { "tag": tags.string,       "color": "#ce9178" },
    { "tag": tags.number,       "color": "#b5cea8" },
    { "tag": tags.keyword,      "color": "#569cd6" },
    { "tag": controlFlowTag,    "color": "#c678dd" },
    { "tag": tags.typeName,     "color": "#3ac9b0" },
    { "tag": tags.className,    "color": "#4ec9b0" },
    { "tag": functionNameTag,   "color": "#dcdcaa" },
    { "tag": tags.variableName, "color": "#9cdcfe" },
    { "tag": tags.operator,     "color": "#d4d4d4" },
    { "tag": tags.punctuation,  "color": "#d4d4d4" },
    { "tag": arrowTag,          "color": "#ff6b6b", "fontWeight": "bold" }
]));

def tokenJac(stream: any, state: any) -> str {

    # --- block comment continuation (multi-line state) ---
    if state.inBlockComment {
        if stream.skipTo("*#") {
            stream.next();  # consume *
            stream.next();  # consume #
            state.inBlockComment = False;
        } else {
            stream.skipToEnd();
        }
        return "comment";
    }

    # --- block comment open: #*  (checked before single-# line comment) ---
    if stream.match("#*") {
        if stream.skipTo("*#") {
            stream.next();  # consume *
            stream.next();  # consume #
        } else {
            stream.skipToEnd();  # consume rest of this line
            state.inBlockComment = True;
        }
        return "comment";
    }

    # --- line comment: # to end of line ---
    if stream.match("#") {
        stream.skipToEnd();
        return "comment";
    }

    # --- strings: single or double quoted with backslash escapes ---
    ch = stream.peek();
    if ch == '"' or ch == "'" {
        quote = ch;
        stream.next();  # consume opening quote
        while not stream.eol() {
            c = stream.next();
            if c == BACKSLASH {
                if not stream.eol() {
                    stream.next();  # skip the escaped character
                }
            } elif c == quote {
                return "string";  # found matching close quote
            }
        }
        return "string";  # unterminated string — still highlight it
    }

    # --- numbers: hex / octal / binary / int / float (single combined regex) ---
    if stream.match(RE_NUMBER) {
        return "number";
    }

    # --- 3-char graph arrows (before 2-char and single-char operators) ---
    if stream.match("-->") or stream.match("<--") or stream.match("++>") or stream.match("<++") {
        return "arrow";
    }

    # --- 2-char graph arrows ---
    if stream.match("->") or stream.match("<-") {
        return "arrow";
    }

    # --- 2-char operators (before single-char to avoid partial consumption) ---
    if stream.match("==") or stream.match("!=") or stream.match("<=") or stream.match(">=") or stream.match("+=") or stream.match("-=") or stream.match("*=") or stream.match("/=") or stream.match("<<") or stream.match(">>") or stream.match("**") {
        return "operator";
    }

    # --- single-char operators ---
    if stream.match(RE_SINGLE_OP) {
        return "operator";
    }

    # --- brackets / braces / parens ---
    if ch == "[" or ch == "]" or ch == "{" or ch == "}" or ch == "(" or ch == ")" {
        stream.next();
        return "punctuation";
    }

    # --- identifiers: classify into keyword / controlFlow / type / className / function / variable ---
    m = stream.match(RE_IDENTIFIER);
    if m {
        word = m[0];

        if word in CONTROL_FLOW {
            return "controlFlow";
        }
        if word in KEYWORDS {
            return "keyword";
        }
        if word in TYPES {
            return "type";
        }
        # Capitalized first letter → class name
        if word[0] >= "A" and word[0] <= "Z" {
            return "className";
        }
        # Immediately followed by ( → function call
        if stream.peek() == "(" {
            return "function";
        }
        return "variable";
    }

    # --- other punctuation (dot, comma, colon, semicolon, etc.) ---
    if stream.match(RE_PUNCTUATION) {
        return "punctuation";
    }

    # --- fallback: advance one character, no highlight ---
    stream.next();
    return None;
}


# ---------------------------------------------------------------------------
# Exported factory — the only public symbol in this module.
# Returns the extension array for a read-only Jac EditorView.
# ---------------------------------------------------------------------------
"""Return CodeMirror 6 extensions for a read-only Jac syntax viewer."""
def:pub getJacExtensions() -> list {
    return [
        StreamLanguage.define({
            "name": "jac",
            "startState": lambda { return { "inBlockComment": False }; },
            "token": tokenJac,
            "tokenTable": JAC_TOKEN_TABLE
        }),
        jacHighlightStyle,
        EditorView.baseTheme({
            "&": {
                "background": "transparent",
                "outline": "none",
                "fontFamily": "Monaco, Menlo, Ubuntu Mono, monospace"
            },
            "&.cm-focused": {
                "outline": "none"
            },
            ".cm-scroller": {
                "overflow": "auto"
            },
            ".cm-content": {
                "padding": "0",
                "caretColor": "transparent"
            }
        }),
        EditorView.editable.of(False)
    ];
}
