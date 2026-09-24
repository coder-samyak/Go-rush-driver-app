from typing import Any
import json
import re
import uuid

from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.intent.schema import IntentResult
from app.ai.language.config import is_language_enabled
from app.ai.language.localization import get_localized_text
from app.ai.language.validator import validate_response_language
from app.ai.llm.gateway import LLMGateway
from app.ai.llm.provider import ChatMessage, ToolSpec
from app.ai.orchestrator.loop_guard import LoopGuard, OrchestrationLimitExceededError
from app.ai.orchestrator.schema import HandoffInfo, OrchestrationResult
from app.ai.prompts.registry import LANGUAGE_CODE_TO_NAME, get_prompt
from app.audit.service import AuditService
from app.common.enums.chat import Intent, MessageRole, Priority, UserRole
from app.common.exceptions.base import ConfirmationRequiredError, ForbiddenError, ToolDeniedError
from app.conversations.context_service import ContextService
from app.conversations.service import ConversationService
from app.core.config import get_settings
from app.core.logging import get_logger
from app.guardrails.input.pipeline import input_guardrail_pipeline
from app.guardrails.output.pipeline import output_guardrail_pipeline
from app.handoff.service import HandoffService
from app.knowledge.embeddings.provider import get_embedding_provider
from app.knowledge.retrieval.service import RAGRetrievalService
from app.tools.registry.registry import ToolRegistry, default_tool_registry
from app.tools.registry.tool_spec import ToolContext
from app.tools.router.tool_router import ToolRouter

logger = get_logger(__name__)


