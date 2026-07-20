"""Login page component with Mantine UI (Jaseci theme)."""

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
    Group,
    Anchor,
    Alert,
    Divider
}
import from "@tabler/icons-react" {
    IconUser,
    IconLock,
    IconAlertCircle
}
import from ..hooks.useAuth { useAuth }

def:pub LoginPage() -> JsxElement {
    hook = useAuth();
    navigate = useNavigate();

    username = hook.username;
    password = hook.password;
    error = hook.error;
    loading = hook.loading;

    # ---- Jaseci theme tokens ----
    BG = "#0b0b0f";
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
        "background": "radial-gradient(circle at 20% 10%, rgba(249,115,22,0.10) 0%, transparent 40%), " +
                      "radial-gradient(circle at 80% 30%, rgba(249,115,22,0.06) 0%, transparent 45%), " +
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
                        Welcome Back
                    </Text>
                    <Text size="sm" c={MUTED}>
                        Sign in to continue to Jac GPT
                    </Text>
                </Box>

                <form onSubmit={hook.handleLogin}>
                    <Stack gap="md">
                        <TextInput
                            label="Username"
                            placeholder="Enter your username"
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

                        <PasswordInput
                            label="Password"
                            placeholder="Enter your password"
                            value={password}
                            onChange={hook.handlePasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="current-password"
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
                            {(("Signing in..." if loading else "Sign In"))}
                        </Button>
                    </Stack>
                </form>

                <Group justify="center">
                    <Anchor
                        component={Link}
                        to="/forgot-password"
                        size="sm"
                        fw={700}
                        style={{
                            "color": ORANGE,
                            "textDecoration": "none"
                        }}
                    >
                        Forgot password?
                    </Anchor>
                </Group>

                <Text ta="center" size="sm" c={MUTED}>
                    {"Don't have an account? "}
                    <Anchor
                        component={Link}
                        to="/register"
                        fw={700}
                        style={{
                            "color": ORANGE,
                            "textDecoration": "none"
                        }}
                    >
                        Sign up
                    </Anchor>
                </Text>

                <Divider color="rgba(255,255,255,0.08)" />

                <Group justify="center">
                    <Anchor
                        component={Link}
                        to="/"
                        size="sm"
                        style={{
                            "color": "rgba(255,255,255,0.55)",
                            "textDecoration": "none"
                        }}
                    >
                        Continue as Guest (Limited messages)
                    </Anchor>
                </Group>
            </Stack>
        </Paper>
    </Box>;
}
