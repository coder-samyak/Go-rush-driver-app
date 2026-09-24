import pytest

from app.ai.intent.detector import intent_detector
from app.ai.prompts.registry import get_prompt
from app.chat.router import DRIVER_QUICK_ACTIONS
from app.common.enums.chat import Intent, UserRole
from app.tools.registry.registry import default_tool_registry


class TestDriverRoleMatrix:
    """Verifies complete behavioral, intent, tool, and prompt isolation for Driver Chatbot."""

    # 1. Driver queries detect driver intents
    @pytest.mark.parametrize("query,expected_intent", [
        ("rider ne meri ride cancel kardi, fee milegi kya?", Intent.CUSTOMER_CANCELLED),
        ("Payment abhi tak nahi aayi, payout kab credit hoga?", Intent.PAYOUT),
        ("Show me today's earnings", Intent.EARNINGS),
        ("Customer pickup spot par nahi mil raha", Intent.CUSTOMER_NOT_FOUND),
        ("My driving license document verification is pending", Intent.DOCUMENT_STATUS),
    ])
    def test_driver_intents_recognized(self, query, expected_intent):
        res = intent_detector.detect(query)
        assert res.intent == expected_intent

    # 2. Customer-only queries in Driver Chatbot MUST NOT execute customer intents
    @pytest.mark.parametrize("customer_query", [
        "I was charged twice, I want a refund",
        "I forgot my umbrella and phone in the cab, lost item",
        "Where is my driver right now? ETA kya hai?",
        "Driver is not moving and ride is delayed",
        "Cancel my ride booking please",
    ])
    def test_customer_queries_rejected_in_driver_backend(self, customer_query):
        res = intent_detector.detect(customer_query)
        # Driver intent router must NOT classify as customer-only action intents
        assert res.intent not in {
            Intent.REFUND,
            Intent.LOST_ITEM,
            Intent.DRIVER_NOT_MOVING,
            Intent.DRIVER_LATE,
            Intent.CANCELLATION,
        }

    # 3. Driver tools must only contain driver allowed tools
    def test_driver_tool_allowlist(self):
        specs = default_tool_registry.list_specs_for_role(UserRole.DRIVER)
        tool_names = {s["name"] for s in specs}

        # Driver authorized tools must be present
        assert "get_active_ride" in tool_names
        assert "get_driver_earnings" in tool_names
        assert "get_document_status" in tool_names
        assert "create_safety_incident" in tool_names
        assert "handoff_to_agent" in tool_names

        # Customer-only tools must NOT be present
        assert "cancel_ride" not in tool_names
        assert "request_refund" not in tool_names
        assert "start_rematch" not in tool_names
        assert "get_refund_status" not in tool_names

    # 4. Quick actions contain only driver actions
    def test_driver_quick_actions(self):
        actions = [a["action"] for a in DRIVER_QUICK_ACTIONS]
        assert "current_trip" in actions
        assert "earnings" in actions
        assert "payout" in actions
        assert "customer_not_found" in actions
        assert "documents" in actions
        assert "incentives" in actions
        assert "cancel_ride" not in actions
        assert "refund" not in actions

    # 5. Driver prompt exists and renders
    def test_driver_prompt(self):
        prompt = get_prompt("driver_support_system")
        assert prompt is not None
        rendered = prompt.render("en")
        assert "driver" in rendered.lower()
