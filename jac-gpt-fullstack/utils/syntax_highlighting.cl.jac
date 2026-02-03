"""Monaco syntax highlighting utilities for Jac language (TextMate grammar)."""

import from "monaco-textmate" { Registry }
import from "monaco-editor-textmate" { wireTmGrammars }
import from "onigasm" { loadWASM }

# CORRECTED PATHS - Use absolute paths from web root
glob ONIG_WASM_PATH = "/static/assets/onigasm.wasm";
glob LANGUAGE_CONFIG_PATH = "/static/assets/language-configuration.json";

glob wasmInitialized = false;
glob languageRegistered = false;
glob grammarLoaded = false;
glob themeRegistered = false;

glob cachedGrammarConfig = null;
glob cachedRegistry = null;
glob cachedGrammarMap = null;

"""Load Jac syntax highlighting with TextMate grammar."""
async def:pub loadSyntax(monaco: any, editor: any) -> any {
    try {
        # Register language if not already registered
        if not languageRegistered {
            monaco.languages.register({ id: "jac" });
            languageRegistered = true;
        }
        
        # Load WASM only once
        if not wasmInitialized {
            await loadWASM(ONIG_WASM_PATH);
            wasmInitialized = true;
        }
        
        # Load grammar only once
        if not grammarLoaded {
            
            # Fetch Jac grammar from GitHub
            response = await fetch("https://raw.githubusercontent.com/jaseci-labs/jac-vscode/main/syntaxes/jac.tmLanguage.json");
            
            if not response.ok {
                raise Reflect.construct(Error, [f"Failed to fetch grammar: {response.status}"]);
            }
            
            grammarConfigRes = await fetch(LANGUAGE_CONFIG_PATH);
            
            if not grammarConfigRes.ok {
                raise Reflect.construct(Error, [f"Failed to fetch language config: {grammarConfigRes.status}"]);
            }
            
            jacGrammar = await response.json();
            cachedGrammarConfig = await grammarConfigRes.json();
            
            # Create TextMate registry
            registry = Reflect.construct(Registry, [{
                getGrammarDefinition: lambda {
                    return {
                        format: "json",
                        content: JSON.stringify(jacGrammar)
                    };
                }
            }]);
            
            cachedRegistry = registry;
            
            # Create grammar map
            grammar = Reflect.construct(Map, []);
            grammar.set("jac", "source.jac");
            cachedGrammarMap = grammar;
            
            grammarLoaded = true;
        }
        
        # Wire grammar to editor
        if editor and cachedRegistry and cachedGrammarMap {
            await wireTmGrammars(monaco, cachedRegistry, cachedGrammarMap, editor);
        }
        # 
        return cachedGrammarConfig;
        
    } except Exception as error {
        return null;
    }
}

"""Configure Monaco theme."""
async def:pub configureTheme(monaco: any, grammarConfig: any, isDark: bool = true) {
    try {
        
        # Set language configuration
        if grammarConfig {
            monaco.languages.setLanguageConfiguration("jac", grammarConfig);
        }
        
        # Define theme (only once)
        if not themeRegistered {
            monaco.editor.defineTheme("jac-theme", {
                base: "vs-dark",
                inherit: true,
                rules: [
                    { token: "storage.type.class.jac", foreground: "569CD6" },
                    { token: "storage.type.function.jac", foreground: "569CD6" },
                    { token: "keyword.control.flow.jac", foreground: "C678DD" },
                    { token: "entity.name.type.class.jac", foreground: "3ac9b0" },
                    { token: "keyword.control.jac", foreground: "C678DD" },
                    { token: "keyword.operator.jac", foreground: "D4D4D4" },
                    { token: "string.quoted.double.jac", foreground: "CE9178" },
                    { token: "string.quoted.single.jac", foreground: "CE9178" },
                    { token: "comment.line.jac", foreground: "6A9955" },
                    { token: "comment.block.jac", foreground: "6A9955" },
                    { token: "constant.numeric.jac", foreground: "B5CEA8" },
                    { token: "entity.name.function.jac", foreground: "DCDCAA" },
                    { token: "variable.other.jac", foreground: "9CDCFE" },
                    { token: "punctuation.separator.jac", foreground: "D4D4D4" },
                    { token: "punctuation.section.jac", foreground: "D4D4D4" }
                ],
                colors: {
                    "editor.foreground": "#FFFFFF",
                    "editor.background": "#1e1e1e"
                }
            });
            
            themeRegistered = true;
        }
        
        # Apply theme
        monaco.editor.setTheme("jac-theme");
        
    } except Exception as error{
    }
}


