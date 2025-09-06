#!/usr/bin/env python3
"""
Simple script to check database state and debug information

Run this to see:
1. Current database connection details
2. All collections in the database  
3. User collections and their contents
4. Environment variables
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def check_database_state():
    """Call the debug database walker to show current state"""
    url = f"{BASE_URL}/walker/debug_database"
    headers = {"Content-Type": "application/json"}
    
    print(f"🔍 Calling debug database endpoint: {url}")
    
    try:
        response = requests.post(url, headers=headers, timeout=30)
        print(f"🔍 Response status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"🔍 Response: {json.dumps(data, indent=2)}")
            except json.JSONDecodeError:
                print(f"🔍 Response text: {response.text}")
        else:
            print(f"❌ Request failed with status {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        print(f"Make sure your JAC server is running on {BASE_URL}")

if __name__ == "__main__":
    print("🔍 Checking database state...")
    print("=" * 50)
    check_database_state()
    print("=" * 50)
    print("🔍 Check server logs for detailed debug information")
