from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.models.product_model import ProductPublic, ProductAdmin
from app.repositories.product_repository import (
    get_public_products_from_db,
    get_admin_products_from_db,
    get_public_product_by_id_from_db,
)
from app.security import verify_admin_token


router = APIRouter(
    prefix="/products",
    tags=["Products"]
)


@router.get("/public", response_model=List[ProductPublic])
async def get_public_products():
    """
    Devuelve productos públicos desde MongoDB Atlas.

    No expone precio de compra, proveedor ni datos internos.
    """
    return await get_public_products_from_db()


@router.get("/admin", response_model=List[ProductAdmin])
async def get_admin_products(
    authorized: bool = Depends(verify_admin_token),
):
    """
    Devuelve productos administrativos desde MongoDB Atlas.

    Este endpoint requiere x-admin-token.
    """
    return await get_admin_products_from_db()


@router.get("/{product_id}", response_model=ProductPublic)
async def get_product_by_id(product_id: int):
    """
    Devuelve un producto público por ID desde MongoDB Atlas.
    """
    product = await get_public_product_by_id_from_db(product_id)

    if not product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    return product