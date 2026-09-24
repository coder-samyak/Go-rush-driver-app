import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.auth.security import hash_password
from app.common.enums.chat import UserRole
from app.database.session import AsyncSessionLocal
from app.users.models import User
from sqlalchemy import select


async def seed():
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.external_ref == "simran77@gmail.com"))
        user = result.scalar_one_or_none()
        if user:
            user.hashed_password = hash_password("user@123")
            user.is_active = True
            print(f"Updated password for existing user: {user.external_ref}")
        else:
            user = User(
                external_ref="simran77@gmail.com",
                role=UserRole.CUSTOMER,
                hashed_password=hash_password("user@123"),
                preferred_language="en",
                is_active=True,
            )
            session.add(user)
            print(f"Created user: {user.external_ref}")
        await session.commit()


if __name__ == "__main__":
    asyncio.run(seed())