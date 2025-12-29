#!/usr/bin/env python3
"""
Streamlit app to visualize evaluation results from JSON log files.

Usage:
    streamlit run view_results.py -- <path_to_json_file>
    
Example:
    streamlit run view_results.py -- eval_results_20251201_124649.json
"""

import json
import argparse
import sys
from pathlib import Path
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go


def load_json_file(file_path: str) -> dict:
    """Load and parse JSON file."""
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        st.error(f"❌ File not found: {file_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        st.error(f"❌ Invalid JSON file: {e}")
        sys.exit(1)


def display_metadata(metadata: dict):
    """Display test run metadata."""
    st.header("📊 Test Run Metadata")
    
    col1, col2, col3, col4 = st.columns(4)
    
    config = metadata.get("configuration", {})
    config_name = metadata.get("configuration_name", "N/A")
    model = config.get("llm", {}).get("model_name", "N/A")
    
    with col1:
        st.metric("Timestamp", metadata.get("timestamp", "N/A"))
    with col2:
        st.metric("Total Tests", metadata.get("total_tests", 0))
    with col3:
        st.metric("Configuration", config_name)
    with col4:
        st.metric("Model", model)
    
    # Display configuration details
    with st.expander("🔧 Configuration Details", expanded=False):
        st.json(config)
    
    # Display notes if available
    notes = metadata.get("notes", "")
    if notes and notes != "No notes provided":
        st.info(f"📝 **Notes:** {notes}")


def display_summary(summary: dict, results: list):
    """Display summary statistics."""
    st.header("📈 Summary Statistics")
    
    # Calculate additional stats
    successful_tests = sum(1 for r in results if r.get("success", False))
    failed_tests = len(results) - successful_tests
    avg_latency = sum(r.get("latency_ms", 0) for r in results) / len(results) if results else 0
    avg_response_length = sum(r.get("response_length", 0) for r in results) / len(results) if results else 0
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric("✅ Successful", successful_tests, f"{(successful_tests/len(results)*100):.1f}%" if results else "0%")
        st.metric("❌ Failed", failed_tests, f"{(failed_tests/len(results)*100):.1f}%" if results else "0%")
    
    with col2:
        st.metric("⚡ Min Latency", f"{summary.get('min_latency_ms', 0):.2f} ms")
        st.metric("🐢 Max Latency", f"{summary.get('max_latency_ms', 0):.2f} ms")
    
    with col3:
        st.metric("📊 Avg Latency", f"{avg_latency:.2f} ms")
        st.metric("📝 Avg Response Length", f"{avg_response_length:.0f} chars")


def display_latency_chart(results: list):
    """Display latency distribution chart."""
    st.header("⏱️ Latency Distribution")
    
    df = pd.DataFrame([
        {
            "Test ID": r.get("test_id", ""),
            "Latency (ms)": r.get("latency_ms", 0),
            "Success": "✅ Success" if r.get("success", False) else "❌ Failed"
        }
        for r in results
    ])
    
    fig = px.bar(
        df,
        x="Test ID",
        y="Latency (ms)",
        color="Success",
        color_discrete_map={"✅ Success": "#00cc66", "❌ Failed": "#ff4444"},
        title="Latency by Test",
        height=400
    )
    
    st.plotly_chart(fig, use_container_width=True)


def display_response_length_chart(results: list):
    """Display response length distribution chart."""
    st.header("📏 Response Length Distribution")
    
    df = pd.DataFrame([
        {
            "Test ID": r.get("test_id", ""),
            "Response Length": r.get("response_length", 0),
            "Success": "✅ Success" if r.get("success", False) else "❌ Failed"
        }
        for r in results
    ])
    
    fig = px.bar(
        df,
        x="Test ID",
        y="Response Length",
        color="Success",
        color_discrete_map={"✅ Success": "#00cc66", "❌ Failed": "#ff4444"},
        title="Response Length by Test",
        height=400
    )
    
    st.plotly_chart(fig, use_container_width=True)


def display_results_table(results: list):
    """Display detailed results table."""
    st.header("📋 Detailed Results")
    
    # Create DataFrame
    df = pd.DataFrame([
        {
            "Test ID": r.get("test_id", ""),
            "Query": r.get("query", "")[:50] + "..." if len(r.get("query", "")) > 50 else r.get("query", ""),
            "Success": "✅" if r.get("success", False) else "❌",
            "Latency (ms)": f"{r.get('latency_ms', 0):.2f}",
            "Response Length": r.get("response_length", 0),
            "Error": r.get("error", "") or "-"
        }
        for r in results
    ])
    
    st.dataframe(df, use_container_width=True, height=400)


def display_individual_results(results: list):
    """Display individual test results with expandable sections."""
    st.header("🔍 Individual Test Details")
    
    for idx, result in enumerate(results):
        test_id = result.get("test_id", f"Test {idx+1}")
        query = result.get("query", "")
        response = result.get("response", "")
        success = result.get("success", False)
        latency = result.get("latency_ms", 0)
        error = result.get("error", "")
        
        # Color-code based on success
        status_icon = "✅" if success else "❌"
        status_color = "green" if success else "red"
        
        with st.expander(f"{status_icon} {test_id} - {query[:60]}{'...' if len(query) > 60 else ''}"):
            col1, col2 = st.columns([3, 1])
            
            with col1:
                st.markdown(f"**Query:**")
                st.text(query)
            
            with col2:
                st.metric("Latency", f"{latency:.2f} ms")
                st.markdown(f"**Status:** :{status_color}[{status_icon}]")
            
            if success:
                st.markdown("**Response:**")
                st.markdown(response)
            else:
                st.markdown("**Error:**")
                st.error(error)
            
            st.divider()


def main():
    """Main Streamlit application."""
    st.set_page_config(
        page_title="Evaluation Results Viewer",
        page_icon="📊",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    st.title("🎯 Evaluation Results Viewer")
    
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="View evaluation results from JSON log files")
    parser.add_argument("json_file", nargs="?", help="Path to JSON log file")
    
    # Handle Streamlit's additional arguments
    try:
        args = parser.parse_args()
    except SystemExit:
        # If no args provided, show file uploader
        st.warning("⚠️ No file specified. Please upload a JSON file or run with: `streamlit run view_results.py -- <json_file>`")
        
        uploaded_file = st.file_uploader("Choose a JSON file", type=['json'])
        
        if uploaded_file is not None:
            data = json.load(uploaded_file)
        else:
            st.info("👆 Upload a JSON file to get started")
            return
    else:
        if not args.json_file:
            st.warning("⚠️ No file specified. Please upload a JSON file.")
            uploaded_file = st.file_uploader("Choose a JSON file", type=['json'])
            
            if uploaded_file is not None:
                data = json.load(uploaded_file)
            else:
                st.info("👆 Upload a JSON file to get started")
                return
        else:
            # Load the JSON file
            data = load_json_file(args.json_file)
            st.success(f"✅ Loaded: {args.json_file}")
    
    # Extract data
    metadata = data.get("test_run_metadata", {})
    results = data.get("results", [])
    summary = data.get("summary", {})
    
    # Sidebar filters
    st.sidebar.header("🔧 Filters")
    
    show_successful = st.sidebar.checkbox("Show Successful Tests", value=True)
    show_failed = st.sidebar.checkbox("Show Failed Tests", value=True)
    
    # Filter results
    filtered_results = [
        r for r in results
        if (show_successful and r.get("success", False)) or (show_failed and not r.get("success", False))
    ]
    
    # Display sections
    display_metadata(metadata)
    st.divider()
    
    display_summary(summary, filtered_results)
    st.divider()
    
    # Charts in columns
    col1, col2 = st.columns(2)
    
    with col1:
        display_latency_chart(filtered_results)
    
    with col2:
        display_response_length_chart(filtered_results)
    
    st.divider()
    
    display_results_table(filtered_results)
    st.divider()
    
    display_individual_results(filtered_results)
    
    # Footer
    st.divider()
    st.caption(f"📁 Displaying {len(filtered_results)} of {len(results)} test results")


if __name__ == "__main__":
    main()
