import uuid
import pytest
from unittest.mock import AsyncMock, patch

from app.ai.llm.provider import ChatMessage
from app.ai.orchestrator.orchestrator import ChatOrchestrator
from app.ai.orchestrator.schema import OrchestrationResult
from app.chatbot.driver.intents import driver_intent_router
from app.common.enums.chat import Intent, MessageRole, Priority, UserRole
from app.chat.models import ChatMessage as ChatMessageModel


@pytest.fixture
def mock_db():
    return AsyncMock()


@pytest.fixture
def mock_redis():
    mock = AsyncMock()
    mock.get = AsyncMock(return_value=None)
    mock.set = AsyncMock(return_value=True)
    return mock


class TestDriverChatbotUnit:
    """Comprehensive test suite for the dedicated Driver Chatbot."""

    # 1. Semantic Fix: Driver saying "rider ne meri ride cancel kardi"
    def test_driver_passenger_cancelled_detection(self):
        result = driver_intent_router.detect("rider ne meri ride cancel kardi, kya mujhe cancellation fee milegi?")
        assert result.intent == Intent.CUSTOMER_CANCELLED
        assert result.requires_tool is True

    # 2. Customer not found at pickup location
    def test_driver_customer_not_found_detection(self):
        result = driver_intent_router.detect("Customer pickup spot par nahi mil raha hai, location pe koi nahi hai")
        assert result.intent == Intent.CUSTOMER_NOT_FOUND
        assert result.requires_tool is True

    # 3. Payout status inquiry ("Payment abhi tak nahi aayi")
    def test_driver_payout_status_detection(self):
        result = driver_intent_router.detect("Meri payment abhi tak nahi aayi hai, bank transfer kab hoga?")
        assert result.intent == Intent.PAYOUT
        assert result.requires_tool is True

    # 4. Daily / weekly earnings inquiry
    def test_driver_earnings_detection(self):
        result = driver_intent_router.detect("Show me my earnings for today, aaj kitni kamai hui?")
        assert result.intent == Intent.EARNINGS
        assert result.requires_tool is True

    # 5. Incentive / Target bonus
    def test_driver_incentive_detection(self):
        result = driver_intent_router.detect("What is my weekly target bonus and incentive status?")
        assert result.intent == Intent.INCENTIVE
        assert result.requires_tool is True

    # 6. Document status / verification
    def test_driver_document_status_detection(self):
        result = driver_intent_router.detect("Are my driving license and vehicle documents approved?")
        assert result.intent == Intent.DOCUMENT_STATUS
        assert result.requires_tool is True

    # 7. Vehicle document / RC update
    def test_driver_vehicle_document_detection(self):
        result = driver_intent_router.detect("I want to update my RC and add a new vehicle.")
        assert result.intent == Intent.VEHICLE_DOCUMENT
        assert result.requires_tool is True

    # 8. Cash payment dispute
    def test_driver_cash_payment_dispute_detection(self):
        result = driver_intent_router.detect("Passenger ne cash payment nahi diya aur chala gaya")
        assert result.intent == Intent.CASH_PAYMENT
        assert result.requires_tool is True

    # 9. Navigation / GPS issues
    def test_driver_navigation_detection(self):
        result = driver_intent_router.detect("App navigation is showing the wrong route and GPS is failing")
        assert result.intent == Intent.NAVIGATION

    # 10. Driver App troubleshooting
    def test_driver_app_troubleshooting_detection(self):
        result = driver_intent_router.detect("The GoRush driver app keeps freezing and crashing on trip start")
        assert result.intent == Intent.APP_TROUBLESHOOTING

    # 11. Safety Emergency (P0)
    def test_driver_safety_emergency_detection(self):
        result = driver_intent_router.detect("Accident ho gaya hai, car hit by truck, emergency help needed immediately!")
        assert result.intent == Intent.SAFETY
        assert result.urgency == Priority.P0_EMERGENCY
        assert result.requires_human is True

    # 12. Human Agent handoff (P2)
    def test_driver_human_agent_detection(self):
        result = driver_intent_router.detect("I want to speak with driver support team directly, connect to agent")
        assert result.intent == Intent.HUMAN_AGENT
        assert result.requires_tool is True

    # 13. Critical Semantic Verification: "rider ne meri ride cancel kardi" does NOT prompt driver to cancel ride
    @pytest.mark.asyncio
    async def test_driver_passenger_cancelled_orchestration(self, mock_db, mock_redis):
        """Verifies that driver reporting customer cancellation receives fee guidance and does NOT get confirmation to cancel ride."""
        orchestrator = ChatOrchestrator(mock_db, mock_redis)
        session_id = uuid.uuid4()
        user_id = uuid.uuid4()

        with patch.object(orchestrator.conversations, 'add_message', new=AsyncMock()), \
             patch.object(orchestrator.conversations, 'get_session', new=AsyncMock()), \
             patch.object(orchestrator.conversations, 'get_recent_messages', new=AsyncMock(return_value=[])), \
             patch.object(orchestrator.context, 'build_llm_messages', new=AsyncMock(return_value=[])), \
             patch.object(orchestrator.context, 'maybe_summarize', new=AsyncMock()):

            res: OrchestrationResult = await orchestrator.handle_message(
                request_id="req-d-1",
                session_id=session_id,
                user_id=user_id,
                role=UserRole.DRIVER,
                text="Rider ne meri ride cancel kardi, kya mujhe cancellation fee milegi?",
            )

            assert res.intent == Intent.CUSTOMER_CANCELLED
            assert "cancel_ride" not in res.actions
            # Must NOT ask confirmation to cancel ride ("Ride cancel karne ke liye confirmation chahiye...")
            assert "ride cancel karne ke liye confirmation" not in res.message.lower()
            assert "confirmation is required to cancel your ride" not in res.message.lower()
            # Must mention fee eligibility or policy
            assert any(w in res.message.lower() for w in ["fee", "शुल्क", "earnings", "credit", "नीति", "policy"])

    # 14. Customer not found orchestration
    @pytest.mark.asyncio
    async def test_driver_customer_not_found_orchestration(self, mock_db, mock_redis):
        orchestrator = ChatOrchestrator(mock_db, mock_redis)
        session_id = uuid.uuid4()
        user_id = uuid.uuid4()

        with patch.object(orchestrator.conversations, 'add_message', new=AsyncMock()), \
             patch.object(orchestrator.conversations, 'get_session', new=AsyncMock()), \
             patch.object(orchestrator.conversations, 'get_recent_messages', new=AsyncMock(return_value=[])), \
             patch.object(orchestrator.context, 'build_llm_messages', new=AsyncMock(return_value=[])), \
             patch.object(orchestrator.context, 'maybe_summarize', new=AsyncMock()):

            res: OrchestrationResult = await orchestrator.handle_message(
                request_id="req-d-2",
                session_id=session_id,
                user_id=user_id,
                role=UserRole.DRIVER,
                text="Customer pickup spot par nahi mil raha hai",
            )

            assert res.intent == Intent.CUSTOMER_NOT_FOUND
            assert "get_active_ride" in res.actions
            # Must explain waiting time / call / no-show guidance
            assert any(w in res.message.lower() for w in ["wait", "call", "5 minute", "5 मिनट", "no-show", "कॉल"])

    # 15. Driver chatbot never exposes customer tools
    def test_driver_tool_specs_isolation(self):
        from app.tools.registry.registry import default_tool_registry
        specs = default_tool_registry.list_specs_for_role(UserRole.DRIVER)
        names = {s["name"] for s in specs}

        assert "get_driver_earnings" in names
        assert "get_document_status" in names
        assert "get_active_ride" in names
        # Customer-only action tools must NEVER be present
        assert "cancel_ride" not in names
        assert "request_refund" not in names
        assert "start_rematch" not in names

    # 16. Driver asking to cancel ride is denied / rejected
    @pytest.mark.asyncio
    async def test_driver_cancel_ride_denied(self, mock_db, mock_redis):
        from app.tools.registry.registry import default_tool_registry
        from app.tools.router.tool_router import ToolRouter
        from app.tools.registry.tool_spec import ToolContext
        from app.common.exceptions.base import ToolDeniedError

        router = ToolRouter(default_tool_registry, mock_db, mock_redis)
        ctx = ToolContext(
            user_id=str(uuid.uuid4()),
            role=UserRole.DRIVER,
            session_id=str(uuid.uuid4()),
            request_id="req-d-perm",
        )

        with pytest.raises(ToolDeniedError):
            await router.invoke(
                ctx=ctx,
                tool_name="cancel_ride",
                arguments={"ride_id": "ride_123", "reason": "driver request"},
                user_confirmed=True,
            )
