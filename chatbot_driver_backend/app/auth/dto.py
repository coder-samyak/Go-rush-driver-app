from pydantic import BaseModel, Field

from app.common.enums.chat import UserRole


class LoginRequest(BaseModel):
    external_ref: str = Field(..., description="GoRush user identifier")
    password: str


class RegisterRequest(BaseModel):
    external_ref: str = Field(..., description="GoRush user identifier (e.g. username or email)")
    password: str = Field(..., description="User password", min_length=4)
    preferred_language: str = Field(default="en", description="Preferred language (en, hi, etc.)")


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: UserRole
