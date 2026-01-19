"""Sidebar component with chat history and user actions using Mantine UI."""

import from react { useState }
import from "@jac-client/utils" { Link, jacIsLoggedIn, jacLogout, useNavigate }
import from "@mantine/core" {
    Box,
    Stack,
    Group,
    Text,
    Button,
    ActionIcon,
    ScrollArea,
    Paper,
    Avatar,
    Tooltip,
    Transition,
    Overlay,
    NavLink,
    Badge,
    Divider,
    UnstyledButton
}
import from "@tabler/icons-react" {
    IconPlus,
    IconX,
    IconChevronLeft,
    IconChevronRight,
    IconTrash,
    IconHelp,
    IconLogout,
    IconUserPlus,
    IconLogin,
    IconMessage,
    IconSparkles
}
import from ..hooks.useAuth { getUsernameFromToken }

"""Sidebar with chat history, new chat button, and user profile."""
def:pub Sidebar(
    isOpen: bool,
    onToggle: any,
    onNewChat: any,
    chatSessions: list = [],
    currentSessionId: str = "",
    onLoadSession: any = None,
    onDeleteSession: any = None,
    isLoading: bool = False,
    messageCount: int = 0,
    maxFreeMessages: int = 30
) -> any {
    has isExpanded: bool = True;
    navigate = useNavigate();
    isAuthenticated = jacIsLoggedIn();
    username = getUsernameFromToken();

    def toggleExpanded() -> None {
        isExpanded = not isExpanded;
    }

    def handleLogout() -> None {
        jacLogout();
        navigate("/login");
    }

    def getUserInitials() -> str {
        if username and username != "Guest" {
            return username[0].toUpperCase();
        }
        return "G";
    }

    # Sidebar width based on expanded state
    sidebarWidth = (260 if isExpanded else 60);

    # Mobile overlay
    mobileOverlay = None;
    if isOpen {
        mobileOverlay = <Box
            style={{
                "position": "fixed",
                "inset": "0",
                "background": "rgba(0,0,0,0.7)",
                "zIndex": "40",
                "display": "block"
            }}
            onClick={onToggle}
            hiddenFrom="lg"
        />;
    }

    # Sidebar container styles
    sidebarStyle = {
        "position": "fixed",
        "left": "0",
        "top": "0",
        "height": "100vh",
        "width": String(sidebarWidth) + "px",
        "background": "linear-gradient(180deg, #0f0f15 0%, #0a0a0f 100%)",
        "borderRight": "1px solid rgba(255,255,255,0.06)",
        "zIndex": "50",
        "transition": "all 0.3s ease",
        "transform": (("translateX(0)" if isOpen else "translateX(-100%)"))
    };

    # Logo section
    logoSection = <Box p="md" style={{"borderBottom": "1px solid rgba(255,255,255,0.06)"}}>
        <Group justify="space-between">
            {(
                <Group gap="sm">
                    <Box style={{
                        "width": "36px",
                        "height": "36px",
                        "borderRadius": "10px",
                        "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "boxShadow": "0 0 20px rgba(124, 58, 237, 0.3)"
                    }}>
                        <IconSparkles size={20} color="white" />
                    </Box>
                    <Box>
                        <Text fw={700} size="sm" c="white">Jaseci</Text>
                        <Text size="xs" c="dimmed">Jac companion</Text>
                    </Box>
                </Group>
                if isExpanded
                else
                <Box mx="auto" style={{
                    "width": "32px",
                    "height": "32px",
                    "borderRadius": "8px",
                    "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center"
                }}>
                    <IconSparkles size={16} color="white" />
                </Box>
            )}

            <Group gap="xs">
                <ActionIcon
                    onClick={toggleExpanded}
                    variant="subtle"
                    color="gray"
                    size="sm"
                    radius="md"
                    visibleFrom="lg"
                >
                    {((<IconChevronLeft size={16} />) if isExpanded else (<IconChevronRight size={16} />))}
                </ActionIcon>

                <ActionIcon
                    onClick={onToggle}
                    variant="subtle"
                    color="gray"
                    size="sm"
                    radius="md"
                    hiddenFrom="lg"
                >
                    <IconX size={16} />
                </ActionIcon>
            </Group>
        </Group>
    </Box>;

    # New chat button
    newChatButton = <Box px="md" py="sm">
        <Button
            onClick={onNewChat}
            disabled={isLoading}
            fullWidth={isExpanded}
            variant="light"
            color="violet"
            leftSection={((<IconPlus size={16} />) if isExpanded else None)}
            radius="md"
            style={{
                "background": "rgba(124, 58, 237, 0.15)",
                "border": "1px solid rgba(124, 58, 237, 0.3)"
            }}
        >
            {(("New Chat") if isExpanded else (<IconPlus size={16} />))}
        </Button>
    </Box>;

    # Chat sessions list
    chatSessionsList = None;
    if isExpanded {
        sessionsContent = <Text size="sm" c="dimmed" ta="center" py="lg">No chat history yet</Text>;
        if chatSessions.length > 0 {
            sessionsContent = <Stack gap={4}>
                {chatSessions.map(lambda session: any -> any {
                    isCurrentSession = session.id == currentSessionId;

                    return <UnstyledButton
                        key={session.id}
                        onClick={lambda -> None {
                            if not isLoading and onLoadSession {
                                onLoadSession(session.id);
                            }
                        }}
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "8px",
                            "padding": "8px 12px",
                            "borderRadius": "8px",
                            "width": "100%",
                            "background": (("rgba(124, 58, 237, 0.15)" if isCurrentSession else "transparent")),
                            "opacity": (("0.5" if isLoading else "1")),
                            "cursor": (("not-allowed" if isLoading else "pointer")),
                            "transition": "all 0.2s ease"
                        }}
                    >
                        <IconMessage size={14} color="#9ca3af" />
                        <Text size="sm" c={(("white" if isCurrentSession else "gray.5"))} style={{"flex": "1", "overflow": "hidden", "textOverflow": "ellipsis", "whiteSpace": "nowrap"}}>
                            {session.title}
                        </Text>
                        <ActionIcon
                            onClick={lambda e: any -> None {
                                e.stopPropagation();
                                if not isLoading and onDeleteSession {
                                    onDeleteSession(session.id);
                                }
                            }}
                            disabled={isLoading}
                            variant="subtle"
                            color="red"
                            size="xs"
                            radius="sm"
                            style={{"opacity": "0.6"}}
                        >
                            <IconTrash size={12} />
                        </ActionIcon>
                    </UnstyledButton>;
                })}
            </Stack>;
        }

        chatSessionsList = <Box px="md" style={{"flex": "1", "overflow": "hidden"}}>
            <Text size="xs" fw={500} c="dimmed" tt="uppercase" mb="sm">Recent Chats</Text>
            <ScrollArea style={{"height": "calc(100vh - 400px)"}} type="scroll">
                {sessionsContent}
            </ScrollArea>
        </Box>;
    }

    # User section for authenticated users
    userSection = None;
    if isAuthenticated and isExpanded {
        userSection = <Box px="md" py="sm">
            <Paper
                p="sm"
                radius="md"
                style={{
                    "background": "rgba(255,255,255,0.03)",
                    "border": "1px solid rgba(255,255,255,0.06)"
                }}
            >
                <Group gap="sm" mb="sm">
                    <Avatar
                        radius="xl"
                        size="sm"
                        style={{
                            "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)"
                        }}
                    >
                        {getUserInitials()}
                    </Avatar>
                    <Text size="sm" fw={500} c="white" style={{"flex": "1"}}>{username}</Text>
                </Group>
                <Button
                    onClick={handleLogout}
                    variant="subtle"
                    color="red"
                    fullWidth
                    size="xs"
                    leftSection={<IconLogout size={14} />}
                >
                    Log out
                </Button>
            </Paper>
        </Box>;
    }

    # Guest section for unauthenticated users
    guestSection = None;
    if not isAuthenticated and isExpanded {
        guestSection = <Box px="md" py="sm">
            <Paper
                p="sm"
                radius="md"
                style={{
                    "background": "rgba(255,255,255,0.03)",
                    "border": "1px solid rgba(255,255,255,0.06)"
                }}
            >
                <Badge
                    variant="light"
                    color="violet"
                    fullWidth
                    mb="sm"
                >
                    {"Free: "}{messageCount}{"/"}{maxFreeMessages}{" messages"}
                </Badge>

                <Stack gap="xs">
                    <Link to="/register" style={{"textDecoration": "none"}}>
                        <Button
                            fullWidth
                            variant="gradient"
                            gradient={{"from": "violet", "to": "purple", "deg": 135}}
                            size="sm"
                            leftSection={<IconUserPlus size={16} />}
                        >
                            Sign Up
                        </Button>
                    </Link>
                    <Link to="/login" style={{"textDecoration": "none"}}>
                        <Button
                            fullWidth
                            variant="outline"
                            color="violet"
                            size="sm"
                            leftSection={<IconLogin size={16} />}
                        >
                            Sign In
                        </Button>
                    </Link>
                </Stack>
            </Paper>
        </Box>;
    }

    # Collapsed auth buttons
    collapsedAuthSection = None;
    if not isExpanded {
        if isAuthenticated {
            collapsedAuthSection = <Stack gap="xs" align="center" px="xs">
                <Tooltip label="Log out" position="right">
                    <ActionIcon
                        onClick={handleLogout}
                        variant="subtle"
                        color="red"
                        size="lg"
                        radius="md"
                    >
                        <IconLogout size={18} />
                    </ActionIcon>
                </Tooltip>
            </Stack>;
        } else {
            collapsedAuthSection = <Stack gap="xs" align="center" px="xs">
                <Tooltip label="Sign Up" position="right">
                    <Link to="/register">
                        <ActionIcon
                            variant="light"
                            color="violet"
                            size="lg"
                            radius="md"
                        >
                            <IconUserPlus size={18} />
                        </ActionIcon>
                    </Link>
                </Tooltip>
                <Tooltip label="Sign In" position="right">
                    <Link to="/login">
                        <ActionIcon
                            variant="subtle"
                            color="gray"
                            size="lg"
                            radius="md"
                        >
                            <IconLogin size={18} />
                        </ActionIcon>
                    </Link>
                </Tooltip>
            </Stack>;
        }
    }

    # Help button
    helpButton = <Box px={(("md" if isExpanded else "xs"))} py="sm">
        <Tooltip label="Help & FAQ" position="right" disabled={isExpanded}>
            <Button
                onClick={lambda -> None { window.open("https://www.jac-lang.org/learn/data_spatial/FAQ/", "_blank"); }}
                variant="subtle"
                color="gray"
                fullWidth={isExpanded}
                size={(("sm" if isExpanded else "md"))}
                leftSection={((<IconHelp size={16} />) if isExpanded else None)}
                style={{"justifyContent": (("flex-start" if isExpanded else "center"))}}
            >
                {(("Help & FAQ") if isExpanded else (<IconHelp size={18} />))}
            </Button>
        </Tooltip>
    </Box>;

    # Status indicator
    statusIndicator = None;
    if isExpanded {
        statusIndicator = <Box px="md" pb="md">
            <Group gap="xs" style={{
                "background": "rgba(255,255,255,0.03)",
                "padding": "8px 12px",
                "borderRadius": "8px"
            }}>
                <Box style={{
                    "width": "8px",
                    "height": "8px",
                    "borderRadius": "50%",
                    "background": (("#22c55e" if isAuthenticated else "#7c3aed")),
                    "animation": "pulse 2s infinite"
                }} />
                <Text size="xs" c="dimmed">
                    {(("Ready to help") if isAuthenticated else ("Guest mode"))}
                </Text>
            </Group>
        </Box>;
    }

    return <>
        {mobileOverlay}

        <Box style={sidebarStyle}>
            <Box style={{"display": "flex", "flexDirection": "column", "height": "100%"}}>
                {logoSection}
                {newChatButton}
                {chatSessionsList}

                <Box style={{"marginTop": "auto"}}>
                    <Divider color="dark.6" />
                    {userSection}
                    {guestSection}
                    {collapsedAuthSection}
                    {helpButton}
                    {statusIndicator}
                </Box>
            </Box>
        </Box>

        <Box style={{"width": String(sidebarWidth) + "px", "flexShrink": "0"}} visibleFrom="lg" />
    </>;
}
