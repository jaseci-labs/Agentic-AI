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
    Group,
    Anchor,
    Alert
}
import from "@tabler/icons-react" {
    IconUser,
    IconMail,
    IconLock,
    IconAlertCircle,
    IconArrowRight
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
    TEXT = "var(--text-primary)";
    MUTED = "var(--text-muted)";
    INPUT_BG = "var(--input-bg)";
    INPUT_BORDER = "var(--border-light)";
    ORANGE = "var(--primary)";
    ORANGE_DARK = "var(--primary-hover)";

    # Shared premium input styling (matches Login)
    INPUT_STYLES = {
        "label": {"color": MUTED, "marginBottom": "8px", "fontWeight": 600, "fontSize": "12px", "textTransform": "uppercase", "letterSpacing": "0.06em"},
        "input": {
            "background": INPUT_BG,
            "border": "1px solid " + INPUT_BORDER,
            "color": TEXT,
            "height": "46px"
        },
        "section": {"color": MUTED}
    };

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
                                Create account
                            </Text>
                            <Text size="sm" c={MUTED}>
                                Join JacGPT to get unlimited access
                            </Text>
                        </Box>
                    </Group>
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
                            radius="md"
                            styles={INPUT_STYLES}
                        />

                        <TextInput
                            label="Email"
                            placeholder="Enter your email"
                            value={email}
                            onChange={hook.handleEmailChange}
                            disabled={loading}
                            leftSection={<IconMail size={16} />}
                            autoComplete="email"
                            radius="md"
                            styles={INPUT_STYLES}
                        />

                        <PasswordInput
                            label="Password"
                            placeholder="Create a password"
                            value={password}
                            onChange={hook.handlePasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            radius="md"
                            styles={INPUT_STYLES}
                        />

                        <PasswordInput
                            label="Confirm Password"
                            placeholder="Confirm your password"
                            value={confirmPassword}
                            onChange={hook.handleConfirmPasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            radius="md"
                            styles={INPUT_STYLES}
                        />

                        {errorDisplay}

                        <Button
                            type="submit"
                            fullWidth
                            loading={loading}
                            size="md"
                            radius="md"
                            mt="xs"
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
                        style={{"color": ORANGE, "textDecoration": "none"}}
                    >
                        Sign in
                    </Anchor>
                </Text>
            </Stack>
        </Paper>;
}
