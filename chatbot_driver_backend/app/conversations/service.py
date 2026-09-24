import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.chat.models import ChatMessage, ChatSession
from app.common.enums.chat import MessageRole, SessionStatus
from app.common.exceptions.base import NotFoundError


class ConversationService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_session(self, user_id: uuid.UUID, language: str = "en") -> ChatSession:
        session = ChatSession(user_id=user_id, language=language, status=SessionStatus.ACTIVE)
        self.db.add(session)
        await self.db.flush()
        return session

    async def get_session(
        self, session_id: uuid.UUID, user_id: uuid.UUID, role: object = None
    ) -> ChatSession:
        from app.users.models import User

        stmt = (
            select(ChatSession)
            .join(User, User.id == ChatSession.user_id)
            .where(ChatSession.id == session_id, ChatSession.user_id == user_id)
        )
        if role is not None:
            role_val = getattr(role, "value", str(role)).lower()
            stmt = stmt.where(User.role == role_val)

        result = await self.db.execute(stmt)
        session = result.scalar_one_or_none()
        if session is None:
            raise NotFoundError("Chat session not found")
        return session

    async def add_message(
        self,
        session_id: uuid.UUID,
        role: MessageRole,
        content: str,
        *,
        language: str | None = None,
        intent: str | None = None,
        sentiment: str | None = None,
        risk_level: str | None = None,
        metadata: dict | None = None,
    ) -> ChatMessage:
        message = ChatMessage(
            session_id=session_id,
            role=role,
            content=content,
            language=language,
            intent=intent,
            sentiment=sentiment,
            risk_level=risk_level,
            metadata_json=metadata or {},
        )
        self.db.add(message)
        await self.db.flush()
        return message

    async def get_recent_messages(self, session_id: uuid.UUID, limit: int = 50, offset: int = 0) -> list[ChatMessage]:
        result = await self.db.execute(
            select(ChatMessage)
            .where(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        return list(reversed(result.scalars().all()))
