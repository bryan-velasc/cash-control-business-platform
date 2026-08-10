from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class PurchaseItemCreate(BaseModel):
    product_id: int
    cantidad: int = Field(..., gt=0)
    costo_unitario: float = Field(..., ge=0)


class PurchaseCreate(BaseModel):
    supplier_id: int
    items: list[PurchaseItemCreate] = Field(..., min_length=1)

    referencia: Optional[str] = None
    notas: Optional[str] = None
    usuario: str = "admin"


class PurchaseItem(BaseModel):
    product_id: int
    producto_nombre: str

    cantidad: int
    costo_unitario: float
    subtotal: float

    stock_anterior: int
    stock_nuevo: int


class PurchaseAdmin(BaseModel):
    purchase_id: str
    folio: str

    supplier_id: int
    supplier_nombre: str

    items: list[PurchaseItem]

    total: float

    referencia: Optional[str] = None
    notas: Optional[str] = None

    usuario: str

    estado: str

    created_at: datetime


class PurchaseSummary(BaseModel):
    total_compras: float
    numero_compras: int
    total_unidades: int