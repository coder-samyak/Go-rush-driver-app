# GoRush Driver AI Chatbot Backend

Dedicated, standalone AI Chatbot backend exclusively designed for the **GoRush Driver Flutter App** (driver-partners).

---

## Key Features

1. **Dedicated Port**: Runs on **Port 8001** by default (`http://localhost:8001`).
2. **Strict Driver Role Enforcement**:
   - Every chat route validates that the JWT belongs to a driver (`role == "driver"`).
   - Customer or unauthorized tokens immediately receive `403 Forbidden`.
3. **Driver-Specific Intents**:
   - `earnings`: Daily, weekly, monthly earnings reports (`get_driver_earnings`).
   - `payout`: Weekly payout status, bank transfer timelines.
   - `incentive`: Target bonuses, peak hour bonuses.
   - `document_status`: Driver license, RC, insurance verification status.
   - `customer_not_found`: Passenger missing at pickup location guidance.
   - `customer_cancelled`: Passenger cancellation guidance and cancellation fee policy (never asks confirmation to cancel a ride).
   - `vehicle_document`: Vehicle change, RC updates.
   - `cash_payment`: Cash payment dispute resolution.
   - `safety`: Road accidents, threats, vehicle damage emergency SOS (P0 escalation).
4. **Tool Isolation**:
   - Customer tools (`cancel_ride`, `request_refund`, `start_rematch`, `get_payment_status`, `get_refund_status`) are **completely removed** and cannot be called.
   - Registered driver tools: `get_active_ride`, `get_driver_eta`, `get_ride_fare_breakdown`, `get_ticket_status`, `get_driver_earnings`, `get_document_status`, `create_support_ticket`, `create_safety_incident`, `handoff_to_agent`.
5. **Multilingual Intelligence**: Full support for English, Hindi, Hinglish, Bengali, Gujarati, Punjabi, Marathi, Tamil, Telugu, Kannada, Malayalam, Odia, Assamese, and Urdu.

---

## Quick Start

### 1. Installation

```bash
cd chatbot_driver_backend
python -m venv venv
# Windows
.\venv\Scripts\activate
# Linux/macOS
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Environment Configuration

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Ensure `PORT=8001` is set.

### 3. Run the Server

```bash
python run.py
```

The server will start on `http://localhost:8001`.

- **Swagger Documentation**: `http://localhost:8001/docs`
- **Health Check**: `http://localhost:8001/health`

### 4. Running Tests

```bash
python -m pytest tests/
```

All 339 tests pass with 100% success rate.
