import requests
import json
import time

BASE_URL = "http://localhost:8000/api"

def test_approval_workflow():
    test_email = f"test_user_{int(time.time())}@example.com"
    test_password = "password123"
    
    # 1. Register a new provider (Preschool)
    print(f"--- Step 1: Registering user {test_email} ---")
    register_payload = {
        "email": test_email,
        "password": test_password,
        "role": "Preschool",
        "center_name": "Test Preschool Center",
        "full_name": "John Doe",
        "phone": "555-0199"
    }
    
    reg_response = requests.post(f"{BASE_URL}/auth/register", json=register_payload)
    print(f"Register Status: {reg_response.status_code}")
    if reg_response.status_code != 201:
        print(f"Error: {reg_response.text}")
        return
    
    user_id = reg_response.json()["user"]["id"]
    print(f"User ID: {user_id}")

    # 2. Attempt to login (should be pending)
    print("\n--- Step 2: Attempting login before approval ---")
    login_payload = {"email": test_email, "password": test_password}
    login_response = requests.post(f"{BASE_URL}/auth/login", json=login_payload)
    print(f"Login Status: {login_response.status_code}")
    login_data = login_response.json()
    print(f"Login Response: {login_data.get('message')}")
    
    if login_data.get("status") == "pending_approval":
        print("SUCCESS: Login blocked by pending approval.")
    else:
        print("FAILURE: Login was NOT blocked by pending approval.")
        return

    # 3. Approve the user via the admin endpoint
    # Note: We need to bypass or mock admin authentication for this test script if it's protected.
    # Looking at admin_routes.py, it doesn't seem to have a mandatory security Depends yet for simplicity.
    print(f"\n--- Step 3: Approving user {user_id} ---")
    approve_response = requests.post(f"{BASE_URL}/admin/users/{user_id}/approve")
    print(f"Approve Status: {approve_response.status_code}")
    if approve_response.status_code != 200:
        print(f"Error: {approve_response.text}")
        return
    print("User approved.")

    # 4. Attempt to login again (should succeed)
    print("\n--- Step 4: Attempting login after approval ---")
    login_response_after = requests.post(f"{BASE_URL}/auth/login", json=login_payload)
    print(f"Login Status After: {login_response_after.status_code}")
    if login_response_after.status_code == 200:
        print("SUCCESS: Login successful after approval.")
    else:
        print(f"FAILURE: Login failed after approval: {login_response_after.text}")

if __name__ == "__main__":
    # Ensure server is running
    try:
        requests.get(f"{BASE_URL}/admin/stats")
    except:
        print("Error: Backend server is not running on http://localhost:8000")
        exit(1)
        
    test_approval_workflow()
