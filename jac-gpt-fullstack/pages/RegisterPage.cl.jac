"""Register page component with Mantine UI (Jaseci theme)."""

import from react { useEffect }
import from "@jac/runtime" { Link, useNavigate, jacIsLoggedIn }
import from "@mantine/core" {
    Box,
    Paper,
    Text,
    TextInput,
    PasswordInput,
    Button,
    Stack,
    Anchor,
    Alert
}
import from "@tabler/icons-react" {
    IconUser,
    IconMail,
    IconLock,
    IconAlertCircle
}
import from ..hooks.useAuth { useAuth }

def:pub RegisterPage() -> JsxElement {
    hook = useAuth();
    navigate = useNavigate();

    username = hook.username;
    email = hook.email;
    password = hook.password;
    confirmPassword = hook.confirmPassword;
    error = hook.error;
    loading = hook.loading;

    # ---- Jaseci theme tokens ----
    BG = "#0b0b0f";
    CARD = "#141414";
    BORDER = "rgba(255,255,255,0.10)";
    BORDER_SOFT = "rgba(255,255,255,0.06)";
    TEXT = "#ffffff";
    MUTED = "#9ca3af";
    INPUT_BG = "rgba(255,255,255,0.04)";
    INPUT_BORDER = "rgba(255,255,255,0.10)";
    ORANGE = "#f97316";
    ORANGE_DARK = "#ea580c";

    # Redirect if already logged in
    useEffect(lambda () {
        if jacIsLoggedIn() {
            navigate("/");
        }
    }, []);

    # Error display
    errorDisplay = None;
    if error {
        errorDisplay = <Alert
            icon={<IconAlertCircle size={16} />}
            color="red"
            variant="light"
            mb="md"
            styles={{
                "root": {
                    "background": "rgba(239, 68, 68, 0.08)",
                    "border": "1px solid rgba(239, 68, 68, 0.25)"
                },
                "message": {"color": "#fecaca"}
            }}
        >
            {error}
        </Alert>;
    }

    return <Box style={{
        "minHeight": "100vh",
        "background": "radial-gradient(circle at 20% 10%, rgba(249,115,22,0.10) 0%, transparent 40%), radial-gradient(circle at 80% 30%, rgba(249,115,22,0.06) 0%, transparent 45%), " +
                      "linear-gradient(135deg, " + BG + " 0%, #0f0f15 50%, " + BG + " 100%)",
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "center",
        "padding": "20px"
    }}>
        <Paper
            p="xl"
            radius="lg"
            style={{
                "width": "100%",
                "maxWidth": "420px",
                "background": "rgba(20, 20, 20, 0.92)",
                "border": "1px solid " + BORDER_SOFT,
                "backdropFilter": "blur(10px)",
                "boxShadow": "0 20px 60px rgba(0,0,0,0.55)"
            }}
        >
            <Stack gap="lg">
                <Box ta="center">
                    <Box style={{
                        "width": "64px",
                        "height": "64px",
                        "margin": "0 auto 16px",
                        "borderRadius": "16px",
                        "background": "rgba(249, 115, 22, 0.12)",
                        "border": "1px solid rgba(249, 115, 22, 0.35)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "boxShadow": "0 0 26px rgba(249, 115, 22, 0.18)"
                    }}>
                        <Box style={{
                            "width": "34px",
                            "height": "34px",
                            "borderRadius": "12px",
                            "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center"
                        }}>
                            <span style={{
                                "display": "block",
                                "width": "10px",
                                "height": "10px",
                                "borderRadius": "50%",
                                "background": "rgba(255,255,255,0.85)"
                            }} />
                        </Box>
                    </Box>

                    <Text size="xl" fw={700} c={TEXT} mb={4}>
                        Create Account
                    </Text>
                    <Text size="sm" c={MUTED}>
                        Join Jac GPT to get unlimited access
                    </Text>
                </Box>

                <form onSubmit={hook.handleRegister}>
                    <Stack gap="md">
                        <TextInput
                            label="Username"
                            placeholder="Choose a username"
                            value={username}
                            onChange={hook.handleUsernameChange}
                            disabled={loading}
                            leftSection={<IconUser size={16} />}
                            autoComplete="username"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT
                                },
                                "section": {"color": MUTED}
                            }}
                        />

                        <TextInput
                            label="Email"
                            placeholder="Enter your email"
                            value={email}
                            onChange={hook.handleEmailChange}
                            disabled={loading}
                            leftSection={<IconMail size={16} />}
                            autoComplete="email"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT
                                },
                                "section": {"color": MUTED}
                            }}
                        />

                        <PasswordInput
                            label="Password"
                            placeholder="Create a password"
                            value={password}
                            onChange={hook.handlePasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT
                                },
                                "section": {"color": MUTED}
                            }}
                        />

                        <PasswordInput
                            label="Confirm Password"
                            placeholder="Confirm your password"
                            value={confirmPassword}
                            onChange={hook.handleConfirmPasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT
                                },
                                "section": {"color": MUTED}
                            }}
                        />

                        {errorDisplay}

                        <Button
                            type="submit"
                            fullWidth
                            loading={loading}
                            size="md"
                            mt="xs"
                            styles={{
                                "root": {
                                    "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)",
                                    "border": "1px solid rgba(249,115,22,0.35)",
                                    "boxShadow": "0 10px 26px rgba(249, 115, 22, 0.18)"
                                },
                                "root:hover": {
                                    "filter": "brightness(1.05)"
                                }
                            }}
                        >
                            {(("Creating account..." if loading else "Create Account"))}
                        </Button>
                    </Stack>
                </form>

                <Text ta="center" size="sm" c={MUTED}>
                    {"Already have an account? "}
                    <Anchor
                        component={Link}
                        to="/login"
                        fw={700}
                        style={{
                            "color": ORANGE,
                            "textDecoration": "none"
                        }}
                    >
                        Sign in
                    </Anchor>
                </Text>
            </Stack>
        </Paper>
    </Box>;
}
