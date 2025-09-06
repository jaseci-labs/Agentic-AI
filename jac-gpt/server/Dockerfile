# Use Python 3.12 slim image as base
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Create directory for any data/logs if needed
RUN mkdir -p /app/data /app/logs

# Expose port 8000 (default for jac serve)
EXPOSE 8080

# Set environment variables for CORS
ENV CORS_ORIGINS="http://localhost:3000,http://127.0.0.1:3000"
ENV CORS_ALLOW_CREDENTIALS="true"

# Set the default command to serve the jac application
CMD ["jac", "serve", "server.jac", "--host", "0.0.0.0", "--port", "8080"]
