# 🌍 AI Translator - Jac Full-Stack Application

A beautiful, AI-powered translation application built with **Jac** and **byLLM**. This app demonstrates how to create a full-stack web application using Jac's unified development approach—no separate frontend/backend, no complex configurations, just pure Jac code.

![AI Translator](https://img.shields.io/badge/Powered%20by-GPT--4o-blue)
![Jac](https://img.shields.io/badge/Built%20with-Jac-orange)

## ✨ Features

- 🤖 **AI-Powered Translation** using GPT-4o via byLLM
- 🎨 **Beautiful Gradient UI** with smooth animations
- 🌐 **8 Languages** supported (Spanish, French, German, Welsh, Japanese, Chinese, Italian, Portuguese)
- ⚡ **Real-time Translation** with loading states
- 📱 **Responsive Design** - works on mobile and desktop
- 🎯 **Pure Jac** - Single language for frontend and backend
- 🎪 **Organized CSS** - Separated styles for maintainability

## 🚀 Quick Start

### Prerequisites

Before starting, ensure you have:

1. **Node.js** installed (v18+ recommended)
   - **Linux**: Visit [nodejs.org](https://nodejs.org/en/download) and follow nvm installation
   - **macOS**: Download from [nodejs.org](https://nodejs.org/en/download)
   - Verify: `node -v` and `npm -v`

2. **Jac Client** installed:
   ```bash
   pip install jac-client
   ```

3. **OpenAI API Key** (for GPT-4o access):
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

### Installation

1. **Clone or navigate to the translator directory**:
   ```bash
   cd translator
   ```

2. **Start the development server**:
   ```bash
   jac serve app.jac
   ```

3. **Open your browser**:
   Navigate to [http://localhost:8000](http://localhost:8000)

That's it! 🎉 Your AI translator is now running.

## 📁 Project Structure

```
translator/
├── app.jac              # Backend: Walker definitions & LLM integration
├── app.cl.jac           # Frontend: React components & UI logic
├── styles.css           # Styling: All visual design
├── package.json         # Node.js dependencies
├── vite.config.js       # Vite configuration
└── build/              # Compiled output (auto-generated)
```

### File Breakdown

- **`app.jac`** - Backend logic
  - Defines `translate_text` walker
  - Integrates with byLLM (GPT-4o)
  - Handles translation requests

- **`app.cl.jac`** - Frontend UI
  - React-based interface
  - State management with hooks
  - User interaction handling

- **`styles.css`** - Visual design
  - Gradient backgrounds
  - Responsive layout
  - Animations and transitions

## 🏗️ How It Works

### Architecture Overview

```
User Input → Jac-client Frontend → Walker: translate_text → byLLM GPT-4o → Translation Result → Frontend
```

### Backend (`app.jac`)

The backend uses a **walker** to handle translation requests:

```jac
import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4o");

walker translate_text {
    has phrase: str;
    has language: str;

    def translate_to(language: str, phrase: str) -> str by llm();
    
    can translate with `root entry {
        result = self.translate_to(language=self.language, phrase=self.phrase);
        report {
            "translation": result,
            "original": self.phrase,
            "language": self.language
        };
    }
}
```

**Key Concepts**:
- **Walker**: Mobile computation unit that processes requests
- **byLLM Integration**: `by llm()` syntax for AI-powered functions
- **Report**: Returns structured data to frontend

### Frontend (`app.cl.jac`)

The frontend is pure Jac with React hooks:

```jac
import from react { useState }
cl import ".styles.css";

def app() -> any {
    let [inputText, setInputText] = useState("");
    let [targetLang, setTargetLang] = useState("Spanish");
    let [translation, setTranslation] = useState(None);
    let [loading, setLoading] = useState(False);

    async def handleTranslate() -> None {
        if not inputText.trim() { return; }
        setLoading(True);
        result = root spawn translate_text(phrase=inputText, language=targetLang);
        setTranslation(result.reports[0]);
        setLoading(False);
    }

    return <div className="translator-container">
        {/* UI components */}
    </div>;
}
```

**Key Features**:
- **React Hooks**: `useState` for state management
- **Walker Spawning**: `root spawn translate_text(...)` calls backend
- **Async/Await**: Clean asynchronous code
- **JSX in Jac**: HTML-like syntax directly in Jac

## 🎨 Customization

### Adding More Languages

Edit the language dropdown in `app.cl.jac`:

```jac
<option value="Korean">
    🇰🇷 Korean
</option>
```

### Changing the AI Model

Modify the model in `app.jac`:

```jac
glob llm = Model(model_name="gpt-4-turbo");  // or "claude-3-opus", etc.
```

### Styling Changes

Edit `styles.css` to customize:
- Colors: Modify gradient values
- Layout: Adjust padding, margins
- Animations: Change keyframes
- Responsiveness: Update media queries

### Custom Translation Logic

Add more sophisticated translation in `app.jac`:

```jac
def translate_to(language: str, phrase: str, context: str) -> str by llm(
    system_prompt="You are a professional translator with cultural awareness."
);
```

## 🧩 Key Concepts Explained

### 1. Walkers (Backend)

Walkers are mobile computational units that traverse the graph:

```jac
walker translate_text {
    has phrase: str;           # Input data
    has language: str;         # Configuration
    
    can translate with `root entry {
        # Logic executed when walker spawns
    }
}
```

### 2. Components (Frontend)

React-style components written in Jac:

```jac
def TranslationResult(data: dict) -> any {
    return <div>
        <h2>{data.language}</h2>
        <p>{data.translation}</p>
    </div>;
}
```

### 3. Walker Spawning

Call backend from frontend with `spawn`:

```jac
result = root spawn translate_text(phrase="Hello", language="Spanish");
// Result: { reports: [{translation: "Hola", ...}] }
```

### 4. byLLM Integration

AI-powered functions with `by llm()`:

```jac
def translate_to(language: str, phrase: str) -> str by llm();
```

This automatically:
- Constructs appropriate prompt
- Calls the LLM (GPT-4o)
- Parses and returns the result

## 📚 Learn More

### Official Documentation

- **Jac Client Docs**: [https://docs.jaseci.org/jac-client/](https://docs.jaseci.org/jac-client/)
- **byLLM Guide**: [https://docs.jaseci.org/learn/jac-byllm/](https://docs.jaseci.org/learn/jac-byllm/)
- **Jac Language**: [https://docs.jaseci.org/](https://docs.jaseci.org/)

### Example Projects

Explore more Jac applications:
- **Todo App**: Full CRUD application with authentication
- **FriendZone**: AI memory capture system
- **Content Creator**: Multi-agent workflow
- **Travel Planner**: Complex multi-agent orchestration

### Tutorials

1. [Building Your First Jac App](https://docs.jaseci.org/jac-client/guide-example/intro)
2. [Styling in Jac](https://docs.jaseci.org/jac-client/styling/intro)
3. [Agentic AI with byLLM](https://docs.jaseci.org/learn/jac-byllm/agentic_ai)

## 🛠️ Development

### Build for Production

```bash
npm run build
```

Outputs optimized files to `/build` directory.

### Run Production Preview

```bash
npm run preview
```

### Hot Reload

The dev server (`jac serve`) supports hot reload:
- Frontend changes: Auto-reload UI
- Backend changes: Restart server automatically

## 🐛 Troubleshooting

### Translation Not Working

1. **Check API Key**: Ensure `OPENAI_API_KEY` is set
   ```bash
   echo $OPENAI_API_KEY
   ```

2. **Verify Model Access**: Ensure you have GPT-4o access
   ```bash
   # Test with curl
   curl https://api.openai.com/v1/models \
     -H "Authorization: Bearer $OPENAI_API_KEY"
   ```

3. **Check Server Logs**: Look for errors in terminal

### Styling Issues

1. **Clear Cache**: Delete `/build` directory
   ```bash
   rm -rf build/
   ```

2. **Rebuild**: Restart dev server
   ```bash
   jac serve app.jac
   ```

### Port Already in Use

Change the port in `vite.config.js`:

```js
export default defineConfig({
  server: {
    port: 8001  // Change to any available port
  }
});
```

## 🤝 Contributing

This is an example project, but contributions are welcome!

1. Fork the repository
2. Create your feature branch
3. Commit changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **Jaseci Team** for creating the Jac language
- **OpenAI** for GPT-4o API
- **React Team** for the amazing UI library

## 💬 Support

- **Discord**: [Join Jaseci Community](https://discord.gg/jaseci)
- **Docs**: [https://docs.jaseci.org](https://docs.jaseci.org)
- **GitHub**: [Report Issues](https://github.com/Jaseci-Labs/jaseci)

---

**Made with ❤️ using Jaseci Stack**

Start building amazing AI applications with Jac today! 🚀
