#!/usr/bin/env python3
"""
Test script for the JAC Server API
This script tests the basic functionality of the JAC server.
"""

import requests
import json
import time

BASE_URL = "http://localhost:8000"
TEST_EMAIL = "test@mail.com"
TEST_PASSWORD = "password"

def test_authentication():
    """Test user authentication"""
    print("Testing authentication...")
    
    # Try to login
    response = requests.post(f"{BASE_URL}/user/login", 
                           json={"email": TEST_EMAIL, "password": TEST_PASSWORD})
    
    if response.status_code != 200:
        print("Login failed, trying to register...")
        # Register user
        response = requests.post(f"{BASE_URL}/user/register",
                               json={"email": TEST_EMAIL, "password": TEST_PASSWORD})
        if response.status_code != 201:
            print(f"Registration failed: {response.text}")
            return None
            
        # Login again
        response = requests.post(f"{BASE_URL}/user/login",
                               json={"email": TEST_EMAIL, "password": TEST_PASSWORD})
    
    if response.status_code == 200:
        token = response.json()["token"]
        print(f"Authentication successful. Token: {token[:20]}...")
        return token
    else:
        print(f"Authentication failed: {response.text}")
        return None

def test_session_creation(token):
    """Test session creation"""
    print("\nTesting session creation...")
    
    session_id = f"test_session_{int(time.time())}"
    response = requests.post(f"{BASE_URL}/walker/new_session",
                           json={"session_id": session_id},
                           headers={"Authorization": f"Bearer {token}"})
    
    if response.status_code == 200:
        data = response.json()
        print(f"Session created successfully: {data['reports'][0]['session_id']}")
        return data['reports'][0]['session_id']
    else:
        print(f"Session creation failed: {response.text}")
        return None

def test_chat_interaction(token, session_id):
    """Test chat interaction"""
    print("\nTesting chat interaction...")
    
    test_message = "What is Jac programming language?"
    response = requests.post(f"{BASE_URL}/walker/interact",
                           json={"message": test_message, "session_id": session_id},
                           headers={"Authorization": f"Bearer {token}"})
    
    if response.status_code == 200:
        data = response.json()
        ai_response = data['reports'][0]['response']
        print(f"User: {test_message}")
        print(f"AI: {ai_response[:200]}...")
        return True
    else:
        print(f"Chat interaction failed: {response.text}")
        return False

def test_session_retrieval(token, session_id):
    """Test session retrieval"""
    print("\nTesting session retrieval...")
    
    response = requests.post(f"{BASE_URL}/walker/get_session",
                           json={"session_id": session_id},
                           headers={"Authorization": f"Bearer {token}"})
    
    if response.status_code == 200:
        data = response.json()
        chat_history = data['reports'][0]['chat_history']
        print(f"Session retrieved successfully. Chat history length: {len(chat_history)}")
        return True
    else:
        print(f"Session retrieval failed: {response.text}")
        return False

def main():
    """Run all tests"""
    print("JAC Server API Test Suite")
    print("=" * 40)
    
    # Test authentication
    token = test_authentication()
    if not token:
        print("Authentication failed. Cannot proceed with other tests.")
        return
    
    # Test session creation
    session_id = test_session_creation(token)
    if not session_id:
        print("Session creation failed. Cannot proceed with other tests.")
        return
    
    # Test chat interaction
    if not test_chat_interaction(token, session_id):
        print("Chat interaction failed.")
        return
    
    # Test session retrieval
    if not test_session_retrieval(token, session_id):
        print("Session retrieval failed.")
        return
    
    print("\n" + "=" * 40)
    print("All tests passed successfully! 🎉")
    print("The JAC server is working correctly.")

if __name__ == "__main__":
    main()
