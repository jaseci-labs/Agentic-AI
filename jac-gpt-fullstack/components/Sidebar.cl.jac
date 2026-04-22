import from react { useState, useEffect }
import from "@jac/runtime" { Link, jacIsLoggedIn, jacLogout, useNavigate }
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
    Divider,
    UnstyledButton,
    Menu
}
import from "@mantine/hooks" { useMediaQuery }
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
    IconShieldCheck,
    IconDots
}
import from ..hooks.useAuth { getUsernameFromToken }
import from ..services.jacService { getUserProfile }

"""Sidebar with chat history, new chat button, and user actions."""
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
) -> JsxElement {

    isDesktop = useMediaQuery("(min-width: 1024px)");
    shouldShow = isDesktop or isOpen;

    has isExpanded: bool = True;
    has isAdmin: bool = False;
    has hoveredSessionId: str = "";
    has sidebarError: any = None;

    navigate = useNavigate();
    isAuthenticated = jacIsLoggedIn();
    username = getUsernameFromToken();

    useEffect(lambda -> None {
        async def checkAdmin() -> None {
            if isAuthenticated and username and username != "Guest" {
                try {
                    result = await getUserProfile(username);
                    if result.isAdmin {
                        isAdmin = True;
                    } elif not result.success {
                        sidebarError = {
                            "code": result.code or "ERR_GET_USER_PROFILE",
                            "message": result.message or "Could not verify account privileges.",
                            "retryable": False
                        };
                    }
                } except Exception as e {
                    console.error("Admin check error:", e);
                    sidebarError = {
                        "code": "ERR_GET_USER_PROFILE",
                        "message": "Could not verify account privileges.",
                        "retryable": False
                    };
                }
            }
        }
        checkAdmin();
    }, [isAuthenticated]);

    useEffect(lambda -> None {
        authError = localStorage.getItem("jac_auth_error");
        if authError {
            sidebarError = {
                "code": "ERR_AUTH_TOKEN_DECODE",
                "message": authError.replace("[ERR_AUTH_TOKEN_DECODE] ", "") if authError.includes("[ERR_AUTH_TOKEN_DECODE]") else authError,
                "retryable": False
            };
            localStorage.removeItem("jac_auth_error");
        }
    }, []);

    BG = "#141414";
    BORDER = "#374151";
    TEXT = "#ffffff";
    MUTED = "#9ca3af";
    MUTED2 = "#6b7280";
    PANEL = "rgba(255,255,255,0.04)";
    PANEL_BORDER = "rgba(255,255,255,0.08)";
    ORANGE = "#f97316";

    LOGO_SRC = "/logo.png";

    def toggleExpanded() -> None {
        isExpanded = not isExpanded;
    }

    def handleLogout() -> None {
        jacLogout();
        navigate("/login");
    }

    def handleLogoClick() -> None {
        if onNewChat {
            onNewChat();
        }
        navigate("/");
    }

    def getUserInitials() -> str {
        if username and username != "Guest" {
            return username[0].toUpperCase();
        }
        return "G";
    }

    sidebarWidth = (260 if isExpanded else 60);

    mobileOverlay = None;
    if isOpen and not isDesktop {
        mobileOverlay = <Box
            style={{
                "position": "fixed",
                "inset": "0",
                "background": "rgba(0,0,0,0.5)",
                "zIndex": "40"
            }}
            onClick={onToggle}
        />;
    }

    sidebarStyle = {
        "position": "fixed",
        "left": "0",
        "top": "0",
        "height": "100vh",
        "width": String(sidebarWidth) + "px",
        "background": BG,
        "borderRight": "1px solid " + BORDER,
        "zIndex": "50",
        "transition": "all 0.25s ease",
        "transform": (("translateX(0)" if shouldShow else "translateX(-100%)"))
    };

    logoSection = <Box
        style={{
            "padding": "14px 14px",
            "borderBottom": "1px solid " + BORDER
        }}
    >
        <Group justify="space-between" align="center" wrap="nowrap">
            {(
                <Group gap="sm" align="center" wrap="nowrap">
                    <Box
                        onClick={handleLogoClick}
                        style={{
                            "width": "44px",
                            "height": "44px",
                            "borderRadius": "12px",
                            "background": "rgba(249,115,22,0.12)",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center",
                            "boxShadow": "0 0 14px rgba(249,115,22,0.25)",
                            "cursor": "pointer",
                            "transition": "transform 0.2s ease"
                        }}
                        onMouseEnter={lambda e: any -> None {
                            e.currentTarget.style.transform = "scale(1.05)";
                        }}
                        onMouseLeave={lambda e: any -> None {
                            e.currentTarget.style.transform = "scale(1)";
                        }}
                    >
                        <img
                            src={LOGO_SRC}
                            alt="Jaseci"
                            style={{
                                "width": "28px",
                                "height": "28px",
                                "objectFit": "contain",
                                "display": "block"
                            }}
                        />
                    </Box>

                    <Box style={{"lineHeight": "1.1"}}>
                        <Text fw={700} style={{"fontSize": "18px", "color": TEXT}}>
                            Jaseci
                        </Text>
                        <Text style={{"fontSize": "12px", "color": MUTED, "marginTop": "2px"}}>
                            Jac programming companion
                        </Text>
                    </Box>
                </Group>
                if isExpanded
                else
                <Box
                    mx="auto"
                    onClick={handleLogoClick}
                    style={{
                        "width": "44px",
                        "height": "44px",
                        "borderRadius": "12px",
                        "background": "rgba(249,115,22,0.12)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "boxShadow": "0 0 14px rgba(249,115,22,0.25)",
                        "cursor": "pointer",
                        "transition": "transform 0.2s ease"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        e.currentTarget.style.transform = "scale(1.05)";
                    }}
                    onMouseLeave={lambda e: any -> None {
                        e.currentTarget.style.transform = "scale(1)";
                    }}
                >
                    <img
                        src={LOGO_SRC}
                        alt="Jaseci"
                        style={{
                            "width": "26px",
                            "height": "26px",
                            "objectFit": "contain",
                            "display": "block"
                        }}
                    />
                </Box>
            )}

            <Group gap="xs" align="center" wrap="nowrap">
                <ActionIcon
                    onClick={toggleExpanded}
                    variant="subtle"
                    size="sm"
                    radius="md"
                    visibleFrom="lg"
                    style={{"color": MUTED}}
                >
                    {((<IconChevronLeft size={18} />) if isExpanded else (<IconChevronRight size={18} />))}
                </ActionIcon>

                <ActionIcon
                    onClick={onToggle}
                    variant="subtle"
                    size="sm"
                    radius="md"
                    hiddenFrom="lg"
                    style={{"color": MUTED}}
                >
                    <IconX size={18} />
                </ActionIcon>
            </Group>
        </Group>
    </Box>;

    newChatButton = <Box px="md" py="sm">
        <Button
            onClick={onNewChat}
            disabled={isLoading}
            fullWidth={True}
            radius="md"
            variant="outline"
            styles={{
                "root": {
                    "background": "rgba(55, 65, 81, 0.80)",
                    "borderColor": "rgba(75, 85, 99, 1)",
                    "color": TEXT,
                    "height": "44px",
                    "paddingLeft": (("14px" if isExpanded else "0px")),
                    "paddingRight": (("14px" if isExpanded else "0px"))
                }
            }}
        >
            <Group justify="center" gap="sm" style={{"width": "100%"}}>
                <IconPlus size={16} />
                {(<Text fw={600} style={{"color": TEXT, "fontSize": "14px"}}>New Chat</Text>) if isExpanded else None}
            </Group>
        </Button>
    </Box>;

    sessionsContent = <Text size="sm" c={MUTED2} ta="center" py="lg">No chat history yet</Text>;

    if isExpanded and chatSessions.length > 0 {
        sessionsContent = <Stack gap={8}>
            {chatSessions.map(lambda session: any -> any {
                isCurrentSession = session.id == currentSessionId;
                isHovered = hoveredSessionId == session.id;

                return <Box
                    key={session.id}
                    style={{
                        "position": "relative",
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "8px",
                        "padding": "8px 12px",
                        "borderRadius": "8px",
                        "width": "100%",
                        "background": (("rgba(55, 65, 81, 0.8)" if isCurrentSession else "transparent")),
                        "color": (TEXT if isCurrentSession else "#d1d5db"),
                        "opacity": (("0.5" if isLoading else "1")),
                        "cursor": (("not-allowed" if isLoading else "pointer")),
                        "transition": "all 0.2s ease"
                    }}
                    onClick={lambda -> None {
                        if not isLoading and onLoadSession {
                            onLoadSession(session.id);
                        }
                    }}
                    onMouseEnter={lambda -> None { hoveredSessionId = session.id; }}
                    onMouseLeave={lambda -> None { hoveredSessionId = ""; }}
                >
                    <Text
                        size="sm"
                        style={{
                            "flex": "1",
                            "overflow": "hidden",
                            "textOverflow": "ellipsis",
                            "whiteSpace": "nowrap"
                        }}
                        c={(TEXT if isCurrentSession else "#d1d5db")}
                    >
                        {session.title}
                    </Text>

                    {(
                        <Menu position="right-start" shadow="md">
                            <Menu.Target>
                                <ActionIcon
                                    variant="subtle"
                                    size="xs"
                                    radius="sm"
                                    onClick={lambda e: any -> None {
                                        e.stopPropagation();
                                    }}
                                    style={{
                                        "color": MUTED,
                                        "opacity": "0.8"
                                    }}
                                >
                                    <IconDots size={14} />
                                </ActionIcon>
                            </Menu.Target>

                            <Menu.Dropdown>
                                <Menu.Item
                                    color="red"
                                    leftSection={<IconTrash size={14} />}
                                    onClick={lambda e: any -> None {
                                        e.stopPropagation();
                                        if not isLoading and onDeleteSession {
                                            onDeleteSession(session.id);
                                        }
                                    }}
                                    disabled={isLoading}
                                >
                                    Delete chat
                                </Menu.Item>
                            </Menu.Dropdown>
                        </Menu>
                        if isHovered
                        else None
                    )}
                </Box>;
            })}
        </Stack>;
    }

    chatSessionsList = None;
    if isExpanded {
        chatSessionsList = <Box px="md" style={{"height": "100%", "display": "flex", "flexDirection": "column", "overflow": "hidden"}}>
            <Text size="xs" fw={600} c={MUTED} tt="uppercase" mb="sm">Recent Chats</Text>
            <ScrollArea style={{"flex": "1", "minHeight": "0"}} type="scroll">
                {sessionsContent}
            </ScrollArea>
        </Box>;
    } else {
        chatSessionsList = <Box style={{"flex": "1"}} />;
    }

    userSection = None;
    if isAuthenticated and isExpanded {
        userSection = <Box px="md" py="sm">
            <Paper
                p="sm"
                radius="md"
                style={{
                    "background": PANEL,
                    "border": "1px solid " + PANEL_BORDER
                }}
            >
                <Group gap="sm" mb="sm">
                    <Avatar
                        radius="xl"
                        size="sm"
                        style={{
                            "background": ORANGE,
                            "color": "white"
                        }}
                    >
                        {getUserInitials()}
                    </Avatar>
                    <Text size="sm" fw={600} c={TEXT} style={{"flex": "1"}}>{username}</Text>
                </Group>

                {(
                    <Button
                        onClick={lambda -> None { navigate("/dashboard"); }}
                        variant="subtle"
                        fullWidth
                        size="xs"
                        leftSection={<IconShieldCheck size={14} />}
                        mb="xs"
                        style={{"color": ORANGE}}
                    >
                        Admin Dashboard
                    </Button>
                    if isAdmin
                    else None
                )}

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

    guestSection = None;
    if not isAuthenticated and isExpanded {
        guestSection = <Box px="md" pt="sm" pb="sm">
            <Paper
                p="sm"
                radius="md"
                style={{
                    "background": PANEL,
                    "border": "1px solid " + PANEL_BORDER
                }}
            >
                <Box
                    style={{
                        "fontSize": "12px",
                        "color": MUTED,
                        "background": "rgba(31, 41, 55, 0.6)",
                        "padding": "10px 12px",
                        "borderRadius": "10px",
                        "marginBottom": "10px"
                    }}
                >
                    {"Free messages: "}{messageCount}{"/"}{maxFreeMessages}
                </Box>

                <Stack gap="xs">
                    <Link to="/register" style={{"textDecoration": "none"}}>
                        <Button
                            fullWidth
                            radius="md"
                            size="sm"
                            leftSection={<IconUserPlus size={16} />}
                            style={{
                                "background": ORANGE,
                                "color": "white",
                                "height": "44px"
                            }}
                        >
                            Sign Up
                        </Button>
                    </Link>

                    <Link to="/login" style={{"textDecoration": "none"}}>
                        <Button
                            fullWidth
                            radius="md"
                            size="sm"
                            variant="outline"
                            leftSection={<IconLogin size={16} />}
                            styles={{
                                "root": {
                                    "borderColor": ORANGE,
                                    "color": ORANGE,
                                    "height": "44px"
                                }
                            }}
                        >
                            Sign In
                        </Button>
                    </Link>
                </Stack>
            </Paper>
        </Box>;
    }

    collapsedAuthSection = None;
    if not isExpanded {
        if isAuthenticated {
            collapsedAuthSection = <Stack gap="xs" align="center" px="xs" pt="sm">
                {(
                    <Tooltip label="Admin Dashboard" position="right">
                        <ActionIcon
                            onClick={lambda -> None { navigate("/dashboard"); }}
                            variant="subtle"
                            size="lg"
                            radius="md"
                            style={{"color": ORANGE}}
                        >
                            <IconShieldCheck size={18} />
                        </ActionIcon>
                    </Tooltip>
                    if isAdmin
                    else None
                )}
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
            collapsedAuthSection = <Stack gap="xs" align="center" px="xs" pt="sm">
                <Tooltip label="Sign Up" position="right">
                    <Link to="/register">
                        <ActionIcon
                            variant="filled"
                            size="lg"
                            radius="md"
                            style={{"background": ORANGE, "color": "white"}}
                        >
                            <IconUserPlus size={18} />
                        </ActionIcon>
                    </Link>
                </Tooltip>

                <Tooltip label="Sign In" position="right">
                    <Link to="/login">
                        <ActionIcon
                            variant="outline"
                            size="lg"
                            radius="md"
                            style={{"borderColor": ORANGE, "color": ORANGE}}
                        >
                            <IconLogin size={18} />
                        </ActionIcon>
                    </Link>
                </Tooltip>
            </Stack>;
        }
    }

    helpButton = <Box px={(("md" if isExpanded else "xs"))} pt="xs" pb="sm">
        <Tooltip label="Help & FAQ" position="right" disabled={isExpanded}>
            <Button
                onClick={lambda -> None { window.open("https://www.jac-lang.org/learn/data_spatial/FAQ/", "_blank"); }}
                variant="subtle"
                fullWidth={isExpanded}
                size={(("sm" if isExpanded else "md"))}
                leftSection={((<IconHelp size={16} />) if isExpanded else None)}
                style={{
                    "justifyContent": (("flex-start" if isExpanded else "center")),
                    "color": MUTED
                }}
            >
                {(("Help & FAQ") if isExpanded else (<IconHelp size={18} />))}
            </Button>
        </Tooltip>
    </Box>;

    statusIndicator = None;
    if isExpanded {
        dotColor = (("#22c55e" if isAuthenticated else ORANGE));
        statusLabel = (("Ready to help" if isAuthenticated else "Guest mode"));

        statusIndicator = <Box px="md" pb="md">
            <Group gap="xs" style={{
                "background": "rgba(31, 41, 55, 0.6)",
                "padding": "10px 12px",
                "borderRadius": "10px"
            }}>
                <Box style={{
                    "width": "8px",
                    "height": "8px",
                    "borderRadius": "50%",
                    "background": dotColor
                }} />
                <Text size="xs" c={MUTED}>
                    {statusLabel}
                </Text>
            </Group>
            {(
                <Box style={{
                    "marginTop": "8px",
                    "fontSize": "12px",
                    "color": "#fecaca",
                    "background": "rgba(239, 68, 68, 0.08)",
                    "border": "1px solid rgba(239, 68, 68, 0.25)",
                    "padding": "8px 10px",
                    "borderRadius": "8px"
                }}>
                    {"[" + (sidebarError.code or "ERR_UNKNOWN_FRONTEND") + "] " + (sidebarError.message or "Something went wrong.")}
                </Box>
                if sidebarError
                else None
            )}
        </Box>;
    }

    bottomArea = <Box>
        <Divider color={BORDER} />
        {userSection}
        {guestSection}
        {collapsedAuthSection}
        {helpButton}
        {statusIndicator}
    </Box>;

    return <>
        {mobileOverlay}

        <Box style={sidebarStyle}>
            <Box style={{"display": "flex", "flexDirection": "column", "height": "100%"}}>
                {logoSection}
                {newChatButton}

                <Box style={{"flex": "1", "minHeight": "0"}}>
                    {chatSessionsList}
                </Box>

                {bottomArea}
            </Box>
        </Box>

        <Box style={{"width": String(sidebarWidth) + "px", "flexShrink": "0"}} visibleFrom="lg" />
    </>;
}
