"""Register page component with Mantine UI."""

import from react { useEffect }
import from "@jac-client/utils" { Link, useNavigate, jacIsLoggedIn }
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
    IconSparkles
}
import from ..hooks.useAuth { useAuth }

def:pub RegisterPage() -> any {
    hook = useAuth();
    navigate = useNavigate();

    username = hook.username;
    email = hook.email;
    password = hook.password;
    confirmPassword = hook.confirmPassword;
    error = hook.error;
    loading = hook.loading;

    # Redirect if already logged in
    useEffect(lambda -> None {
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
        >
            {error}
        </Alert>;
    }

    return <Box style={{
        "minHeight": "100vh",
        "background": "linear-gradient(135deg, #0a0a0f 0%, #0f0f15 50%, #0a0a0f 100%)",
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
                "background": "rgba(15, 15, 20, 0.95)",
                "border": "1px solid rgba(255,255,255,0.06)",
                "backdropFilter": "blur(10px)"
            }}
        >
            <Stack gap="lg">
                <Box ta="center">
                    <Box style={{
                        "width": "64px",
                        "height": "64px",
                        "margin": "0 auto 16px",
                        "borderRadius": "16px",
                        "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "boxShadow": "0 0 30px rgba(124, 58, 237, 0.3)"
                    }}>
                        <IconSparkles size={28} color="white" />
                    </Box>
                    <Text size="xl" fw={700} c="white" mb={4}>
                        Create Account
                    </Text>
                    <Text size="sm" c="dimmed">
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
                                "label": {"color": "#a1a1aa", "marginBottom": "8px"},
                                "input": {
                                    "background": "rgba(255,255,255,0.05)",
                                    "border": "1px solid rgba(255,255,255,0.1)",
                                    "color": "white"
                                }
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
                                "label": {"color": "#a1a1aa", "marginBottom": "8px"},
                                "input": {
                                    "background": "rgba(255,255,255,0.05)",
                                    "border": "1px solid rgba(255,255,255,0.1)",
                                    "color": "white"
                                }
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
                                "label": {"color": "#a1a1aa", "marginBottom": "8px"},
                                "input": {
                                    "background": "rgba(255,255,255,0.05)",
                                    "border": "1px solid rgba(255,255,255,0.1)",
                                    "color": "white"
                                }
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
                                "label": {"color": "#a1a1aa", "marginBottom": "8px"},
                                "input": {
                                    "background": "rgba(255,255,255,0.05)",
                                    "border": "1px solid rgba(255,255,255,0.1)",
                                    "color": "white"
                                }
                            }}
                        />

                        {errorDisplay}

                        <Button
                            type="submit"
                            fullWidth
                            loading={loading}
                            variant="gradient"
                            gradient={{"from": "violet", "to": "purple", "deg": 135}}
                            size="md"
                            mt="xs"
                        >
                            {(("Creating account..." if loading else "Create Account"))}
                        </Button>
                    </Stack>
                </form>

                <Text ta="center" size="sm" c="dimmed">
                    {"Already have an account? "}
                    <Anchor
                        component={Link}
                        to="/login"
                        c="violet.4"
                        fw={600}
                    >
                        Sign in
                    </Anchor>
                </Text>
            </Stack>
        </Paper>
    </Box>;
}
