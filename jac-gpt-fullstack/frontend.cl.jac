"""Main entry point for Jac GPT Client application."""
import from react { useEffect }
import from "@jac/runtime" { Router, Routes, Route }
import from "@mantine/core" { MantineProvider, createTheme }

import from .pages.JacChatbot { JacChatbot }
import from .pages.LoginPage { LoginPage }
import from .pages.RegisterPage { RegisterPage }
import from .pages.ForgotPasswordPage { ForgotPasswordPage }
import from .pages.ResetPasswordPage { ResetPasswordPage }

import from ".utils.monaco_initializer" { initializeMonacoGlobally }

import "@mantine/core/styles.css";
import ".global.css";

"""Main app component with routing."""
def:pub app() -> any {
    useEffect(lambda {
        async def initMonaco() -> None {
            try {
                await initializeMonacoGlobally();
            } except Exception {
            }
        }

        initMonaco();
    }, []);
    # Custom Mantine theme for dark mode
    theme = createTheme({
        "primaryColor": "violet",
        "defaultRadius": "md",
        "fontFamily": "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif",
        "colors": {
            "dark": [
                "#C1C2C5",
                "#A6A7AB",
                "#909296",
                "#5c5f66",
                "#373A40",
                "#2C2E33",
                "#25262b",
                "#1A1B1E",
                "#141517",
                "#101113"
            ]
        }
    });

    return <MantineProvider theme={theme} defaultColorScheme="dark">
        <Router>
            <Routes>
                <Route path="/" element={<JacChatbot />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/forgot-password" element={<ForgotPasswordPage />} />
                <Route path="/reset-password" element={<ResetPasswordPage />} />
            </Routes>
        </Router>
    </MantineProvider>;
}
