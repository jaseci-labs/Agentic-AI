import requests
import os
from dotenv import load_dotenv

# Load environment variables if your user management API needs them
load_dotenv()

# This should be the base URL of your user management service
USER_API_URL = "http://127.0.0.1:8000"
REGISTER_ENDPOINT = f"{USER_API_URL}/user/register"

# --- DEFINE YOUR ADMIN CREDENTIALS HERE ---
# You can choose any email and password you like.
ADMIN_EMAIL = "admin@test.com"
ADMIN_PASSWORD = "admin123" 
# IMPORTANT: Remember this password! You will use it to log in to the Streamlit app.

def create_admin_user():
    """Sends a request to the /user/register endpoint to create the admin user."""
    print(f"Attempting to register admin user: {ADMIN_EMAIL}")

    payload = {
        "email": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD
    }

    try:
        response = requests.post(REGISTER_ENDPOINT, json=payload)
        
        # Check if the request was successful
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Admin user successfully registered!")
            print("You can now run the Streamlit app and log in with these credentials.")
        elif response.status_code == 409: # 409 Conflict often means "user already exists"
             print("⚠️  Admin user already exists. You are ready to log in.")
        else:
            print(f"❌ Failed to register admin user. Status Code: {response.status_code}")
            print(f"Response: {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"❌ Could not connect to the user management API at {USER_API_URL}.")
        print("Please ensure your user management service is running before executing this script.")
        print(f"Error: {e}")

if __name__ == "__main__":
    create_admin_user()