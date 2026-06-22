import os

from dotenv import load_dotenv
from fastapi import Header, HTTPException, status


load_dotenv()

ADMIN_API_TOKEN = os.getenv("ADMIN_API_TOKEN")


async def verify_admin_token(x_admin_token: str = Header(None)):
    if not ADMIN_API_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="ADMIN_API_TOKEN no configurado en el servidor"
        )

    if x_admin_token != ADMIN_API_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token administrativo inválido"
        )

    return True
