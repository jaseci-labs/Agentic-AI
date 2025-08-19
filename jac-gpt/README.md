# JAC GPT - AI Chatbot with JAC Backend

This project consists of a JAC (Jaseci) backend server and a React frontend that work together to provide an AI-powered chatbot experience. The frontend communicates with the JAC server instead of directly calling OpenAI APIs.

## Architecture

- **JAC Server**: Handles AI conversations, routing, and session management
- **React Client**: Modern UI for chatting with the AI assistant
- **No Direct OpenAI Calls**: All AI interactions go through the JAC backend

## Project Structure

```
jac-gpt/
├── server/
│   ├── simple_server.jac    # Main JAC server file
│   └── server.jac          # Original multimodal server (reference)
└── client/                 # React frontend
    ├── src/
    │   ├── services/
    │   │   ├── jacServer.ts    # JAC server API client
    │   │   └── openai.ts      # Legacy OpenAI service (not used)
    │   └── components/
    │       └── JacChatbot.tsx  # Main chat component
    └── ...
```

## Setup Instructions

### Prerequisites

- Python 3.8+ with JAC installed
- Node.js 18+ and npm/yarn/bun
- OpenAI API key (for the JAC server)

### 1. JAC Server Setup

1. **Navigate to the server directory:**
   ```bash
   cd jac-gpt/server
   ```

2. **Install JAC dependencies:**
   ```bash
   # Install jaclang and mtllm if not already installed
   pip install jaclang mtllm
   ```

3. **Set up environment variables:**
   ```bash
   export OPENAI_API_KEY="your-openai-api-key-here"
   ```

4. **Run the JAC server:**
   ```bash
   jac serve simple_server.jac
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
   
   Edit `.env` and update the JAC server URL if needed:
   ```env
   VITE_JAC_SERVER_URL=http://localhost:8000
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

   The client will start on `http://localhost:5173` by default.

## How It Works

### JAC Server Features

1. **Smart Routing**: Messages are automatically classified as either:
   - `QA`: General questions about Jac programming language
   - `RAG`: Document-related queries (for future document support)

2. **Session Management**: Each chat session is tracked with a unique session ID

3. **Authentication**: Simple email/password authentication with automatic user registration

### Frontend Integration

The React frontend interacts with the JAC server through several endpoints:

- `POST /walker/new_session` - Create a new chat session
- `POST /walker/interact` - Send messages and get AI responses
- `POST /walker/get_session` - Retrieve session history

### API Flow

1. **Session Creation**: When the app starts, a new session is created
2. **Authentication**: The client automatically authenticates with the JAC server
3. **Message Sending**: User messages are sent to `/walker/interact`
4. **AI Processing**: The JAC server routes the message, processes it with AI, and returns a response
5. **UI Update**: The React frontend displays the AI response

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
