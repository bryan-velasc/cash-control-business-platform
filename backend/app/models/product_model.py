from pydantic import BaseModel, Field
from typing import Optional


class ProductPublic(BaseModel):
    id: int = Field(..., description="Identificador público del producto")
    nombre: str = Field(..., description="Nombre del producto")
    categoria: str = Field(..., description="Categoría del producto")
    precio: float = Field(..., description="Precio público de venta")
    imagen: str = Field(..., description="Ruta o URL de imagen del producto")
    stock: int = Field(..., description="Cantidad disponible")
    activo: bool = Field(..., description="Indica si el producto se muestra al público")


class ProductAdmin(ProductPublic):
    precio_compra: Optional[float] = Field(None, description="Precio interno de compra")
    proveedor: Optional[str] = Field(None, description="Proveedor del producto")
    stock_minimo: Optional[int] = Field(None, description="Stock mínimo recomendado")