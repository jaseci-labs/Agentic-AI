import { ONIGASM_WASM_PATH, LANGUAGE_CONFIG_PATH, JAC_GRAMMAR_PATH } from "./assetPaths";

export async function loadJacLanguage(monaco: any) {
  const { loadWASM } = await import("onigasm");
  const { Registry } = await import("monaco-textmate");
  const { wireTmGrammars } = await import("monaco-editor-textmate");

  monaco.languages.register({ id: "jac" });

  try {
    await loadWASM(ONIGASM_WASM_PATH);
  } catch (e) {
    console.warn("WASM already loaded or failed to load:", e);
  }

  const grammerConfigRes = await fetch(LANGUAGE_CONFIG_PATH);
  const jacGrammarRes = await fetch(JAC_GRAMMAR_PATH);
  const grammerConfig = await grammerConfigRes.json();
  const jacGrammar = await jacGrammarRes.json();

  const registry = new Registry({
    getGrammarDefinition: async () => ({
      format: "json",
      content: jacGrammar,
    }),
  });

  const grammars = new Map();
  grammars.set("jac", "source.jac");

  monaco.languages.setLanguageConfiguration("jac", grammerConfig);
  
  // Define custom Jac theme
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
      { token: "punctuation.section.jac", foreground: "D4D4D4" },
    ],
    colors: {
      "editor.foreground": "#FFFFFF",
      "editor.background": "#1e1e1e",
    }
  });

  return { registry, grammars, grammerConfig };
}

export async function highlightJacCode(code: string): Promise<string> {
  // Simple and safe syntax highlighting for Jac language
  let highlightedCode = code;

  // Escape HTML first
  highlightedCode = highlightedCode
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

  // Define patterns in order of priority (most specific first)
  const patterns = [
    // Comments (highest priority)
    { regex: /(#.*$)/gm, replacement: '<span class="jac-comment">$1</span>' },
    { regex: /(#\*[\s\S]*?\*#)/g, replacement: '<span class="jac-comment">$1</span>' },
    
    // Strings
    { regex: /("(?:[^"\\]|\\.)*")/g, replacement: '<span class="jac-string">$1</span>' },
    { regex: /('(?:[^'\\]|\\.)*')/g, replacement: '<span class="jac-string">$1</span>' },
    
    // Numbers
    { regex: /\b(\d+\.?\d*)\b/g, replacement: '<span class="jac-number">$1</span>' },
    
    // Archetype definitions
    { regex: /\b(node|edge|walker|obj|class|enum)(\s+)([a-zA-Z_]\w*)/g, 
      replacement: '<span class="jac-keyword">$1</span>$2<span class="jac-type">$3</span>' },
    
    // Function/ability definitions
    { regex: /\b(def|can|ability)(\s+)([a-zA-Z_]\w*)/g, 
      replacement: '<span class="jac-keyword">$1</span>$2<span class="jac-function">$3</span>' },
    
    // Keywords
    { regex: /\b(node|edge|walker|can|with|entry|exit|def|class|obj|enum|has|ability|if|else|elif|for|while|return|spawn|visit|disengage|yield|try|except|finally|assert|import|include|from|as|global|async|await|lambda|here|self|root|super|init|postinit|visitor|impl|and|or|not|in|is|True|False|None|break|continue|pass|del|raise|test|check)\b/g, 
      replacement: '<span class="jac-keyword">$1</span>' },
    
    // Built-in types
    { regex: /\b(str|int|float|bool|list|dict|tuple|set|any|type)\b/g, 
      replacement: '<span class="jac-type">$1</span>' },
  ];

  // Apply patterns sequentially, being careful not to modify already highlighted content
  patterns.forEach(pattern => {
    // Split by existing spans to avoid modifying highlighted content
    const parts = highlightedCode.split(/(<span[^>]*>.*?<\/span>)/);
    
    for (let i = 0; i < parts.length; i += 2) { // Only process non-span parts
      if (parts[i]) {
        parts[i] = parts[i].replace(pattern.regex, pattern.replacement);
      }
    }
    
    highlightedCode = parts.join('');
  });

  return highlightedCode;
}