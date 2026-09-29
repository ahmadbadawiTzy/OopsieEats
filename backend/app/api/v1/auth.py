from fastapi import APIRouter, Depends, Request, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, UserResponse
from app.services.auth_service import authenticate_user, register_user, revoke_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Registrasi pengguna baru",
)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    user = register_user(db, req)
    return user


@router.post(
    "/login",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Login dan dapatkan token akses",
)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    _, token, expires_in = authenticate_user(db, req)
    return TokenResponse(access_token=token, token_type="bearer", expires_in=expires_in)


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Logout dan cabut token akses",
)
def logout(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    jti = getattr(request.state, "current_token_jti", None)
    exp = getattr(request.state, "current_token_exp", None)
    if jti and exp:
        revoke_token(db, jti, exp)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
