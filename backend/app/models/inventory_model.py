from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field


class StockAdjustment(BaseModel):
    tipo: Literal["entrada", "salida", "ajuste"] = Field(
        ...,
        description="Tipo de movimiento: entrada, salida o ajuste"
    )
    cantidad: int = Field(
        ...,
        ge=0,
        description="Cantidad a mover. En ajuste representa el nuevo stock final."
    )
    motivo: str = Field(
        ...,
        min_length=3,
        description="Motivo del movimiento de stock"
    )
    usuario: Optional[str] = Field(
        "admin",
        description="Usuario o responsable del movimiento"
    )
    referencia: Optional[str] = Field(
        None,
        description="Referencia opcional: compra, venta, pedido, corrección, etc."
    )


class StockMovement(BaseModel):
    movement_id: str
    product_id: int
    producto_nombre: str
    tipo: Literal["entrada", "salida", "ajuste"]
    stock_anterior: int
    cantidad: int
    stock_nuevo: int
    motivo: str
    usuario: str
    referencia: Optional[str] = None
    created_at: datetime


class StockHistoryResponse(BaseModel):
    total: int
    movimientos: list[StockMovement]