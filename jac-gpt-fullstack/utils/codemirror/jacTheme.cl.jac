"""Jaseci Orange theme for CodeMirror with syntax highlighting."""

import from "@codemirror/view" { EditorView }
import from "@lezer/highlight" { HighlightStyle, tags as t }

"""Create Jaseci Orange theme for CodeMirror."""
def:pub createJacTheme() -> list {
    # Jaseci color palette
    ORANGE = "#f97316";
    AMBER = "#fbbf24";
    LIGHT_ORANGE = "#fb923c";
    GREEN = "#86efac";
    PURPLE = "#c084fc";
    GRAY = "#6b7280";
    LIGHT_BLUE = "#93c5fd";
    BG = "#1a1b1e";
    TEXT = "#e4e4e7";
    LINE_HIGHLIGHT = "rgba(255, 255, 255, 0.03)";
    SELECTION = "rgba(249, 115, 22, 0.2)";
    
    # Editor theme (UI styling)
    editorTheme = EditorView.theme({
        "&": {
            "backgroundColor": BG,
            "color": TEXT,
            "height": "100%"
        },
        ".cm-content": {
            "caretColor": ORANGE,
            "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace",
            "fontSize": "13px",
            "lineHeight": "1.6",
            "padding": "8px 0"
        },
        ".cm-cursor, .cm-dropCursor": {
            "borderLeftColor": ORANGE,
            "borderLeftWidth": "2px"
        },
        ".cm-activeLine": {
            "backgroundColor": LINE_HIGHLIGHT
        },
        ".cm-selectionBackground, ::selection": {
            "backgroundColor": SELECTION + " !important"
        },
        "&.cm-focused .cm-selectionBackground, &.cm-focused ::selection": {
            "backgroundColor": SELECTION + " !important"
        },
        ".cm-gutters": {
            "backgroundColor": BG,
            "color": GRAY,
            "border": "none",
            "borderRight": "1px solid rgba(255, 255, 255, 0.1)"
        },
        ".cm-activeLineGutter": {
            "backgroundColor": LINE_HIGHLIGHT,
            "color": ORANGE
        },
        ".cm-lineNumbers .cm-gutterElement": {
            "color": GRAY,
            "padding": "0 8px",
            "minWidth": "32px"
        },
        ".cm-foldGutter": {
            "color": GRAY
        },
        ".cm-scroller": {
            "overflow": "auto",
            "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace"
        },
        ".cm-tooltip": {
            "backgroundColor": BG,
            "border": "1px solid rgba(255, 255, 255, 0.1)"
        }
    }, { dark: true });
    
    # Syntax highlighting style
    highlightStyle = HighlightStyle.define([
        # Keywords - Orange (bold)
        { tag: t.keyword, color: ORANGE, fontWeight: "bold" },
        { tag: t.controlKeyword, color: ORANGE, fontWeight: "bold" },
        { tag: t.definitionKeyword, color: ORANGE, fontWeight: "bold" },
        { tag: t.moduleKeyword, color: ORANGE },
        { tag: t.operatorKeyword, color: ORANGE },
        
        # Class/Function names - Amber
        { tag: t.className, color: AMBER },
        { tag: t.function(t.variableName), color: AMBER },
        { tag: t.definition(t.variableName), color: AMBER },
        { tag: t.definition(t.function(t.variableName)), color: AMBER },
        
        # Types - Light Orange
        { tag: t.typeName, color: LIGHT_ORANGE },
        { tag: t.standard(t.typeName), color: LIGHT_ORANGE },
        { tag: t.standard(t.variableName), color: LIGHT_ORANGE },
        
        # Strings - Green
        { tag: t.string, color: GREEN },
        { tag: t.special(t.string), color: GREEN },
        { tag: t.docString, color: GREEN },
        { tag: t.character, color: GREEN },
        
        # Numbers - Purple
        { tag: t.number, color: PURPLE },
        { tag: t.integer, color: PURPLE },
        { tag: t.float, color: PURPLE },
        { tag: t.bool, color: PURPLE },
        
        # Comments - Gray (italic)
        { tag: t.comment, color: GRAY, fontStyle: "italic" },
        { tag: t.lineComment, color: GRAY, fontStyle: "italic" },
        { tag: t.blockComment, color: GRAY, fontStyle: "italic" },
        { tag: t.docComment, color: GRAY, fontStyle: "italic" },
        
        # Variables - Light Blue
        { tag: t.variableName, color: LIGHT_BLUE },
        { tag: t.propertyName, color: LIGHT_BLUE },
        { tag: t.attributeName, color: LIGHT_BLUE },
        { tag: t.local(t.variableName), color: LIGHT_BLUE },
        
        # Special variables
        { tag: t.self, color: LIGHT_BLUE, fontWeight: "bold" },
        { tag: t.special(t.variableName), color: LIGHT_BLUE },
        
        # Constants - Light Orange
        { tag: t.constant(t.variableName), color: LIGHT_ORANGE },
        { tag: t.null, color: LIGHT_ORANGE },
        { tag: t.atom, color: LIGHT_ORANGE },
        
        # Operators - White
        { tag: t.operator, color: TEXT },
        { tag: t.arithmeticOperator, color: TEXT },
        { tag: t.logicOperator, color: ORANGE },
        { tag: t.compareOperator, color: ORANGE },
        
        # Punctuation - White
        { tag: t.punctuation, color: TEXT },
        { tag: t.separator, color: TEXT },
        { tag: t.bracket, color: TEXT },
        { tag: t.paren, color: TEXT },
        { tag: t.brace, color: TEXT },
        
        # Special
        { tag: t.regexp, color: GREEN },
        { tag: t.escape, color: PURPLE },
        { tag: t.link, color: LIGHT_BLUE },
        { tag: t.emphasis, fontStyle: "italic" },
        { tag: t.strong, fontWeight: "bold" },
        
        # Meta
        { tag: t.meta, color: GRAY },
        { tag: t.annotation, color: GRAY },
        
        # Invalid/Error
        { tag: t.invalid, color: "#ef4444", textDecoration: "underline" }
    ]);
    
    # Return both theme and highlight style
    return [editorTheme, highlightStyle];
}