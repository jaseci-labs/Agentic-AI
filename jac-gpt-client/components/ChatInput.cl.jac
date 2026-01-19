"""Chat input component with send button using Mantine UI."""

import from react { useRef, useEffect }
import from "@mantine/core" {
    Box,
    Group,
    Textarea,
    ActionIcon,
    Paper,
    Tooltip
}
import from "@tabler/icons-react" {
    IconSend,
    IconPlayerStop
}

"""Chat input with auto-expanding textarea."""
def:pub ChatInput(
    onSendMessage: any,
    disabled: bool = False,
    placeholder: str = "Ask me anything about Jac...",
    isLoading: bool = False,
    onStop: any = None
) -> any {
    has inputValue: str = "";
    textareaRef = useRef(None);

    # Auto-resize textarea
    useEffect(lambda -> None {
        if textareaRef.current {
            textareaRef.current.style.height = "auto";
            newHeight = Math.min(textareaRef.current.scrollHeight, 200);
            textareaRef.current.style.height = String(newHeight) + "px";
        }
    }, [inputValue]);

    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if inputValue.trim() and not disabled and not isLoading {
            onSendMessage(inputValue.trim());
            inputValue = "";
            if textareaRef.current {
                textareaRef.current.style.height = "auto";
            }
        }
    }

    def handleKeyDown(e: any) -> None {
        # Submit on Enter, new line on Shift+Enter
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleSubmit(e);
        }
    }

    def handleInputChange(e: any) -> None {
        inputValue = e.target.value;
    }

    # Determine button state
    canSend = inputValue.trim() and not disabled and not isLoading;

    # Stop button when loading
    stopButton = <Tooltip label="Stop generating" position="top">
        <ActionIcon
            onClick={onStop}
            variant="filled"
            color="red"
            size="xl"
            radius="xl"
            style={{
                "boxShadow": "0 4px 12px rgba(239, 68, 68, 0.3)"
            }}
        >
            <IconPlayerStop size={20} />
        </ActionIcon>
    </Tooltip>;

    # Send button
    sendButton = <Tooltip label="Send message" position="top" disabled={not canSend}>
        <ActionIcon
            onClick={handleSubmit}
            disabled={not canSend}
            variant={(("gradient" if canSend else "subtle"))}
            gradient={{"from": "violet", "to": "purple", "deg": 135}}
            color={(("violet" if canSend else "gray"))}
            size="xl"
            radius="xl"
            style={{
                "boxShadow": (("0 4px 12px rgba(124, 58, 237, 0.3)" if canSend else "none")),
                "transition": "all 0.2s ease"
            }}
        >
            <IconSend size={20} />
        </ActionIcon>
    </Tooltip>;

    return <Paper
        p="md"
        radius={0}
        style={{
            "borderTop": "1px solid rgba(255,255,255,0.06)",
            "background": "rgba(15,15,20,0.95)",
            "backdropFilter": "blur(10px)"
        }}
    >
        <Box maw={900} mx="auto">
            <form onSubmit={handleSubmit}>
                <Group gap="md" align="flex-end">
                    <Box style={{"flex": "1"}}>
                        <Textarea
                            ref={textareaRef}
                            value={inputValue}
                            onChange={handleInputChange}
                            onKeyDown={handleKeyDown}
                            placeholder={placeholder}
                            disabled={disabled or isLoading}
                            autosize
                            minRows={1}
                            maxRows={6}
                            radius="xl"
                            size="md"
                            styles={{
                                "input": {
                                    "background": "rgba(255,255,255,0.05)",
                                    "border": "1px solid rgba(255,255,255,0.1)",
                                    "color": "white",
                                    "fontSize": "15px",
                                    "padding": "12px 20px",
                                    "transition": "all 0.2s ease"
                                }
                            }}
                        />
                    </Box>
                    {((stopButton if isLoading and onStop else sendButton))}
                </Group>
            </form>

            <Box mt="xs" ta="center">
                <span style={{"fontSize": "11px", "color": "rgba(255,255,255,0.4)"}}>
                    {"Press Enter to send, Shift+Enter for new line"}
                </span>
            </Box>
        </Box>
    </Paper>;
}
