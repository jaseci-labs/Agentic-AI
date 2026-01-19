"""Authentication hook for managing user login/register state."""

import from "@jac-client/utils" { useNavigate, jacLogin, jacSignup, jacLogout, jacIsLoggedIn }

"""Hook for managing authentication state and actions."""
def:pub useAuth() -> any {
    navigate = useNavigate();

    has username: str = "";
    has password: str = "";
    has confirmPassword: str = "";
    has email: str = "";
    has error: str = "";
    has loading: bool = False;

    def handleUsernameChange(e: any) -> None {
        username = e.target.value;
    }

    def handlePasswordChange(e: any) -> None {
        password = e.target.value;
    }

    def handleConfirmPasswordChange(e: any) -> None {
        confirmPassword = e.target.value;
    }

    def handleEmailChange(e: any) -> None {
        email = e.target.value;
    }

    async def handleLogin(e: any) -> None {
        e.preventDefault();
        error = "";

        if not username or not password {
            error = "Please fill in all fields";
            return;
        }

        loading = True;

        try {
            success = await jacLogin(username, password);
            if success {
                navigate("/");
            } else {
                error = "Invalid username or password";
            }
        } except Exception as ex {
            console.error("Login error:", ex);
            error = "An error occurred during login";
        } finally {
            loading = False;
        }
    }

    async def handleRegister(e: any) -> None {
        e.preventDefault();
        error = "";

        if not username or not password or not email {
            error = "Please fill in all fields";
            return;
        }

        if password != confirmPassword {
            error = "Passwords do not match";
            return;
        }

        if password.length < 6 {
            error = "Password must be at least 6 characters";
            return;
        }

        loading = True;

        try {
            success = await jacSignup(username, password);
            if success {
                # Auto-login after successful registration
                loginSuccess = await jacLogin(username, password);
                if loginSuccess {
                    navigate("/");
                } else {
                    navigate("/login");
                }
            } else {
                error = "Registration failed. Username may already exist.";
            }
        } except Exception as ex {
            console.error("Registration error:", ex);
            error = "An error occurred during registration";
        } finally {
            loading = False;
        }
    }

    def handleLogout() -> None {
        jacLogout();
        navigate("/login");
    }

    return {
        "username": username,
        "password": password,
        "confirmPassword": confirmPassword,
        "email": email,
        "error": error,
        "loading": loading,
        "handleUsernameChange": handleUsernameChange,
        "handlePasswordChange": handlePasswordChange,
        "handleConfirmPasswordChange": handleConfirmPasswordChange,
        "handleEmailChange": handleEmailChange,
        "handleLogin": handleLogin,
        "handleRegister": handleRegister,
        "handleLogout": handleLogout
    };
}

"""Get username from JWT token stored in localStorage."""
def:pub getUsernameFromToken() -> str {
    token = localStorage.getItem("jac_token");
    result = "Guest";

    if token {
        try {
            parts = token.split(".");
            if parts.length > 1 {
                payload = JSON.parse(atob(parts[1]));
                result = payload.username or payload.email or "User";
            }
        } except Exception as decode_error {
            console.error("Failed to decode token:", decode_error);
        }
    }

    return result;
}

"""Check if user is authenticated."""
def:pub isUserAuthenticated() -> bool {
    return jacIsLoggedIn();
}
