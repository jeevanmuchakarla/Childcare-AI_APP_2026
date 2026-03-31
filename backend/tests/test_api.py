import requests
import json

BASE_URL = "http://localhost:8000/api"

def test_health():
    print("Testing /health endpoint...")
    try:
        response = requests.get(f"http://localhost:8000/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_recommendations():
    print("\nTesting /ai/recommendations endpoint...")
    try:
        params = {
            "provider_type": "Preschool",
            "budget": "Standard",
            "max_distance": 10.0
        }
        response = requests.get(f"{BASE_URL}/ai/recommendations", params=params)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            results = response.json()
            print(f"Found {len(results)} recommendations.")
            if results:
                print(f"First result: {results[0]['name']}")
        else:
            print(f"Error Response: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    health_ok = test_health()
    if health_ok:
        test_recommendations()
    else:
        print("Health check failed. Is the server running?")
