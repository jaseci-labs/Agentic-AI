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
  const keywords = [
    'node', 'edge', 'walker', 'can', 'with', 'entry', 'exit', 'def', 'class', 'obj',
    'enum', 'has', 'ability', 'visit', 'disengage', 'yield', 'try', 'except', 'finally', 'assert',
    'import', 'include', 'from', 'as', 'global', 'async', 'await', 'lambda',
    'here', 'self', 'root', 'super', 'init', 'postinit', 'visitor', 'impl',
    'and', 'or', 'not', 'in', 'is', 'True', 'False', 'None',
    'pass', 'del', 'raise', 'test', 'check'
  ];

  const controlFlowKeywords = [
    'if', 'else', 'elif', 'for', 'while', 'return', 'break', 'continue', 'spawn'
  ];

  const types = ['str', 'int', 'float', 'bool', 'list', 'dict', 'tuple', 'set', 'any', 'type'];

  // Tokenize the code to handle proper highlighting without overlaps
  const tokens = tokenizeJacCode(code);
  
  return tokens.map(token => {
    switch (token.type) {
      case 'comment':
        return `<span class="jac-comment">${escapeHtml(token.value)}</span>`;
      case 'string':
        return `<span class="jac-string">${escapeHtml(token.value)}</span>`;
      case 'number':
        return `<span class="jac-number">${escapeHtml(token.value)}</span>`;
      case 'keyword':
        return `<span class="jac-keyword">${escapeHtml(token.value)}</span>`;
      case 'control-flow':
        return `<span class="jac-control-flow">${escapeHtml(token.value)}</span>`;
      case 'special-keyword':
        return `<span class="jac-special-keyword">${escapeHtml(token.value)}</span>`;
      case 'type':
        return `<span class="jac-type">${escapeHtml(token.value)}</span>`;
      case 'class-name':
        return `<span class="jac-class-name">${escapeHtml(token.value)}</span>`;
      case 'module':
        return `<span class="jac-module">${escapeHtml(token.value)}</span>`;
      case 'function':
        return `<span class="jac-function">${escapeHtml(token.value)}</span>`;
      case 'variable':
        return `<span class="jac-variable">${escapeHtml(token.value)}</span>`;
      case 'operator':
        return `<span class="jac-operator">${escapeHtml(token.value)}</span>`;
      case 'arrow':
        return `<span class="jac-arrow">${escapeHtml(token.value)}</span>`;
      case 'bracket':
        return `<span class="jac-bracket-level-${token.level % 4}">${escapeHtml(token.value)}</span>`;
      default:
        return escapeHtml(token.value);
    }
  }).join('');
}

