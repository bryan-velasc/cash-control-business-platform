from typing import Optional

from pydantic import BaseModel, Field


class ProductPublic(BaseModel):
    id: int
    nombre: str
    categoria: str
    precio: float
    imagen: str
    stock: int
    activo: bool


class ProductAdmin(ProductPublic):
    precio_compra: Optional[float] = None
    proveedor: Optional[str] = None
    stock_minimo: Optional[int] = 0


class ProductCreate(BaseModel):
    nombre: str = Field(..., min_length=1)
    categoria: str = Field(..., min_length=1)
    precio: float = Field(..., ge=0)
    imagen: str = ""
    stock: int = Field(default=0, ge=0)
    activo: bool = True
    precio_compra: Optional[float] = Field(default=None, ge=0)
    proveedor: Optional[str] = None
    stock_minimo: Optional[int] = Field(default=0, ge=0)


class ProductUpdate(BaseModel):
    nombre: Optional[str] = None
    categoria: Optional[str] = None
    precio: Optional[float] = Field(default=None, ge=0)
    imagen: Optional[str] = None
    stock: Optional[int] = Field(default=None, ge=0)
    activo: Optional[bool] = None
    precio_compra: Optional[float] = Field(default=None, ge=0)
    proveedor: Optional[str] = None
    stock_minimo: Optional[int] = Field(default=None, ge=0)


class ProductStockUpdate(BaseModel):
    stock: int = Field(..., ge=0)


class ApiMessage(BaseModel):
    message: str
    product_id: Optional[int] = None