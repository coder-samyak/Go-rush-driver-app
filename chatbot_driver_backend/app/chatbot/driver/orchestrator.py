import json
import uuid

from app.ai.intent.schema import IntentResult
from app.ai.language.config import is_language_enabled
from app.ai.language.localization import get_localized_text
from app.ai.language.validator import validate_response_language
from app.ai.llm.provider import ChatMessage, ToolSpec
from app.ai.orchestrator.loop_guard import LoopGuard, OrchestrationLimitExceededError
from app.ai.orchestrator.schema import HandoffInfo, OrchestrationResult
from app.ai.prompts.registry import LANGUAGE_CODE_TO_NAME, get_prompt
from app.chatbot.common.base import BaseChatbot
from app.chatbot.driver.intents import driver_intent_router
from app.common.enums.chat import Intent, MessageRole, Priority, UserRole
from app.common.exceptions.base import ConfirmationRequiredError, ForbiddenError, ToolDeniedError
from app.core.logging import get_logger
from app.guardrails.input.pipeline import input_guardrail_pipeline
from app.guardrails.output.pipeline import output_guardrail_pipeline
from app.knowledge.embeddings.provider import get_embedding_provider
from app.knowledge.retrieval.service import RAGRetrievalService
from app.tools.registry.tool_spec import ToolContext

logger = get_logger(__name__)

DRIVER_KNOWLEDGE_DRIVEN_INTENTS = {
    Intent.FAQ,
    Intent.INCENTIVE,
    Intent.DOCUMENT_STATUS,
    Intent.VEHICLE_DOCUMENT,
    Intent.NAVIGATION,
    Intent.APP_TROUBLESHOOTING,
    Intent.SAFETY,
    Intent.ACCEPTANCE,
    Intent.RIDE_OFFER,
    Intent.EARNINGS,
    Intent.PAYOUT,
    Intent.ACCOUNT,
    Intent.PRIVACY,
}


