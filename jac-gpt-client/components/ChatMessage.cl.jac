"""Chat message component with markdown rendering using Mantine UI."""

import from react { useState, useEffect }
import from "react-markdown" { default as ReactMarkdown }
import from "rehype-highlight" { default as rehypeHighlight }
import from "@mantine/core" {
    Box,
    Group,
    Text,
    Paper,
    ActionIcon,
    CopyButton,
    Tooltip,
    Code
}
import from "@tabler/icons-react" {
    IconCopy,
    IconCheck,
    IconUser,
    IconSparkles
}

"""Code block component with copy functionality."""
def:pub CodeBlock(language: str, code: str, children: any = None) -> any {
    has copied: bool = False;

    def handleCopy() -> None {
        navigator.clipboard.writeText(code);
        copied = True;
        setTimeout(lambda -> None { copied = False; }, 2000);
    }

    copyLabel = "Copy code";
    copyColor = "gray";
    copyIcon = <IconCopy size={14} />;
    if copied {
        copyLabel = "Copied!";
        copyColor = "green";
        copyIcon = <IconCheck size={14} />;
    }

    displayLang = language;
    if not displayLang {
        displayLang = "code";
    }

    return <Box my="sm">
        <Paper
            radius="md"
            style={{
                "background": "rgba(0,0,0,0.4)",
                "border": "1px solid rgba(255,255,255,0.08)",
                "overflow": "hidden"
            }}
        >
            <Group
                justify="space-between"
                px="md"
                py="xs"
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.06)",
                    "background": "rgba(0,0,0,0.2)"
                }}
            >
                <Text size="xs" c="dimmed" ff="monospace">
                    {displayLang}
                </Text>
                <Tooltip label={copyLabel} position="left">
                    <ActionIcon
                        onClick={handleCopy}
                        variant="subtle"
                        color={copyColor}
                        size="sm"
                    >
                        {copyIcon}
                    </ActionIcon>
                </Tooltip>
            </Group>
            <Box px="md" py="sm" style={{"overflowX": "auto"}}>
                <pre style={{
                    "margin": "0",
                    "padding": "0",
                    "fontSize": "13px",
                    "lineHeight": "1.6",
                    "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace",
                    "whiteSpace": "pre-wrap",
                    "wordBreak": "break-word",
                    "color": "#e4e4e7"
                }}>
                    <code>{code}</code>
                </pre>
            </Box>
        </Paper>
    </Box>;
}

"""Chat message component."""
def:pub ChatMessage(message: str, isUser: bool, timestamp: any = None) -> any {
    if isUser {
        # User message - right aligned with bubble
        return <Box py="sm" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
            <Group justify="flex-end">
                <Paper
                    p="md"
                    radius="lg"
                    maw="80%"
                    style={{
                        "background": "linear-gradient(135deg, rgba(124, 58, 237, 0.2) 0%, rgba(168, 85, 247, 0.15) 100%)",
                        "border": "1px solid rgba(124, 58, 237, 0.3)"
                    }}
                >
                    <Text size="sm" c="white" style={{"whiteSpace": "pre-wrap", "lineHeight": "1.6"}}>
                        {message}
                    </Text>
                </Paper>
            </Group>
        </Box>;
    }

    # Custom components for ReactMarkdown
    components = {
        "code": lambda props: any -> any {
            className = props.className or "";
            children = props.children;
            isInline = not className.includes("language-");

            # Extract language from className by splitting
            language = "";
            if className.includes("language-") {
                parts = className.split("language-");
                if parts.length > 1 {
                    langPart = parts[1].split(" ")[0];
                    language = langPart;
                }
            }
            codeContent = String(children);
            if codeContent.endsWith("\n") {
                codeContent = codeContent.slice(0, -1);
            }

            if not isInline and language {
                return <CodeBlock language={language} code={codeContent} />;
            }
            return <Code
                style={{
                    "background": "rgba(124, 58, 237, 0.15)",
                    "color": "#c084fc",
                    "padding": "2px 6px",
                    "borderRadius": "4px",
                    "fontSize": "13px"
                }}
            >
                {children}
            </Code>;
        },
        "h1": lambda props: any -> any {
            return <Text size="lg" fw={700} c="white" mt="md" mb="xs" style={{"borderBottom": "1px solid rgba(255,255,255,0.1)", "paddingBottom": "8px"}}>
                {props.children}
            </Text>;
        },
        "h2": lambda props: any -> any {
            return <Text size="md" fw={700} c="white" mt="sm" mb="xs">
                {props.children}
            </Text>;
        },
        "h3": lambda props: any -> any {
            return <Text size="sm" fw={700} c="white" mt="sm" mb="xs">
                {props.children}
            </Text>;
        },
        "p": lambda props: any -> any {
            return <Text size="sm" c="gray.3" my="xs" style={{"lineHeight": "1.7"}}>
                {props.children}
            </Text>;
        },
        "ul": lambda props: any -> any {
            return <Box component="ul" my="xs" pl="md" style={{"listStyleType": "disc"}}>
                {props.children}
            </Box>;
        },
        "ol": lambda props: any -> any {
            return <Box component="ol" my="xs" pl="md" style={{"listStyleType": "decimal"}}>
                {props.children}
            </Box>;
        },
        "li": lambda props: any -> any {
            return <Text component="li" size="sm" c="gray.3" style={{"lineHeight": "1.7", "marginBottom": "4px"}}>
                {props.children}
            </Text>;
        },
        "strong": lambda props: any -> any {
            return <Text component="strong" fw={700} c="white" span>
                {props.children}
            </Text>;
        },
        "em": lambda props: any -> any {
            return <Text component="em" fs="italic" c="gray.4" span>
                {props.children}
            </Text>;
        },
        "a": lambda props: any -> any {
            return <Text
                component="a"
                href={props.href}
                target="_blank"
                rel="noopener noreferrer"
                c="violet.4"
                td="none"
                style={{"cursor": "pointer"}}
                span
            >
                {props.children}
            </Text>;
        },
        "hr": lambda props: any -> any {
            return <Box my="md" style={{"borderTop": "1px solid rgba(255,255,255,0.1)"}} />;
        }
    };

    # Bot message - full width with markdown
    return <Box py="sm" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
        <Group gap="sm" align="flex-start">
            <Box style={{
                "width": "32px",
                "height": "32px",
                "borderRadius": "8px",
                "background": "linear-gradient(135deg, #7c3aed 0%, #a855f7 100%)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "flexShrink": "0"
            }}>
                <IconSparkles size={16} color="white" />
            </Box>
            <Box style={{"flex": "1", "minWidth": "0"}}>
                <ReactMarkdown
                    rehypePlugins={[rehypeHighlight]}
                    components={components}
                >
                    {message}
                </ReactMarkdown>
            </Box>
        </Group>
    </Box>;
}
