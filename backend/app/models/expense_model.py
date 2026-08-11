from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class ExpenseCreate(BaseModel):
    categoria: str = Field(..., min_length=1)
    descripcion: str = Field(..., min_length=1)
    monto: float = Field(..., gt=0)

    metodo_pago: str = "efectivo"

    referencia: Optional[str] = None
    notas: Optional[str] = None
    usuario: Optional[str] = "admin"


class ExpenseUpdate(BaseModel):
    categoria: Optional[str] = None
    descripcion: Optional[str] = None
    monto: Optional[float] = Field(default=None, gt=0)

    metodo_pago: Optional[str] = None

    referencia: Optional[str] = None
    notas: Optional[str] = None


class ExpenseResponse(BaseModel):
    expense_id: str

    categoria: str
    descripcion: str

    monto: float
    metodo_pago: str

    referencia: Optional[str] = None
    notas: Optional[str] = None

    usuario: str

    activo: bool

    created_at: datetime
    updated_at: Optional[datetime] = None


class ExpenseSummary(BaseModel):
    numero_gastos: int

    total_gastos: float

    transporte: float = 0
    publicidad: float = 0
    servicios: float = 0
    comisiones: float = 0
    empaques: float = 0
    mantenimiento: float = 0
    otros: float = 0