function tokenizeJacCode(code: string): Array<{type: string, value: string, level?: number}> {
  const tokens: Array<{type: string, value: string, level?: number}> = [];
  const keywords = new Set([
    'node', 'edge', 'walker', 'can', 'with', 'entry', 'exit', 'def', 'class', 'obj',
    'enum', 'has', 'ability', 'visit', 'disengage', 'yield', 'try', 'except', 'finally', 'assert',
    'import', 'include', 'from', 'as', 'global', 'async', 'await', 'lambda',
    'here', 'self', 'root', 'super', 'init', 'postinit', 'visitor', 'impl',
    'and', 'or', 'not', 'in', 'is', 'True', 'False', 'None',
    'pass', 'del', 'raise', 'test', 'check'
  ]);
  
  const controlFlowKeywords = new Set([
    'if', 'else', 'elif', 'for', 'while', 'return', 'break', 'continue', 'spawn'
  ]);
  
  const types = new Set(['str', 'int', 'float', 'bool', 'list', 'dict', 'tuple', 'set', 'any', 'type']);
  const operators = new Set(['=', '+', '-', '*', '/', '%', '==', '!=', '<', '>', '<=', '>=', '+=', '-=', '*=', '/=', '|', '&', '^', '~', '<<', '>>', '**']);
  const arrowOperators = new Set(['-->', '++>', '<--', '<++', '->', '<-']);

  let i = 0;
  let bracketStack: string[] = [];

  while (i < code.length) {
    // Skip whitespace
    if (/\s/.test(code[i])) {
      let whitespace = '';
      while (i < code.length && /\s/.test(code[i])) {
        whitespace += code[i];
        i++;
      }
      tokens.push({ type: 'whitespace', value: whitespace });
      continue;
    }

    // Handle comments
    if (code[i] === '#') {
      if (code[i + 1] === '*') {
        // Block comment
        let comment = '';
        while (i < code.length && !(code[i] === '*' && code[i + 1] === '#')) {
          comment += code[i];
          i++;
        }
        if (i < code.length) {
          comment += code[i] + code[i + 1]; // Add closing */
          i += 2;
        }
        tokens.push({ type: 'comment', value: comment });
      } else {
        // Line comment
        let comment = '';
        while (i < code.length && code[i] !== '\n') {
          comment += code[i];
          i++;
        }
        tokens.push({ type: 'comment', value: comment });
      }
      continue;
    }

    // Handle strings
    if (code[i] === '"' || code[i] === "'") {
      const quote = code[i];
      let string = quote;
      i++;
      while (i < code.length && code[i] !== quote) {
        if (code[i] === '\\' && i + 1 < code.length) {
          string += code[i] + code[i + 1];
          i += 2;
        } else {
          string += code[i];
          i++;
        }
      }
      if (i < code.length) {
        string += code[i]; // Add closing quote
        i++;
      }
      tokens.push({ type: 'string', value: string });
      continue;
    }

    // Handle numbers
    if (/\d/.test(code[i])) {
      let number = '';
      while (i < code.length && /[\d.]/.test(code[i])) {
        number += code[i];
        i++;
      }
      tokens.push({ type: 'number', value: number });
      continue;
    }

    // Handle brackets with nesting
    if (code[i] === '{') {
      bracketStack.push('{');
      tokens.push({ type: 'bracket', value: code[i], level: bracketStack.length - 1 });
      i++;
      continue;
    }
    
    if (code[i] === '}') {
      if (bracketStack.length > 0 && bracketStack[bracketStack.length - 1] === '{') {
        bracketStack.pop();
      }
      tokens.push({ type: 'bracket', value: code[i], level: bracketStack.length });
      i++;
      continue;
    }

    // Handle other brackets (parentheses and square brackets)
    if (code[i] === '(' || code[i] === '[') {
      bracketStack.push(code[i]);
      tokens.push({ type: 'bracket', value: code[i], level: bracketStack.length - 1 });
      i++;
      continue;
    }
    
    if (code[i] === ')' || code[i] === ']') {
      const expectedOpen = code[i] === ')' ? '(' : '[';
      if (bracketStack.length > 0 && bracketStack[bracketStack.length - 1] === expectedOpen) {
        bracketStack.pop();
      }
      tokens.push({ type: 'bracket', value: code[i], level: bracketStack.length });
      i++;
      continue;
    }

    // Handle operators (check for arrows first, then regular operators)
    let operator = '';
    let j = i;
    
    // Check for arrow operators first (check 3-char, then 2-char patterns)
    if (i + 2 < code.length) {
      const threeChar = code.slice(i, i + 3);
      if (threeChar === '-->' || threeChar === '<--') {
        // Split into -- (red) and > (white) or < (white) and -- (red)
        if (threeChar === '-->') {
          tokens.push({ type: 'arrow', value: '--' });
          tokens.push({ type: 'punctuation', value: '>' });
        } else if (threeChar === '<--') {
          tokens.push({ type: 'punctuation', value: '<' });
          tokens.push({ type: 'arrow', value: '--' });
        }
        i += 3;
        continue;
      } else if (threeChar === '++>' || threeChar === '<++') {
        // Split into ++ (white) and > (white) or < (white) and ++ (white)
        if (threeChar === '++>') {
          tokens.push({ type: 'punctuation', value: '++' });
          tokens.push({ type: 'punctuation', value: '>' });
        } else if (threeChar === '<++') {
          tokens.push({ type: 'punctuation', value: '<' });
          tokens.push({ type: 'punctuation', value: '++' });
        }
        i += 3;
        continue;
      }
    }
    
    // Check for 2-character single arrows (entire thing red)
    if (i + 1 < code.length) {
      const twoChar = code.slice(i, i + 2);
      if (twoChar === '->' || twoChar === '<-') {
        tokens.push({ type: 'arrow', value: twoChar });
        i += 2;
        continue;
      }
    }
    
    // Check for regular operators
    while (j < code.length && /[=+\-*/%<>!&|^~]/.test(code[j])) {
      operator += code[j];
      j++;
    }
    if (operator && operators.has(operator)) {
      tokens.push({ type: 'operator', value: operator });
      i = j;
      continue;
    }

    // Handle identifiers (keywords, types, functions, variables)
    if (/[a-zA-Z_]/.test(code[i])) {
      let identifier = '';
      while (i < code.length && /[a-zA-Z0-9_]/.test(code[i])) {
        identifier += code[i];
        i++;
      }
      
      // Handle dotted module names (like settings.config)
      const prevNonWhitespaceToken = tokens.slice().reverse().find(t => t.type !== 'whitespace');
      const isAfterImport = prevNonWhitespaceToken && 
        ['import', 'include', 'from'].includes(prevNonWhitespaceToken.value);
      
      if (isAfterImport) {
        // For imports, handle the full dotted path
        while (i < code.length && code[i] === '.') {
          identifier += code[i];
          i++;
          while (i < code.length && /[a-zA-Z0-9_]/.test(code[i])) {
            identifier += code[i];
            i++;
          }
        }
        tokens.push({ type: 'module', value: identifier });
        continue;
      }
      
      // Check context for class names and functions
      const isAfterArchetypeKeyword = prevNonWhitespaceToken && 
        ['walker', 'node', 'edge', 'obj', 'class', 'enum'].includes(prevNonWhitespaceToken.value);
      const isAfterCan = prevNonWhitespaceToken && prevNonWhitespaceToken.value === 'can';
      const isAfterWith = prevNonWhitespaceToken && prevNonWhitespaceToken.value === 'with';
      const isAfterRoot = prevNonWhitespaceToken && prevNonWhitespaceToken.value === 'root';
      
      // Special keywords like 'entry', 'exit' in certain contexts (check BEFORE general keywords)
      if (['entry', 'exit'].includes(identifier) && (isAfterWith || isAfterCan || isAfterRoot)) {
        tokens.push({ type: 'special-keyword', value: identifier });
      } else if (controlFlowKeywords.has(identifier)) {
        tokens.push({ type: 'control-flow', value: identifier });
      } else if (keywords.has(identifier)) {
        tokens.push({ type: 'keyword', value: identifier });
      } else if (types.has(identifier)) {
        tokens.push({ type: 'type', value: identifier });
      } else if (isAfterArchetypeKeyword || /^[A-Z]/.test(identifier)) {
        // Capitalized identifiers or identifiers after archetype keywords are class names
        tokens.push({ type: 'class-name', value: identifier });
      } else if (isAfterCan) {
        // Function names after 'can' keyword
        tokens.push({ type: 'function', value: identifier });
      } else {
        // Check if it's followed by '(' to determine if it's a function
        let k = i;
        while (k < code.length && /\s/.test(code[k])) k++;
        if (k < code.length && code[k] === '(') {
          tokens.push({ type: 'function', value: identifier });
        } else {
          tokens.push({ type: 'variable', value: identifier });
        }
      }
      continue;
    }

    // Handle single characters (punctuation, etc.)
    tokens.push({ type: 'punctuation', value: code[i] });
    i++;
  }

  return tokens;
}

function escapeHtml(text: string): string {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}