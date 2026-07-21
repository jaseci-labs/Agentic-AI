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
    IconAlertCircle,
    IconArrowRight
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
    TEXT = "var(--text-primary)";
    MUTED = "var(--text-muted)";
    INPUT_BG = "var(--input-bg)";
    INPUT_BORDER = "var(--border-light)";
    ORANGE = "var(--primary)";
    ORANGE_DARK = "var(--primary-hover)";

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
                    "border": "1px solid rgba(239, 68, 68, 0.25)",
                    "borderRadius": "12px"
                },
                "message": {"color": "#fecaca"}
            }}
        >
            {error}
        </Alert>;
    }

    logoMark = <img
        src="/logo.png"
        alt="JacGPT"
        style={{
            "height": "42px",
            "width": "auto",
            "display": "block",
            "flexShrink": 0,
            "filter": "drop-shadow(0 0 12px rgba(249,115,22,0.35))"
        }}
    />;

    return <Paper
        p={36}
        radius={20}
        className="jc-float-card jc-card-in"
        style={{"width": "100%"}}
    >
        <Stack gap="lg">
                <Box>
                    <Group gap="sm" mb={20}>
                        {logoMark}
                        <Box>
                            <Text size="xl" fw={800} c={TEXT} style={{"letterSpacing": "-0.02em"}}>
                                Welcome back
                            </Text>
                            <Text size="sm" c={MUTED}>
                                Sign in to your JacGPT workspace
                            </Text>
                        </Box>
                    </Group>
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
                            radius="md"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px", "fontWeight": 600, "fontSize": "12px", "textTransform": "uppercase", "letterSpacing": "0.06em"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT,
                                    "height": "46px"
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
                            radius="md"
                            styles={{
                                "label": {"color": MUTED, "marginBottom": "8px", "fontWeight": 600, "fontSize": "12px", "textTransform": "uppercase", "letterSpacing": "0.06em"},
                                "input": {
                                    "background": INPUT_BG,
                                    "border": "1px solid " + INPUT_BORDER,
                                    "color": TEXT,
                                    "height": "46px"
                                },
                                "section": {"color": MUTED}
                            }}
                        />

                        <Group justify="flex-end" mt={-4}>
                            <Anchor
                                component={Link}
                                to="/forgot-password"
                                size="sm"
                                fw={600}
                                style={{"color": ORANGE, "textDecoration": "none"}}
                            >
                                Forgot password?
                            </Anchor>
                        </Group>

                        {errorDisplay}

                        <Button
                            type="submit"
                            fullWidth
                            loading={loading}
                            size="md"
                            radius="md"
                            rightSection={<IconArrowRight size={16} />}
                            styles={{
                                "root": {
                                    "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)",
                                    "border": "1px solid rgba(249,115,22,0.35)",
                                    "boxShadow": "0 10px 26px rgba(249, 115, 22, 0.22)",
                                    "height": "48px",
                                    "fontWeight": 700,
                                    "transition": "filter 200ms ease, transform 200ms ease"
                                },
                                "root:hover": {
                                    "filter": "brightness(1.06)",
                                    "transform": "translateY(-1px)"
                                }
                            }}
                        >
                            {(("Signing in..." if loading else "Sign In"))}
                        </Button>
                    </Stack>
                </form>

                <Divider color="var(--border)" label="or" labelPosition="center" styles={{"label": {"color": MUTED}}} />

                <Anchor
                    component={Link}
                    to="/"
                    style={{"textDecoration": "none"}}
                >
                    <Box style={{
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "gap": "8px",
                        "height": "46px",
                        "borderRadius": "12px",
                        "background": "var(--hover-bg)",
                        "border": "1px solid var(--border-light)",
                        "color": "var(--text-secondary)",
                        "fontSize": "14px",
                        "fontWeight": 600
                    }}>
                        Continue as Guest
                        <span style={{"color": "var(--text-muted)", "fontWeight": 400}}>(Limited messages)</span>
                        <IconArrowRight size={14} />
                    </Box>
                </Anchor>

                <Text ta="center" size="sm" c={MUTED}>
                    {"Don't have an account? "}
                    <Anchor
                        component={Link}
                        to="/register"
                        fw={700}
                        style={{"color": ORANGE, "textDecoration": "none"}}
                    >
                        Sign up free
                    </Anchor>
                </Text>
            </Stack>
        </Paper>;
}
