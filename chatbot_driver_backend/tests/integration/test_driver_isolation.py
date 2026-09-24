import uuid
import pytest
from httpx import ASGITransport, AsyncClient

from app.auth.security import create_access_token, hash_password
from app.chat.models import ChatSession
from app.common.enums.chat import UserRole
from app.database.session import AsyncSessionLocal, Base, engine
from app.main import app
from app.users.models import User


@pytest.mark.asyncio
async def test_driver_backend_isolation_and_role_enforcement():
    """Verifies that driver backend enforces driver role and driver-only features."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    customer_id = uuid.uuid4()
    driver_id = uuid.uuid4()
    driver_session_id = uuid.uuid4()

    async with AsyncSessionLocal() as db:
        cust_user = User(
            id=customer_id,
            external_ref=f"cust_{customer_id}@gorush.com",
            role=UserRole.CUSTOMER.value,
            hashed_password=hash_password("password123"),
            preferred_language="en",
            is_active=True,
        )
        drv_user = User(
            id=driver_id,
            external_ref=f"drv_{driver_id}@gorush.com",
            role=UserRole.DRIVER.value,
            hashed_password=hash_password("password123"),
            preferred_language="en",
            is_active=True,
        )
        db.add(cust_user)
        db.add(drv_user)
        await db.commit()

        drv_sess = ChatSession(
            id=driver_session_id,
            user_id=driver_id,
            language="en",
            status="active",
        )
        db.add(drv_sess)
        await db.commit()

    cust_token = create_access_token(subject=str(customer_id), role="customer")
    drv_token = create_access_token(subject=str(driver_id), role="driver")

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Customer token MUST receive 403 Forbidden on driver chat endpoint
        resp_forbidden = await client.get(
            "/v1/chat/quick-actions",
            headers={"Authorization": f"Bearer {cust_token}"},
        )
        assert resp_forbidden.status_code == 403, f"Expected 403 for customer, got {resp_forbidden.status_code}"

        # 2. Driver token succeeds on quick-actions and receives ONLY driver actions
        resp_qa = await client.get(
            "/v1/chat/quick-actions",
            headers={"Authorization": f"Bearer {drv_token}"},
        )
        assert resp_qa.status_code == 200
        qa_data = resp_qa.json()["data"]
        actions = qa_data["actions"]
        assert "current_trip" in actions
        assert "earnings" in actions
        assert "payout" in actions
        assert "customer_not_found" in actions
        assert "documents" in actions
        # Ensure customer actions are completely absent
        assert "refund" not in actions
        assert "cancel_ride" not in actions

        # 3. Dedicated /v1/driver/chat endpoint works for driver
        resp_drv_qa = await client.get(
            "/v1/driver/chat/quick-actions",
            headers={"Authorization": f"Bearer {drv_token}"},
        )
        assert resp_drv_qa.status_code == 200
        assert "earnings" in resp_drv_qa.json()["data"]["actions"]

        # 4. Customer endpoint does NOT exist in driver backend (404)
        resp_cust = await client.get(
            "/v1/customer/chat/quick-actions",
            headers={"Authorization": f"Bearer {cust_token}"},
        )
        assert resp_cust.status_code == 404
