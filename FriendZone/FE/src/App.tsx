import React from "react";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Index from "./pages/Index";
import Login from "./pages/Login";
import Register from "./pages/Register";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

// Simple function to check if user is authenticated
const isAuthenticated = () => !!localStorage.getItem("token");

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <BrowserRouter>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          {/* Redirect root to login for unauthenticated users */}
          <Route
            path="/"
            element={
              isAuthenticated() ? <Index /> : <Navigate to="/login" replace />
            }
          />
          {/* Protected NotFound route */}
          <Route
            path="*"
            element={
              isAuthenticated() ? <NotFound /> : <Navigate to="/login" replace />
            }
          />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;