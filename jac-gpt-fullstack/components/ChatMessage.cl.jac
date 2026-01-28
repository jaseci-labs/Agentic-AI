"""Chat message component with markdown rendering using Mantine UI (Jaseci theme)."""

import from react { useState, useEffect, useRef, useMemo }
import from "react-markdown" { default as ReactMarkdown }
import from "@mantine/core" {
    Box,
    Group,
    Text,
    Paper,
    ActionIcon,
    Tooltip,
    Code
}
import from "@tabler/icons-react" {
    IconCopy,
    IconCheck
}

# Lightweight syntax highlighting (instant rendering)
import from "..utils/jac_highlighter" { highlightCode }


"""Generic code block component with copy functionality (for non-Jac languages)."""
def:pub CodeBlock(language: str, code: str, children: any = null) -> any {
    has copied: bool = false;

    def handleCopy() -> None {
        navigator.clipboard.writeText(code);
        copied = true;
        setTimeout(lambda { copied = false; }, 2000);
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
                "background": "rgba(0,0,0,0.42)",
                "border": "1px solid rgba(255,255,255,0.10)",
                "overflow": "hidden"
            }}
        >
            <Group
                justify="space-between"
                px="md"
                py="xs"
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.06)",
                    "background": "rgba(0,0,0,0.25)"
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


"""Lightweight Jac code block with instant syntax highlighting."""
def:pub JacCodeBlock(code: str) -> any {
    has copied: bool = false;

    # Memoize highlighted HTML - only re-compute when code changes
    highlightedHtml = useMemo(lambda -> str { return highlightCode(code, "jac"); }, [code]);

    def handleCopy() -> None {
        navigator.clipboard.writeText(code);
        copied = true;
        setTimeout(lambda { copied = false; }, 2000);
    }

    copyLabel = "Copy code";
    copyColor = "gray";
    copyIcon = <IconCopy size={14} />;
    if copied {
        copyLabel = "Copied!";
        copyColor = "green";
        copyIcon = <IconCheck size={14} />;
    }

    # Split code into lines for line numbers
    lines = code.split("\n");
    lineCount = lines.length;

    return <Box my="sm">
        <Paper
            radius="md"
            style={{
                "background": "rgba(0,0,0,0.42)",
                "border": "1px solid rgba(255,255,255,0.10)",
                "overflow": "hidden"
            }}
        >
            <Group
                justify="space-between"
                px="md"
                py="xs"
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.06)",
                    "background": "rgba(0,0,0,0.25)"
                }}
            >
                <Text size="xs" c="dimmed" ff="monospace">jac</Text>
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

            <Box className="jac-code-container" style={{"display": "flex", "overflowX": "auto"}}>
                <Box
                    className="line-numbers"
                    style={{
                        "padding": "8px 12px",
                        "textAlign": "right",
                        "userSelect": "none",
                        "borderRight": "1px solid rgba(255,255,255,0.06)",
                        "background": "rgba(0,0,0,0.15)"
                    }}
                >
                    {lines.map(lambda _: any, idx: int -> any {
                        return <div key={idx} style={{
                            "fontSize": "13px",
                            "lineHeight": "1.6",
                            "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace",
                            "color": "#6b7280"
                        }}>{idx + 1}</div>;
                    })}
                </Box>
                <Box style={{"flex": "1", "overflow": "auto"}}>
                    <pre
                        className="hljs jac-highlighted"
                        style={{
                            "margin": "0",
                            "padding": "8px 16px",
                            "fontSize": "13px",
                            "lineHeight": "1.6",
                            "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace",
                            "whiteSpace": "pre",
                            "background": "transparent",
                            "color": "#e4e4e7"
                        }}
                        dangerouslySetInnerHTML={{ "__html": highlightedHtml }}
                    />
                </Box>
            </Box>
        </Paper>
    </Box>;
}

"""Chat message component."""
def:pub ChatMessage(message: str, isUser: bool, timestamp: any = null) -> any {

    ORANGE = "#f97316";
    logoSrc = "/logo.png";

    if isUser {
        # User message - right aligned
        return <Box py="4px" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
            <Group justify="flex-end">
                <div
                    style={{
                        "padding": "16px",
                        "maxWidth": "80%",
                        "background": "rgba(255, 255, 255, 0.05)",
                        "border": "none",
                        "borderRadius": "24px",
                        "boxShadow": "none"
                    }}
                >
                    <Text size="sm" c="white" style={{"whiteSpace": "pre-wrap", "lineHeight": "1.6"}}>
                        {message}
                    </Text>
                </div>
            </Group>
        </Box>;
    }

    # Bot message: Markdown enabled
    components = {
        "code": lambda props: any -> any {
            className = props.className or "";
            children = props.children;
            isInline = not className.includes("language-");

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

            # Block code
            if not isInline and language {
                # Use lightweight highlighter for Jac code (instant rendering)
                if language == "jac" {
                    return <JacCodeBlock code={codeContent} />;
                }

                # Use simple block for other languages
                return <CodeBlock language={language} code={codeContent} />;
            }

            # Inline code
            return <Code
                style={{
                    "background": "rgba(249,115,22,0.15)",
                    "color": "#fdba74",
                    "padding": "2px 6px",
                    "borderRadius": "4px",
                    "fontSize": "13px",
                    "border": "1px solid rgba(249,115,22,0.20)"
                }}
            >
                {children}
            </Code>;
        },

        "h1": lambda props: any -> any {
            return <Text size="lg" fw={700} c="white" mt="md" mb="xs"
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.10)",
                    "paddingBottom": "8px"
                }}>
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
            return <Text component="li" size="sm" c="gray.3"
                style={{"lineHeight": "1.7", "marginBottom": "4px"}}>
                {props.children}
            </Text>;
        },

        "strong": lambda props: any -> any {
            return <strong style={{
                "fontWeight": "700",
                "color": "#ffffff"
            }}>
                {props.children}
            </strong>;
        },

        "em": lambda props: any -> any {
            return <em style={{
                "fontStyle": "italic",
                "color": "#a1a1aa"
            }}>
                {props.children}
            </em>;
        },

        "a": lambda props: any -> any {
            return <Text
                component="a"
                href={props.href}
                target="_blank"
                rel="noopener noreferrer"
                td="none"
                span
                style={{
                    "cursor": "pointer",
                    "color": ORANGE
                }}
            >
                {props.children}
            </Text>;
        },

        "hr": lambda props: any -> any {
            return <Box my="md" style={{"borderTop": "1px solid rgba(255,255,255,0.10)"}} />;
        }
    };

    # Bot message - left aligned
    return <Box py="sm" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
        <Box style={{"flex": "1", "minWidth": "0"}}>
            <ReactMarkdown components={components}>
                {message}
            </ReactMarkdown>
        </Box>
    </Box>;
}