from datetime import datetime, timezone
from typing import Optional
from uuid import uuid4

from app.database import get_database


PRODUCTS_COLLECTION = "products"
MOVEMENTS_COLLECTION = "stock_movements"


def get_products_collection():
    db = get_database()
    return db[PRODUCTS_COLLECTION]


def get_stock_movements_collection():
    db = get_database()
    return db[MOVEMENTS_COLLECTION]


async def create_inventory_indexes():
    movements = get_stock_movements_collection()

    await movements.create_index("movement_id", unique=True)
    await movements.create_index("product_id")
    await movements.create_index("tipo")
    await movements.create_index("created_at")


async def adjust_product_stock_in_db(product_id: int, adjustment_data: dict) -> Optional[dict]:
    products = get_products_collection()
    movements = get_stock_movements_collection()

    product = await products.find_one(
        {"id": product_id},
        {"_id": 0}
    )

    if not product:
        return None

    stock_anterior = int(product.get("stock", 0))
    cantidad = int(adjustment_data["cantidad"])
    tipo = adjustment_data["tipo"]

    if tipo == "entrada":
        stock_nuevo = stock_anterior + cantidad

    elif tipo == "salida":
        if cantidad > stock_anterior:
            raise ValueError(
                f"Stock insuficiente. Disponible: {stock_anterior}, solicitado: {cantidad}"
            )

        stock_nuevo = stock_anterior - cantidad

    elif tipo == "ajuste":
        stock_nuevo = cantidad

    else:
        raise ValueError("Tipo de movimiento inválido")

    await products.update_one(
        {"id": product_id},
        {"$set": {"stock": stock_nuevo}}
    )

    movement = {
        "movement_id": str(uuid4()),
        "product_id": product_id,
        "producto_nombre": product.get("nombre", "Producto sin nombre"),
        "tipo": tipo,
        "stock_anterior": stock_anterior,
        "cantidad": cantidad,
        "stock_nuevo": stock_nuevo,
        "motivo": adjustment_data["motivo"],
        "usuario": adjustment_data.get("usuario") or "admin",
        "referencia": adjustment_data.get("referencia"),
        "created_at": datetime.now(timezone.utc)
    }

    await movements.insert_one(movement)

    movement.pop("_id", None)

    return movement


async def get_stock_history_from_db(
    product_id: Optional[int] = None,
    limit: int = 100
) -> dict:
    movements = get_stock_movements_collection()

    query = {}

    if product_id is not None:
        query["product_id"] = product_id

    cursor = movements.find(
        query,
        {"_id": 0}
    ).sort("created_at", -1).limit(limit)

    results = await cursor.to_list(length=limit)

    return {
        "total": len(results),
        "movimientos": results
    }


async def get_low_stock_products_from_db():
    products = get_products_collection()

    cursor = products.find(
        {
            "$expr": {
                "$lte": [
                    "$stock",
                    {
                        "$ifNull": ["$stock_minimo", 0]
                    }
                ]
            },
            "activo": True
        },
        {
            "_id": 0,
            "id": 1,
            "nombre": 1,
            "categoria": 1,
            "precio": 1,
            "imagen": 1,
            "stock": 1,
            "activo": 1,
            "precio_compra": 1,
            "proveedor": 1,
            "stock_minimo": 1
        }
    ).sort("stock", 1)

    return await cursor.to_list(None)