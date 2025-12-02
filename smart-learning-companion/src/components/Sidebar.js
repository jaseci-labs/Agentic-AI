import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { Box, Paper, Typography, Stack, Avatar, Divider, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText } from "@mui/material";
import { School, Lightbulb } from "@mui/icons-material";
function Sidebar(props) {
  let activeTab = props.activeTab;
  let setActiveTab = props.setActiveTab;
  let navigationItems = props.navigationItems;
  return __jacJsx(Drawer, {"variant": "permanent", "sx": {"width": 280, "flexShrink": 0, "& .MuiDrawer-paper": {"width": 280, "boxSizing": "border-box", "background": "rgba(15, 23, 42, 0.95)", "backdropFilter": "blur(20px)", "borderRight": "1px solid rgba(167, 139, 250, 0.2)", "pt": 3}}}, [__jacJsx(Box, {"sx": {"px": 3, "mb": 4}}, [__jacJsx(Stack, {"direction": "row", "spacing": 2, "alignItems": "center"}, [__jacJsx(Avatar, {"sx": {"width": 48, "height": 48, "background": "linear-gradient(135deg, #a78bfa 0%, #f472b6 100%)"}}, [__jacJsx(School, {"sx": {"fontSize": 28}}, [])]), __jacJsx(Box, {}, [__jacJsx(Typography, {"variant": "h6", "sx": {"fontWeight": 700, "lineHeight": 1.2}}, ["Smart Learning"]), __jacJsx(Typography, {"variant": "caption", "color": "text.secondary"}, ["Companion"])])])]), __jacJsx(Divider, {"sx": {"borderColor": "rgba(167, 139, 250, 0.2)", "mb": 2}}, []), __jacJsx(List, {"sx": {"px": 2}}, [navigationItems.map(item => {
    let isActive = activeTab === item["id"];
    return __jacJsx(ListItem, {"key": item["id"], "disablePadding": true, "sx": {"mb": 1}}, [__jacJsx(ListItemButton, {"onClick": () => {
      setActiveTab(item["id"]);
    }, "sx": {"borderRadius": 2, "py": 1.5, "background": isActive ? "linear-gradient(135deg, rgba(167, 139, 250, 0.2) 0%, rgba(244, 114, 182, 0.2) 100%)" : "transparent", "border": isActive ? "1px solid rgba(167, 139, 250, 0.4)" : "1px solid transparent", "&:hover": {"background": "rgba(167, 139, 250, 0.1)", "border": "1px solid rgba(167, 139, 250, 0.3)"}}}, [__jacJsx(ListItemIcon, {"sx": {"color": isActive ? "primary.main" : "text.secondary", "minWidth": 40}}, [item["icon"]]), __jacJsx(ListItemText, {"primary": item["label"], "primaryTypographyProps": {"fontWeight": isActive ? 600 : 500, "color": isActive ? "primary.light" : "text.primary"}}, [])])]);
  })]), __jacJsx(Box, {"sx": {"flexGrow": 1}}, []), __jacJsx(Box, {"sx": {"p": 3, "pt": 2}}, [__jacJsx(Paper, {"sx": {"p": 2, "background": "rgba(167, 139, 250, 0.1)", "border": "1px solid rgba(167, 139, 250, 0.2)"}}, [__jacJsx(Stack, {"spacing": 1}, [__jacJsx(Stack, {"direction": "row", "spacing": 1, "alignItems": "center"}, [__jacJsx(Lightbulb, {"sx": {"fontSize": 20, "color": "primary.main"}}, []), __jacJsx(Typography, {"variant": "caption", "sx": {"fontWeight": 600}}, ["Quick Tip"])]), __jacJsx(Typography, {"variant": "caption", "color": "text.secondary", "sx": {"lineHeight": 1.4}}, ["Ask follow-up questions to dive deeper into topics!"])])])])]);
}
export { Sidebar };
