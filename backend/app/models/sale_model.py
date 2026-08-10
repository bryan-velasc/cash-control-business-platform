from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field


PaymentMethod = Literal[
    "efectivo",
    "transferencia",
    "tarjeta",
    "fiado",
]


class SaleItemCreate(BaseModel):
    product_id: int

    cantidad: int = Field(
        ...,
        gt=0,
        description="Cantidad de unidades vendidas",
    )


class SaleCreate(BaseModel):
    items: list[SaleItemCreate] = Field(
        ...,
        min_length=1,
    )

    metodo_pago: PaymentMethod

    customer_id: Optional[int] = None

    notas: Optional[str] = None

    usuario: Optional[str] = "admin"


class SaleItem(BaseModel):
    product_id: int

    producto_nombre: str

    cantidad: int

    precio_unitario: float

    precio_compra_unitario: float

    subtotal: float

    costo_total: float

    utilidad_bruta: float


class SaleAdmin(BaseModel):
    sale_id: str

    folio: str

    customer_id: Optional[int] = None

    customer_nombre: Optional[str] = None

    items: list[SaleItem]

    total: float

    costo_total: float

    utilidad_bruta: float

    metodo_pago: PaymentMethod

    credit_id: Optional[int] = None

    notas: Optional[str] = None

    usuario: str

    estado: Literal[
        "completada",
        "cancelada",
    ]

    created_at: datetime


class SalesSummary(BaseModel):
    total_ventas: float

    total_costo: float

    utilidad_bruta: float

    numero_ventas: int

    efectivo: float

    transferencia: float

    tarjeta: float

    fiado: float