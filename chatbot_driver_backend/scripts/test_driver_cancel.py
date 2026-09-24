import urllib.request
import json

BASE_URL = "http://127.0.0.1:8000"

# 1. Login as driver
login_req = urllib.request.Request(
    f"{BASE_URL}/v1/auth/login",
    data=json.dumps({"external_ref": "driver_demo@gorush.com", "password": "password123"}).encode(),
    headers={"Content-Type": "application/json"}
)
with urllib.request.urlopen(login_req) as resp:
    token = json.loads(resp.read().decode())["access_token"]

headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# 2. Create session
sess_req = urllib.request.Request(
    f"{BASE_URL}/v1/chat/sessions",
    data=json.dumps({"language": "en"}).encode(),
    headers=headers
)
with urllib.request.urlopen(sess_req) as resp:
    session_id = json.loads(resp.read().decode())["data"]["session_id"]

# 3. Test queries
driver_queries = [
    "rider ne meri ride cancel kardi",
    "Passenger ne ride cancel kar di.",
    "Passenger cancelled the ride.",
    "The rider cancelled my ride.",
    "Passenger ne meri ride cancel kar di, kya mujhe cancellation fee milegi?",
    "The passenger cancelled my ride. Will I get a cancellation fee?",
    "Passenger cancelled but my earnings were not updated.",
]

print("=" * 80)
print("LIVE DRIVER CANCELLATION API TEST RESULTS")
print("=" * 80)

for q in driver_queries:
    msg_req = urllib.request.Request(
        f"{BASE_URL}/v1/chat/messages",
        data=json.dumps({"session_id": session_id, "message": q}).encode(),
        headers=headers
    )
    with urllib.request.urlopen(msg_req) as resp:
        res = json.loads(resp.read().decode())
        data = res["data"]
        print(f"\nDriver Input:    \"{q}\"")
        print(f"Detected Intent: {data.get('intent')}")
        print(f"Language:        {data.get('language')}")
        print(f"Actions Taken:   {data.get('actions')}")
        print(f"Handoff Status:  {data.get('handoff')}")
        print(f"Bot Message:     {data.get('message')}")

print("\n" + "=" * 80)
