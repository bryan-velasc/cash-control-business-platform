from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class SupplierCreate(BaseModel):
    nombre: str = Field(..., min_length=2)
    contacto: Optional[str] = None
    telefono: Optional[str] = None
    email: Optional[str] = None
    direccion: Optional[str] = None
    notas: Optional[str] = None
    activo: bool = True


class SupplierUpdate(BaseModel):
    nombre: Optional[str] = None
    contacto: Optional[str] = None
    telefono: Optional[str] = None
    email: Optional[str] = None
    direccion: Optional[str] = None
    notas: Optional[str] = None
    activo: Optional[bool] = None


class SupplierAdmin(BaseModel):
    supplier_id: int
    nombre: str
    contacto: Optional[str] = None
    telefono: Optional[str] = None
    email: Optional[str] = None
    direccion: Optional[str] = None
    notas: Optional[str] = None
    activo: bool
    created_at: datetime
    updated_at: datetime


class SupplierSummary(BaseModel):
    supplier_id: int
    nombre: str
    total_compras: float
    numero_compras: int