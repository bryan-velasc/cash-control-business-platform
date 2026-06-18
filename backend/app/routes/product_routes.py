from fastapi import APIRouter, HTTPException
from typing import List

from app.models.product_model import ProductPublic, ProductAdmin
from app.data.products_seed import PRODUCTS

router = APIRouter(
    prefix="/products",
    tags=["Products"]
)


@router.get("/public", response_model=List[ProductPublic])
async def get_public_products():
    """
    Devuelve productos públicos para la página web.

    No expone datos internos como precio de compra,
    proveedor o ganancia estimada.
    """
    public_products = []

    for product in PRODUCTS:
        if product.get("activo"):
            public_products.append({
                "id": product["id"],
                "nombre": product["nombre"],
                "categoria": product["categoria"],
                "precio": product["precio"],
                "imagen": product["imagen"],
                "stock": product["stock"],
                "activo": product["activo"]
            })

    return public_products


@router.get("/admin", response_model=List[ProductAdmin])
async def get_admin_products():
    """
    Devuelve productos con información administrativa.

    Este endpoint todavía es demo.
    En una fase posterior debe protegerse con autenticación.
    """
    return PRODUCTS


@router.get("/{product_id}", response_model=ProductPublic)
async def get_product_by_id(product_id: int):
    """
    Devuelve un producto público por ID.
    """
    for product in PRODUCTS:
        if product["id"] == product_id and product.get("activo"):
            return {
                "id": product["id"],
                "nombre": product["nombre"],
                "categoria": product["categoria"],
                "precio": product["precio"],
                "imagen": product["imagen"],
                "stock": product["stock"],
                "activo": product["activo"]
            }

    raise HTTPException(status_code=404, detail="Producto no encontrado")