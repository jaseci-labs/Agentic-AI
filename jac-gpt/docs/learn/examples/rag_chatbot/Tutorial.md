# MCP Chatbot Full Guide

## 1. Introduction & Overview
This guide will walk you through building a Model Context Protocol (MCP) integrated chatbot using Jac Cloud, Jac-Streamlit, FastMCP, LangChain, ChromaDB, and multimodal LLMs. You'll learn to:

- Upload and index your own documents (PDFs, text files), images, and videos
- Chat with an AI assistant that uses both your documents, media, and web search
- Build modular MCP servers for tool management using FastMCP
- Use Object Spatial Programming with nodes and walkers for intelligent architecture
- Leverage Mean Typed Programming (MTP) for query classification and routing
- Implement multimodal LLM capabilities for image and video understanding

## 2. Features & Architecture
- **Multimodal Upload & Processing**: Upload PDFs, text files, images, and videos, which are processed and indexed for semantic and multimodal search.
- **Retrieval-Augmented Generation**: Combines LLMs with document retrieval for context-aware answers.
- **Multimodal Chat**: Users can chat about uploaded images and videos using advanced multimodal LLMs.
- **Web Search Integration**: Augments responses with real-time web search results using Serper API.
- **MCP Server Architecture**: Uses FastMCP for modular, scalable tool management.
- **Object Spatial Programming**: Leverages Jac's node-walker architecture for intelligent routing and task handling.
- **Mean Typed Programming (MTP)**: LLM-based classification determines the best approach for each query.
- **Streamlit Frontend**: User-friendly chat interface.
- **Session Management**: Maintains chat history and user sessions with file context.

**Project Structure:**

- `client.jac`: Streamlit frontend for chat and multimodal file upload (PDFs, images, videos)
- `server.jac`: Jac Cloud API server using Object Spatial Programming with Router, Session, and specialized Chat nodes
- `mcp_server.jac`: FastMCP server exposing document search and web search tools
- `mcp_client.jac`: Client interface for communicating with MCP servers
- `tools.jac`: RAG engine and web search implementations
- `docs/`: Example PDFs, images, and videos for testing

**Node-Walker Architecture:**
- **Router Node**: Uses Mean Typed Programming (MTP) to classify queries (RAG, QA, IMAGE, VIDEO)
- **Chat Nodes**: Specialized nodes for different interaction types
- **Session Node**: Manages user sessions and chat history
- **Walkers**: Handle routing (`infer`), session management (`interact`), and file uploads (`upload_file`)

## 3. Full Source Code

=== "client.jac"
    ```jac linenums="1"
    --8<-- "docs/learn/examples/rag_chatbot/solution/client.jac"
    ```

=== "mcp_server.jac"
    ```jac linenums="1"
    --8<-- "docs/learn/examples/rag_chatbot/solution/mcp_server.jac"
    ```

=== "mcp_client.jac"
    ```jac linenums="1"
    --8<-- "docs/learn/examples/rag_chatbot/solution/mcp_client.jac"
    ```

=== "server.jac"
    ```jac linenums="1"
    --8<-- "docs/learn/examples/rag_chatbot/solution/server.jac"
    ```

=== "tools.jac"
    ```jac linenums="1"
    --8<-- "docs/learn/examples/rag_chatbot/solution/tools.jac"
    ```

## 4. Setup Instructions
1. **Install dependencies** (Python 3.12+ recommended):
   ```bash
   pip install jaclang jac-cloud jac-streamlit mtllm langchain langchain-community langchain-openai langchain-chroma chromadb openai pypdf tiktoken requests mcp[cli] anyio
   ```
