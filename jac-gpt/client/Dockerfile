# Multi-stage build for client application
FROM oven/bun:1.1.30-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies
RUN bun install

# Copy source code
COPY . .

# Accept build arguments
# Accept build arguments
ARG VITE_API_URL=http://localhost:8080
ARG VITE_JAC_USER_EMAIL=test@mail.com
ARG VITE_JAC_USER_PASSWORD=password

# Set environment variables for the build
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_JAC_USER_EMAIL=$VITE_JAC_USER_EMAIL
ENV VITE_JAC_USER_PASSWORD=$VITE_JAC_USER_PASSWORD

# Build the application
RUN bun run build

# Production stage
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration if needed
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]