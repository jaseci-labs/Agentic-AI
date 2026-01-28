"""Lightweight Jac syntax highlighter using highlight.js - instant rendering."""

import from "highlight.js" { default as hljs }

glob jacLanguageRegistered = false;

"""Jac language definition for highlight.js."""
def getJacLanguageDefinition(hljs: any) -> any {
    # Orange keywords - control flow
    KEYWORDS = "if elif else for while with try except finally " +
               "return yield break continue pass raise assert and or not in is lambda " +
               "global nonlocal del async await spawn visit ignore disengage revisit " +
               "by to report take skip entry exit init postinit def pub priv " +
               "static abstract override test glob let";

    # Blue - archetype declarations + can + has
    TYPES = "node edge walker graph object class enum archetype ability obj can has";

    # Blue - built-in types
    BUILT_INS = "str int float bool list dict set tuple any type";

    # Orange - literals
    LITERALS = "True False None null true false";

    # Blue - special variables
    SPECIALS = "root here self super visitor";

    return {
        name: "Jac",
        aliases: ["jac"],
        keywords: {
            keyword: KEYWORDS,
            type: TYPES,
            built_in: BUILT_INS,
            literal: LITERALS,
            variable: SPECIALS
        },
        contains: [
            hljs.HASH_COMMENT_MODE,
            hljs.C_NUMBER_MODE,
            # Triple-quoted strings
            {
                className: "string",
                begin: '"""',
                end: '"""'
            },
            # F-strings double quote
            {
                className: "string",
                begin: 'f"',
                end: '"'
            },
            # F-strings single quote
            {
                className: "string",
                begin: "f'",
                end: "'"
            },
            # Regular strings
            hljs.QUOTE_STRING_MODE,
            hljs.APOS_STRING_MODE,
            # Import keywords - Purple
            {
                className: "symbol",
                begin: "\\b(import|from|as|include|cl)\\b"
            },
            # Decorators - Purple
            {
                className: "meta",
                begin: "@",
                end: "\\s",
                excludeEnd: true
            }
        ]
    };
}

"""Register Jac language with highlight.js for instant syntax highlighting."""
def:pub registerJacLanguage() -> None {
    if jacLanguageRegistered {
        return;
    }

    try {
        hljs.registerLanguage("jac", getJacLanguageDefinition);
        jacLanguageRegistered = true;
        console.log("Jac language registered successfully");
    } except Exception as e {
        console.error("Failed to register Jac language:", e);
    }
}

"""Highlight Jac code and return HTML string."""
def:pub highlightJacCode(code: str) -> str {
    registerJacLanguage();

    try {
        result = hljs.highlight(code, { language: "jac" });
        return result.value;
    } except Exception as e {
        console.error("Jac highlight error:", e);
        return code;
    }
}

"""Highlight code with auto-detection or specified language."""
def:pub highlightCode(code: str, language: str = "") -> str {
    registerJacLanguage();

    try {
        if language == "jac" {
            return highlightJacCode(code);
        } elif language {
            result = hljs.highlight(code, { language: language, ignoreIllegals: true });
            return result.value;
        } else {
            return hljs.highlightAuto(code).value;
        }
    } except Exception as e {
        console.error("Highlight error:", e);
        return code;
    }
}
