"""
Driver Chatbot: Tool Registration Tests
Verifies that all driver-authorized tools are registered, schemas are valid,
and customer-only tools are strictly excluded from the registry.
"""
import pytest
from app.tools.registry.registry import build_default_registry
from app.common.exceptions.base import ToolDeniedError


DRIVER_BRD_TOOLS = [
    # READ TOOLS (6)
    "get_active_ride",
    "get_driver_eta",
    "get_ride_fare_breakdown",
    "get_ticket_status",
    "get_driver_earnings",
    "get_document_status",
    # ACTION TOOLS (3)
    "create_support_ticket",
    "create_safety_incident",
    "handoff_to_agent",
]

CUSTOMER_ONLY_TOOLS = [
    "request_refund",
    "cancel_ride",
    "start_rematch",
    "get_payment_status",
    "get_refund_status",
]

READ_TOOLS = {
    "get_active_ride", "get_driver_eta", "get_ride_fare_breakdown",
    "get_ticket_status", "get_driver_earnings", "get_document_status",
}

ACTION_TOOLS = {
    "create_support_ticket", "create_safety_incident", "handoff_to_agent",
}

IDEMPOTENCY_REQUIRED = {
    "create_support_ticket", "create_safety_incident", "handoff_to_agent",
}


@pytest.fixture(scope="module")
def registry():
    return build_default_registry()


class TestToolRegistration:

    def test_all_driver_tools_registered(self, registry):
        """All driver-authorized tools must be registered."""
        specs = {s["name"] for s in registry.list_specs_for_llm()}
        assert specs == set(DRIVER_BRD_TOOLS), (
            f"Missing: {set(DRIVER_BRD_TOOLS) - specs}\n"
            f"Extra: {specs - set(DRIVER_BRD_TOOLS)}"
        )

    def test_customer_tools_excluded(self, registry):
        """Customer-only tools must NOT be registered in driver backend."""
        specs = {s["name"] for s in registry.list_specs_for_llm()}
        for cust_tool in CUSTOMER_ONLY_TOOLS:
            assert cust_tool not in specs, f"Customer tool {cust_tool} leaked into driver backend"

    @pytest.mark.parametrize("tool_name", DRIVER_BRD_TOOLS)
    def test_tool_schema_has_required_fields(self, registry, tool_name):
        tool = registry.get(tool_name)
        assert tool.definition.name == tool_name
        assert isinstance(tool.definition.description, str) and len(tool.definition.description) > 10
        assert isinstance(tool.definition.input_schema, dict)
        assert "type" in tool.definition.input_schema

    @pytest.mark.parametrize("tool_name", READ_TOOLS)
    def test_read_tools_have_low_or_medium_risk(self, registry, tool_name):
        tool = registry.get(tool_name)
        assert tool.definition.risk_level.value in {"low", "medium"}

    @pytest.mark.parametrize("tool_name", IDEMPOTENCY_REQUIRED)
    def test_action_tools_require_idempotency_key(self, registry, tool_name):
        tool = registry.get(tool_name)
        assert tool.definition.requires_idempotency_key is True

    def test_safety_tool_never_requires_confirmation(self, registry):
        tool = registry.get("create_safety_incident")
        assert tool.definition.requires_confirmation is False

    def test_unregistered_tool_denied(self, registry):
        with pytest.raises(ToolDeniedError):
            registry.get("execute_code_arbitrary")
