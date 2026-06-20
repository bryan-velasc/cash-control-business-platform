from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class CustomerCreate(BaseModel):
    nombre: str = Field(..., min_length=2)
    telefono: Optional[str] = None
    alias: Optional[str] = None
    notas: Optional[str] = None
    activo: bool = True


class CustomerUpdate(BaseModel):
    nombre: Optional[str] = None
    telefono: Optional[str] = None
    alias: Optional[str] = None
    notas: Optional[str] = None
    activo: Optional[bool] = None


class CustomerAdmin(BaseModel):
    customer_id: int
    nombre: str
    telefono: Optional[str] = None
    alias: Optional[str] = None
    notas: Optional[str] = None
    activo: bool
    created_at: datetime
    updated_at: datetime


class CustomerSummary(BaseModel):
    customer_id: int
    nombre: str
    telefono: Optional[str] = None
    total_fiado: float
    total_pagado: float
    saldo_pendiente: float
    creditos_activos: int