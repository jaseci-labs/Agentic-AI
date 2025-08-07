"""This module renders the streamlit app for the Email Handle Action Interact Action."""

from streamlit_router import StreamlitRouter

from jvcli.client.lib.widgets import app_controls, app_header, app_update_action


def render(router: StreamlitRouter, agent_id: str, action_id: str, info: dict) -> None:
    """Render the Streamlit app for the Email Handle Action Interact Action.
    :param router: The StreamlitRouter instance
    :param agent_id: The agent ID
    :param action_id: The action ID
    :param info: The action info dict
    """

    # Add app header controls
    (model_key, action) = app_header(agent_id, action_id, info)

    # Add app main controls
    app_controls(agent_id, action_id)

    # Add update button to apply changes
    app_update_action(agent_id, action_id)
