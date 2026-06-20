from datetime import date, datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field


CreditStatus = Literal["pendiente", "parcial", "pagado", "vencido", "cancelado"]


class CreditCreate(BaseModel):
    customer_id: int
    concepto: str = Field(..., min_length=3)
    monto_total: float = Field(..., gt=0)
    fecha_limite: Optional[date] = None
    notas: Optional[str] = None
    usuario: Optional[str] = "admin"


class CreditUpdate(BaseModel):
    concepto: Optional[str] = None
    fecha_limite: Optional[date] = None
    notas: Optional[str] = None
    estado: Optional[CreditStatus] = None


class CreditAdmin(BaseModel):
    credit_id: int
    customer_id: int
    customer_nombre: str
    concepto: str
    monto_total: float
    monto_pagado: float
    saldo_pendiente: float
    fecha_limite: Optional[date] = None
    estado: CreditStatus
    notas: Optional[str] = None
    usuario: str
    activo: bool
    created_at: datetime
    updated_at: datetime


class CreditPaymentCreate(BaseModel):
    monto: float = Field(..., gt=0)
    metodo_pago: Literal["efectivo", "transferencia", "tarjeta", "otro"] = "efectivo"
    nota: Optional[str] = None
    usuario: Optional[str] = "admin"


class CreditPayment(BaseModel):
    payment_id: str
    credit_id: int
    customer_id: int
    customer_nombre: str
    monto: float
    metodo_pago: str
    nota: Optional[str] = None
    usuario: str
    created_at: datetime


class CreditPaymentsResponse(BaseModel):
    total: int
    pagos: list[CreditPayment]


class ApiMessage(BaseModel):
    message: str
    customer_id: Optional[int] = None
    credit_id: Optional[int] = None