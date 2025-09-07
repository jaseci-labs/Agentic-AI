# JAC GPT - Jaseci Assistant Chatbot

A sophisticated AI chatbot built with JAC (Jaseci programming language) that specializes in helping users with Jac programming language questions and Jaseci ecosystem guidance. The project features intelligent routing, persistent chat sessions, and comprehensive brand protection.

## 🚀 Architecture

- **JAC Server**: Advanced conversational AI with intelligent routing and session management
- **React Client**: Modern, responsive UI built with shadcn/ui components
- **MongoDB Integration**: Persistent chat history and session storage
- **RAG Engine**: Document retrieval system for enhanced responses (Langchain + ChromaDB)
- **Smart Routing**: Automatic classification of queries (QA, RAG, OFF_TOPIC)

## 📁 Project Structure

```
jac-gpt/
├── server/
│   ├── server.jac           # Main JAC server with routing and chat logic
│   ├── database.jac         # MongoDB integration for session persistence
│   ├── rag_engine.jac       # RAG system for document retrieval
│   ├── requirements.txt     # Python dependencies
│   └── docs/               # Documentation files for RAG
└── client/                 # React frontend with TypeScript
    ├── src/
    │   ├── services/
    │   │   └── jacServer.ts    # JAC server API client
    │   ├── components/
    │   │   ├── JacChatbot.tsx  # Main chat interface
    │   │   ├── ChatMessage.tsx # Message display component
    │   │   ├── ChatInput.tsx   # Message input component
    │   │   └── Sidebar.tsx     # Chat session management
    │   └── pages/
    └── package.json
```

## 🛠️ Setup Instructions

### Prerequisites

- **Python 3.12+** with JAC installed
- **Node.js 18+** and npm/yarn/bun
- **MongoDB** (local or cloud instance)
- **OpenAI API key** (for the JAC server)
- **Serper API key** (optional, for web search functionality)

### 1. JAC Server Setup

1. **Navigate to the server directory:**
   ```bash
   cd jac-gpt/server
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**
   Create a `.env` file in the server directory:
   ```bash
   # OpenAI Configuration
   OPENAI_API_KEY=your-openai-api-key-here
   
   # MongoDB Configuration
   MONGODB_URI=mongodb://localhost:27017/
   MONGODB_DATABASE=jaseci
   
   # Optional: Serper API for web search
   SERPER_API_KEY=your-serper-api-key-here
   ```

4. **Start MongoDB** (if using local instance):
   ```bash
   # Ubuntu/Debian
   sudo systemctl start mongod
   
   # macOS with Homebrew
   brew services start mongodb-community
   
   # Docker
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   ```

5. **Run the JAC server:**
   ```bash
   jac serve server.jac
   ```

   The server will start on `http://localhost:8000` by default.

### 2. React Client Setup

1. **Navigate to the client directory:**
   ```bash
   cd jac-gpt/client
   ```

2. **Install dependencies:**
   ```bash
   npm install
   # or
   yarn install
   # or
   bun install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and update the configuration:
   ```env
   # JAC Server Configuration
   VITE_API_URL=http://localhost:8000
   
   # Authentication (uses defaults if not provided)
   VITE_JAC_USER_EMAIL=test@mail.com
   VITE_JAC_USER_PASSWORD=password
   ```

4. **Run the React development server:**
   ```bash
   npm run dev
   # or
   yarn dev
   # or
   bun dev
   ```

   The client will start on `http://localhost:8080` by default.

## 🧠 How It Works

### Intelligent Message Routing

The JAC server automatically classifies every incoming message into one of three categories:

1. **QA**: General questions about Jac programming language and Jaseci ecosystem
2. **RAG**: Document-related queries requiring information retrieval
3. **OFF_TOPIC**: Non-Jac related messages (handled with brand protection)

### Chat Types & Features

#### QAChat Node
- **Purpose**: Handles general Jac/Jaseci questions and greetings
- **AI Method**: ReAct with up to 3 iterations for complex reasoning
- **Brand Protection**: Strictly focuses on Jac/Jaseci domain
- **Examples**: Syntax questions, best practices, code examples

#### RagChat Node  
- **Purpose**: Document-based queries and file content analysis
- **Integration**: Langchain + ChromaDB for vector search
- **Document Support**: PDF files in the `docs/` directory
- **AI Method**: ReAct with document context injection

#### OffTopicChat Node
- **Purpose**: Handles non-Jac related messages
- **Brand Protection**: Detects negative sentiment about Jac/Jaseci
- **Response Strategy**: Redirects to Jac-related topics or provides positive information

### Session Management

- **Persistent Storage**: MongoDB integration for chat history
- **Session Lifecycle**: Create, interact, retrieve, close operations
- **Auto-Registration**: Automatic user creation for new sessions
- **Statistics Tracking**: Message counts and session metadata

## Key Differences from Original

### Removed Features
- Multimodal support (images, videos)
- File upload functionality
- MCP (Model Context Protocol) tools
- RAG engine integration

### Simplified Architecture
- Focus on text-based conversations
- Streamlined routing (QA vs RAG)
- Direct JAC-to-OpenAI communication
- Clean session management

## Development

### JAC Server Development

The JAC server uses several key concepts:

- **Walkers**: `interact`, `new_session`, `get_session` for different operations
- **Nodes**: `Router`, `QAChat`, `RagChat`, `Session` for different functionalities
- **Routing**: Automatic classification of message types

### Frontend Development

The React client is built with:

- TypeScript for type safety
- Tailwind CSS for styling
- Custom JAC server service for API calls
- Session state management

## Troubleshooting

### Common Issues

1. **JAC Server won't start**:
   - Check if the OpenAI API key is set
   - Ensure JAC is properly installed
   - Verify port 8000 is available

2. **Frontend can't connect to server**:
   - Check if the JAC server is running
   - Verify the server URL in `.env`
   - Check browser console for CORS errors

3. **Authentication fails**:
   - The server automatically creates users, so this should rarely happen
   - Check server logs for authentication errors

### Logs

- JAC server logs appear in the terminal where you ran `jac serve`
- Frontend logs appear in the browser developer console

## Future Enhancements

- Document upload and RAG functionality
- File-based conversation persistence
- Advanced routing capabilities
- Streaming responses
- Chat history management
