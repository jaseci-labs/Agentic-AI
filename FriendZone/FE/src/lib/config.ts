// Configuration for API host
// Uses Vite environment variable VITE_API_HOST if available, otherwise defaults to example.com
export const HOST = import.meta.env.VITE_API_HOST ?? "http://0.0.0.0:8000";