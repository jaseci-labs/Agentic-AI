#!/bin/bash

# JAC GPT Server Startup Script

echo "Starting JAC GPT Server..."
echo "=========================="

# Check if JAC is installed
if ! command -v jac &> /dev/null; then
    echo "Error: JAC is not installed. Please install it first:"
    echo "pip install jaclang mtllm"
    exit 1
fi

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Warning: OPENAI_API_KEY environment variable is not set."
    echo "Please set it before starting the server:"
    echo "export OPENAI_API_KEY='your-api-key-here'"
    echo ""
    echo "Continuing anyway (server may fail to respond to AI queries)..."
fi

# Navigate to server directory
cd "$(dirname "$0")/server"

# Start the JAC server
echo "Starting JAC server on http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo ""

jac serve simple_server.jac
