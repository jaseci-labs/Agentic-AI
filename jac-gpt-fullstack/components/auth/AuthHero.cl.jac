"""Shared left-hand hero for the auth screens (Login / Register).

Pure presentation — branding, tagline, and feature cards. Identical on both
pages so it lives here once.
"""

import from "@mantine/core" { Box, Text, Group }
import from "@tabler/icons-react" {
    IconCode,
    IconCpu,
    IconBolt,
    IconDatabase,
    IconSparkles
}

def:pub AuthHero() -> JsxElement {
    TEXT = "var(--text-primary)";
    MUTED = "var(--text-muted)";
    ORANGE = "var(--primary)";

    logoMark = <img
        src="/logo.png"
        alt="JacGPT"
        style={{
            "height": "42px",
            "width": "auto",
            "display": "block",
            "flexShrink": 0,
            "filter": "drop-shadow(0 0 12px rgba(249,115,22,0.35))"
        }}
    />;

    return <div className="jc-auth-hero jc-fade-in">
        <Group gap="sm" mb={40}>
            {logoMark}
            <Box>
                <Text fw={800} fz="20px" c={TEXT} style={{"letterSpacing": "-0.02em"}}>
                    JacGPT
                </Text>
                <Text fz="11px" c={MUTED} style={{"letterSpacing": "0.14em", "textTransform": "uppercase"}}>
                    Jaseci Ecosystem
                </Text>
            </Box>
        </Group>

        <Group gap={8} mb={28} style={{
            "display": "inline-flex",
            "alignSelf": "flex-start",
            "padding": "6px 14px",
            "borderRadius": "999px",
            "background": "rgba(249,115,22,0.08)",
            "border": "1px solid rgba(249,115,22,0.22)"
        }}>
            <IconSparkles size={13} color={ORANGE} />
            <Text fz="12px" fw={600} style={{"color": "rgba(249,115,22,0.9)"}}>
                Powered by Jaseci Ecosystem
            </Text>
        </Group>

        <Text component="h1" fw={800} style={{
            "fontSize": "clamp(34px, 4vw, 52px)",
            "lineHeight": 1.05,
            "letterSpacing": "-0.03em",
            "color": TEXT,
            "marginBottom": "18px"
        }}>
            The AI built for{" "}
            <span className="jc-gradient-text">Jac developers</span>
        </Text>

        <Text fz="16px" c={MUTED} maw={440} style={{"lineHeight": 1.6, "marginBottom": "36px"}}>
            Ask questions, write Jac code, and explore the Jaseci ecosystem — all in one
            intelligent workspace.
        </Text>

        <Box style={{
            "display": "grid",
            "gridTemplateColumns": "repeat(2, minmax(0, 1fr))",
            "gap": "12px",
            "maxWidth": "520px"
        }}>
            <div className="jc-feature-card">
                <Group gap={10} align="flex-start" wrap="nowrap">
                    <IconCode size={18} color={ORANGE} style={{"marginTop": "2px", "flexShrink": 0}} />
                    <Box>
                        <Text fw={700} fz="14px" c={TEXT}>Jac Language</Text>
                        <Text fz="12.5px" c={MUTED} style={{"lineHeight": 1.5}}>
                            Write and run Jac code natively
                        </Text>
                    </Box>
                </Group>
            </div>
            <div className="jc-feature-card">
                <Group gap={10} align="flex-start" wrap="nowrap">
                    <IconCpu size={18} color={ORANGE} style={{"marginTop": "2px", "flexShrink": 0}} />
                    <Box>
                        <Text fw={700} fz="14px" c={TEXT}>Agentic AI</Text>
                        <Text fz="12.5px" c={MUTED} style={{"lineHeight": 1.5}}>
                            Multi-agent orchestration built-in
                        </Text>
                    </Box>
                </Group>
            </div>
            <div className="jc-feature-card">
                <Group gap={10} align="flex-start" wrap="nowrap">
                    <IconBolt size={18} color={ORANGE} style={{"marginTop": "2px", "flexShrink": 0}} />
                    <Box>
                        <Text fw={700} fz="14px" c={TEXT}>Jaseci Runtime</Text>
                        <Text fz="12.5px" c={MUTED} style={{"lineHeight": 1.5}}>
                            Powered by the Jaseci ecosystem
                        </Text>
                    </Box>
                </Group>
            </div>
            <div className="jc-feature-card">
                <Group gap={10} align="flex-start" wrap="nowrap">
                    <IconDatabase size={18} color={ORANGE} style={{"marginTop": "2px", "flexShrink": 0}} />
                    <Box>
                        <Text fw={700} fz="14px" c={TEXT}>RAG & MCP</Text>
                        <Text fz="12.5px" c={MUTED} style={{"lineHeight": 1.5}}>
                            Retrieval-augmented generation modes
                        </Text>
                    </Box>
                </Group>
            </div>
        </Box>

        <Text fz="12px" c={MUTED} mt={40} style={{"opacity": 0.7}}>
            Built by Jaseci Labs · jaseci.org
        </Text>
    </div>;
}
