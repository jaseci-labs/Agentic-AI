#!/usr/bin/env python3
"""
Script to convert all Python files in aider/coders directory to Jac language files.
Uses the `jac py2jac` command to perform the conversion.
"""

import os
import subprocess
import sys
from pathlib import Path


def activate_venv_and_run_command(command, cwd=None):
    """
    Run a command with the virtual environment activated.
    """
    
    try:
        # Run the command using bash
        result = subprocess.run(
            ["bash", "-c", command],
            capture_output=True,
            text=True,
            cwd=cwd
        )
        
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)


def convert_py_to_jac(py_file_path, output_dir=None):
    """
    Convert a Python file to Jac using the jac py2jac command.
    
    Args:
        py_file_path (Path): Path to the Python file
        output_dir (Path): Directory to save the .jac file (optional)
    
    Returns:
        bool: True if conversion was successful, False otherwise
    """
    print(f"Converting {py_file_path.name}...")
    
    # Run jac py2jac command
    command = f"jac py2jac {py_file_path}"
    success, stdout, stderr = activate_venv_and_run_command(command)
    
    if not success:
        print(f"  ❌ Failed to convert {py_file_path.name}")
        if stderr:
            print(f"  Error: {stderr}")
        return False
    
    if not stdout.strip():
        print(f"  ⚠️  No output from jac py2jac for {py_file_path.name}")
        return False
    
    # Determine output file path
    if output_dir:
        output_file = output_dir / f"{py_file_path.stem}.jac"
    else:
        output_file = py_file_path.parent / f"{py_file_path.stem}.jac"
    
    # Write the Jac code to file
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(stdout)
        print(f"  ✅ Converted to {output_file}")
        # Remove the original Python file after successful conversion
        try:
            os.remove(py_file_path)
            print(f"  🗑️  Removed original file: {py_file_path}")
        except Exception as e:
            print(f"  ⚠️  Could not remove {py_file_path}: {e}")
        return True
    except Exception as e:
        print(f"  ❌ Failed to write output file {output_file}: {e}")
        return False


def main():
    """
    Main function to convert all Python files in aider/coders to Jac.
    """
    # Get the script directory and project root
    script_dir = Path(__file__).parent
    project_root = script_dir
    coders_dir = project_root / "aider" / "coders"
    
    # Check if coders directory exists
    if not coders_dir.exists():
        print(f"Error: Directory {coders_dir} does not exist!")
        sys.exit(1)
    
    print(f"Converting Python files in {coders_dir} to Jac...")
    print("=" * 60)
    
    # Create output directory for Jac files
    jac_output_dir = coders_dir  #/ "jac_converted"
    jac_output_dir.mkdir(exist_ok=True)
    print(f"Jac files will be saved to: {jac_output_dir}")
    print()
    
    # Find all Python files in the coders directory
    py_files = list(coders_dir.glob("*.py"))
    
    if not py_files:
        print("No Python files found in the coders directory.")
        return
    
    print(f"Found {len(py_files)} Python files to convert:")
    for py_file in py_files:
        print(f"  - {py_file.name}")
    print()
    
    # Convert each Python file
    successful_conversions = 0
    failed_conversions = 0
    
    for py_file in py_files:
        # Skip __init__.py and other special files if desired
        if py_file.name in ["__init__.py"]:
            print(f"Skipping {py_file.name}")
            continue
            
        success = convert_py_to_jac(py_file, jac_output_dir)
        if success:
            successful_conversions += 1
        else:
            failed_conversions += 1
        print()  # Add spacing between conversions
    
    # Summary
    print("=" * 60)
    print("Conversion Summary:")
    print(f"  ✅ Successful: {successful_conversions}")
    print(f"  ❌ Failed: {failed_conversions}")
    print(f"  📁 Output directory: {jac_output_dir}")
    
    if failed_conversions > 0:
        print("\nSome conversions failed. Please check the error messages above.")
        sys.exit(1)
    else:
        print("\n🎉 All conversions completed successfully!")


if __name__ == "__main__":
    main()