"""Lightweight tokenizer-based Jac syntax highlighting."""
async def:pub highlightJacCode(code: str) -> str {
    console.log("=== highlightJacCode called ===");
    console.log("Input code:", code);
    console.log("Code length:", code.length);
    
    tokens = tokenizeJacCode(code);
    console.log("Tokens count:", tokens.length);
    console.log("First 5 tokens:", tokens.slice(0, 5));
    
    result = "";
    for token in tokens {
        tokenType = token.type;
        value = token.value;
        
        if tokenType == "comment" {
            result = result + f"<span class='jac-comment'>{escapeHtml(value)}</span>";
        } elif tokenType == "string" {
            result = result + f"<span class='jac-string'>{escapeHtml(value)}</span>";
        } elif tokenType == "number" {
            result = result + f"<span class='jac-number'>{escapeHtml(value)}</span>";
        } elif tokenType == "keyword" {
            result = result + f"<span class='jac-keyword'>{escapeHtml(value)}</span>";
        } elif tokenType == "control-flow" {
            result = result + f"<span class='jac-control-flow'>{escapeHtml(value)}</span>";
        } elif tokenType == "special-keyword" {
            result = result + f"<span class='jac-special-keyword'>{escapeHtml(value)}</span>";
        } elif tokenType == "type" {
            result = result + f"<span class='jac-type'>{escapeHtml(value)}</span>";
        } elif tokenType == "class-name" {
            result = result + f"<span class='jac-class-name'>{escapeHtml(value)}</span>";
        } elif tokenType == "module" {
            result = result + f"<span class='jac-module'>{escapeHtml(value)}</span>";
        } elif tokenType == "function" {
            result = result + f"<span class='jac-function'>{escapeHtml(value)}</span>";
        } elif tokenType == "variable" {
            result = result + f"<span class='jac-variable'>{escapeHtml(value)}</span>";
        } elif tokenType == "operator" {
            result = result + f"<span class='jac-operator'>{escapeHtml(value)}</span>";
        } elif tokenType == "arrow" {
            result = result + f"<span class='jac-arrow'>{escapeHtml(value)}</span>";
        } elif tokenType == "bracket" {
            level = token.level if "level" in token else 0;
            bracketClass = f"jac-bracket-level-{level % 4}";
            result = result + f"<span class=\"{bracketClass}\">{escapeHtml(value)}</span>";
        } else {
            result = result + escapeHtml(value);
        }
    }
    
    console.log("=== highlightJacCode result ===");
    console.log("Result length:", result.length);
    console.log("Result preview:", result.slice(0, 200));
    return result;
}

