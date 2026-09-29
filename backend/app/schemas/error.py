from typing import List, Optional

from pydantic import BaseModel, ConfigDict


class ErrorDetail(BaseModel):
    field: str
    message: str


class ErrorInfo(BaseModel):
    code: str
    message: str
    request_id: str
    details: Optional[List[ErrorDetail]] = None


class ErrorResponse(BaseModel):
    error: ErrorInfo

    model_config = ConfigDict(extra="forbid")
