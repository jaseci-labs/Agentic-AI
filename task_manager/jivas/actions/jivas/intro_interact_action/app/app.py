"""This module contains the main app logic for the Intro Interact action."""

from jvclient.lib.widgets import app_controls, app_header, app_update_action
from streamlit_router import StreamlitRouter


def render(router: StreamlitRouter, agent_id: str, action_id: str, info: dict) -> None:
    """
    Renders the app for the Intro Interact action.

    :param router: The StreamlitRouter instance.
    :param agent_id: The agent ID.
    :param action_id: The action ID.
    :param info: A dictionary containing additional information.
    """

    # add app header controls
    (model_key, module_root) = app_header(agent_id, action_id, info)
    # add app main controls
    app_controls(agent_id, action_id)
    # add update button to apply changes
    app_update_action(agent_id, action_id)
