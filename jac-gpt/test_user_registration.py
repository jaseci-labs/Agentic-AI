#!/usr/bin/env python3
"""
Test script to debug user registration process

This script will:
1. Call the debug database walker to show current database state
2. Attempt to register a test user
3. Call the debug database walker again to see changes
4. Try to login with the test user
5. Call get_user_profile to see if user is found

Run this script after starting your JAC server to debug user registration issues.
"""

import requests
import json
import time
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"  # Change if your server runs on different port
TEST_EMAIL = f"test_user_{int(time.time())}@example.com"
TEST_PASSWORD = "testpass123"
TEST_NAME = "Test User"

def make_request(endpoint, method="POST", data=None):
    """Make HTTP request and return response with debug info"""
    url = f"{BASE_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}
    
    print(f"\n🔍 [TEST] Making {method} request to: {url}")
    if data:
        print(f"🔍 [TEST] Request data: {json.dumps(data, indent=2)}")
    
    try:
        if method == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=30)
        else:
            response = requests.get(url, headers=headers, timeout=30)
        
        print(f"🔍 [TEST] Response status: {response.status_code}")
        
        try:
            response_data = response.json()
            print(f"🔍 [TEST] Response data: {json.dumps(response_data, indent=2)}")
            return response_data
        except json.JSONDecodeError:
            print(f"🔍 [TEST] Response text: {response.text}")
            return {"error": "Invalid JSON response", "text": response.text}
    
    except requests.exceptions.RequestException as e:
        print(f"❌ [TEST] Request failed: {e}")
        return {"error": str(e)}

def main():
    print(f"🔍 [TEST] Starting user registration debug test")
    print(f"🔍 [TEST] Test email: {TEST_EMAIL}")
    print(f"🔍 [TEST] Server URL: {BASE_URL}")
    print(f"🔍 [TEST] Timestamp: {datetime.now()}")
    
    # Step 1: Check initial database state
    print(f"\n{'='*60}")
    print(f"STEP 1: Checking initial database state")
    print(f"{'='*60}")
    make_request("/walker/debug_database")
    
    # Step 2: Register test user
    print(f"\n{'='*60}")
    print(f"STEP 2: Registering test user")
    print(f"{'='*60}")
    
    register_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD,
        "name": TEST_NAME
    }
    
    register_result = make_request("/user/register", data=register_data)
    
    # Step 3: Check database state after registration
    print(f"\n{'='*60}")
    print(f"STEP 3: Checking database state after registration")
    print(f"{'='*60}")
    make_request("/walker/debug_database")
    
    # Step 4: Try to login
    print(f"\n{'='*60}")
    print(f"STEP 4: Attempting login with test user")
    print(f"{'='*60}")
    
    login_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }
    
    login_result = make_request("/user/login", data=login_data)
    
    # Step 5: Try to get user profile
    print(f"\n{'='*60}")
    print(f"STEP 5: Getting user profile")
    print(f"{'='*60}")
    
    profile_data = {
        "email": TEST_EMAIL
    }
    
    profile_result = make_request("/walker/get_user_profile", data=profile_data)
    
    # Step 6: Final database state check
    print(f"\n{'='*60}")
    print(f"STEP 6: Final database state check")
    print(f"{'='*60}")
    make_request("/walker/debug_database")
    
    # Summary
    print(f"\n{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    
    print(f"📧 Test email: {TEST_EMAIL}")
    
    if register_result and not register_result.get("error"):
        print(f"✅ Registration: SUCCESS")
    else:
        print(f"❌ Registration: FAILED")
    
    if login_result and not login_result.get("error") and login_result.get("message"):
        print(f"✅ Login: SUCCESS")
    else:
        print(f"❌ Login: FAILED")
    
    if profile_result and profile_result.get("reports") and profile_result["reports"][0].get("user"):
        print(f"✅ User Profile: FOUND")
    else:
        print(f"❌ User Profile: NOT FOUND")
    
    print(f"\n🔍 [TEST] Check server logs for detailed debug information")
    print(f"🔍 [TEST] Look for lines with [DEBUG] prefix")

if __name__ == "__main__":
    main()
