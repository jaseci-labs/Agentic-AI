# Main chatbot page component with Mantine UI

import from react { useState, useEffect }
import from "@jac-client/utils" { jacIsLoggedIn }
import from "@mantine/core" {
    AppShell,
    Group,
    Text,
    ActionIcon,
    Box,
    Stack,
    Paper,
    ScrollArea,
    Badge,
    Loader,
    Transition,
    Burger,
    Tooltip,
    Button
}
import from "@tabler/icons-react" {
    IconBook,
    IconMenu2,
    IconSparkles,
    IconMessageCircle
}
import from ..hooks.useChat { useChat }
import from ..components.ChatMessage { ChatMessage }
import from ..components.ChatInput { ChatInput }
import from ..components.Sidebar { Sidebar }
import from ..components.DocumentationPanel { DocumentationPanel }

# Main Jac GPT Chatbot component
def:pub JacChatbot() -> any {
    has sidebarOpen: bool = False;
    has docPanelOpen: bool = False;

    chat = useChat();
    isAuthenticated = jacIsLoggedIn();

    def toggleSidebar() -> None {
        sidebarOpen = not sidebarOpen;
    }

    def toggleDocPanel() -> None {
        docPanelOpen = not docPanelOpen;
    }

    # Build message items
    messageItems = [];
    for msg in chat.messages {
        messageItems.push(<ChatMessage
            key={msg.id}
            message={msg.content}
            isUser={msg.isUser}
            timestamp={msg.timestamp}
        />);
    }

    # Loading indicator with Mantine
    loadingIndicator = <Group gap="sm" py="md" px="xs">
        <Box style={{"width": "32px", "height": "32px", "borderRadius": "8px", "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)", "display": "flex", "alignItems": "center", "justifyContent": "center"}}>
            <Text c="white" fw={700} size="sm">J</Text>
        </Box>
        <Loader size="sm" type="dots" color="violet" />
    </Group>;

    # Check if we have messages
    hasMessages = False;
    for _ in chat.messages {
        hasMessages = True;
        break;
    }

    # Build content based on state
    loadingContent = None;
    if chat.isLoading {
        loadingContent = loadingIndicator;
    }

    # Message count display for guests
    messageCountDisplay = None;
    if not isAuthenticated {
        messageCountDisplay = <Badge
            variant="light"
            color="violet"
            size="sm"
        >
            {chat.messageCount}{" / "}{chat.maxFreeMessages}{" free messages"}
        </Badge>;
    }

    # Messages content or empty state
    messagesContent = <EmptyState onSendMessage={chat.handleSendMessage} />;
    if hasMessages {
        messagesContent = <Box maw={900} mx="auto" p="md">
            <Stack gap="md">
                {messageItems}
                {loadingContent}
            </Stack>
            <div ref={chat.messagesEndRef} />
        </Box>;
    }

    # Determine button variant and color based on docPanelOpen
    buttonVariant = "subtle";
    buttonColor = "gray";
    if docPanelOpen {
        buttonVariant = "filled";
        buttonColor = "violet";
    }

    # Determine chat area width
    chatAreaWidth = "100%";
    if docPanelOpen {
        chatAreaWidth = "50%";
    }

    # Doc panel element
    docPanelElement = None;
    if docPanelOpen {
        docPanelElement = <Box style={{"width": "50%", "borderLeft": "1px solid rgba(255,255,255,0.06)"}}>
            <DocumentationPanel
                message={chat.lastUserMessage}
                suggestions={chat.docSuggestions}
                isVisible={docPanelOpen}
                onToggle={toggleDocPanel}
            />
        </Box>;
    }

    return <Box style={{"display": "flex", "height": "100vh", "background": "#0a0a0f"}}>
        <Sidebar
            isOpen={sidebarOpen}
            onToggle={toggleSidebar}
            onNewChat={chat.handleNewChat}
            chatSessions={chat.chatSessions}
            currentSessionId={chat.sessionId}
            onLoadSession={chat.handleLoadSession}
            onDeleteSession={chat.handleDeleteSession}
            isLoading={chat.isLoading}
            messageCount={chat.messageCount}
            maxFreeMessages={chat.maxFreeMessages}
        />

        <Box style={{"flex": "1", "display": "flex", "flexDirection": "column", "minWidth": "0"}}>
            <Paper
                p="sm"
                px="md"
                radius={0}
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.06)",
                    "background": "rgba(15,15,20,0.95)",
                    "backdropFilter": "blur(10px)"
                }}
            >
                <Group justify="space-between">
                    <Group gap="md">
                        <Burger
                            opened={sidebarOpen}
                            onClick={toggleSidebar}
                            hiddenFrom="lg"
                            size="sm"
                            color="gray"
                        />
                        <Group gap="xs">
                            <Box style={{"width": "28px", "height": "28px", "borderRadius": "6px", "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)", "display": "flex", "alignItems": "center", "justifyContent": "center"}}>
                                <Text c="white" fw={700} size="xs">J</Text>
                            </Box>
                            <Text fw={600} size="lg" c="white">
                                Jac GPT
                            </Text>
                        </Group>
                    </Group>

                    <Group gap="sm">
                        <Button
                            onClick={toggleDocPanel}
                            variant={buttonVariant}
                            color={buttonColor}
                            size="sm"
                            radius="md"
                            leftSection={<IconBook size={16} />}
                            visibleFrom="md"
                        >
                            Show Docs
                        </Button>
                        {messageCountDisplay}
                    </Group>
                </Group>
            </Paper>

            <Box style={{"flex": "1", "display": "flex", "overflow": "hidden"}}>
                <Box style={{"flex": "1", "display": "flex", "flexDirection": "column", "minWidth": "0", "width": chatAreaWidth}}>
                    <ScrollArea style={{"flex": "1"}} type="scroll">
                        {messagesContent}
                    </ScrollArea>

                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask me anything about Jac..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                </Box>

                {docPanelElement}
            </Box>
        </Box>
    </Box>;
}