class BaseChatbot:
    """Base class providing shared infrastructure for role-specific GoRush chatbots."""

    def __init__(
        self,
        db: AsyncSession,
        redis: Redis,
        *,
        registry: ToolRegistry = default_tool_registry,
        conversations: ConversationService | None = None,
        context: ContextService | None = None,
        handoffs: HandoffService | None = None,
        audit: AuditService | None = None,
        tool_router: ToolRouter | None = None,
        llm_gateway: LLMGateway | None = None,
    ):
        self.db = db
        self.redis = redis
        self.settings = get_settings()
        self.registry = registry
        self.conversations = conversations or ConversationService(db)
        self.context = context or ContextService(db, llm=LLMGateway().primary)
        self.handoffs = handoffs or HandoffService(db, conversations=self.conversations)
        self.audit = audit or AuditService(db)
        self.tool_router = tool_router or ToolRouter(registry, db, redis)
        self.llm_gateway = llm_gateway or LLMGateway()

    async def _handle_safety_escalation(
        self, *, request_id: str, session_id: uuid.UUID, user_id: uuid.UUID, role: UserRole, text: str, intent_result: IntentResult
    ) -> OrchestrationResult:
        ctx = ToolContext(user_id=str(user_id), role=role, session_id=str(session_id), request_id=request_id)
        result = await self.tool_router.invoke(
            ctx=ctx, tool_name="create_safety_incident", arguments={"details": text}, user_confirmed=True,
        )
        handoff_info = await self._escalate(
            request_id, session_id, user_id, Priority.P0_EMERGENCY, "safety_incident",
            intent_result, ["create_safety_incident"],
        )
        reply = get_localized_text(
            "safety_escalation", intent_result.language.value,
            incident_id=result.get("incident_id", "pending"),
        )
        await self.conversations.add_message(
            session_id, MessageRole.ASSISTANT, reply, language=intent_result.language.value,
            intent=Intent.SAFETY.value, metadata={"actions": ["create_safety_incident"]},
        )
        return OrchestrationResult(
            message=reply, language=intent_result.language, intent=Intent.SAFETY,
            actions=["create_safety_incident"], handoff=handoff_info,
            llm_version="deterministic-safety-flow", prompt_version="safety_system_v1",
        )

    async def _escalate(
        self, request_id: str, session_id: uuid.UUID, user_id: uuid.UUID, priority: Priority, reason: str, intent_result: IntentResult, actions_taken: list[str]
    ) -> HandoffInfo:
        session = await self.conversations.get_session(session_id, user_id)
        handoff = await self.handoffs.escalate(
            session=session, user_id=user_id, priority=priority, reason=reason,
            intent=intent_result.intent.value, language=intent_result.language.value,
            tool_calls_summary=actions_taken,
        )
        await self.audit.record(
            request_id=request_id, action="handoff_triggered", decision="allowed",
            user_id=user_id, session_id=session_id, details={"reason": reason, "priority": priority.value},
        )
        return HandoffInfo(triggered=True, priority=priority, reason=reason, handoff_id=str(handoff.id))

    async def _save_session_state(self, session_id: uuid.UUID, state: dict[str, Any]) -> None:
        key = f"session_state:{session_id}"
        try:
            await self.redis.set(key, json.dumps(state), ex=3600)
        except Exception as exc:
            logger.warning("failed_to_save_session_state_redis", error=str(exc))

    async def _get_session_state(self, session_id: uuid.UUID) -> dict[str, Any] | None:
        key = f"session_state:{session_id}"
        try:
            cached = await self.redis.get(key)
            if cached:
                if isinstance(cached, bytes):
                    cached = cached.decode("utf-8")
                return json.loads(cached)
        except Exception as exc:
            logger.warning("failed_to_get_session_state_redis", error=str(exc))

        recent_messages = await self.conversations.get_recent_messages(session_id, limit=5)
        for msg in reversed(recent_messages):
            if str(msg.role).lower() in ("assistant", "messagerole.assistant") and msg.metadata_json:
                refund_state = msg.metadata_json.get("refund_state")
                if refund_state:
                    return refund_state
        return None

    @staticmethod
    def _is_confirmation_text(text: str) -> bool:
        from app.chatbot.common.intents import ACTIVE_SAFETY_PATTERN
        if ACTIVE_SAFETY_PATTERN.search(text):
            return False

        normalized = text.strip().lower()
        clean = re.sub(r"[^\w\s\u0900-\u097F\u0A80-\u0AFF\u0980-\u09FF\u0A00-\u0A7F]", " ", normalized)
        clean = " ".join(clean.split())

        exact_affirmatives = {
            "yes", "confirm", "ok", "okay", "sure", "proceed", "do it", "yes please", "go ahead",
            "yes please submit it", "yes submit it", "please submit it", "yes kar do", "please kar do",
            "haan", "ha", "haa", "bilkul", "kar do", "karo", "start kar do", "shuru kar do",
            "haan kar do", "ha kar do", "haan start kar do", "haan shuru", "bilkul kar do",
            "kar dijiye", "kijiye", "haan ji", "ha ji",
            "हाँ", "हौ", "होय", "बिलकुल", "शुरू कर दो", "कर दो", "करो", "हाँ शुरू कर दो", "हाँ कर दो",
            "हाँ, कर दीजिए", "हाँ कर दीजिए", "कर दीजिए", "हाँ जी",
            "હા", "શરૂ કરો", "કરી દો", "હા શરૂ કરો", "હા કરો",
            "হ্যাঁ", "শুরু করুন", "করুন", "হ্যাঁ शुरू করুন", "হ্যাঁ করুন",
            "ਹਾਂ", "ਸ਼ੁਰੂ ਕਰੋ", "ਕਰੋ", "ਹਾਂਜੀ", "ਹਾਂ ਕਰੋ",
            "करा", "सुरू करा"
        }
        if clean in exact_affirmatives or normalized in exact_affirmatives:
            return True

        words = set(clean.split())
        single_word_keywords = {
            "yes", "confirm", "ok", "okay", "sure", "proceed", "start",
            "haan", "ha", "haa", "bilkul", "karo", "shuru",
            "हाँ", "हौ", "होय", "बिलकुल", "शुरू", "करो",
            "હા", "શરૂ", "કરી", "হ্যাঁ", "করুন", "ਹਾਂ", "करा"
        }
        if words.intersection(single_word_keywords):
            return True

        multi_word_phrases = [
            "do it", "yes please", "go ahead", "kar do", "start kar do", "shuru kar do",
            "haan kar do", "ha kar do", "haan start kar do", "haan shuru", "bilkul kar do",
            "kar dijiye", "kijiye", "haan ji", "ha ji",
            "शुरू कर दो", "कर दो", "हाँ शुरू कर दो", "हाँ कर दो",
            "हाँ, कर दीजिए", "हाँ कर दीजिए", "कर दीजिए", "हाँ जी",
            "શરૂ કરો", "કરી દો", "હા શરૂ કરો", "હા કરો",
            "শুরু করুন", "করুন", "হ্যাঁ शुरू করুন", "হ্যাঁ করুন",
            "ਸ਼ੁਰੂ ਕਰੋ", "ਹਾਂਜੀ", "ਹਾਂ ਕਰੋ",
            "करा", "सुरू करा"
        ]
        return any(p in clean for p in multi_word_phrases)

    @classmethod
    def _is_user_confirming(cls, text: str, history: list[ChatMessage] | None = None) -> bool:
        from app.chatbot.common.intents import ACTIVE_SAFETY_PATTERN
        if ACTIVE_SAFETY_PATTERN.search(text):
            return False

        if cls._is_confirmation_text(text):
            return True
        normalized = text.strip().lower()
        has_prior_confirmation_prompt = False
        if history:
            has_prior_confirmation_prompt = any(
                m.role == "assistant" and any(
                    w in (m.content or "").lower() for w in [
                        "confirm", "chahiye", "જોઈએ", "ਚਾਹੀਦਾ", "চাই", "आवश्यकता", "गरज", "तक्रार", "पुष्टि", "निশ্চিতকরণ"
                    ]
                )
                for m in history
            )
        words = set(re.findall(r"\b[a-zA-Z\u0900-\u097F\u0A80-\u0AFF\u0980-\u09FF\u0A00-\u0A7F]+\b", normalized))
        confirm_tokens = {"yes", "confirm", "haan", "ha", "ok", "okay", "हाँ", "होय", "હા", "হ্যাঁ", "ਹਾਂ"}
        if has_prior_confirmation_prompt and (words.intersection(confirm_tokens) or any(p in normalized for p in ["kar do", "karo", "कर दो", "करो"])):
            return True
        return False

    async def _resolve_pending_intent(
        self, session_id: uuid.UUID, current_text: str, detected_intent: Intent
    ) -> Intent:
        if detected_intent in (Intent.SAFETY, Intent.HUMAN_AGENT):
            return detected_intent

        if not self._is_confirmation_text(current_text):
            return detected_intent

        recent_messages = await self.conversations.get_recent_messages(session_id, limit=5)
        if not recent_messages:
            return detected_intent

        last_assistant_msg = next((m for m in reversed(recent_messages) if str(m.role).lower() in ("assistant", "messagerole.assistant")), None)
        if not last_assistant_msg:
            return detected_intent

        meta = last_assistant_msg.metadata_json or {}
        requires_confirm = meta.get("requires_confirmation") or any(
            w in (last_assistant_msg.content or "").lower() for w in [
                "confirm", "chahiye", "જોઈએ", "ਚਾਹੀਦਾ", "চাই", "आवश्यकता", "तक्रार", "dispute", "cancel", "refund"
            ]
        )

        if not requires_confirm:
            return detected_intent

        pending_intent_str = meta.get("pending_intent") or last_assistant_msg.intent
        if not pending_intent_str or pending_intent_str == Intent.UNKNOWN.value:
            last_user_msg = next((m for m in reversed(recent_messages) if str(m.role).lower() in ("user", "messagerole.user")), None)
            if last_user_msg:
                pending_intent_str = last_user_msg.intent

        if pending_intent_str and pending_intent_str != Intent.UNKNOWN.value:
            try:
                return Intent(pending_intent_str)
            except ValueError:
                pass

        return detected_intent
