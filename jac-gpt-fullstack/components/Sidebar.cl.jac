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
    IconDots,
    IconSun,
    IconMoon
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
    maxFreeMessages: int = 30,
    theme: str = "dark",
    onSetTheme: any = None
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

    useEffect(lambda () {
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

    useEffect(lambda () {
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

    BG = "var(--sidebar)";
    BORDER = "var(--border)";
    TEXT = "var(--text-primary)";
    MUTED = "var(--text-muted)";
    MUTED2 = "var(--text-dim)";
    PANEL = "var(--panel)";
    PANEL_BORDER = "var(--panel-border)";
    ORANGE = "var(--primary)";
    ORANGE_LIGHT = "var(--primary-light)";
    HOVER_BG = "var(--hover-bg)";
    ACTIVE_BG = "var(--active-bg)";

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
        "zIndex": "50",
        "transition": "width 0.25s ease, transform 0.25s ease",
        "transform": (("translateX(0)" if shouldShow else "translateX(-100%)"))
    };

    logoBox = <Box
        onClick={handleLogoClick}
        style={{
            "width": "40px",
            "height": "40px",
            "borderRadius": "11px",
            "background": "rgba(249,115,22,0.12)",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "boxShadow": "0 0 14px rgba(249,115,22,0.22)",
            "cursor": "pointer",
            "transition": "transform 0.2s ease",
            "flexShrink": 0
        }}
        onMouseEnter={lambda (e: any) {
            e.currentTarget.style.transform = "scale(1.05)";
        }}
        onMouseLeave={lambda (e: any) {
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
    </Box>;

    logoSection = None;
    if isExpanded {
        logoSection = <Box style={{"padding": "14px 14px", "borderBottom": "1px solid " + BORDER}}>
            <Group justify="space-between" align="center" wrap="nowrap">
                <Group gap="sm" align="center" wrap="nowrap" style={{"minWidth": "0"}}>
                    {logoBox}
                    <Box style={{"lineHeight": "1.15", "minWidth": "0"}}>
                        <Text fw={700} style={{"fontSize": "18px", "color": TEXT}}>
                            Jac GPT
                        </Text>
                        <Text style={{"fontSize": "12px", "color": MUTED, "marginTop": "2px"}}>
                            Your AI companion for Jac programming
                        </Text>
                    </Box>
                </Group>

                <Group gap="xs" align="center" wrap="nowrap" style={{"flexShrink": 0}}>
                    <ActionIcon
                        onClick={toggleExpanded}
                        variant="subtle"
                        size="sm"
                        radius="md"
                        visibleFrom="lg"
                        style={{"color": MUTED}}
                    >
                        <IconChevronLeft size={18} />
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
    } else {
        logoSection = <Box style={{
            "padding": "14px 6px",
            "borderBottom": "1px solid " + BORDER,
            "display": "flex",
            "flexDirection": "column",
            "alignItems": "center",
            "gap": "10px"
        }}>
            {logoBox}
            <ActionIcon
                onClick={toggleExpanded}
                variant="subtle"
                size="sm"
                radius="md"
                visibleFrom="lg"
                style={{"color": MUTED}}
            >
                <IconChevronRight size={18} />
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
        </Box>;
    }

    newChatButton = <Box px="md" py="sm">
        <Tooltip label="New Chat" position="right" offset={12} withinPortal={True} disabled={isExpanded}>
            <Button
                onClick={onNewChat}
                disabled={isLoading}
                fullWidth={True}
                radius="md"
                variant="outline"
                className="jc-newchat"
                styles={{
                    "root": {
                        "background": "var(--hover-bg)",
                        "borderColor": "var(--border-light)",
                        "borderLeft": (("2px solid " + ORANGE) if isExpanded else "1px solid var(--border-light)"),
                        "color": TEXT,
                        "height": "46px",
                        "paddingLeft": (("14px" if isExpanded else "0px")),
                        "paddingRight": (("14px" if isExpanded else "0px"))
                    }
                }}
            >
                <Group justify="center" gap="sm" style={{"width": "100%"}}>
                    <IconPlus size={16} color={ORANGE} />
                    {(<Text fw={600} style={{"color": TEXT, "fontSize": "14px"}}>New Chat</Text>) if isExpanded else None}
                </Group>
            </Button>
        </Tooltip>
    </Box>;

    sessionsContent = <Text size="sm" c={MUTED2} ta="center" py="lg">No chat history yet</Text>;

    if isExpanded and chatSessions.length > 0 {
        sessionsContent = <Stack gap={8}>
            {chatSessions.map(lambda (session: any) {
                isCurrentSession = session.id == currentSessionId;
                isHovered = hoveredSessionId == session.id;

                return <Box
                    key={session.id}
                    className="jc-sidebar-item"
                    style={{
                        "position": "relative",
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "10px",
                        "padding": "9px 10px",
                        "borderRadius": "8px",
                        "width": "100%",
                        "borderLeft": (("2px solid " + ORANGE) if isCurrentSession else "2px solid transparent"),
                        "background": (ACTIVE_BG if isCurrentSession else (HOVER_BG if isHovered else "transparent")),
                        "color": (TEXT if isCurrentSession else "var(--text-secondary)"),
                        "opacity": (("0.5" if isLoading else "1")),
                        "cursor": (("not-allowed" if isLoading else "pointer")),
                        "transition": "all 0.2s ease"
                    }}
                    onClick={lambda () {
                        if not isLoading and onLoadSession {
                            onLoadSession(session.id);
                        }
                    }}
                    onMouseEnter={lambda () { hoveredSessionId = session.id; }}
                    onMouseLeave={lambda () { hoveredSessionId = ""; }}
                >
                    <IconMessage
                        size={15}
                        color={(ORANGE if isCurrentSession else MUTED)}
                        style={{"flexShrink": 0}}
                    />
                    <Text
                        size="sm"
                        style={{
                            "flex": "1",
                            "overflow": "hidden",
                            "textOverflow": "ellipsis",
                            "whiteSpace": "nowrap"
                        }}
                        c={(TEXT if isCurrentSession else "var(--text-secondary)")}
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
                                    onClick={lambda (e: any) {
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
                                    onClick={lambda (e: any) {
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
            <Text size="xs" fw={700} c={MUTED} tt="uppercase" mb="sm" style={{"letterSpacing": "0.1em", "opacity": 0.75}}>Recent Chats</Text>
            <ScrollArea style={{"flex": "1", "minHeight": "0"}} type="scroll">
                {sessionsContent}
            </ScrollArea>
        </Box>;
    } else {
        chatSessionsList = <Box style={{"flex": "1"}} />;
    }

    userSection = None;
    if isAuthenticated and isExpanded {
        userSection = <Box px="md" py={6}>
            <Paper
                p={10}
                radius="md"
                style={{
                    "background": PANEL,
                    "border": "1px solid " + PANEL_BORDER
                }}
            >
                <Group gap="sm" mb={8}>
                    <Avatar
                        radius="xl"
                        size={38}
                        styles={{
                            "root": {
                                "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_LIGHT + " 100%)",
                                "boxShadow": "0 0 12px rgba(249,115,22,0.30)"
                            },
                            "placeholder": {
                                "background": "transparent",
                                "color": "white",
                                "fontWeight": 700
                            }
                        }}
                    >
                        {getUserInitials()}
                    </Avatar>
                    <Box style={{"flex": "1", "minWidth": "0", "lineHeight": "1.2"}}>
                        <Text size="sm" fw={700} c={TEXT} style={{"overflow": "hidden", "textOverflow": "ellipsis", "whiteSpace": "nowrap"}}>{username}</Text>
                        <Text size="xs" c={MUTED}>Jac Developer</Text>
                    </Box>
                </Group>

                {(
                    <Button
                        onClick={lambda () { navigate("/dashboard"); }}
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
        guestSection = <Box px="md" pt={6} pb={6}>
            <Paper
                p={10}
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
                        "background": "var(--chip-bg)",
                        "padding": "8px 12px",
                        "borderRadius": "10px",
                        "marginBottom": "10px"
                    }}
                >
                    {"Free messages: "}{messageCount}{"/"}{maxFreeMessages}
                </Box>

                <Text size="xs" c={MUTED} style={{"lineHeight": 1.5, "marginBottom": "10px"}}>
                    Sign in to save your chats.
                </Text>

                <Link to="/login" style={{"textDecoration": "none"}}>
                    <Button
                        fullWidth
                        radius="md"
                        size="sm"
                        className="jc-primary-cta"
                        leftSection={<IconLogin size={16} />}
                        style={{
                            "background": "linear-gradient(135deg, #f97316 0%, #ea580c 100%)",
                            "color": "white",
                            "height": "44px",
                            "boxShadow": "0 6px 18px rgba(249,115,22,0.22)"
                        }}
                    >
                        Sign In
                    </Button>
                </Link>

                <Text ta="center" size="xs" c={MUTED} mt={10}>
                    {"Don't have an account? "}
                    <Link to="/register" className="jc-create-account">
                        {"Create Account →"}
                    </Link>
                </Text>
            </Paper>
        </Box>;
    }

    collapsedAuthSection = None;
    if not isExpanded {
        if isAuthenticated {
            collapsedAuthSection = <Stack gap="xs" align="center" px="xs" pt="sm">
                {(
                    <Tooltip label="Admin Dashboard" position="right" offset={12} withinPortal={True}>
                        <ActionIcon
                            onClick={lambda () { navigate("/dashboard"); }}
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
                <Tooltip label="Log out" position="right" offset={12} withinPortal={True}>
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
                <Tooltip label="Sign In" position="right" offset={12} withinPortal={True}>
                    <Link to="/login">
                        <ActionIcon
                            variant="filled"
                            size="lg"
                            radius="md"
                            style={{"background": ORANGE, "color": "white"}}
                        >
                            <IconLogin size={18} />
                        </ActionIcon>
                    </Link>
                </Tooltip>
            </Stack>;
        }
    }

    helpButton = <Box px={(("md" if isExpanded else "xs"))} pt={2} pb={2}>
        <Tooltip label="Help & FAQ" position="right" offset={12} withinPortal={True} disabled={isExpanded}>
            <Button
                onClick={lambda () { window.open("https://www.jac-lang.org/learn/data_spatial/FAQ/", "_blank"); }}
                variant="subtle"
                fullWidth={isExpanded}
                size={(("xs" if isExpanded else "md"))}
                leftSection={((<IconHelp size={16} />) if isExpanded else None)}
                styles={{
                    "root": {
                        "height": "30px",
                        "justifyContent": (("flex-start" if isExpanded else "center")),
                        "color": MUTED
                    },
                    "root:hover": {
                        "background": "rgba(255,255,255,0.03)"
                    }
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

        statusIndicator = <Box px="md" pt={2} pb={8}>
            <Group gap="xs" style={{
                "background": "var(--chip-bg)",
                "padding": "7px 12px",
                "borderRadius": "10px"
            }}>
                <Box className="jc-pulse-dot" style={{
                    "width": "8px",
                    "height": "8px",
                    "borderRadius": "50%",
                    "background": dotColor,
                    "boxShadow": "0 0 8px " + dotColor
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

    def toggleTheme() -> None {
        if onSetTheme {
            onSetTheme(("light" if theme == "dark" else "dark"));
        }
    }

    themeSwitch = None;
    themeToggleCollapsed = None;
    if isExpanded {
        themeSwitch = <Box px="md" pt={2} pb={10}>
            <Group justify="space-between" align="center" wrap="nowrap">
                <Text size="xs" fw={600} c={MUTED}>Theme</Text>
                <div
                    className="jc-theme-switch"
                    role="switch"
                    tabIndex={0}
                    aria-label="Toggle light or dark theme"
                    onClick={lambda () { toggleTheme(); }}
                    onKeyDown={lambda (e: any) {
                        if e.key == "Enter" or e.key == " " {
                            e.preventDefault();
                            toggleTheme();
                        }
                    }}
                >
                    <span className="jc-sw-knob" />
                    <IconSun size={13} className="jc-sw-sun" />
                    <IconMoon size={13} className="jc-sw-moon" />
                </div>
            </Group>
        </Box>;
    } else {
        themeIcon = ((<IconSun size={18} />) if theme == "light" else (<IconMoon size={18} />));
        themeToggleCollapsed = <Box px="xs" pt={2} pb="sm" style={{"display": "flex", "justifyContent": "center"}}>
            <Tooltip label="Toggle theme" position="right" offset={12} withinPortal={True}>
                <ActionIcon
                    onClick={lambda () { toggleTheme(); }}
                    variant="subtle"
                    size="lg"
                    radius="md"
                    style={{"color": ORANGE}}
                >
                    {themeIcon}
                </ActionIcon>
            </Tooltip>
        </Box>;
    }

    bottomArea = <Box>
        <Divider color={BORDER} />
        {userSection}
        {guestSection}
        {collapsedAuthSection}
        {helpButton}
        {statusIndicator}
        {themeSwitch}
        {themeToggleCollapsed}
    </Box>;

    return <>
        {mobileOverlay}

        <Box className="jc-sidebar" style={sidebarStyle}>
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
