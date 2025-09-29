# Build an AI-Powered Multimodal MCP Chatbot

This project demonstrates how to build a modern chatbot capable of interacting with documents, images, and videos. By leveraging Jac's unique programming paradigms, you'll create a multimodal AI assistant with advanced capabilities.

## Features

- **Multimodal Interaction**: Chat with PDFs, text files, images, and videos.
- **Context-Aware Responses**: Search documents and provide relevant answers.
- **Web Search Integration**: Answer general questions using real-time web search.
- **AI Vision**: Understand and discuss images and videos.
- **Intelligent Query Routing**: Automatically route questions to specialized AI handlers.

## Learning Objectives

- **Object Spatial Programming (OSP)**: Organize your application using Jac's node-walker architecture.
- **Mean Typed Programming (MTP)**: Enable AI to classify and route user queries automatically.
- **Model Context Protocol (MCP)**: Build modular, reusable AI tools.
- **Multimodal AI Development**: Work with text, images, and videos in one application.

## Technologies Used

- **Jac Language**: Core application logic.
- **Jac Cloud**: Backend server infrastructure.
- **Streamlit**: User-friendly web interface.
- **ChromaDB**: Document search and storage.
- **OpenAI GPT**: AI chat and vision capabilities.
- **Serper API**: Real-time web search.

## Project Structure

- `client.jac`: Web interface for chat and file uploads.
- `server.jac`: Main application logic using Object Spatial Programming.
- `server.impl.jac`: Implementation details for `server.jac`.
- `mcp_server.jac`: Tool server for document and web search.
- `mcp_client.jac`: Interface for tool communication.
- `tools.jac`: Document processing and search logic.

## Setup Instructions

### Prerequisites

- Python 3.12 or newer.
- API keys for OpenAI and Serper.

### Installation

1. Install required packages:

   ```bash
   pip install jaclang jac-cloud jac-streamlit byllm langchain langchain-community langchain-openai langchain-chroma chromadb openai pypdf tiktoken requests mcp[cli] anyio
   ```

2. Set environment variables:

   ```bash
   export OPENAI_API_KEY=<your-openai-key>
   export SERPER_API_KEY=<your-serper-key>
   ```

### Running the Application

1. Start the tool server:

   ```bash
   jac run mcp_server.jac
   ```

2. Start the main application:

   ```bash
   jac serve server.jac
   ```

3. Launch the web interface:

   ```bash
   jac streamlit client.jac
   ```

Access the web interface at `http://localhost:8501`.

## Usage

1. **Register and log in** using the web interface.
2. **Upload files**: PDFs, text files, images, or videos.
3. **Start chatting**: Ask questions about your uploaded content or general topics.

## Troubleshooting

- Ensure all dependencies are installed and compatible.
- Verify API keys are set correctly.
- Check server logs for errors.
- Ensure services are running on their respective ports.

## Extending the Chatbot

- Add support for new file types (e.g., audio, spreadsheets).
- Integrate additional tools (e.g., weather APIs, database connections).
- Enhance AI models for specialized tasks.
- Implement hybrid search combining keyword and semantic search.
- Create custom chat nodes for domain-specific queries.

## API Endpoints

- `POST /user/register`: Create a new user account.
- `POST /user/login`: Login and get an access token.
- `POST /walker/upload_file`: Upload files (requires authentication).
- `POST /walker/interact`: Chat with the AI (requires authentication).

Visit `http://localhost:8000/docs` for full API documentation.
