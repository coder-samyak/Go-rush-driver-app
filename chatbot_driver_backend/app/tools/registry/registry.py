from app.common.enums.chat import UserRole
from app.common.exceptions.base import ToolDeniedError
from app.tools.registry.tool_spec import BaseTool


class ToolRegistry:
    """The single allowlist of tools the LLM is permitted to invoke.
    The LLM never gets raw DB/API access -- only what's registered here."""

    def __init__(self):
        self._tools: dict[str, BaseTool] = {}

    def register(self, tool: BaseTool) -> None:
        self._tools[tool.definition.name] = tool

    def get(self, name: str) -> BaseTool:
        tool = self._tools.get(name)
        if tool is None:
            raise ToolDeniedError(f"Tool '{name}' is not registered / not allowlisted")
        return tool

    def list_specs_for_llm(self) -> list[dict]:
        """Tool specs exposed to the LLM as callable functions."""
        return [
            {
                "name": t.definition.name,
                "description": t.definition.description,
                "input_schema": t.definition.input_schema,
            }
            for t in self._tools.values()
        ]

    def list_specs_for_role(self, role: "UserRole") -> list[dict]:
        """Tool specs exposed to the LLM filtered by authorized user role."""
        return [
            {
                "name": t.definition.name,
                "description": t.definition.description,
                "input_schema": t.definition.input_schema,
            }
            for t in self._tools.values()
            if role in t.definition.required_role
        ]



def build_default_registry() -> ToolRegistry:
    from app.tools.driver.tools import (
        GetDocumentStatusTool,
        GetDriverEarningsTool,
    )
    from app.tools.ride.gorush_clients import (
        MockGoRushDriverClient,
        MockGoRushHandoffClient,
        MockGoRushRideClient,
        MockGoRushSafetyClient,
        MockGoRushSupportClient,
    )
    from app.tools.ride.tools import (
        GetActiveRideTool,
        GetDriverEtaTool,
        GetFareBreakdownTool,
    )
    from app.tools.safety.tools import CreateSafetyIncidentTool
    from app.tools.support.tools import CreateSupportTicketTool, GetTicketStatusTool, HandoffToAgentTool

    ride_client = MockGoRushRideClient()
    support_client = MockGoRushSupportClient()
    safety_client = MockGoRushSafetyClient()
    driver_client = MockGoRushDriverClient()
    handoff_client = MockGoRushHandoffClient()

    registry = ToolRegistry()
    # --- DRIVER READ TOOLS (6) ---
    registry.register(GetActiveRideTool(ride_client))                         # 1
    registry.register(GetDriverEtaTool(ride_client))                          # 2
    registry.register(GetFareBreakdownTool(ride_client))                      # 3
    registry.register(GetTicketStatusTool(support_client))                    # 4
    registry.register(GetDriverEarningsTool(driver_client))                   # 5
    registry.register(GetDocumentStatusTool(driver_client))                   # 6
    # --- DRIVER ACTION TOOLS (3) ---
    registry.register(CreateSupportTicketTool(support_client))                # 7
    registry.register(CreateSafetyIncidentTool(safety_client))                # 8
    registry.register(HandoffToAgentTool(handoff_client))                     # 9
    return registry


default_tool_registry = build_default_registry()

