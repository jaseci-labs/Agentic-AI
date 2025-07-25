#!/usr/bin/env python3
"""
Script to find .jac files with syntax errors by running 'jac run' on each file.
"""

import os
import subprocess
import glob
import sys
from pathlib import Path
from typing import List, Tuple, Dict
import argparse


def find_jac_files(directory: str, recursive: bool = True) -> List[str]:
    """
    Find all .jac files in the given directory.
    
    Args:
        directory: Directory to search in
        recursive: Whether to search recursively in subdirectories
    
    Returns:
        List of .jac file paths
    """
    if recursive:
        pattern = os.path.join(directory, "**", "*.jac")
        return glob.glob(pattern, recursive=True)
    else:
        pattern = os.path.join(directory, "*.jac")
        return glob.glob(pattern)


def check_jac_syntax(file_path: str) -> Tuple[bool, str]:
    """
    Check if a .jac file has syntax errors by running 'jac run' on it.
    
    Args:
        file_path: Path to the .jac file
    
    Returns:
        Tuple of (has_syntax_error, error_message)
    """
    try:
        # Run jac run command and capture output
        result = subprocess.run(
            ['jac', 'run', file_path],
            capture_output=True,
            text=True,
            timeout=30  # 30 second timeout to prevent hanging
        )
        
        # Check stderr for syntax errors regardless of return code
        # (jac run sometimes returns 0 even with syntax errors)
        error_output = result.stderr.strip()
        
        if "Syntax Error" in error_output:
            # Extract the first syntax error line for brevity
            error_lines = error_output.split('\n')
            syntax_error_line = next(
                (line for line in error_lines if "Syntax Error" in line), 
                error_output
            )
            return True, syntax_error_line
        elif error_output and result.returncode != 0:
            # Non-syntax error (runtime error, etc.)
            return False, f"Runtime/Other error: {error_output[:200]}..."
        elif error_output:
            # There's error output but return code is 0 - could be warnings
            return False, f"Warning/Info: {error_output[:200]}..."
        
        return False, "No syntax errors"
        
    except subprocess.TimeoutExpired:
        return True, "Timeout - file may have infinite loop or hang"
    except FileNotFoundError:
        return True, "jac command not found - please install jaclang"
    except Exception as e:
        return True, f"Error running jac: {str(e)}"


def main():
    parser = argparse.ArgumentParser(
        description="Find .jac files with syntax errors"
    )
    parser.add_argument(
        "directory", 
        nargs="?", 
        default="aider/coders", 
        help="Directory to search for .jac files (default: current directory)"
    )
    parser.add_argument(
        "--no-recursive", 
        action="store_true", 
        help="Don't search recursively in subdirectories"
    )
    parser.add_argument(
        "--verbose", "-v", 
        action="store_true", 
        help="Show all files checked, not just errors"
    )
    parser.add_argument(
        "--output", "-o", 
        help="Output results to file instead of stdout"
    )
    parser.add_argument(
        "--list-only", 
        action="store_true", 
        help="Output only the list of files with syntax errors (one per line)"
    )
    
    args = parser.parse_args()
    
    # Find all .jac files
    directory = os.path.abspath(args.directory)
    if not os.path.exists(directory):
        print(f"Error: Directory '{directory}' does not exist", file=sys.stderr)
        sys.exit(1)
    
    print(f"Searching for .jac files in: {directory}")
    recursive = not args.no_recursive
    jac_files = find_jac_files(directory, recursive)
    
    if not jac_files:
        if not args.list_only:
            print("No .jac files found")
        return
    
    if not args.list_only:
        print(f"Found {len(jac_files)} .jac files")
        print("-" * 60)
    
    # Results storage
    syntax_errors: List[Tuple[str, str]] = []
    runtime_errors: List[Tuple[str, str]] = []
    valid_files: List[str] = []
    
    # Check each file
    for i, file_path in enumerate(jac_files, 1):
        rel_path = os.path.relpath(file_path, directory)
        
        if args.verbose and not args.list_only:
            print(f"[{i}/{len(jac_files)}] Checking: {rel_path}")
        
        has_error, error_msg = check_jac_syntax(file_path)
        
        if has_error:
            if "Syntax Error" in error_msg:
                syntax_errors.append((rel_path, error_msg))
                if args.list_only:
                    print(rel_path)
                elif not args.verbose:
                    print(f"❌ SYNTAX ERROR: {rel_path}")
                    print(f"   {error_msg}")
            else:
                runtime_errors.append((rel_path, error_msg))
                if not args.verbose and not args.list_only:
                    print(f"⚠️  OTHER ERROR: {rel_path}")
                    print(f"   {error_msg}")
        else:
            valid_files.append(rel_path)
            if args.verbose and not args.list_only:
                print(f"✅ OK: {rel_path}")
    
    # If list-only mode, don't show summary
    if args.list_only:
        return
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Total files checked: {len(jac_files)}")
    print(f"Files with syntax errors: {len(syntax_errors)}")
    print(f"Files with other errors: {len(runtime_errors)}")
    print(f"Valid files: {len(valid_files)}")
    
    # Detailed results
    if syntax_errors:
        print(f"\n📋 FILES WITH SYNTAX ERRORS ({len(syntax_errors)}):")
        print("-" * 40)
        for file_path, error in syntax_errors:
            print(f"• {file_path}")
            print(f"  {error}")
    
    if runtime_errors:
        print(f"\n⚠️  FILES WITH OTHER ERRORS ({len(runtime_errors)}):")
        print("-" * 40)
        for file_path, error in runtime_errors:
            print(f"• {file_path}")
            print(f"  {error}")
    
    # Save to file if requested
    if args.output:
        with open(args.output, 'w') as f:
            f.write("JAC SYNTAX ERROR REPORT\n")
            f.write("=" * 60 + "\n\n")
            f.write(f"Total files checked: {len(jac_files)}\n")
            f.write(f"Files with syntax errors: {len(syntax_errors)}\n")
            f.write(f"Files with other errors: {len(runtime_errors)}\n")
            f.write(f"Valid files: {len(valid_files)}\n\n")
            
            if syntax_errors:
                f.write("FILES WITH SYNTAX ERRORS:\n")
                f.write("-" * 40 + "\n")
                for file_path, error in syntax_errors:
                    f.write(f"{file_path}\n{error}\n\n")
            
            if runtime_errors:
                f.write("FILES WITH OTHER ERRORS:\n")
                f.write("-" * 40 + "\n")
                for file_path, error in runtime_errors:
                    f.write(f"{file_path}\n{error}\n\n")
        
        print(f"\nResults saved to: {args.output}")
    
    # Exit with error code if syntax errors found
    if syntax_errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
