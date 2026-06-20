from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from app.models.inventory_model import (
    StockAdjustment,
    StockMovement,
    StockHistoryResponse
)
from app.models.product_model import ProductAdmin
from app.repositories.inventory_repository import (
    adjust_product_stock_in_db,
    get_stock_history_from_db,
    get_low_stock_products_from_db
)
from app.security import verify_admin_token


router = APIRouter(
    prefix="/inventory",
    tags=["Inventory"]
)


@router.post("/stock/adjust/{product_id}", response_model=StockMovement)
async def adjust_stock(
    product_id: int,
    adjustment: StockAdjustment,
    _: bool = Depends(verify_admin_token)
):
    """
    Registra un movimiento de inventario y actualiza el stock del producto.

    Tipos disponibles:
    - entrada: suma stock.
    - salida: resta stock.
    - ajuste: reemplaza el stock por la cantidad indicada.
    """
    try:
        movement = await adjust_product_stock_in_db(
            product_id,
            adjustment.model_dump()
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))

    if not movement:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    return movement


@router.get("/stock/history", response_model=StockHistoryResponse)
async def get_stock_history(
    product_id: Optional[int] = Query(None),
    limit: int = Query(100, ge=1, le=500),
    _: bool = Depends(verify_admin_token)
):
    """
    Consulta el historial de movimientos de stock.

    Puede filtrarse por producto usando product_id.
    """
    return await get_stock_history_from_db(
        product_id=product_id,
        limit=limit
    )


@router.get("/stock/low", response_model=list[ProductAdmin])
async def get_low_stock_products(_: bool = Depends(verify_admin_token)):
    """
    Devuelve productos cuyo stock actual está igual o por debajo del stock mínimo.
    """
    return await get_low_stock_products_from_db()