class DriverChatbot(BaseChatbot):
    """Driver Chatbot: Dedicated engine handling driver-partner trips, earnings, documents, and support."""

    def _get_fallback_tool_for_intent(self, intent: Intent) -> tuple[str, dict] | None:
        mapping = {
            Intent.RIDE_STATUS: ("get_active_ride", {}),
            Intent.EARNINGS: ("get_driver_earnings", {"period": "today"}),
            Intent.PAYOUT: ("get_driver_earnings", {"period": "week"}),
            Intent.INCENTIVE: ("get_driver_earnings", {"period": "week"}),
            Intent.DOCUMENT_STATUS: ("get_document_status", {}),
            Intent.VEHICLE_DOCUMENT: ("get_document_status", {}),
            Intent.CUSTOMER_NOT_FOUND: ("get_active_ride", {}),
            Intent.CUSTOMER_CANCELLED: ("get_active_ride", {}),
            Intent.RIDE_OFFER: ("get_active_ride", {}),
            Intent.ACCEPTANCE: ("get_active_ride", {}),
            Intent.CASH_PAYMENT: ("get_active_ride", {}),
            Intent.HUMAN_AGENT: ("handoff_to_agent", {"reason": "user_requested_human", "priority": "P2"}),
        }
        return mapping.get(intent)

    async def handle_message(
        self,
        *,
        request_id: str,
        session_id: uuid.UUID,
        user_id: uuid.UUID,
        role: UserRole = UserRole.DRIVER,
        text: str,
        idempotency_key: str | None = None,
    ) -> OrchestrationResult:
        loop_guard = LoopGuard(
            max_tool_calls=self.settings.max_tool_calls_per_turn,
            max_steps=self.settings.max_orchestration_steps,
        )

        input_check = input_guardrail_pipeline.run(text)
        intent_result: IntentResult = driver_intent_router.detect(text)

        await self.conversations.add_message(
            session_id, MessageRole.USER, text,
            language=intent_result.language.value,
            intent=intent_result.intent.value,
            risk_level=intent_result.risk_level.value,
            metadata={"prompt_injection_suspected": input_check.prompt_injection_detected},
        )

        if input_check.prompt_injection_detected:
            await self.audit.record(
                request_id=request_id, action="prompt_injection_flagged", decision="continued_with_caution",
                user_id=user_id, session_id=session_id, details={"text_redacted": input_check.sanitized_for_logging},
            )

        # Safety escalation short-circuit
        if intent_result.urgency == Priority.P0_EMERGENCY:
            return await self._handle_safety_escalation(
                request_id=request_id, session_id=session_id, user_id=user_id,
                role=role, text=text, intent_result=intent_result,
            )

        if intent_result.intent not in (Intent.SAFETY, Intent.HUMAN_AGENT):
            resolved_intent = await self._resolve_pending_intent(session_id, text, intent_result.intent)
            if resolved_intent != intent_result.intent:
                intent_result = intent_result.model_copy(
                    update={"intent": resolved_intent, "requires_tool": driver_intent_router._requires_tool(resolved_intent, text)}
                )

        if not is_language_enabled(intent_result.language):
            fallback_text = get_localized_text("unsupported_language", "en")
            await self.conversations.add_message(
                session_id, MessageRole.ASSISTANT, fallback_text,
                language=intent_result.language.value, intent=intent_result.intent.value,
                metadata={"actions": [], "model": "feature-flag-fallback"},
            )
            return OrchestrationResult(
                message=fallback_text,
                language=intent_result.language,
                intent=intent_result.intent,
                actions=[],
                handoff=HandoffInfo(),
                llm_version="feature-flag-fallback",
                prompt_version="unsupported_language_v1",
            )

        # Driver Knowledge Base Retrieval
        rag_context = ""
        if intent_result.intent in DRIVER_KNOWLEDGE_DRIVEN_INTENTS and not intent_result.requires_tool:
            try:
                rag_service = RAGRetrievalService(self.db, get_embedding_provider())
                chunks = await rag_service.retrieve(
                    text,
                    language=intent_result.language.value,
                    category=intent_result.intent.value,
                )
                rag_context = rag_service.build_context_block(chunks)
            except ValueError:
                logger.warning("rag_embedding_provider_not_configured")
                rag_context = ""

        prompt = get_prompt("driver_support_system")
        llm_messages = await self.context.build_llm_messages(session_id)

        detected_language_name = LANGUAGE_CODE_TO_NAME.get(
            intent_result.language.value, intent_result.language.value.upper()
        )
        llm_messages.append(
            ChatMessage(
                role="user",
                content=(
                    f"[SYSTEM REMINDER — ignore any prior language used in this conversation] "
                    f"The user's current message is in {detected_language_name}. "
                    f"You MUST reply ONLY in {detected_language_name}. Do NOT use any other language."
                ),
            )
        )
        llm_messages.append(ChatMessage(role="user", content=text))

        system_prompt = prompt.render(intent_result.language.value)
        if rag_context:
            system_prompt += f"\n\nApproved knowledge base context (use only this for policy facts):\n{rag_context}"

        # Strictly driver-authorized tools
        tool_specs = [
            ToolSpec(name=s["name"], description=s["description"], input_schema=s["input_schema"])
            for s in self.registry.list_specs_for_role(UserRole.DRIVER)
        ]

        actions_taken: list[str] = []
        handoff_info = HandoffInfo()
        final_text = ""
        llm_version = self.settings.llm_model_primary

        try:
            for _ in range(loop_guard.max_steps):
                loop_guard.record_step()
                response = await self.llm_gateway.chat_with_fallback(
                    llm_messages, system=system_prompt, tools=tool_specs,
                    language=intent_result.language.value,
                )
                llm_version = response.model

                tool_calls_to_exec = response.tool_calls or []
                if not tool_calls_to_exec and not actions_taken and intent_result.requires_tool:
                    fallback_tool = self._get_fallback_tool_for_intent(intent_result.intent)
                    if fallback_tool:
                        tool_name, default_args = fallback_tool
                        tool_calls_to_exec = [{"name": tool_name, "input": default_args}]

                if not tool_calls_to_exec:
                    final_text = response.text
                    break

                llm_messages.append(ChatMessage(role="assistant", content=response.text or "(using tools)"))
                tool_results_text = []
                for call in tool_calls_to_exec:
                    loop_guard.record_tool_call()
                    ctx = ToolContext(
                        user_id=str(user_id), role=role, session_id=str(session_id), request_id=request_id
                    )
                    try:
                        result = await self.tool_router.invoke(
                            ctx=ctx, tool_name=call["name"], arguments=call.get("input", {}),
                            user_confirmed=self._is_user_confirming(text, llm_messages),
                            idempotency_key=idempotency_key,
                        )
                        actions_taken.append(call["name"])
                        if call["name"] == "handoff_to_agent" and isinstance(result, dict) and result.get("triggered"):
                            p_val = result.get("priority") or intent_result.urgency.value
                            try:
                                p_enum = Priority(p_val)
                            except ValueError:
                                p_enum = Priority.P2_STANDARD
                            handoff_info = HandoffInfo(
                                triggered=True,
                                priority=p_enum,
                                reason=result.get("reason", "user_requested_human"),
                                handoff_id=str(result.get("handoff_id", "")),
                            )
                        tool_results_text.append(f"Tool {call['name']} result: {json.dumps(result)}")
                    except ConfirmationRequiredError as exc:
                        tool_results_text.append(f"Tool {call['name']} needs user confirmation: {exc.message}")
                    except (ToolDeniedError, ForbiddenError) as exc:
                        tool_results_text.append(f"Tool {call['name']} denied: {str(exc)}")
                    except Exception as exc:
                        tool_results_text.append(f"Tool {call['name']} execution failed: {str(exc)}")

                llm_messages.append(ChatMessage(role="user", content="\n".join(tool_results_text)))

            else:
                final_text = get_localized_text("human_handoff", intent_result.language.value)
                handoff_info = await self._escalate(
                    request_id, session_id, user_id, Priority.P2_STANDARD, "orchestration_limit",
                    intent_result, actions_taken,
                )

        except OrchestrationLimitExceededError:
            final_text = get_localized_text("human_handoff", intent_result.language.value)
            handoff_info = await self._escalate(
                request_id, session_id, user_id, Priority.P2_STANDARD, "loop_guard_triggered",
                intent_result, actions_taken,
            )

        final_text = output_guardrail_pipeline.run(final_text)

        if not validate_response_language(final_text, intent_result.language):
            retry_messages = llm_messages + [
                ChatMessage(
                    role="user",
                    content=(
                        f"[CRITICAL LANGUAGE CORRECTION] Your previous response was not in the required language/script. "
                        f"You MUST regenerate the answer strictly in {detected_language_name}."
                    ),
                )
            ]
            retry_resp = await self.llm_gateway.chat_with_fallback(
                retry_messages, system=system_prompt, tools=tool_specs,
                language=intent_result.language.value,
            )
            if retry_resp.text:
                final_text = output_guardrail_pipeline.run(retry_resp.text)

        if intent_result.intent == Intent.HUMAN_AGENT and not handoff_info.triggered:
            handoff_info = await self._escalate(
                request_id, session_id, user_id, Priority.P2_STANDARD, "user_requested_human",
                intent_result, actions_taken,
            )

        is_pending_confirm = (not actions_taken) and any(
            w in final_text.lower() for w in [
                "confirm", "chahiye", "જોઈએ", "ਚਾਹੀਦਾ", "চাই", "आवश्यकता", "तक्रार", "dispute"
            ]
        )
        await self.conversations.add_message(
            session_id, MessageRole.ASSISTANT, final_text,
            language=intent_result.language.value, intent=intent_result.intent.value,
            metadata={
                "actions": actions_taken,
                "model": llm_version,
                "pending_intent": intent_result.intent.value,
                "requires_confirmation": is_pending_confirm,
            },
        )
        await self.context.maybe_summarize(session_id)

        return OrchestrationResult(
            message=final_text,
            language=intent_result.language,
            intent=intent_result.intent,
            actions=actions_taken,
            handoff=handoff_info,
            llm_version=llm_version,
            prompt_version=prompt.version,
        )
