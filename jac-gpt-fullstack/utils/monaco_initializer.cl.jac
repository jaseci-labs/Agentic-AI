"""Global Monaco initialization - ensures syntax highlighting is loaded once."""

import from "monaco-textmate" { Registry }
import from "monaco-editor-textmate" { wireTmGrammars }
import from "onigasm" { loadWASM }

# CORRECTED PATHS - Use absolute paths from web root
glob ONIG_WASM_PATH = "/static/assets/onigasm.wasm";
glob LANGUAGE_CONFIG_PATH = "/static/assets/language-configuration.json";

# Global initialization state
glob monacoInitialized = false;
glob initializationPromise = null;
glob cachedGrammarConfig = null;
glob cachedRegistry = null;
glob cachedGrammarMap = null;

"""Internal function to perform the actual initialization."""
async def _performInitialization() -> any {
    try {
        # Load WASM
        await loadWASM(ONIG_WASM_PATH);

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

        monacoInitialized = true;

        return cachedGrammarConfig;

    } except Exception as error {
        initializationPromise = null;  # Reset on error to allow retry
        return null;
    }
}

"""Initialize Monaco globally - call this once when the app loads."""
async def:pub initializeMonacoGlobally() -> any {
    # If already initialized or in progress, return the existing promise
    if monacoInitialized {
        return cachedGrammarConfig;
    }

    if initializationPromise {
        return await initializationPromise;
    }

    # Create initialization promise by calling the async function
    initializationPromise = _performInitialization();

    return await initializationPromise;
}

"""Setup Monaco editor instance with Jac syntax highlighting."""
async def:pub setupMonacoEditor(monaco: any, editor: any) -> any {
    try {
        # Ensure global initialization is complete
        if not monacoInitialized {
            await initializeMonacoGlobally();
        }

        # Register language if not already registered
        languages = monaco.languages.getLanguages();
        isJacRegistered = languages.some(lambda lang: any { return lang.id == "jac"; });

        if not isJacRegistered {
            monaco.languages.register({ id: "jac" });
        }

        # Wire grammar to this specific editor instance (lightweight operation)
        if editor and cachedRegistry and cachedGrammarMap {
            await wireTmGrammars(monaco, cachedRegistry, cachedGrammarMap, editor);
        }

        return cachedGrammarConfig;

    } except Exception as error {
        return null;
    }
}

"""Configure Monaco theme - only needs to be called once per Monaco instance."""
def:pub defineJacTheme(monaco: any) -> None {
    try {
        monaco.editor.defineTheme("jac-theme", {
            base: "vs-dark",
            inherit: true,
            rules: [
                # Keywords - Orange
                { token: "storage.type.class.jac", foreground: "f97316", fontStyle: "bold" },
                { token: "storage.type.function.jac", foreground: "f97316", fontStyle: "bold" },
                { token: "keyword.control.flow.jac", foreground: "f97316", fontStyle: "bold" },
                { token: "keyword.control.import.jac", foreground: "f97316" },
                { token: "storage.type.has.jac", foreground: "f97316" },
                { token: "storage.modifier.declaration.jac", foreground: "f97316" },

                # Class/Function Names - Amber
                { token: "entity.name.type.class.jac", foreground: "fbbf24" },
                { token: "entity.name.function.jac", foreground: "fbbf24" },

                # Types - Light Orange
                { token: "support.type.jac", foreground: "fb923c" },
                { token: "constant.language.jac", foreground: "fb923c" },

                # Strings - Green
                { token: "string.quoted.single.jac", foreground: "86efac" },
                { token: "string.quoted.double.jac", foreground: "86efac" },
                { token: "string.interpolated.jac", foreground: "86efac" },

                # Numbers - Purple
                { token: "constant.numeric.jac", foreground: "c084fc" },

                # Comments - Gray
                { token: "comment.line.jac", foreground: "6b7280", fontStyle: "italic" },
                { token: "comment.block.jac", foreground: "6b7280", fontStyle: "italic" },

                # Variables - Light Blue
                { token: "variable.parameter.jac", foreground: "93c5fd" },
                { token: "variable.language.special.self.jac", foreground: "93c5fd" }
            ],
            colors: {
                "editor.background": "#1a1b1e",
                "editor.foreground": "#e4e4e7",
                "editorLineNumber.foreground": "#6b7280",
                "editorLineNumber.activeForeground": "#f97316",
                "editorCursor.foreground": "#f97316",
                "editor.selectionBackground": "#f9731633"
            }
        });
    } except Exception as error {
    }
}

"""Configure Monaco theme - only needs to be called once per Monaco instance."""
def:pub configureMonacoTheme(monaco: any, grammarConfig: any) -> None {
    try {
        # Set language configuration
        if grammarConfig {
            monaco.languages.setLanguageConfiguration("jac", grammarConfig);
        }

        # Define and apply the theme
        defineJacTheme(monaco);
        monaco.editor.setTheme("jac-theme");

    } except Exception as error {
    }
}