2. **Set environment variables** (for LLMs and web search):
   To use the Web Search, get a free API key from [Serper](https://serper.dev/).
   ```bash
   export OPENAI_API_KEY=<your-openai-key>
   export SERPER_API_KEY=<your-serper-key>
   ```
3. **Start the MCP server** (in one terminal):
   ```bash
   jac run mcp_server.jac
   ```
4. **Start the Jac Chatbot server** (in another terminal):
   ```bash
   jac serve server.jac
   ```
5. **Run the Streamlit frontend** (in a third terminal):
   ```bash
   jac streamlit client.jac
   ```

## 5. Streamlit Frontend (`client.jac`)
The frontend is built with Jac-Streamlit and handles authentication, multimodal file upload (PDFs, images, videos), and chat with an improved user experience. Users can upload various file types and chat about their content as well as general queries.

**Multimodal Upload and Chat Logic:**
```jac
--8<-- "docs/learn/examples/rag_chatbot/solution/client.jac"
```

## 6. MCP Server Architecture (`mcp_server.jac`)
The MCP server exposes tools for document search and web search using FastMCP.

```jac
--8<-- "docs/learn/examples/rag_chatbot/solution/mcp_server.jac"
```

## 7. MCP Client Interface (`mcp_client.jac`)
The MCP client handles communication with the MCP server.

```jac
--8<-- "docs/learn/examples/rag_chatbot/solution/mcp_client.jac"
```

## 8. RAG Engine & Web Search (`tools.jac`)
The RAG engine manages document ingestion, chunking, embedding, and retrieval for text documents. The web search component provides real-time search capabilities using the Serper API.

```jac
--8<-- "docs/learn/examples/rag_chatbot/solution/tools.jac"
```

## 9. Backend Logic & Object Spatial Programming (`server.jac`)
The backend demonstrates Object Spatial Programming with nodes and walkers. It uses Mean Typed Programming (MTP) for intelligent query classification and routing to specialized chat nodes. The architecture includes:

- **Router Node**: Classifies queries using LLM-based MTP
- **Chat Nodes**: Specialized nodes for RAG, QA, IMAGE, and VIDEO interactions
- **Session Node**: Manages user sessions and chat history
- **Walkers**: Handle different aspects of the system (routing, interaction, file upload)

```jac
--8<-- "docs/learn/examples/rag_chatbot/solution/server.jac"
```

## 10. Usage Guide
- Open the Streamlit app in your browser.
- Upload one or more files: PDFs, text files, images (PNG, JPG, JPEG, WEBP), or videos (MP4, AVI, MOV).
- The backend will process and index text documents for RAG, while images and videos are stored for multimodal chat.
- Start chatting! Ask questions about uploaded documents, images, videos, or general queries.
- The system uses Mean Typed Programming to intelligently route your questions to specialized nodes:
  - **RAG**: For document-based questions
  - **QA**: For general questions and web search
  - **IMAGE**: For image analysis and discussion
  - **VIDEO**: For video analysis and discussion

## 11. API Endpoints (selected)
- `POST /user/register` — Register a new user
- `POST /user/login` — Login and receive an access token
- `POST /walker/upload_file` — Upload any supported file type (requires Bearer token)
- `POST /walker/interact` — Chat endpoint with multimodal support (requires Bearer token)

See `http://localhost:8000/docs` for full Swagger API documentation.

## 12. Advanced Features
- **Multimodal Capabilities**: Chat with images and videos using GPT-4o-mini's vision capabilities
- **Object Spatial Programming**: Leverages Jac's unique node-walker architecture for clean separation of concerns
- **Mean Typed Programming (MTP)**: LLM-based query classification for intelligent routing
- **Web Search**: Augments answers with real-time web search results using Serper API
- **ChromaDB Vector Search**: Efficient semantic search over your documents
- **Session Management**: Each chat session is tracked with file context
- **FastMCP Architecture**: Modular tool system using Model Context Protocol with FastMCP
- **ReAct Pattern**: Used in chat nodes for intelligent reasoning and acting with tools
- **Extensible**: Add new nodes, walkers, or endpoints in Jac for custom logic

## 13. Troubleshooting
- Ensure all dependencies are installed and compatible with your Python version
- Make sure to start the MCP server before the main server
- If file upload fails, check server logs for errors and ensure file types are supported
- For LLM/API issues, verify your API keys and environment variables
- Check that all three services (MCP server, main server, frontend) are running on their respective ports
- For multimodal features, ensure you're using a compatible model like GPT-4o-mini

---
For a quick overview, see `Overview`.
