"""CodeMirror setup and configuration utilities."""

import from "@codemirror/state" { EditorState }
import from "@codemirror/view" { EditorView, keymap, lineNumbers }
import from "@codemirror/commands" { defaultKeymap }
import from "@codemirror/language" { syntaxHighlighting }

import from .jacLanguage { createJacLanguage }
import from .jacTheme { createJacTheme }

"""Create CodeMirror extensions for Jac code (read-only)."""
def:pub createJacExtensions() -> list {
    # Get Jac language support
    jacLanguage = createJacLanguage();
    
    # Get Jaseci Orange theme
    themeComponents = createJacTheme();
    editorTheme = themeComponents[0];
    highlightStyle = themeComponents[1];
    
    # Build extensions array
    extensions = [
        jacLanguage,                              # Jac language support
        editorTheme,                              # Editor UI theme
        syntaxHighlighting(highlightStyle),       # Syntax colors
        lineNumbers(),                            # Line numbers
        EditorView.editable.of(false),           # Read-only
        EditorView.lineWrapping,                  # Word wrap
        keymap.of(defaultKeymap)                 # Basic key bindings
    ];
    
    return extensions;
}

"""Create a CodeMirror editor instance for Jac code."""
def:pub createJacEditor(parent: any, code: str) -> any {
    # Get extensions
    extensions = createJacExtensions();
    
    # Create editor state
    state = EditorState.create({
        doc: code,
        extensions: extensions
    });
    
    # Create editor view
    view = Reflect.construct(EditorView, [{
        state: state,
        parent: parent
    }]);
    
    return view;
}

"""Update existing editor with new code."""
def:pub updateEditorContent(editor: any, newCode: str) -> None {
    transaction = editor.state.update({
        changes: {
            from: 0,
            to: editor.state.doc.length,
            insert: newCode
        }
    });
    
    editor.dispatch(transaction);
}

"""Destroy editor instance."""
def:pub destroyEditor(editor: any) -> None {
    if editor and editor.destroy {
        editor.destroy();
    }
}