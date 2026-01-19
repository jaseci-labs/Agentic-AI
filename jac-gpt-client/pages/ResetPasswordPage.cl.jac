"""Reset password page component."""

import from react { useState, useEffect }
import from "@jac-client/utils" { Link, useNavigate }
import from ..utils.cn { cn }

def:pub ResetPasswordPage() -> any {
    navigate = useNavigate();

    has password: str = "";
    has confirmPassword: str = "";
    has error: str = "";
    has success: str = "";
    has loading: bool = False;
    has token: str = "";

    # Get token from URL on mount
    useEffect(lambda -> None {
        urlParams = URLSearchParams(window.location.search);
        tokenParam = urlParams.get("token");
        if tokenParam {
            token = tokenParam;
        }
    }, []);

    def handlePasswordChange(e: any) -> None {
        password = e.target.value;
        error = "";
    }

    def handleConfirmPasswordChange(e: any) -> None {
        confirmPassword = e.target.value;
        error = "";
    }

    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        error = "";
        success = "";

        if not password or not confirmPassword {
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
            # TODO: Implement password reset API call with token
            await Promise.resolve(setTimeout(lambda -> None { }, 1000));
            success = "Password has been reset successfully!";
            setTimeout(lambda -> None {
                navigate("/login");
            }, 2000);
        } except Exception as ex {
            console.error("Reset password error:", ex);
            error = "Failed to reset password. The link may have expired.";
        } finally {
            loading = False;
        }
    }

    # Input classes
    inputClass = cn(
        "w-full px-4 py-3 border rounded-xl text-base bg-surface border-border text-text-primary",
        "focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all",
        ("opacity-50 cursor-not-allowed" if loading else "")
    );

    # Button class
    buttonClass = cn(
        "w-full py-3.5 rounded-xl font-semibold text-white transition-all",
        "gradient-primary hover:opacity-90",
        ("opacity-50 cursor-not-allowed" if loading else "cursor-pointer")
    );

    # Error display
    errorDisplay = None;
    if error {
        errorDisplay = <div className="p-3 mb-4 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-sm">
            {error}
        </div>;
    }

    # Success display
    successDisplay = None;
    if success {
        successDisplay = <div className="p-3 mb-4 bg-green-500/10 border border-green-500/30 rounded-lg text-green-400 text-sm">
            {success}
        </div>;
    }

    return <div className="min-h-screen bg-background flex items-center justify-center p-5">
        <div className="bg-surface p-10 rounded-2xl w-full max-w-md border border-border">
            
            <div className="text-center mb-8">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full gradient-primary flex items-center justify-center">
                    <span className="text-2xl font-bold text-white">J</span>
                </div>
                <h1 className="text-3xl font-bold text-text-primary mb-2">
                    {"Reset Password"}
                </h1>
                <p className="text-text-secondary">
                    {"Enter your new password"}
                </p>
            </div>

            
            <form onSubmit={handleSubmit}>
                <div className="mb-4">
                    <label className="block mb-2 text-sm font-medium text-text-secondary">
                        {"New Password"}
                    </label>
                    <input
                        type="password"
                        value={password}
                        onChange={handlePasswordChange}
                        placeholder="Enter new password"
                        disabled={loading}
                        className={inputClass}
                        autoComplete="new-password"
                    />
                </div>

                <div className="mb-6">
                    <label className="block mb-2 text-sm font-medium text-text-secondary">
                        {"Confirm Password"}
                    </label>
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={handleConfirmPasswordChange}
                        placeholder="Confirm new password"
                        disabled={loading}
                        className={inputClass}
                        autoComplete="new-password"
                    />
                </div>

                {errorDisplay}
                {successDisplay}

                <button
                    type="submit"
                    disabled={loading}
                    className={buttonClass}
                >
                    {("Resetting..." if loading else "Reset Password")}
                </button>
            </form>

            
            <div className="mt-6 text-center text-sm text-text-secondary">
                {"Back to "}
                <Link to="/login" className="text-primary font-semibold hover:underline">
                    {"Sign in"}
                </Link>
            </div>
        </div>
    </div>;
}
