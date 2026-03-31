import requests
import sys
import time

BASE_URL = "http://localhost:8000/api"

def test_admin_registration():
    print("Testing ADMIN registration restriction...")
    payload = {
        "email": "newadmin@test.com",
        "password": "password123",
        "role": "Admin",
        "full_name": "New Admin"
    }
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=payload)
        if response.status_code == 403:
            print("✅ Correctly blocked new admin registration (403 Forbidden)")
        else:
            print(f"❌ Failed to block admin registration: Status {response.status_code}, {response.text}")
    except requests.exceptions.ConnectionError:
        print("❌ Server is not running. Please start the backend server first.")
        sys.exit(1)

def test_parent_registration():
    print("\nTesting PARENT registration (should still work)...")
    payload = {
        "email": "newparent_" + str(int(time.time())) + "@test.com",
        "password": "password123",
        "role": "Parent",
        "full_name": "New Parent",
        "agree_to_terms": True
    }
    response = requests.post(f"{BASE_URL}/auth/register", json=payload)
    if response.status_code == 201:
        print("✅ Parent registration still works (201 Created)")
    else:
        print(f"❌ Parent registration failed: Status {response.status_code}, {response.text}")

if __name__ == "__main__":
    test_admin_registration()
    test_parent_registration()
