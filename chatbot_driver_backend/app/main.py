from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from app.admin.router import router as admin_router
from app.auth.router import router as auth_router
from app.chat.gateway import router as chat_ws_router
from app.chat.router import router as chat_router
from app.chat.tools_router import router as chat_tools_router
from app.chatbot.driver.router import router as driver_chat_router
from app.common.middleware.error_handler import register_exception_handlers
from app.common.middleware.request_id import RequestIdMiddleware
from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger
from app.health.router import router as health_router

from app.database.session import Base, engine
import app.users.models  # noqa
import app.chat.models  # noqa
import app.audit.models  # noqa
import app.handoff.models  # noqa
import app.knowledge.models  # noqa

configure_logging()
logger = get_logger(__name__)
settings = get_settings()

app = FastAPI(
    title=settings.app_title,
    version=settings.api_version,
    description="Dedicated Driver Chatbot Backend for GoRush Driver-Partners.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.app_env == "development" else [],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(RequestIdMiddleware)

register_exception_handlers(app)

app.include_router(health_router)
app.include_router(auth_router)
app.include_router(driver_chat_router)
app.include_router(chat_router)
app.include_router(chat_tools_router)
app.include_router(chat_ws_router)
app.include_router(admin_router)


@app.get("/")
async def root():
    return {
        "app": "GoRush Driver AI Chatbot Backend",
        "docs": "/docs",
        "health": "/healthz",
        "status": "online",
    }


@app.on_event("startup")
async def on_startup():
    logger.info("app_startup", env=settings.app_env, version=settings.api_version)
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("db_init_success")

        # Automatically seed demo driver users
        from app.database.session import AsyncSessionLocal
        from app.users.models import User
        from app.auth.security import hash_password
        from app.common.enums.chat import UserRole
        from sqlalchemy import select

        async with AsyncSessionLocal() as session:
            for ref, pwd, role in [
                ("user123", "user@123", UserRole.DRIVER.value),
                ("driver_demo@gorush.com", "password123", UserRole.DRIVER.value),
            ]:
                existing = (await session.execute(select(User).where(User.external_ref == ref))).scalar_one_or_none()
                if existing is None:
                    session.add(User(
                        external_ref=ref,
                        role=role,
                        hashed_password=hash_password(pwd),
                        preferred_language="en",
                        is_active=True,
                    ))
                else:
                    existing.hashed_password = hash_password(pwd)
                    existing.role = role
                    existing.is_active = True
            await session.commit()
        logger.info("db_seed_success")
    except Exception as exc:
        logger.warning("db_init_warning", error=str(exc))
