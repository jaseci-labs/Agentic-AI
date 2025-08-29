import React, { useState, useEffect } from "react";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Index from "./pages/Index";
import Login from "./pages/Login";
import Register from "./pages/Register";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(() => {
    const token = localStorage.getItem("token");
    return Boolean(token);
  });

  // Listen for storage changes to update authentication state
  useEffect(() => {
    const handleStorageChange = () => {
      const token = localStorage.getItem("token");
      const newAuthState = Boolean(token);
      if (newAuthState !== isAuthenticated) {
        setIsAuthenticated(newAuthState);
      }
    };

    // Check immediately
    handleStorageChange();

    // Listen for storage events (when localStorage is changed from another tab)
    window.addEventListener("storage", handleStorageChange);
    
    // Custom event for same-tab localStorage changes
    window.addEventListener("authStateChange", handleStorageChange);

    return () => {
      window.removeEventListener("storage", handleStorageChange);
      window.removeEventListener("authStateChange", handleStorageChange);
    };
  }, [isAuthenticated]);


  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <BrowserRouter>
          <Routes>
            {/* Public Routes */}
            <Route
              path="/login"
              element={
                isAuthenticated ? <Navigate to="/" replace /> : <Login />
              }
            />
            <Route
              path="/register"
              element={
                isAuthenticated ? <Navigate to="/" replace /> : <Register />
              }
            />
            {/* Index Route - Shows landing page or main app based on auth */}
            <Route path="/" element={<Index />} />
            {/* NotFound Route (public) */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </QueryClientProvider>
  );
};

export default App;