"""Tokenize Jac code into syntax tokens - matches TypeScript version exactly."""
def tokenizeJacCode(code: str) -> list {
    console.log("=== tokenizeJacCode called ===");
    console.log("Input code:", code);
    tokens = [];
    
    keywords = [
        "node", "edge", "walker", "can", "with", "entry", "exit", "def", "class", "obj",
        "enum", "has", "ability", "visit", "disengage", "yield", "try", "except", "finally", "assert",
        "include", "as", "global", "async", "await", "lambda",
        "here", "self", "root", "super", "init", "postinit", "visitor", "impl",
        "and", "or", "not", "in", "is", "True", "False", "None",
        "pass", "del", "raise", "test", "check", "glob"
    ];
    
    controlFlowKeywords = [
        "if", "else", "elif", "for", "while", "return", "break", "continue", "spawn", "from", "import"
    ];
    
    types = ["str", "int", "float", "bool", "list", "dict", "tuple", "set", "any", "type"];
    operators = ["=", "+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">=", "+=", "-=", "*=", "/=", "|", "&", "^", "~", "<<", ">>", "**"];
    
    i = 0;
    bracketStack = [];
    
    while i < code.length {
        # Skip whitespace (using regex test)
        if code[i] == " " or code[i] == "\t" or code[i] == "\n" or code[i] == "\r" {
            whitespace = "";
            while i < code.length and (code[i] == " " or code[i] == "\t" or code[i] == "\n" or code[i] == "\r") {
                whitespace = whitespace + code[i];
                i = i + 1;
            }
            tokens = tokens + [{"type": "whitespace", "value": whitespace}];
            continue;
        }
        
        # Handle comments
        if code[i] == "#" {
            if i + 1 < code.length and code[i + 1] == "*" {
                # Block comment
                comment = "";
                while i < code.length and not (code[i] == "*" and i + 1 < code.length and code[i + 1] == "#") {
                    comment = comment + code[i];
                    i = i + 1;
                }
                if i < code.length {
                    comment = comment + code[i] + code[i + 1];
                    i = i + 2;
                }
                tokens = tokens + [{"type": "comment", "value": comment}];
            } else {
                # Line comment
                comment = "";
                while i < code.length and code[i] != "\n" {
                    comment = comment + code[i];
                    i = i + 1;
                }
                tokens = tokens + [{"type": "comment", "value": comment}];
            }
            continue;
        }
        
        # Handle strings
        if code[i] == '"' or code[i] == "'" {
            quote = code[i];
            string = quote;
            i = i + 1;
            while i < code.length and code[i] != quote {
                if code[i] == "\\" and i + 1 < code.length {
                    string = string + code[i] + code[i + 1];
                    i = i + 2;
                } else {
                    string = string + code[i];
                    i = i + 1;
                }
            }
            if i < code.length {
                string = string + code[i];
                i = i + 1;
            }
            tokens = tokens + [{"type": "string", "value": string}];
            continue;
        }
        
        # Handle numbers
        if code[i] >= "0" and code[i] <= "9" {
            number = "";
            while i < code.length and ((code[i] >= "0" and code[i] <= "9") or code[i] == ".") {
                number = number + code[i];
                i = i + 1;
            }
            tokens = tokens + [{"type": "number", "value": number}];
            continue;
        }
        
        # Handle brackets with nesting - EXACT MATCH TO TYPESCRIPT
        if code[i] == "{" {
            bracketStack = bracketStack + ["{"];
            tokens = tokens + [{"type": "bracket", "value": code[i], "level": bracketStack.length - 1}];
            i = i + 1;
            continue;
        }
        
        if code[i] == "}" {
            if bracketStack.length > 0 and bracketStack[bracketStack.length - 1] == "{" {
                bracketStack = bracketStack.slice(0, -1);
            }
            tokens = tokens + [{"type": "bracket", "value": code[i], "level": bracketStack.length}];
            i = i + 1;
            continue;
        }
        
        # Handle other brackets (parentheses and square brackets)
        if code[i] == "(" or code[i] == "[" {
            bracketStack = bracketStack + [code[i]];
            tokens = tokens + [{"type": "bracket", "value": code[i], "level": bracketStack.length - 1}];
            i = i + 1;
            continue;
        }
        
        if code[i] == ")" or code[i] == "]" {
            expectedOpen = "(" if code[i] == ")" else "[";
            if bracketStack.length > 0 and bracketStack[bracketStack.length - 1] == expectedOpen {
                bracketStack = bracketStack.slice(0, -1);
            }
            tokens = tokens + [{"type": "bracket", "value": code[i], "level": bracketStack.length}];
            i = i + 1;
            continue;
        }
        
        # Handle arrow operators (3-char)
        if i + 2 < code.length {
            threeChar = code.slice(i, i + 3);
            if threeChar == "-->" {
                tokens = tokens + [{"type": "arrow", "value": "--"}];
                tokens = tokens + [{"type": "punctuation", "value": ">"}];
                i = i + 3;
                continue;
            } elif threeChar == "<--" {
                tokens = tokens + [{"type": "punctuation", "value": "<"}];
                tokens = tokens + [{"type": "arrow", "value": "--"}];
                i = i + 3;
                continue;
            } elif threeChar == "++>" {
                tokens = tokens + [{"type": "punctuation", "value": "++"}];
                tokens = tokens + [{"type": "punctuation", "value": ">"}];
                i = i + 3;
                continue;
            } elif threeChar == "<++" {
                tokens = tokens + [{"type": "punctuation", "value": "<"}];
                tokens = tokens + [{"type": "punctuation", "value": "++"}];
                i = i + 3;
                continue;
            }
        }
        
        # Handle arrow operators (2-char)
        if i + 1 < code.length {
            twoChar = code.slice(i, i + 2);
            if twoChar == "->" or twoChar == "<-" {
                # Find previous non-whitespace token
                prevNonWhitespaceToken = None;
                j = tokens.length - 1;
                while j >= 0 {
                    if tokens[j].type != "whitespace" {
                        prevNonWhitespaceToken = tokens[j];
                        break;
                    }
                    j = j - 1;
                }
                
                isInFunctionSignature = prevNonWhitespaceToken and (
                    prevNonWhitespaceToken.value == ")" or
                    prevNonWhitespaceToken.type == "type" or
                    prevNonWhitespaceToken.value == ":"
                );
                
                if twoChar == "->" and isInFunctionSignature {
                    tokens = tokens + [{"type": "operator", "value": twoChar}];
                } else {
                    tokens = tokens + [{"type": "arrow", "value": twoChar}];
                }
                i = i + 2;
                continue;
            }
        }
        
        # Check for regular operators
        operator = "";
        j = i;
        while j < code.length {
            ch = code[j];
            if ch == "=" or ch == "+" or ch == "-" or ch == "*" or ch == "/" or ch == "%" or ch == "<" or ch == ">" or ch == "!" or ch == "&" or ch == "|" or ch == "^" or ch == "~" {
                operator = operator + ch;
                j = j + 1;
            } else {
                break;
            }
        }
        
        if operator and operator in operators {
            tokens = tokens + [{"type": "operator", "value": operator}];
            i = j;
            continue;
        }
        
        # Handle identifiers (keywords, types, functions, variables)
        if (code[i] >= "a" and code[i] <= "z") or (code[i] >= "A" and code[i] <= "Z") or code[i] == "_" {
            identifier = "";
            while i < code.length {
                ch = code[i];
                if (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9") or ch == "_" {
                    identifier = identifier + ch;
                    i = i + 1;
                } else {
                    break;
                }
            }
            
            # Find previous non-whitespace token
            prevNonWhitespaceToken = None;
            j = tokens.length - 1;
            while j >= 0 {
                if tokens[j].type != "whitespace" {
                    prevNonWhitespaceToken = tokens[j];
                    break;
                }
                j = j - 1;
            }
            
            isAfterImport = prevNonWhitespaceToken and prevNonWhitespaceToken.value in ["import", "include", "from"];
            
            if isAfterImport {
                # Special case: "from" should be treated as a control-flow keyword
                if identifier == "from" {
                    tokens = tokens + [{"type": "control-flow", "value": identifier}];
                    continue;
                }
                
                # For imports, handle the full dotted path
                while i < code.length and code[i] == "." {
                    identifier = identifier + code[i];
                    i = i + 1;
                    while i < code.length {
                        ch = code[i];
                        if (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9") or ch == "_" {
                            identifier = identifier + ch;
                            i = i + 1;
                        } else {
                            break;
                        }
                    }
                }
                tokens = tokens + [{"type": "module", "value": identifier}];
                continue;
            }
            
            # Check context for class names and functions
            isAfterArchetypeKeyword = prevNonWhitespaceToken and prevNonWhitespaceToken.value in ["walker", "node", "edge", "obj", "class", "enum"];
            isAfterCan = prevNonWhitespaceToken and prevNonWhitespaceToken.value == "can";
            isAfterWith = prevNonWhitespaceToken and prevNonWhitespaceToken.value == "with";
            isAfterRoot = prevNonWhitespaceToken and prevNonWhitespaceToken.value == "root";
            
            # Special keywords like 'entry', 'exit' in certain contexts
            if identifier in ["entry", "exit"] and (isAfterWith or isAfterCan or isAfterRoot) {
                tokens = tokens + [{"type": "special-keyword", "value": identifier}];
            } elif identifier in controlFlowKeywords {
                tokens = tokens + [{"type": "control-flow", "value": identifier}];
            } elif identifier in keywords {
                tokens = tokens + [{"type": "keyword", "value": identifier}];
            } elif identifier in types {
                tokens = tokens + [{"type": "type", "value": identifier}];
            } elif isAfterArchetypeKeyword or (identifier.length > 0 and identifier[0] >= "A" and identifier[0] <= "Z") {
                # Capitalized identifiers or identifiers after archetype keywords are class names
                tokens = tokens + [{"type": "class-name", "value": identifier}];
            } elif isAfterCan {
                # Function names after 'can' keyword
                tokens = tokens + [{"type": "function", "value": identifier}];
            } else {
                # Check if it's followed by '(' to determine if it's a function
                k = i;
                while k < code.length and (code[k] == " " or code[k] == "\t") {
                    k = k + 1;
                }
                if k < code.length and code[k] == "(" {
                    tokens = tokens + [{"type": "function", "value": identifier}];
                } else {
                    tokens = tokens + [{"type": "variable", "value": identifier}];
                }
            }
            continue;
        }
        
        # Handle single characters (punctuation, etc.)
        tokens = tokens + [{"type": "punctuation", "value": code[i]}];
        i = i + 1;
    }
    
    console.log("=== tokenizeJacCode complete ===");
    console.log("Total tokens:", tokens.length);
    console.log("Sample tokens:", tokens.slice(0, 10));
    return tokens;
}

"""Escape HTML special characters."""
def escapeHtml(text: str) -> str {
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("'", "&#39;");
}
