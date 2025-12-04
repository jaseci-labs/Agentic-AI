cl {
    import from '@mui/material' {
        Box,
        Paper,
        Typography,
        Stack,
        Avatar,
        Divider,
        Drawer,
        List,
        ListItem,
        ListItemButton,
        ListItemIcon,
        ListItemText
    }
    import from '@mui/icons-material' {
        School,
        Lightbulb
    }
}

cl def Sidebar(props: any) -> any {
    let activeTab = props.activeTab;
    let setActiveTab = props.setActiveTab;
    let navigationItems = props.navigationItems;

    return <Drawer
        variant="permanent"
        sx={{
            "width": 280,
            "flexShrink": 0,
            "& .MuiDrawer-paper": {
                "width": 280,
                "boxSizing": "border-box",
                "background": "rgba(15, 23, 42, 0.95)",
                "backdropFilter": "blur(20px)",
                "borderRight": "1px solid rgba(167, 139, 250, 0.2)",
                "pt": 3
            }
        }}
    >
        <Box sx={{"px": 3, "mb": 4}}>
            <Stack direction="row" spacing={2} alignItems="center">
                <Avatar
                    sx={{
                        "width": 48,
                        "height": 48,
                        "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)"
                    }}
                >
                    <School sx={{"fontSize": 28}} />
                </Avatar>
                <Box>
                    <Typography variant="h6" sx={{"fontWeight": 700, "lineHeight": 1.2}}>
                        {"Smart Learning"}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                        {"Companion"}
                    </Typography>
                </Box>
            </Stack>
        </Box>
        <Divider sx={{"borderColor": "rgba(167, 139, 250, 0.2)", "mb": 2}} />
        <List sx={{"px": 2}}>
            {navigationItems.map(
                lambda item: any -> any {
                    let isActive = activeTab == item["id"];
                    return <ListItem key={item["id"]} disablePadding sx={{"mb": 1}}>
                        <ListItemButton
                            onClick={lambda -> None { setActiveTab(item["id"]); }}
                            sx={{
                                "borderRadius": 2,
                                "py": 1.5,
                                "background": (
                                    "linear-gradient(135deg, rgba(167, 139, 250, 0.2) 0%, rgba(244, 114, 182, 0.2) 100%)"
                                    if isActive
                                    else "transparent"
                                ),
                                "border": (
                                    "1px solid rgba(167, 139, 250, 0.4)"
                                    if isActive
                                    else "1px solid transparent"
                                ),
                                "&:hover": {
                                    "background": "rgba(167, 139, 250, 0.1)",
                                    "border": "1px solid rgba(167, 139, 250, 0.3)"
                                }
                            }}
                        >
                            <ListItemIcon
                                sx={{
                                    "color": (
                                        "primary.main"
                                        if isActive
                                        else "text.secondary"
                                    ),
                                    "minWidth": 40
                                }}
                            >
                                {item["icon"]}
                            </ListItemIcon>
                            <ListItemText
                                primary={item["label"]}
                                primaryTypographyProps={{
                                    "fontWeight": (600 if isActive else 500),
                                    "color": (
                                        "primary.light"
                                        if isActive
                                        else "text.primary"
                                    )
                                }}
                            />
                        </ListItemButton>
                    </ListItem>;
                }
            )}
        </List>
        <Box sx={{"flexGrow": 1}} />
        <Box sx={{"p": 3, "pt": 2}}>
            <Paper
                sx={{
                    "p": 2,
                    "background": "rgba(167, 139, 250, 0.1)",
                    "border": "1px solid rgba(167, 139, 250, 0.2)"
                }}
            >
                <Stack spacing={1}>
                    <Stack direction="row" spacing={1} alignItems="center">
                        <Lightbulb sx={{"fontSize": 20, "color": "primary.main"}} />
                        <Typography variant="caption" sx={{"fontWeight": 600}}>
                            {"Quick Tip"}
                        </Typography>
                    </Stack>
                    <Typography variant="caption" color="text.secondary" sx={{"lineHeight": 1.4}}>
                        {"Ask follow-up questions to dive deeper into topics!"}
                    </Typography>
                </Stack>
            </Paper>
        </Box>
    </Drawer>;
}
