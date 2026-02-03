"""Jac language definition for CodeMirror.
Based on Python mode with Jac-specific keywords and syntax."""

import from "@codemirror/language" { LanguageSupport, StreamLanguage }

"""Create Jac language support for CodeMirror."""
def:pub createJacLanguage() -> any {
    # Define Jac language mode
    jacMode = {
        # Mode name
        "name": "jac",
        
        # Start with Python-like tokenizer
        "startState": lambda -> any {
            return {
                "tokenize": null,
                "lastToken": null,
                "lambda": false,
                "dedent": 0
            };
        },
        
        # Main tokenizer
        "token": lambda stream: any, state: any -> str {
            # Handle whitespace
            if stream.eatSpace() {
                return null;
            }
            
            # Comments
            if stream.match("#*") {
                stream.skipToEnd();
                return "comment";
            }
            if stream.match("#") {
                stream.skipToEnd();
                return "comment";
            }
            
            # Strings
            if stream.match('"""') or stream.match("'''") {
                state.tokenize = tokenStringFactory(stream.current());
                return state.tokenize(stream, state);
            }
            if stream.match('"') or stream.match("'") {
                state.tokenize = tokenStringFactory(stream.current());
                return state.tokenize(stream, state);
            }
            
            # Numbers
            if stream.match(/^[0-9]+\.?[0-9]*/) {
                return "number";
            }
            
            # Keywords
            keywords = [
                "and", "as", "assert", "async", "await", "break", "class", "continue",
                "def", "del", "elif", "else", "except", "finally", "for", "from",
                "global", "if", "import", "in", "is", "lambda", "nonlocal", "not",
                "or", "pass", "raise", "return", "try", "while", "with", "yield",
                "node", "edge", "walker", "obj", "enum", "test",
                "can", "has", "entry", "exit", "visit", "spawn", "ignore",
                "disengage", "report", "here", "visitor", "by", "to",
                "impl", "sem", "priv", "protect", "pub", "abs", "override",
                "static", "cl", "glob", "let", "check"
            ];
            
            # Check for keywords
            for kw in keywords {
                if stream.match(Reflect.construct(RegExp, [f"^\\b{kw}\\b"])) {
                    return "keyword";
                }
            }
            
            # Built-in types
            builtins = ["str", "int", "float", "bool", "list", "dict", "tuple", "set", "any", "type"];
            for builtin in builtins {
                if stream.match(Reflect.construct(RegExp, [f"^\\b{builtin}\\b"])) {
                    return "type";
                }
            }
            
            # Special constants
            if stream.match(/^(True|False|None)\b/) {
                return "atom";
            }
            
            # Function/class definitions
            if state.lastToken == "def" or state.lastToken == "class" {
                if stream.match(/^[a-zA-Z_][a-zA-Z0-9_]*/) {
                    state.lastToken = null;
                    return "def";
                }
            }
            
            # Variable names
            if stream.match(/^[a-zA-Z_][a-zA-Z0-9_]*/) {
                word = stream.current();
                state.lastToken = word;
                return "variable";
            }
            
            # Operators
            if stream.match(/^[+\-*\/%<>=!&|^~]/) {
                return "operator";
            }
            
            # Default: advance one character
            stream.next();
            return null;
        }
    };
    
    # String tokenizer factory
    def tokenStringFactory(quote: str) -> any {
        def tokenString(stream: any, state: any) -> str {
            escaped = false;
            
            while not stream.eol() {
                ch = stream.next();
                
                if ch == quote and not escaped {
                    state.tokenize = null;
                    return "string";
                }
                
                escaped = not escaped and ch == "\\";
            }
            
            return "string";
        }
        
        return tokenString;
    }
    
    # Create StreamLanguage
    language = StreamLanguage.define(jacMode);
    
    # Return LanguageSupport
    return Reflect.construct(LanguageSupport, [language]);
}