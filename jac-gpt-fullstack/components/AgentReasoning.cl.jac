"""Agent reasoning panel that displays intermediate LLM steps (thoughts, tool calls, results)."""

import from react { useState, useEffect, useRef }
import from "@mantine/core" {
    Box,
    Text,
    Paper,
    Group,
    ActionIcon,
    Badge,
    Loader
}
import from "@tabler/icons-react" {
    IconChevronDown,
    IconChevronUp,
    IconBulb,
    IconTool,
    IconFileText,
    IconCheck
}


"""Single reasoning step display."""
def:pub ReasoningStep(step: any, index: int) -> JsxElement {
    has expanded: bool = false;

    icon = null;
    label = "";
    color = "";
    content = "";

    if step.type == "thought" {
        icon = <IconBulb size={14} />;
        label = "Thinking";
        color = "yellow";
        content = step.data.content or "";
    } elif step.type == "tool_call" {
        icon = <IconTool size={14} />;
        label = step.data.tool or "Tool Call";
        color = "blue";
        argsStr = "";
        try {
            argsStr = JSON.stringify(step.data.args);
        } except Exception {
            argsStr = String(step.data.args or "");
        }
        content = argsStr;
    } elif step.type == "tool_result" {
        icon = <IconFileText size={14} />;
        label = step.data.tool or "Result";
        color = "teal";
        content = step.data.result or "";
    } elif step.type == "steps_done" {
        icon = <IconCheck size={14} />;
        label = "Complete";
        color = "green";
        iterations = step.data.iterations or 0;
        suffix = "";
        if iterations != 1 {
            suffix = "s";
        }
        content = "Done in " + String(iterations) + " iteration" + suffix;
    }

    isLongContent = content.length > 120;
    displayContent = content;
    if isLongContent and not expanded {
        displayContent = content.substring(0, 120) + "...";
    }

    cursorStyle = "default";
    if isLongContent {
        cursorStyle = "pointer";
    }

    iterationLabel = None;
    if step.data.iteration {
        iterationLabel = <Text size="xs" c="dimmed">
            {"Step " + String(step.data.iteration)}
        </Text>;
    }

    contentBlock = None;
    if content {
        contentBlock = <Box mt="4px">
            <Text
                size="xs"
                c="dimmed"
                style={{
                    "fontFamily": "JetBrains Mono, Consolas, monospace",
                    "fontSize": "11px",
                    "lineHeight": "1.5",
                    "whiteSpace": "pre-wrap",
                    "wordBreak": "break-word",
                    "cursor": cursorStyle
                }}
                onClick={lambda { if isLongContent { expanded = not expanded; } }}
            >
                {displayContent}
            </Text>
        </Box>;
    }

    return <Box
        py="4px"
        style={{
            "borderLeft": "2px solid rgba(249, 115, 22, 0.3)",
            "paddingLeft": "12px",
            "animation": "fadeIn 0.3s ease"
        }}
    >
        <Group gap="xs" align="center">
            <Badge
                size="xs"
                variant="light"
                color={color}
                leftSection={icon}
                style={{ "textTransform": "none" }}
            >
                {label}
            </Badge>
            {iterationLabel}
        </Group>
        {contentBlock}
    </Box>;
}


"""Agent reasoning panel - collapsible display of all intermediate steps."""
def:pub AgentReasoning(steps: list, isActive: bool = false) -> JsxElement {
    has isOpen: bool = true;
    stepsEndRef = useRef(None);

    # Auto-scroll within the reasoning panel when new steps arrive
    useEffect(lambda -> None {
        if isOpen and stepsEndRef.current {
            stepsEndRef.current.scrollIntoView({"behavior": "smooth", "block": "nearest"});
        }
    }, [steps.length, isOpen]);

    if steps.length == 0 and not isActive {
        return null;
    }

    toggleIcon = <IconChevronUp size={14} />;
    if not isOpen {
        toggleIcon = <IconChevronDown size={14} />;
    }

    headerLabel = "Agent Reasoning";
    if steps.length > 0 {
        headerLabel = "Agent Reasoning (" + String(steps.length) + " steps)";
    }

    borderBottom = "none";
    if isOpen {
        borderBottom = "1px solid rgba(249, 115, 22, 0.10)";
    }

    loaderElement = None;
    if isActive {
        loaderElement = <Loader size="xs" color="orange" type="dots" />;
    }

    contentDisplay = "none";
    contentPadding = "0";
    if isOpen {
        contentDisplay = "block";
        contentPadding = "8px 12px";
    }

    return <Paper
        radius="md"
        mb="xs"
        style={{
            "background": "rgba(249, 115, 22, 0.04)",
            "border": "1px solid rgba(249, 115, 22, 0.15)",
            "overflow": "hidden"
        }}
    >
        <Group
            justify="space-between"
            px="sm"
            py="6px"
            style={{
                "cursor": "pointer",
                "borderBottom": borderBottom
            }}
            onClick={lambda { isOpen = not isOpen; }}
        >
            <Group gap="xs">
                {loaderElement}
                <Text size="xs" fw={600} c="orange.4">
                    {headerLabel}
                </Text>
            </Group>
            <ActionIcon variant="subtle" color="gray" size="xs">
                {toggleIcon}
            </ActionIcon>
        </Group>

        <div style={{
            "display": contentDisplay,
            "maxHeight": "300px",
            "overflowY": "auto",
            "padding": contentPadding
        }}>
            {steps.map(lambda (step: any, i: int) -> any {
                return <ReasoningStep key={i} step={step} index={i} />;
            })}
            <div ref={stepsEndRef} />
        </div>
    </Paper>;
}
