"""This module provides the Streamlit application for managing agent utilities."""

import json
import time
from io import BytesIO
from typing import Any, Dict, List, Union

import streamlit as st
import yaml
from jvclient.lib.utils import (
    call_api,
    get_reports_payload,
    call_get_agent,
    call_healthcheck,
    call_import_agent,
    call_update_agent,
)
from jvclient.lib.widgets import app_controls, app_header
from streamlit_router import StreamlitRouter


def render(router: StreamlitRouter, agent_id: str, action_id: str, info: dict) -> None:
    """Render the Streamlit application for managing agent utilities."""
    # Add application header controls
    (model_key, module_root) = app_header(agent_id, action_id, info)

    # initialise the agent object by fetching the agent based on agent_id
    agent_details = call_get_agent(agent_id)    

    with st.expander("Agent Configuration", False):

        for item_key in agent_details:
            st.session_state[model_key][item_key] = agent_details[item_key]
        hidden = ["id", "published", "descriptor", "meta", "healthcheck_status"]

        # Editable fields for agent configuration
        app_controls(agent_id, action_id, hidden)

        if st.button(
            "Update Configuration", key=f"{model_key}_btn_update_configuration"
        ):
            updated_data = st.session_state[model_key]
            # Prepare the updated agent data
            agent_data = {}
            for item_key in updated_data:
                if item_key not in hidden:
                    agent_data[item_key] = updated_data[item_key]

            # Call the function to update the agent configuration
            if result := call_update_agent(agent_id, agent_data):
                st.success("Agent updated successfully")
            else:
                st.error("Failed to update agent.")

    with st.expander("Initialize Agents", False):
        # Initialize all agents

        if st.button("Initialize Agents", key=f"{model_key}_btn_init_agents"):

            response = call_api("walker/init_agents", json_data={})
            if response is not None and response.status_code == 200:
                st.success("Agents initialized successfully")
            else:
                st.error("Failed to initialize agents.")

    with st.expander("Agent Healthcheck", False):
        if st.button("Run Healthcheck", key=f"{model_key}_btn_health_check_agent"):
            # Call the function to check the health
            if result := call_healthcheck(agent_id=agent_id):
                if result.get("status") == 200:
                    st.success("Agent health okay")
                else:
                    st.error("Agent health not okay")
                st.code(json.dumps(result, indent=2, sort_keys=False))
            else:
                st.error("Agent health not okay")
                st.code(json.dumps(result, indent=2, sort_keys=False))

    with st.expander("Memory Healthcheck", False):
        # User input fields
        session_id = st.text_input(
            "Session ID (optional)", value="", key=f"{model_key}_healthcheck_session_id"
        )

        if st.button("Run Healthcheck", key=f"{model_key}_btn_healthcheck"):
            # Prepare parameters
            params = {"session_id": session_id}

            # Call the function for healthcheck
            result = call_api(
                endpoint="action/walker/agent_utils_action/memory_healthcheck",
                json_data={"agent_id": agent_id, "session_id": session_id},
            )

            # Display results
            if result and result.status_code == 200:
                result = get_reports_payload(result)
                # json_result = result.json()
                # result = json_result.get("reports", [{}])[0]
                st.success("Memory healthcheck completed successfully!")

                # Dynamically display key-value pairs
                for key, value in result.items():
                    st.write(f"**{key}:** {value}")
            else:
                st.error(
                    "Failed to run memory healthcheck. Please check your inputs and try again."
                )

    with st.expander("Purge Frame Memory", False):
        session_id = st.text_input(
            "Session ID (optional)", value="", key=f"{model_key}_purge_frame_session_id"
        )

        # Step 1: Trigger confirmation
        if st.button("Purge Frame", key=f"{model_key}_btn_purge_frame"):
            st.session_state.confirm_purge_frame = True
            st.session_state.purge_frame_result = None  # Clear any previous result

        # Step 2: Handle confirmation prompt
        if st.session_state.get("confirm_purge_frame", False):
            st.warning(
                "Are you sure you want to purge the frame? This action cannot be undone.",
                icon="⚠️",
            )
            col1, col2 = st.columns(2)

            with col1:
                if st.button("Yes, Purge Frame"):
                    purge_frame_result = call_api(
                        endpoint = "action/walker/agent_utils_action/purge_frame_memory",
                        json_data = {"agent_id": agent_id, "session_id": session_id},
                    )
                    if purge_frame_result and purge_frame_result.status_code == 200:
                        st.session_state.purge_frame_result = True
                        st.session_state.confirm_purge_frame = False

            with col2:
                if st.button("No, Keep Frame"):
                    st.session_state.confirm_purge_frame = False
                    st.session_state.purge_frame_result = None
                    st.rerun()

        # Step 3: Show result *outside* confirmation
        purge_frame_result = st.session_state.get("purge_frame_result")
        if purge_frame_result in [True, []]:
            st.success("Agent frame memory purged successfully")
            st.session_state.purge_frame_result = None  # Reset after showing
            time.sleep(2)
            st.rerun()
        elif purge_frame_result is False:
            st.error(
                "Failed to purge frame memory. Ensure that there is something to purge or check functionality"
            )
            st.session_state.purge_frame_result = None  # Reset after showing
            time.sleep(2)
            st.rerun()

    with st.expander("Purge Collection Memory", False):
        collection_name = st.text_input(
            "Collection Name (optional)",
            value="",
            key=f"{model_key}_purge_collection_collection_name",
        )

        # Step 1: Trigger confirmation
        if st.button("Purge Collection", key=f"{model_key}_btn_purge_collection"):
            st.session_state.confirm_purge_collection = True
            st.session_state.purge_collection_result = None  # Clear any previous result

        # Step 2: Handle confirmation prompt
        if st.session_state.get("confirm_purge_collection", False):
            st.warning(
                "Are you sure you want to purge the collection? This action cannot be undone.",
                icon="⚠️",
            )
            col1, col2 = st.columns(2)

            with col1:
                if st.button("Yes, Purge Collection"):
                    purge_collection_result = call_api(
                        endpoint = "action/walker/agent_utils_action/purge_collection_memory",
                        json_data = {"agent_id": agent_id, "collection_name": collection_name},
                    )
                    st.session_state.purge_collection_result = purge_collection_result
                    st.session_state.confirm_purge_collection = False

            with col2:
                if st.button("No, Keep Collection"):
                    st.session_state.confirm_purge_collection = False
                    st.session_state.purge_collection_result = None
                    st.rerun()

        # Step 3: Show result *outside* confirmation
        purge_collection_result = st.session_state.get("purge_collection_result")
        if purge_collection_result in [True, []]:
            st.success("Agent collection memory purged successfully")
            st.session_state.purge_collection_result = None  # Reset after showing
            time.sleep(2)
            st.rerun()
        elif purge_collection_result is False:
            st.error(
                "Failed to purge collection memory. Ensure that there is something to purge or check functionality"
            )
            st.session_state.purge_collection_result = None  # Reset after showing
            time.sleep(2)
            st.rerun()

    with st.expander("Logging", False):
        _logging = call_api(endpoint="action/walker/agent_utils_action/get_logging", json_data={"agent_id": agent_id})

        if _logging and _logging.status_code == 200:
            # _logging = _logging.json()
            # _logging = _logging.get("reports", [False])[0]
            _logging = get_reports_payload(_logging)
            logging = st.checkbox(
                "Log Interactions", value=_logging, key=f"{model_key}_logging"
            )

            if st.button("Update", key=f"{model_key}_btn_logging_update"):
                if result := call_api(
                    endpoint="action/walker/agent_utils_action/set_logging", json_data={"agent_id": agent_id, "agent_logging": logging}
                ):
                    st.success("Agent logging config updated")
                else:
                    st.error(
                        "Failed to update logging config. Ensure that there is something to refresh or check functionality"
                    )

    with st.expander("Refresh Memory", False):
        session_id = st.text_input(
            "Session ID", value="", key=f"{model_key}_refresh_session_id"
        )

        if st.button(
            "Purge", key=f"{model_key}_btn_refresh", disabled=(not session_id)
        ):
            # Call the function to purge
            if result := call_api(
                endpoint="action/walker/agent_utils_action/refresh_memory",
                json_data={"agent_id": agent_id, "session_id": session_id},
            ):
                st.success("Agent memory refreshed successfully")
            else:
                st.error(
                    "Failed to refresh agent memory. Ensure that there is something to refresh or check functionality"
                )

    with st.expander("Import Memory", False):
        memory_data = st.text_area(
            "Agent Memory in YAML or JSON",
            value="",
            height=170,
            key=f"{model_key}_memory_data",
        )
        overwrite = st.toggle(
            "Overwrite", value=True, key=f"{model_key}_overwrite_memory"
        )

        if st.button("Import", key=f"{model_key}_btn_import_memory"):
            # Call the function to import
            if result := call_api(
                endpoint="action/walker/agent_utils_action/import_memory",
                json_data={"agent_id": agent_id, "data": memory_data, "overwrite": overwrite},
            ):
                st.success("Agent memory imported successfully")
            else:
                st.error(
                    "Failed to import agent. Ensure that the  descriptor is in valid YAML format"
                )

            uploaded_file = st.file_uploader(
                "Upload file", key=f"{model_key}_agent_memory_upload"
            )

            if uploaded_file is not None:
                loaded_config = yaml.safe_load(uploaded_file)
                if loaded_config:
                    st.write(loaded_config)
                    if result := call_api(
                        endpoint="action/walker/agent_utils_action/import_memory",
                        json_data={"agent_id": agent_id, "data": memory_data},
                    ):
                        st.success("Agent memory imported successfully")
                    else:
                        st.error(
                            "Failed to import agent memory. Ensure that you are uploading a valid YAML file"
                        )
                else:
                    st.error("File is invalid. Please upload a valid YAML file")

    with st.expander("Export Memory", False):
        # User input and toggle
        session_id = st.text_input(
            "Session ID (optional)", value="", key=f"{model_key}_export_session_id"
        )
        export_json = st.toggle(
            "Export as JSON", value=True, key=f"{model_key}_export_json"
        )

        # Toggle label adjustment
        toggle_label = "Export as JSON" if export_json else "Export as YAML"
        st.caption(f"**{toggle_label} enabled**")

        if st.button("Export", key=f"{model_key}_btn_export_memory"):

            # Call the function to export memory
            result = call_api(
                endpoint="action/walker/agent_utils_action/export_memory",
                json_data={"agent_id": agent_id, "session_id": session_id},
            )

            # Log results and provide download options
            if result and "memory" in result:
                st.success("Agent memory exported successfully!")

                # Process the first two entries of memory
                memory_entries = result["memory"][:2]  # First 2 entries
                if export_json:
                    # JSON display
                    st.json(memory_entries)

                    # Prepare downloadable JSON file
                    json_data = json.dumps(result, indent=4)
                    # json_file = BytesIO(json_data.encode("utf-8"))
                    st.download_button(
                        label="Download JSON File",
                        data=json_data,
                        file_name="exported_memory.json",
                        mime="application/json",
                        key="download_json",
                    )
                else:
                    # YAML display
                    yaml_data = yaml.dump(memory_entries, sort_keys=False)
                    st.code(yaml_data, language="yaml")

                    # full memory dump
                    full_yaml_data = yaml.dump(result, sort_keys=False)

                    # Prepare downloadable YAML file
                    # yaml_file = BytesIO(full_yaml_data.encode("utf-8"))
                    st.download_button(
                        label="Download YAML File",
                        data=full_yaml_data,
                        file_name="exported_memory.yaml",
                        mime="application/x-yaml",
                        key="download_yaml",
                    )
            else:
                st.error(
                    "Failed to export agent memory. Please check your inputs and try again."
                )

    with st.expander("Import Descriptor", False):
        agent_descriptor = st.text_area(
            "Agent Descriptor in YAML/JSON",
            value="",
            height=170,
            key=f"{model_key}_agent_descriptor",
        )

        if st.button("Import", key=f"{model_key}_btn_import_agent"):
            # Call the function to import
            if result := call_import_agent(descriptor=agent_descriptor):
                st.success("Agent imported successfully")
            else:
                st.error(
                    "Failed to import agent. Ensure that the  descriptor is in valid YAML format"
                )

        uploaded_file = st.file_uploader("Upload Descriptor file")

        if uploaded_file is not None:
            st.write(uploaded_file)
            if result := call_import_agent(descriptor=uploaded_file):
                st.success("Agent imported successfully")
            else:
                st.error(
                    "Failed to import agent. Ensure that you are uploading a valid YAML file"
                )

    with st.expander("Import DAF", False):
        # Initialize lists to store classified data
        daf_name = st.text_input("DAF Name", value="", key=f"{model_key}_daf_name")

        daf_version = st.text_input(
            "DAF Version", value="0.0.1", key=f"{model_key}_daf_version"
        )

        if st.button("Import", key=f"{model_key}_btn_importing_daf"):

            response = call_api(
                endpoint="action/walker/agent_utils_action/import_agent",
                json_data={
                    "agent_id": agent_id,
                    "daf_name": daf_name,
                    "daf_version": daf_version,
                },
            )
            if response is not None and response.status_code == 200:
                st.success("Daf imported successfully")
            else:
                st.error("Failed to import DAF.")

    with st.expander("Export DAF", False):

        clean = st.checkbox(
            "Clean Descriptor",
            value=True,
            key=f"{model_key}_exporting_daf_clean_descriptor",
        )
        with_memory = st.checkbox(
            "Memory",
            value=False,
            key=f"{model_key}_exporting_daf_with_memory",
        )
        with_knowledge = st.checkbox(
            "Knowledge",
            value=False,
            key=f"{model_key}_exporting_daf_with_knowledge",
        )

        if st.button("Export", key=f"{model_key}_btn_exporting_daf"):

            response = call_api(
                endpoint="action/walker/agent_utils_action/export_agent",
                json_data={
                    "agent_id": agent_id,
                    "clean": clean,
                    "with_memory": with_memory,
                    "with_knowledge": with_knowledge,
                    "reporting": True,
                },
            )
            if response is not None and response.status_code == 200:
                st.success("DAF exported successfully")
                # result = response.json()
                # daf_result = result.get("reports", [{}])[0]
                daf_result = get_reports_payload(response)
                st.download_button(
                    label="Download DAF",
                    data=json.dumps(daf_result, indent=2),
                    file_name="exported_daf.json",
                    mime="application/json",
                )
                st.json(daf_result)
                # download_url = reports[0] if reports else "#"

                # st.markdown(
                #     f"""
                #     <a href="{download_url}" target="_blank">
                #         <button kind="secondary">
                #             Download DAF
                #         </button>
                #     </a>
                #     <br>
                #     <br>
                #     """,
                #     unsafe_allow_html=True,
                # )
            else:
                st.error("Failed to export DAF.")

    with st.expander("Delete Agent", False):
        if st.button(
            "Delete Agent", key=f"{model_key}_btn_delete_agent", disabled=(not agent_id)
        ):
            # Call the function to purge
            if result := call_api(
                endpoint="action/walker/agent_utils_action/delete_agent",
                json_data={"agent_id": agent_id},
            ):
                st.success("Agent deleted successfully")
            else:
                st.error(
                    "Failed to delete agent. Ensure that there is something to refresh or check functionality"
                )

    with st.expander("Test Interaction", expanded=False):
        selected_interaction: Dict[str, Any] = {}
        interactions: List[Dict[str, Any]] = []
        
        # Configuration section
        col1, col2 = st.columns(2)
        with col1:
            session_id = st.text_input(
                "Session ID (optional)", 
                value="", 
                key=f"{model_key}_test_interaction_session_id",
                help="Leave empty to start a new session"
            )
        with col2:
            max_interactions = st.number_input(
                "Max Interactions", 
                min_value=1,
                value=3, 
                key=f"{model_key}_test_interaction_max_interactions",
                help="Maximum number of interactions to retrieve"
            )


        # Action button
        if st.button(
            "Get Interactions", 
            key=f"{model_key}_btn_test_interaction",
            help="Fetch interaction history for this session"
        ):
            with st.spinner("Fetching interactions..."):
                try:
                    result =  call_api(
                        endpoint="action/walker/agent_utils_action/test_interactions",
                        json_data={
                            "agent_id": agent_id,
                            "session_id": session_id,
                            "max_interactions": max_interactions
                        }
                    )
                    if result and result.status_code == 200:
                        # json_result = result.json()
                        # interactions = json_result.get("reports", [{}])[0]
                        interactions = get_reports_payload(result)

                        st.session_state['last_interactions'] = interactions
                except Exception as e:
                    st.error(f"Failed to fetch interactions: {str(e)}")
                    interactions = []

        # Display results
        interactions = st.session_state.get('last_interactions', [])
        
        if not interactions:
            st.info("No interactions found. Configure and run a test interaction first.")
        else:
            # Create a dropdown with all available utterances
            selected_interaction = st.selectbox(
                "Select an utterance",
                options=interactions,
                format_func=lambda x: x["utterance"][:50] + "..." if len(x["utterance"]) > 50 else x["utterance"],
                help="Select an interaction to inspect",
                key=f"{model_key}_interaction_select"
            )
            
            if selected_interaction:
                # Create a dropdown for ModelActionResults within the selected interaction
                selected_result_index = st.selectbox(
                    "Select a Result",
                    options=range(len(selected_interaction.get("ModelActionResult", []))),
                    format_func=lambda i: f"{selected_interaction['ModelActionResult'][i].get('result', 'unknown')}",
                    help="Select a specific result to test",
                    key=f"{model_key}_result_select"
                )
                
                # Display the selected ModelActionResult
                if selected_interaction["ModelActionResult"]:
                    selected_result = selected_interaction["ModelActionResult"][selected_result_index]
    
        if selected_interaction and selected_interaction["ModelActionResult"]:
            st.write("---")
            selected_result = selected_interaction["ModelActionResult"][selected_result_index]
            
            temperature = st.slider(
                "Temperature",
                min_value=0.0,
                max_value=1.0,
                value=selected_result.get("temperature", 0.2),
                step=0.1,
                key=f"{model_key}_temperature_slider"
            )
            
            col1, col2 = st.columns(2)
            
            with col1:
                model_name = st.text_input(
                    "Model Name",
                    value=selected_result.get("model_name", ""),
                    key=f"{model_key}_model_name_input"
                )

            with col2:
                max_tokens = st.number_input(
                    "Max Tokens",
                    min_value=0,
                    value=selected_result.get("max_tokens", 0),
                    step=1,
                    key=f"{model_key}_max_tokens_input"
                )

            # Use a regular text_area but with dynamic height calculation
            prompt = selected_result.get("prompt", "")
            line_count = prompt.count('\n') + 2
            height = min(max(100, line_count * 20), 600)  # Between 100 and 500 px

            edited_prompt = st.text_area(
                "Prompt",
                value=prompt,
                height=height,
                key=f"{model_key}_prompt_editor"
            )
            
            if st.button("Test Prompt", key=f"{model_key}_save_prompt"):
                llm_result = call_api(
                    endpoint="action/walker/agent_utils_action/test_llm_call",
                    json_data={
                        "agent_id": agent_id,
                        "llm_prompt_message": edited_prompt,
                        "model_name": model_name,
                        "model_temperature": temperature,
                        "model_max_tokens": max_tokens
                    }
                )

                if llm_result and llm_result.status_code == 200:
                    # llm_result = llm_result.json()
                    # llm_result = llm_result.get("reports", [{}])[0]
                    llm_result = get_reports_payload(llm_result)

                result = llm_result.get("result", "No result found")
                if "[" in result and "]" in result or "{" in result and "}" in result:
                    st.warning("New Result:")
                    st.json(result)
                    st.info("Agent Result:")
                    st.json(selected_result.get("result", {}))
                else:
                    st.warning(f"New Result: {llm_result.get("result", "No result found")}")
                    st.info(f"Agent Result: {selected_result.get('result', 'No result found')}")

        


def classify_data(data: Union[Dict[str, Any], List[Dict[str, Any]]]) -> str:
    """
    Classifies input data into predefined categories.

    Args:
        data (Union[Dict[str, Any], List[Dict[str, Any]]]): The input data to classify.

    Returns:
        str: The category of the data. Possible values are "descriptor", "knowledge", "memory", or "unknown".
    """

    if isinstance(data, dict):
        if "actions" in data and "name" in data:
            return "descriptor"
    elif isinstance(data, list):
        for item in data:
            if isinstance(item, dict):
                if "metadata" in item and "text" in item:
                    return "knowledge"
                elif "frame" in item:
                    return "memory"
    return "unknown"
