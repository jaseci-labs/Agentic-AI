import React from "react";
import { useForm } from "react-hook-form";
import { useMutation } from "@tanstack/react-query";
import { useNavigate, Link } from "react-router-dom";
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { HOST } from "@/lib/config";
import { toast } from "@/components/ui/use-toast";

interface LoginFormValues {
  email: string;
  password: string;
}

interface LoginResponse {
  token: string;
  message?: string;
  user?: { id: string; email: string; name?: string }; // Added user field
}

const Login: React.FC = () => {
  const navigate = useNavigate();
  const form = useForm<LoginFormValues>({
    defaultValues: { email: "", password: "" },
    mode: "onChange",
  });

  const mutation = useMutation<LoginResponse, Error, LoginFormValues>({
    mutationFn: (values) => {
      console.log("Login attempt with values:", values); // Debug: Log form values
      return fetch(`${HOST}/user/login/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(values),
      }).then(async (res) => {
        const data = await res.json();
        console.log("Login response:", data); // Debug: Log server response
        if (!res.ok) {
          throw new Error(data.message || "Invalid email or password");
        }
        return data;
      });
    },
    onSuccess: (data) => {
      console.log("Login successful, token:", data.token);
      localStorage.setItem("token", data.token);
      if (data.user) {
        console.log("User data:", data.user);
        localStorage.setItem("user", JSON.stringify(data.user));
      }
      toast({
        title: "Login Successful",
        description: "You have been logged in successfully.",
      });
      // Redirect to home and reload to update authentication state
      navigate("/", { replace: true });
      window.location.reload();
    },
    onError: (error) => {
      console.error("Login error:", error.message); // Debug: Log error
      toast({
        title: "Login Failed",
        description: error.message,
        variant: "destructive",
      });
      form.setError("root", { message: error.message });
    },
  });

  const onSubmit = (values: LoginFormValues) => {
    mutation.mutate(values);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="w-full max-w-md p-8 space-y-6 bg-card rounded-lg shadow-lg">
        <h1 className="text-2xl font-bold text-center">Login</h1>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="email"
              rules={{
                required: "Email is required",
                pattern: {
                  value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                  message: "Please enter a valid email address",
                },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input
                      type="email"
                      placeholder="you@example.com"
                      autoComplete="email"
                      aria-describedby="email-error"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage id="email-error" />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="password"
              rules={{
                required: "Password is required",
                minLength: {
                  value: 6,
                  message: "Password must be at least 6 characters",
                },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Password</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="********"
                      autoComplete="current-password"
                      aria-describedby="password-error"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage id="password-error" />
                </FormItem>
              )}
            />
            <Button
              type="submit"
              className="w-full"
              disabled={mutation.isPending || !form.formState.isValid}
            >
              {mutation.isPending ? (
                <span className="flex items-center justify-center">
                  <svg
                    className="animate-spin h-5 w-5 mr-2 inline-block"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    />
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                    />
                  </svg>
                  Logging in...
                </span>
              ) : (
                "Login"
              )}
            </Button>
            {form.formState.errors.root && (
              <p className="text-sm font-medium text-destructive text-center">
                {form.formState.errors.root.message}
              </p>
            )}
          </form>
        </Form>
        <p className="text-sm text-center">
          Don't have an account?{" "}
          <Link
            to="/register"
            className="text-primary underline hover:text-primary/80"
            aria-label="Register for a new account"
          >
            Register
          </Link>
        </p>
      </div>
    </div>
  );
};

export default Login;