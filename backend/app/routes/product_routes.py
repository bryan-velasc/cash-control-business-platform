from typing import List

from fastapi import APIRouter, Depends, HTTPException, status

from app.models.product_model import (
    ApiMessage,
    ProductAdmin,
    ProductCreate,
    ProductPublic,
    ProductStockUpdate,
    ProductUpdate,
)
from app.repositories.product_repository import (
    create_product_in_db,
    delete_product_in_db,
    get_admin_product_by_id_from_db,
    get_admin_products_from_db,
    get_public_product_by_id_from_db,
    get_public_products_from_db,
    update_product_in_db,
    update_product_stock_in_db,
)
from app.security import verify_admin_token


router = APIRouter(
    prefix="/products",
    tags=["Products"],
)


@router.get("/public", response_model=List[ProductPublic])
async def get_public_products():
    return await get_public_products_from_db()


@router.get("/admin", response_model=List[ProductAdmin])
async def get_admin_products(
    authorized: bool = Depends(verify_admin_token),
):
    return await get_admin_products_from_db()


@router.post(
    "/create",
    response_model=ProductAdmin,
    status_code=status.HTTP_201_CREATED,
)
async def create_product(
    product: ProductCreate,
    authorized: bool = Depends(verify_admin_token),
):
    return await create_product_in_db(
        product.model_dump()
    )


@router.put("/update/{product_id}", response_model=ProductAdmin)
async def update_product(
    product_id: int,
    product: ProductUpdate,
    authorized: bool = Depends(verify_admin_token),
):
    existing_product = await get_admin_product_by_id_from_db(product_id)

    if not existing_product:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado",
        )

    updated_product = await update_product_in_db(
        product_id,
        product.model_dump(exclude_none=True),
    )

    return updated_product


@router.patch("/stock/{product_id}", response_model=ProductAdmin)
async def update_product_stock(
    product_id: int,
    stock_data: ProductStockUpdate,
    authorized: bool = Depends(verify_admin_token),
):
    existing_product = await get_admin_product_by_id_from_db(product_id)

    if not existing_product:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado",
        )

    updated_product = await update_product_stock_in_db(
        product_id,
        stock_data.stock,
    )

    return updated_product


@router.delete("/delete/{product_id}", response_model=ApiMessage)
async def delete_product(
    product_id: int,
    authorized: bool = Depends(verify_admin_token),
):
    existing_product = await get_admin_product_by_id_from_db(product_id)

    if not existing_product:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado",
        )

    deleted = await delete_product_in_db(product_id)

    if not deleted:
        raise HTTPException(
            status_code=400,
            detail="No se pudo desactivar el producto",
        )

    return ApiMessage(
        message="Producto desactivado correctamente",
        product_id=product_id,
    )


@router.get("/{product_id}", response_model=ProductPublic)
async def get_product_by_id(product_id: int):
    product = await get_public_product_by_id_from_db(product_id)

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado",
        )

    return product