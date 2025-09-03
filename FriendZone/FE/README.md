# FriendZone Frontend

This is the frontend application for FriendZone built with React, TypeScript, and Vite.

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn package manager

## Setup Instructions

1. **Clone the repository**
   ```sh
   git clone <repository-url>
   cd FriendZone/FE
   ```

2. **Install dependencies**
   ```sh
   npm install
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory if needed and add any required environment variables.

## Available Scripts

- **Development server**
  ```sh
  npm run dev
  ```
  Starts the development server with hot-reload at `http://localhost:5173`

- **Build for production**
  ```sh
  npm run build
  ```

- **Build for development**
  ```sh
  npm run build:dev
  ```

- **Lint code**
  ```sh
  npm run lint
  ```

- **Preview production build**
  ```sh
  npm run preview
  ```

## Running the Server

To start the development server:

```sh
npm run dev
```

The application will be available at `http://localhost:5173`

## Development Workflow

1. Make sure all dependencies are installed
2. Start the development server using `npm run dev`
3. Make your changes - the server will automatically reload
4. Run linting with `npm run lint` before committing
5. Build the project with `npm run build` to check for any build errors

## Technologies Used

This project is built with:

- **Vite** - Fast build tool and development server
- **React** - Frontend library
- **TypeScript** - Type-safe JavaScript
- **shadcn/ui** - UI component library
- **Tailwind CSS** - Utility-first CSS framework
- **React Router** - Client-side routing
- **React Query** - Data fetching and state management
- **React Hook Form** - Form handling
- **Zod** - Schema validation

## Project Structure

```
FE/
├── src/
│   ├── components/     # Reusable UI components
│   ├── pages/         # Page components
│   ├── hooks/         # Custom React hooks
│   ├── lib/           # Utility functions
│   └── types/         # TypeScript type definitions
├── public/            # Static assets
└── package.json       # Dependencies and scripts
```

## Troubleshooting

- **Port already in use**: If port 5173 is busy, Vite will automatically use the next available port
- **Build errors**: Run `npm run lint` to check for code issues
- **Module not found**: Make sure all dependencies are installed with `npm install`
