"""Admin Dashboard page for monitoring users, sessions and questions."""

import from react { useEffect }
import from "@jac/runtime" { useNavigate, jacIsLoggedIn, jacLogout }
import from "@mantine/core" {
    Box,
    Stack,
    Group,
    Text,
    Button,
    Paper,
    Badge,
    ScrollArea,
    TextInput,
    Alert,
    Loader,
    ActionIcon,
    Divider,
    SimpleGrid
}
import from "@tabler/icons-react" {
    IconUsers,
    IconMessageCircle,
    IconMessages,
    IconQuestionMark,
    IconSearch,
    IconArrowLeft,
    IconLogout,
    IconEye,
    IconShieldCheck,
    IconAlertCircle,
    IconMapPin
}
import from ..hooks.useAuth { getUsernameFromToken }
import from ..services.jacService {
    getUserProfile,
    getAllUsers,
    getAllSessionsAdmin,
    getSessionMessagesAdmin
}

def:pub AdminDashboard() -> JsxElement {
    navigate = useNavigate();
    username = getUsernameFromToken();

    has users: list = [];
    has sessions: list = [];
    has userQuestions: list = [];
    has questionSearchTerm: str = "";
    has selectedSession: any = None;
    has loading: bool = True;
    has sessionLoading: bool = False;
    has questionsLoading: bool = False;
    has questionsLoaded: bool = False;
    has error: str = "";
    has activeTab: str = "overview";
    has isAdmin: bool = False;
    has checkingAuth: bool = True;
    has hadQuestionLoadError: bool = False;

    # Theme tokens
    BG = "#141414";
    SURFACE = "#1a1a1e";
    BORDER = "#374151";
    TEXT = "#ffffff";
    MUTED = "#9ca3af";
    MUTED2 = "#6b7280";
    ORANGE = "#f97316";
    ORANGE_DARK = "#ea580c";
    PANEL = "rgba(255,255,255,0.04)";
    PANEL_BORDER = "rgba(255,255,255,0.08)";

    # Check auth + admin status on mount
    useEffect(lambda -> None {
        async def checkAdminAndLoad() -> None {
            if not jacIsLoggedIn() {
                navigate("/login");
                return;
            }

            try {
                console.log("AdminDashboard: username from token:", username);
                result = await getUserProfile(username);
                console.log("AdminDashboard: getUserProfile result:", JSON.stringify(result));
                console.log("AdminDashboard: result.isAdmin:", result.isAdmin);
                if result.isAdmin {
                    isAdmin = True;
                    checkingAuth = False;

                    # Load data
                    usersResult = await getAllUsers(username);
                    sessionsResult = await getAllSessionsAdmin(username);

                    if usersResult.success {
                        users = usersResult.users;
                    } else {
                        error = "[" + (usersResult.code or "ERR_GET_ALL_USERS") + "] " + (usersResult.message or "Failed to load users.");
                    }
                    if sessionsResult.success {
                        sessions = sessionsResult.sessions;
                    } else {
                        error = "[" + (sessionsResult.code or "ERR_GET_ALL_SESSIONS") + "] " + (sessionsResult.message or "Failed to load sessions.");
                    }
                    loading = False;
                } else {
                    isAdmin = False;
                    checkingAuth = False;
                    loading = False;
                }
            } except Exception as e {
                console.error("Admin check error:", e);
                error = "Failed to verify admin status";
                checkingAuth = False;
                loading = False;
            }
        }

        checkAdminAndLoad();
    }, []);

    # Load questions when tab is clicked (lazy)
    useEffect(lambda -> None {
        async def loadQuestions() -> None {
            if activeTab != "questions" or questionsLoaded or sessions.length == 0 {
                return;
            }

            # Filter to only sessions with messages
            sessionsWithMessages = sessions.filter(lambda s: any -> any {
                return (s.message_count or 0) > 0;
            });

            questionsLoading = True;
            questions = [];
            console.log("Loading questions from", sessionsWithMessages.length, "sessions");

            for session in sessionsWithMessages {
                try {
                    result = await getSessionMessagesAdmin(session.session_id, username);
                    console.log("Session", session.session_id, "messages:", result.messages.length if result.messages else 0);
                    if result.success and result.messages {
                        sessionUser = None;
                        for u in users {
                            if u.email == session.user_email {
                                sessionUser = u;
                                break;
                            }
                        }

                        for msg in result.messages {
                            if msg.role == "user" {
                                questions.push({
                                    "question": msg.content,
                                    "user_email": session.user_email,
                                    "user_name": (sessionUser.name if sessionUser else None),
                                    "session_id": session.session_id,
                                    "created_at": session.created_at
                                });
                            }
                        }
                    }
                } except Exception as e {
                    console.error("Error loading session messages:", e);
                    if not hadQuestionLoadError {
                        error = "[ERR_GET_SESSION_MESSAGES] Some session messages could not be loaded.";
                        hadQuestionLoadError = True;
                    }
                }
            }

            userQuestions = questions;
            questionsLoaded = True;
            questionsLoading = False;
        }

        loadQuestions();
    }, [activeTab]);

    def handleLogout() -> None {
        jacLogout();
        navigate("/login");
    }

    def formatDate(dateString: str) -> str {
        if not dateString {
            return "N/A";
        }
        try {
            d = Reflect.construct(Date, [dateString]);
            return d.toLocaleString();
        } except Exception {
            return dateString;
        }
    }

    def truncateText(text: str, maxLen: int = 80) -> str {
        if not text {
            return "";
        }
        if text.length > maxLen {
            return text.substring(0, maxLen) + "...";
        }
        return text;
    }

    def getFilteredQuestions() -> list {
        if not questionSearchTerm {
            return userQuestions;
        }
        term = questionSearchTerm.toLowerCase();
        return userQuestions.filter(lambda q: any -> any {
            return (
                (q.question and q.question.toLowerCase().includes(term)) or
                (q.user_email and q.user_email.toLowerCase().includes(term)) or
                (q.user_name and q.user_name.toLowerCase().includes(term))
            );
        });
    }

    async def handleViewSession(sessionId: str) -> None {
        sessionLoading = True;
        try {
            result = await getSessionMessagesAdmin(sessionId, username);
            if result.success {
                selectedSession = result;
            } else {
                error = "[" + (result.code or "ERR_GET_SESSION_MESSAGES") + "] " + (result.message or "Failed to load session messages");
            }
        } except Exception as e {
            console.error("Error loading session:", e);
            error = "[ERR_GET_SESSION_MESSAGES] Failed to load session messages";
        } finally {
            sessionLoading = False;
        }
    }

    # --- Loading state ---
    if checkingAuth or (loading and not users.length) {
        return <Box style={{
            "minHeight": "100vh",
            "background": BG,
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center"
        }}>
            <Stack align="center" gap="md">
                <Loader color={ORANGE} size="lg" />
                <Text c={MUTED} size="sm">Loading admin dashboard...</Text>
            </Stack>
        </Box>;
    }

    # --- Access denied ---
    if not isAdmin {
        return <Box style={{
            "minHeight": "100vh",
            "background": BG,
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "padding": "20px"
        }}>
            <Paper p="xl" radius="lg" style={{
                "background": SURFACE,
                "border": "1px solid " + PANEL_BORDER,
                "maxWidth": "420px",
                "width": "100%",
                "textAlign": "center"
            }}>
                <Stack align="center" gap="md">
                    <IconShieldCheck size={48} color={ORANGE} />
                    <Text size="xl" fw={700} c={TEXT}>Access Denied</Text>
                    <Text c={MUTED} size="sm">Admin privileges required to access this page.</Text>
                    <Button
                        onClick={lambda -> None { navigate("/"); }}
                        leftSection={<IconArrowLeft size={16} />}
                        styles={{
                            "root": {
                                "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)"
                            }
                        }}
                    >
                        Back to Chat
                    </Button>
                </Stack>
            </Paper>
        </Box>;
    }

    # Filter out empty sessions (created on page load but never used)
    activeSessions_list = sessions.filter(lambda s: any -> any {
        return (s.message_count or 0) > 0;
    });

    # --- Compute stats ---
    totalMessages = 0;
    activeSessions = 0;
    adminCount = 0;
    userCount = 0;

    for s in activeSessions_list {
        totalMessages = totalMessages + (s.message_count or 0);
        if s.status == "active" {
            activeSessions = activeSessions + 1;
        }
    }
    for u in users {
        if u.role == "admin" {
            adminCount = adminCount + 1;
        } else {
            userCount = userCount + 1;
        }
    }

    # ===== Overview Tab =====
    overviewContent = None;
    if activeTab == "overview" {
        overviewContent = <SimpleGrid cols={3} spacing="lg" style={{"marginBottom": "24px"}}>
            <Paper p="lg" radius="md" style={{
                "background": SURFACE,
                "border": "1px solid " + PANEL_BORDER
            }}>
                <Group justify="space-between" mb="xs">
                    <Text size="sm" fw={500} c={MUTED}>Total Users</Text>
                    <IconUsers size={20} color={ORANGE} />
                </Group>
                <Text size="xl" fw={700} c={TEXT} style={{"fontSize": "32px"}}>{users.length}</Text>
                <Text size="xs" c={MUTED2} mt="xs">
                    {String(adminCount)}{" admin(s), "}{String(userCount)}{" user(s)"}
                </Text>
            </Paper>

            <Paper p="lg" radius="md" style={{
                "background": SURFACE,
                "border": "1px solid " + PANEL_BORDER
            }}>
                <Group justify="space-between" mb="xs">
                    <Text size="sm" fw={500} c={MUTED}>Total Sessions</Text>
                    <IconMessageCircle size={20} color="#3b82f6" />
                </Group>
                <Text size="xl" fw={700} c={TEXT} style={{"fontSize": "32px"}}>{activeSessions_list.length}</Text>
                <Text size="xs" c={MUTED2} mt="xs">
                    {String(activeSessions)}{" active session(s)"}
                </Text>
            </Paper>

            <Paper p="lg" radius="md" style={{
                "background": SURFACE,
                "border": "1px solid " + PANEL_BORDER
            }}>
                <Group justify="space-between" mb="xs">
                    <Text size="sm" fw={500} c={MUTED}>Total Messages</Text>
                    <IconMessages size={20} color="#22c55e" />
                </Group>
                <Text size="xl" fw={700} c={TEXT} style={{"fontSize": "32px"}}>{totalMessages}</Text>
                <Text size="xs" c={MUTED2} mt="xs">Across all sessions</Text>
            </Paper>
        </SimpleGrid>;
    }

    # ===== Users Tab =====
    usersContent = None;
    if activeTab == "users" {
        usersContent = <Paper radius="md" style={{
            "background": SURFACE,
            "border": "1px solid " + PANEL_BORDER
        }}>
            <Box p="md" style={{"borderBottom": "1px solid " + PANEL_BORDER}}>
                <Text size="lg" fw={600} c={TEXT}>Users</Text>
                <Text size="sm" c={MUTED}>All registered users</Text>
            </Box>
            <Box p="md">
                <Stack gap="sm">
                    {users.map(lambda u: any, index: int -> any {
                        return <Paper key={index} p="md" radius="md" style={{
                            "background": PANEL,
                            "border": "1px solid " + PANEL_BORDER
                        }}>
                            <Group justify="space-between" align="flex-start">
                                <Box>
                                    <Group gap="sm" mb="xs">
                                        <Text fw={600} c={TEXT}>{u.email or "Unknown"}</Text>
                                        <Badge
                                            size="sm"
                                            color={((ORANGE if u.role == "admin" else "gray"))}
                                            variant="filled"
                                        >
                                            {u.role or "user"}
                                        </Badge>
                                    </Group>
                                    {(
                                        <Text size="sm" c={MUTED}>{u.name}</Text>
                                        if u.name
                                        else None
                                    )}
                                    <Group gap="lg" mt="xs">
                                        <Text size="xs" c={MUTED2}>
                                            {"Activated: "}{((String(u.is_activated) if u.is_activated != None else "N/A"))}
                                        </Text>
                                    </Group>
                                    {(
                                        <Group gap="xs" mt="xs">
                                            <IconMapPin size={12} color="#3b82f6" />
                                            <Text size="xs" c="#3b82f6">
                                                {((u.location.city + ", " if u.location.city else ""))}{u.location.country or "Unknown location"}
                                            </Text>
                                        </Group>
                                        if u.location and (u.location.city or u.location.country)
                                        else None
                                    )}
                                </Box>
                            </Group>
                        </Paper>;
                    })}
                </Stack>
            </Box>
        </Paper>;
    }

    # ===== Sessions Tab =====
    sessionsContent = None;
    if activeTab == "sessions" {
        # Session list
        sessionsList = <Paper radius="md" style={{
            "background": SURFACE,
            "border": "1px solid " + PANEL_BORDER,
            "flex": "1",
            "minWidth": "0"
        }}>
            <Box p="md" style={{"borderBottom": "1px solid " + PANEL_BORDER}}>
                <Text size="lg" fw={600} c={TEXT}>Chat Sessions</Text>
                <Text size="sm" c={MUTED}>Click a session to view conversation</Text>
            </Box>
            <ScrollArea style={{"height": "500px"}} p="md">
                <Stack gap="xs">
                    {activeSessions_list.map(lambda s: any, index: int -> any {
                        isSelected = selectedSession and selectedSession.session_id == s.session_id;
                        return <Box
                            key={index}
                            onClick={lambda -> None { handleViewSession(s.session_id); }}
                            style={{
                                "padding": "12px",
                                "borderRadius": "8px",
                                "cursor": "pointer",
                                "background": (("rgba(249,115,22,0.08)" if isSelected else PANEL)),
                                "border": "1px solid " + (("rgba(249,115,22,0.3)" if isSelected else PANEL_BORDER)),
                                "transition": "all 0.2s ease"
                            }}
                        >
                            <Group justify="space-between" mb="xs">
                                <Group gap="xs">
                                    <Text size="sm" fw={500} c={TEXT}>
                                        {s.session_id.substring(0, 16)}{"..."}
                                    </Text>
                                    <Badge
                                        size="xs"
                                        color={((ORANGE if s.status == "active" else "gray"))}
                                        variant="filled"
                                    >
                                        {s.status}
                                    </Badge>
                                </Group>
                                <Text size="xs" c={MUTED}>{String(s.message_count or 0)}{" msgs"}</Text>
                            </Group>
                            {(
                                <Badge size="xs" variant="outline" color="gray" mb="xs">
                                    {s.user_email}
                                </Badge>
                                if s.user_email
                                else None
                            )}
                            {(
                                <Text size="xs" c={MUTED2} mb="xs">
                                    {"\""}{truncateText(s.first_message, 60)}{"\""}
                                </Text>
                                if s.first_message
                                else None
                            )}
                            <Text size="xs" c={MUTED2}>
                                {"Created: "}{formatDate(s.created_at)}
                            </Text>
                        </Box>;
                    })}
                </Stack>
            </ScrollArea>
        </Paper>;

        # Session detail
        sessionDetailContent = None;
        if sessionLoading {
            sessionDetailContent = <Box style={{
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "height": "300px"
            }}>
                <Loader color={ORANGE} />
            </Box>;
        } elif selectedSession {
            sessionDetailContent = <ScrollArea style={{"height": "500px"}} p="md">
                <Stack gap="md">
                    {selectedSession.messages.map(lambda msg: any, index: int -> any {
                        isUser = msg.role == "user";
                        return <Box
                            key={index}
                            style={{
                                "padding": "12px 16px",
                                "borderRadius": "8px",
                                "background": (("rgba(249,115,22,0.08)" if isUser else PANEL)),
                                "border": "1px solid " + (("rgba(249,115,22,0.2)" if isUser else PANEL_BORDER)),
                                "marginLeft": (("20px" if isUser else "0")),
                                "marginRight": (("0" if isUser else "20px"))
                            }}
                        >
                            <Group justify="space-between" mb="xs">
                                <Badge
                                    size="sm"
                                    color={((ORANGE if isUser else "gray"))}
                                    variant="filled"
                                >
                                    {msg.role}
                                </Badge>
                            </Group>
                            <Text size="sm" c={TEXT} style={{"whiteSpace": "pre-wrap", "lineHeight": "1.6"}}>
                                {msg.content}
                            </Text>
                        </Box>;
                    })}
                </Stack>
            </ScrollArea>;
        } else {
            sessionDetailContent = <Box style={{
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "height": "300px"
            }}>
                <Stack align="center" gap="sm">
                    <IconEye size={48} color={MUTED2} style={{"opacity": "0.5"}} />
                    <Text c={MUTED}>Select a session to view the conversation</Text>
                </Stack>
            </Box>;
        }

        sessionDetail = <Paper radius="md" style={{
            "background": SURFACE,
            "border": "1px solid " + PANEL_BORDER,
            "flex": "1",
            "minWidth": "0"
        }}>
            <Box p="md" style={{"borderBottom": "1px solid " + PANEL_BORDER}}>
                <Text size="lg" fw={600} c={TEXT}>Session Details</Text>
                <Text size="sm" c={MUTED}>
                    {(
                        ("Viewing: " + selectedSession.session_id.substring(0, 16) + "...")
                        if selectedSession
                        else "Select a session to view"
                    )}
                </Text>
            </Box>
            {sessionDetailContent}
        </Paper>;

        sessionsContent = <Group align="flex-start" gap="lg" style={{"flexWrap": "nowrap"}}>
            {sessionsList}
            {sessionDetail}
        </Group>;
    }

    # ===== Questions Tab =====
    questionsContent = None;
    if activeTab == "questions" {
        filteredQuestions = getFilteredQuestions();

        questionsBody = None;
        if questionsLoading {
            questionsBody = <Box style={{
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "height": "300px"
            }}>
                <Stack align="center" gap="sm">
                    <Loader color={ORANGE} />
                    <Text c={MUTED} size="sm">Loading questions from all sessions...</Text>
                </Stack>
            </Box>;
        } elif userQuestions.length > 0 and filteredQuestions.length > 0 {
            questionsBody = <ScrollArea style={{"height": "500px"}}>
                <Stack gap="sm" p="md">
                    {filteredQuestions.map(lambda q: any, index: int -> any {
                        return <Paper key={index} p="md" radius="md" style={{
                            "background": PANEL,
                            "border": "1px solid " + PANEL_BORDER
                        }}>
                            <Group justify="space-between" mb="sm">
                                <Group gap="xs">
                                    {(
                                        <Badge size="sm" variant="light" color="blue">
                                            {q.user_name}
                                        </Badge>
                                        if q.user_name
                                        else None
                                    )}
                                    {(
                                        <Badge size="sm" variant="outline" color="gray">
                                            {q.user_email}
                                        </Badge>
                                        if q.user_email
                                        else None
                                    )}
                                    <Badge size="sm" variant="outline" color={ORANGE}>
                                        {q.session_id.substring(0, 8)}{"..."}
                                    </Badge>
                                </Group>
                                <Text size="xs" c={MUTED2}>{formatDate(q.created_at)}</Text>
                            </Group>
                            <Box style={{
                                "background": "rgba(31, 41, 55, 0.6)",
                                "padding": "12px 16px",
                                "borderRadius": "8px",
                                "borderLeft": "4px solid " + ORANGE
                            }}>
                                <Text size="sm" c={TEXT} style={{"whiteSpace": "pre-wrap", "lineHeight": "1.6"}}>
                                    {q.question}
                                </Text>
                            </Box>
                        </Paper>;
                    })}
                </Stack>
            </ScrollArea>;
        } elif userQuestions.length > 0 and filteredQuestions.length == 0 {
            questionsBody = <Box style={{
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "height": "300px"
            }}>
                <Stack align="center" gap="sm">
                    <IconQuestionMark size={48} color={MUTED2} style={{"opacity": "0.5"}} />
                    <Text c={MUTED}>No questions match your search</Text>
                </Stack>
            </Box>;
        } else {
            questionsBody = <Box style={{
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "height": "300px"
            }}>
                <Stack align="center" gap="sm">
                    <IconQuestionMark size={48} color={MUTED2} style={{"opacity": "0.5"}} />
                    <Text c={MUTED}>No user questions found</Text>
                    <Text size="xs" c={MUTED2}>Questions will appear once users start chatting</Text>
                </Stack>
            </Box>;
        }

        questionsContent = <Paper radius="md" style={{
            "background": SURFACE,
            "border": "1px solid " + PANEL_BORDER
        }}>
            <Box p="md" style={{"borderBottom": "1px solid " + PANEL_BORDER}}>
                <Group justify="space-between">
                    <Box>
                        <Text size="lg" fw={600} c={TEXT}>User Questions</Text>
                        <Text size="sm" c={MUTED}>
                            {"All questions asked across sessions"}
                            {(
                                (" - " + String(filteredQuestions.length) + " of " + String(userQuestions.length) + " shown")
                                if questionSearchTerm
                                else ""
                            )}
                        </Text>
                    </Box>
                    <TextInput
                        placeholder="Search questions..."
                        value={questionSearchTerm}
                        onChange={lambda e: any -> None { questionSearchTerm = e.target.value; }}
                        leftSection={<IconSearch size={16} />}
                        style={{"width": "280px"}}
                        styles={{
                            "input": {
                                "background": PANEL,
                                "border": "1px solid " + PANEL_BORDER,
                                "color": TEXT
                            }
                        }}
                    />
                </Group>
            </Box>
            {questionsBody}
        </Paper>;
    }

    # ===== Error alert =====
    errorAlert = None;
    if error {
        errorAlert = <Alert
            icon={<IconAlertCircle size={16} />}
            color="red"
            variant="light"
            mb="lg"
            withCloseButton
            onClose={lambda -> None { error = ""; }}
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

    # ===== Main layout =====
    return <Box style={{
        "minHeight": "100vh",
        "background": BG,
        "padding": "24px"
    }}>
        <Box style={{"maxWidth": "1400px", "margin": "0 auto"}}>
            <Group justify="space-between" align="flex-start" mb="xl">
                <Box>
                    <Group gap="sm" mb="xs">
                        <Button
                            onClick={lambda -> None { navigate("/"); }}
                            variant="subtle"
                            size="sm"
                            leftSection={<IconArrowLeft size={16} />}
                            style={{"color": MUTED}}
                        >
                            Back to Chat
                        </Button>
                    </Group>
                    <Text size="xl" fw={700} c={TEXT} style={{"fontSize": "28px"}}>
                        Admin Dashboard
                    </Text>
                    <Text c={MUTED} size="sm">
                        {"Welcome, "}{username}{". Monitor all user activity and chat sessions."}
                    </Text>
                </Box>
                <Button
                    onClick={handleLogout}
                    variant="outline"
                    leftSection={<IconLogout size={16} />}
                    styles={{
                        "root": {
                            "borderColor": BORDER,
                            "color": MUTED
                        }
                    }}
                >
                    Logout
                </Button>
            </Group>

            {errorAlert}

            <Group gap="sm" mb="lg">
                <Button
                    onClick={lambda -> None { activeTab = "overview"; }}
                    variant={((("filled" if activeTab == "overview" else "outline")))}
                    styles={{
                        "root": {
                            "background": (("linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)" if activeTab == "overview" else "transparent")),
                            "borderColor": ((ORANGE if activeTab == "overview" else BORDER)),
                            "color": ((TEXT if activeTab == "overview" else MUTED))
                        }
                    }}
                >
                    Overview
                </Button>
                <Button
                    onClick={lambda -> None { activeTab = "users"; }}
                    variant={((("filled" if activeTab == "users" else "outline")))}
                    leftSection={<IconUsers size={16} />}
                    styles={{
                        "root": {
                            "background": (("linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)" if activeTab == "users" else "transparent")),
                            "borderColor": ((ORANGE if activeTab == "users" else BORDER)),
                            "color": ((TEXT if activeTab == "users" else MUTED))
                        }
                    }}
                >
                    {"Users ("}{String(users.length)}{")"}
                </Button>
                <Button
                    onClick={lambda -> None { activeTab = "sessions"; }}
                    variant={((("filled" if activeTab == "sessions" else "outline")))}
                    leftSection={<IconMessageCircle size={16} />}
                    styles={{
                        "root": {
                            "background": (("linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)" if activeTab == "sessions" else "transparent")),
                            "borderColor": ((ORANGE if activeTab == "sessions" else BORDER)),
                            "color": ((TEXT if activeTab == "sessions" else MUTED))
                        }
                    }}
                >
                    {"Sessions ("}{String(activeSessions_list.length)}{")"}
                </Button>
                <Button
                    onClick={lambda -> None { activeTab = "questions"; }}
                    variant={((("filled" if activeTab == "questions" else "outline")))}
                    leftSection={<IconQuestionMark size={16} />}
                    styles={{
                        "root": {
                            "background": (("linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)" if activeTab == "questions" else "transparent")),
                            "borderColor": ((ORANGE if activeTab == "questions" else BORDER)),
                            "color": ((TEXT if activeTab == "questions" else MUTED))
                        }
                    }}
                >
                    {"Questions ("}{String(userQuestions.length)}{")"}
                </Button>
            </Group>

            {overviewContent}
            {usersContent}
            {sessionsContent}
            {questionsContent}
        </Box>
    </Box>;
}