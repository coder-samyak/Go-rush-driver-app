import pytest

from app.common.enums.chat import UserRole
from app.common.exceptions.base import ConfirmationRequiredError, ForbiddenError, ToolDeniedError
from app.tools.registry.tool_spec import ToolContext
from app.tools.registry.registry import build_default_registry


@pytest.fixture
def ctx_customer():
    return ToolContext(user_id="11111111-1111-1111-1111-111111111111", role=UserRole.CUSTOMER,
                        session_id="22222222-2222-2222-2222-222222222222", request_id="req-1")


def test_unregistered_tool_is_denied():
    registry = build_default_registry()
    with pytest.raises(ToolDeniedError):
        registry.get("drop_all_tables")


@pytest.mark.asyncio
async def test_customer_tools_not_in_driver_registry():
    registry = build_default_registry()
    for cust_tool in ["cancel_ride", "request_refund", "start_rematch"]:
        with pytest.raises(ToolDeniedError):
            registry.get(cust_tool)


@pytest.mark.asyncio
async def test_ownership_check_rejects_foreign_ride_id(ctx_customer):
    registry = build_default_registry()
    tool = registry.get("get_driver_eta")
    with pytest.raises(ForbiddenError):
        await tool.authorize_ownership(ctx_customer, {"ride_id": "someone_elses_ride"})


def test_safety_tool_never_requires_confirmation():
    registry = build_default_registry()
    tool = registry.get("create_safety_incident")
    assert tool.definition.requires_confirmation is False