# Empty state component with Mantine
def EmptyState(onSendMessage: any) -> any {
    suggestions = [
        "What is Jac programming language?",
        "How do I create a walker?",
        "Explain nodes and edges",
        "Show me a byLLM example"
    ];

    return <Box style={{"flex": "1", "display": "flex", "flexDirection": "column", "alignItems": "center", "justifyContent": "center", "padding": "32px", "textAlign": "center"}}>
        <Box style={{
            "width": "80px",
            "height": "80px",
            "borderRadius": "20px",
            "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "marginBottom": "24px",
            "boxShadow": "0 0 40px rgba(124, 58, 237, 0.3)"
        }}>
            <IconSparkles size={36} color="white" />
        </Box>

        <Text size="xl" fw={700} c="white" mb="xs">
            Ask me anything about Jac
        </Text>

        <Text size="sm" c="dimmed" maw={400} mb="xl">
            Your AI-powered companion for learning and coding in Jac. I can help with syntax, walkers, nodes, edges, and more!
        </Text>

        <Stack gap="sm" w="100%" maw={450}>
            {suggestions.map(lambda suggestion: any, idx: int -> any {
                return <Button
                    key={idx}
                    variant="subtle"
                    color="gray"
                    size="md"
                    fullWidth
                    justify="flex-start"
                    leftSection={<IconMessageCircle size={16} color="#71717a" />}
                    onClick={lambda -> None { onSendMessage(suggestion); }}
                    styles={{
                        "root": {
                            "background": "rgba(124, 58, 237, 0.1)",
                            "border": "1px solid rgba(124, 58, 237, 0.2)",
                            "color": "#a1a1aa",
                            "transition": "all 0.2s ease"
                        }
                    }}
                >
                    {suggestion}
                </Button>;
            })}
        </Stack>
    </Box>;
}
