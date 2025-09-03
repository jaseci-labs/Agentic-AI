# FriendZone

FriendZone is an AI-powered memory sharing platform that allows users to capture, organize, and share their precious memories through an intelligent conversational interface. The application combines image analysis, natural language processing, and location services to create rich, contextual memories that can be shared with friends and family.

## 🎥 Demo

https://github.com/user-attachments/assets/fe7fca5b-356f-4e07-9820-6abb4dfe3889


## 🌟 Features

- **Intelligent Memory Creation**: Upload photos with location and date information to create rich, contextual memories
- **AI-Powered Analysis**: Automatic extraction of who, what, where, and when from your photos
- **Interactive Conversations**: Engage in natural conversations to add more context and details to your memories
- **Memory Sharing**: Share your memories with friends and family members
- **Social Network**: Connect with friends and manage your social connections
- **Profile Management**: Comprehensive user profile and authentication system
- **Location Integration**: Google Maps integration for accurate location tracking

## 🏗️ Project Architecture

This project is built as a full-stack application with separate backend and frontend components:

### Backend (BE)
- **Framework**: jac-cloud
- **Language**: jaclang
- **APIs**: RESTful API with comprehensive authentication and memory management
- **Services**: OpenAI integration, Google Maps API, AWS S3 for file storage

### Frontend (FE)
- **Framework**: React with TypeScript
- **Build Tool**: Vite
- **UI Components**: shadcn-ui with Tailwind CSS
- **State Management**: TanStack Query for server state
- **Routing**: React Router for navigation

## 🚀 Getting Started

### Prerequisites
- Python 3.12 or higher (for backend)
- Node.js & npm (for frontend)
- Required API keys (OpenAI, Google Maps)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd FriendZone
   ```

2. **Set up the Backend:**
   ```bash
   cd BE
   # Follow the setup instructions in BE/README.md
   ```

3. **Set up the Frontend:**
   ```bash
   cd FE
   # Follow the setup instructions in FE/README.md
   ```

## 📚 Documentation

For detailed setup, configuration, and usage instructions, please refer to the component-specific README files:

- **[Backend Documentation](./BE/README.md)** - Complete backend setup, API documentation, and usage examples
- **[Frontend Documentation](./FE/README.md)** - Frontend development setup, technologies used, and deployment instructions

## 🔧 Core Functionality

### Memory Management
- Create memories from photos with automatic AI analysis
- Add context through conversational interfaces
- Organize memories by date, location, and people
- Save and retrieve memories with rich metadata

### Social Features
- User registration and authentication
- Friend connections and management
- Memory sharing between users
- Comments and interactions on shared memories

### AI Integration
- Automatic image analysis and content extraction
- Natural language processing for conversations
- Location recognition and mapping
- Contextual follow-up questions

## 🛠️ Technologies Used

### Backend
- jaclang
- jac-cloud
- byLLm
- Python 3.12+
- OpenAI API
- Google Maps API
- AWS S3

### Frontend
- React 18
- TypeScript
- Vite
- shadcn-ui
- Tailwind CSS
- TanStack Query
- React Router

## 🌐 API Overview

The backend provides a comprehensive REST API with endpoints for:
- User authentication and management
- Memory creation and retrieval
- Session-based conversations
- Friend connections
- File upload and storage

For complete API documentation, see [BE/README.md](./BE/README.md).

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of the Jaseci Labs ecosystem and follows the organization's licensing terms.

## 🔗 Links

- [Jaseci](https://github.com/Jaseci-Labs/jaseci)
- [Backend Documentation](./BE/README.md)
- [Frontend Documentation](./FE/README.md)
