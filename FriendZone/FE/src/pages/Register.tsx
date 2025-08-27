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
import { toast } from "@/components/ui/use-toast"; // Assuming a toast component for notifications

// Define form values with TypeScript
interface RegisterFormValues {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
}

// Define API response type
interface RegisterResponse {
  message: string;
  // Add other expected fields from your API
}

const Register: React.FC = () => {
  const navigate = useNavigate();
  const form = useForm<RegisterFormValues>({
    defaultValues: { name: "", email: "", password: "", confirmPassword: "" },
    mode: "onChange", // Validate on change for better UX
  });

  // Register API call
  const registerUser = async (values: RegisterFormValues): Promise<RegisterResponse> => {
    const response = await fetch(`${HOST}/user/register/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: values.name.trim(),
        email: values.email.trim().toLowerCase(),
        password: values.password,
      }),
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || "Registration failed");
    }
    return data;
  };

  const mutation = useMutation({
    mutationFn: registerUser,
    onSuccess: () => {
      toast({
        title: "Success",
        description: "Registration successful! Redirecting to login...",
      });
      setTimeout(() => navigate("/login"), 1500); // Delay for user to see toast
    },
    onError: (error: Error) => {
      toast({
        variant: "destructive",
        title: "Error",
        description: error.message || "An unexpected error occurred",
      });
    },
  });

  const onSubmit = (values: RegisterFormValues) => {
    if (values.password !== values.confirmPassword) {
      form.setError("confirmPassword", { message: "Passwords do not match" });
      return;
    }
    mutation.mutate(values);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="w-full max-w-md p-8 space-y-6 bg-card rounded-lg shadow-lg">
        <h1 className="text-2xl font-bold text-center">Register</h1>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="name"
              rules={{
                required: "Name is required",
                minLength: { value: 2, message: "Name must be at least 2 characters" },
                maxLength: { value: 50, message: "Name must be less than 50 characters" },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Name</FormLabel>
                  <FormControl>
                    <Input
                      type="text"
                      placeholder="Your name"
                      aria-describedby="name-error"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage id="name-error" />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="email"
              rules={{
                required: "Email is required",
                pattern: {
                  value: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
                  message: "Invalid email address",
                },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input
                      type="email"
                      placeholder="you@example.com"
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
                minLength: { value: 8, message: "Password must be at least 8 characters" },
                pattern: {
                  value: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
                  message: "Password must include uppercase, lowercase, number, and special character",
                },
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Password</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="********"
                      aria-describedby="password-error"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage id="password-error" />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="confirmPassword"
              rules={{
                required: "Please confirm your password",
                validate: (value) =>
                  value === form.getValues("password") || "Passwords do not match",
              }}
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Confirm Password</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="********"
                      aria-describedby="confirm-password-error"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage id="confirm-password-error" />
                </FormItem>
              )}
            />
            <Button
              type="submit"
              className="w-full"
              disabled={mutation.isPending || !form.formState.isValid}
            >
              {mutation.isPending ? (
                <span className="flex items-center gap-2">
                  <svg
                    className="animate-spin h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
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
                      d="M4 12a8 8 0 018-8v8h8a8 8 0 01-8 8 8 8 0 01-8-8z"
                    />
                  </svg>
                  Registering...
                </span>
              ) : (
                "Register"
              )}
            </Button>
          </form>
        </Form>
        <p className="text-sm text-center">
          Already have an account?{" "}
          <Link to="/login" className="text-primary underline">
            Login
          </Link>
        </p>
      </div>
    </div>
  );
};

export default Register;