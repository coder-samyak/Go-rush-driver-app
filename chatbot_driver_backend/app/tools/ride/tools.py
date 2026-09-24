from typing import Any

from app.common.enums.chat import RiskLevel, UserRole
from app.common.exceptions.base import ForbiddenError
from app.tools.registry.tool_spec import BaseTool, ToolContext, ToolDefinition
from app.tools.ride.gorush_clients import GoRushRideClient


class GetActiveRideTool(BaseTool):
    definition = ToolDefinition(
        name="get_active_ride",
        description="Fetch the caller's current active or most recent ride.",
        input_schema={"type": "object", "properties": {}},
        required_role=[UserRole.CUSTOMER, UserRole.DRIVER, UserRole.SUPPORT_AGENT],
        risk_level=RiskLevel.LOW,
    )

    def __init__(self, client: GoRushRideClient):
        self.client = client

    async def authorize_ownership(self, ctx: ToolContext, arguments: dict[str, Any]) -> None:
        return  # no externally supplied ride id to validate

    async def execute(self, ctx: ToolContext, arguments: dict[str, Any]) -> dict[str, Any]:
        ride = await self.client.get_active_ride(ctx.user_id)
        return {"ride": ride}


class GetDriverEtaTool(BaseTool):
    definition = ToolDefinition(
        name="get_driver_eta",
        description="Get the verified ETA for the driver on a given ride.",
        input_schema={
            "type": "object",
            "properties": {"ride_id": {"type": "string"}},
        },
        required_role=[UserRole.CUSTOMER, UserRole.DRIVER, UserRole.SUPPORT_AGENT],
        risk_level=RiskLevel.LOW,
    )

    def __init__(self, client: GoRushRideClient):
        self.client = client

    async def authorize_ownership(self, ctx: ToolContext, arguments: dict[str, Any]) -> None:
        ride_id = arguments.get("ride_id")
        ride = await self.client.get_active_ride(ctx.user_id)
        if ride_id and (not ride or ride.get("ride_id") != ride_id):
            raise ForbiddenError("Ride does not belong to the requesting user")

    async def execute(self, ctx: ToolContext, arguments: dict[str, Any]) -> dict[str, Any]:
        ride_id = arguments.get("ride_id")
        if not ride_id:
            ride = await self.client.get_active_ride(ctx.user_id)
            if not ride:
                from app.common.exceptions.base import RideNotFoundError
                raise RideNotFoundError("No active ride found")
            ride_id = ride["ride_id"]
        return await self.client.get_driver_eta(ride_id)


class GetFareBreakdownTool(BaseTool):
    definition = ToolDefinition(
        name="get_ride_fare_breakdown",
        description="Get the itemized fare breakdown for a ride.",
        input_schema={
            "type": "object",
            "properties": {"ride_id": {"type": "string"}},
        },
        required_role=[UserRole.CUSTOMER, UserRole.DRIVER, UserRole.SUPPORT_AGENT],
        risk_level=RiskLevel.LOW,
    )

    def __init__(self, client: GoRushRideClient):
        self.client = client

    async def authorize_ownership(self, ctx: ToolContext, arguments: dict[str, Any]) -> None:
        ride_id = arguments.get("ride_id")
        ride = await self.client.get_active_ride(ctx.user_id)
        if ride_id and (not ride or ride.get("ride_id") != ride_id):
            raise ForbiddenError("Ride does not belong to the requesting user")

    async def execute(self, ctx: ToolContext, arguments: dict[str, Any]) -> dict[str, Any]:
        ride_id = arguments.get("ride_id")
        if not ride_id:
            ride = await self.client.get_active_ride(ctx.user_id)
            if not ride:
                from app.common.exceptions.base import RideNotFoundError
                raise RideNotFoundError("No active ride found")
            ride_id = ride["ride_id"]
        return await self.client.get_fare_breakdown(ride_id)

