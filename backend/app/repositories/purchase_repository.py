from datetime import datetime, timezone
from typing import Optional
from uuid import uuid4

from app.database import get_database

from app.repositories.inventory_repository import (
    adjust_product_stock_in_db,
)


PURCHASES_COLLECTION = "purchases"
PRODUCTS_COLLECTION = "products"
SUPPLIERS_COLLECTION = "suppliers"


def get_purchases_collection():
    db = get_database()
    return db[PURCHASES_COLLECTION]


def get_products_collection():
    db = get_database()
    return db[PRODUCTS_COLLECTION]


def get_suppliers_collection():
    db = get_database()
    return db[SUPPLIERS_COLLECTION]


async def create_purchase_indexes():
    purchases = get_purchases_collection()

    await purchases.create_index(
        "purchase_id",
        unique=True,
    )

    await purchases.create_index(
        "folio",
        unique=True,
    )

    await purchases.create_index(
        "supplier_id",
    )

    await purchases.create_index(
        "created_at",
    )

    await purchases.create_index(
        "estado",
    )


def _generate_folio() -> str:
    now = datetime.now(
        timezone.utc,
    )

    timestamp = now.strftime(
        "%Y%m%d-%H%M%S",
    )

    suffix = str(
        uuid4(),
    )[:6].upper()

    return f"COM-{timestamp}-{suffix}"


async def create_purchase_in_db(
    purchase_data: dict,
) -> dict:
    purchases = get_purchases_collection()
    products = get_products_collection()
    suppliers = get_suppliers_collection()

    supplier_id = int(
        purchase_data["supplier_id"]
    )

    supplier = await suppliers.find_one(
        {
            "supplier_id": supplier_id,
            "activo": True,
        },
        {
            "_id": 0,
        },
    )

    if not supplier:
        raise ValueError(
            "Proveedor no encontrado o inactivo"
        )

    items_received = purchase_data["items"]

    if not items_received:
        raise ValueError(
            "La compra debe contener productos"
        )

    purchase_id = str(
        uuid4()
    )

    folio = _generate_folio()

    purchase_items = []

    total = 0.0

    for item in items_received:
        product_id = int(
            item["product_id"]
        )

        cantidad = int(
            item["cantidad"]
        )

        costo_unitario = float(
            item["costo_unitario"]
        )

        if cantidad <= 0:
            raise ValueError(
                "La cantidad debe ser mayor a cero"
            )

        if costo_unitario < 0:
            raise ValueError(
                "El costo unitario no puede ser negativo"
            )

        product = await products.find_one(
            {
                "id": product_id,
                "activo": True,
            },
            {
                "_id": 0,
            },
        )

        if not product:
            raise ValueError(
                f"Producto {product_id} no encontrado o inactivo"
            )

        stock_anterior = int(
            product.get(
                "stock",
                0,
            )
        )

        movement = await adjust_product_stock_in_db(
            product_id,
            {
                "tipo": "entrada",
                "cantidad": cantidad,
                "motivo": "Compra",
                "usuario": (
                    purchase_data.get("usuario")
                    or "admin"
                ),
                "referencia": folio,
            },
        )

        if not movement:
            raise ValueError(
                f"No se pudo actualizar stock del producto {product_id}"
            )

        stock_nuevo = int(
            movement["stock_nuevo"]
        )

        await products.update_one(
            {
                "id": product_id,
            },
            {
                "$set": {
                    "precio_compra": costo_unitario,
                    "proveedor": supplier["nombre"],
                }
            },
        )

        subtotal = round(
            costo_unitario * cantidad,
            2,
        )

        total += subtotal

        purchase_items.append(
            {
                "product_id": product_id,
                "producto_nombre": product.get(
                    "nombre",
                    "Producto",
                ),
                "cantidad": cantidad,
                "costo_unitario": costo_unitario,
                "subtotal": subtotal,
                "stock_anterior": stock_anterior,
                "stock_nuevo": stock_nuevo,
            }
        )

    total = round(
        total,
        2,
    )

    now = datetime.now(
        timezone.utc,
    )

    purchase = {
        "purchase_id": purchase_id,
        "folio": folio,

        "supplier_id": supplier_id,
        "supplier_nombre": supplier["nombre"],

        "items": purchase_items,

        "total": total,

        "referencia": purchase_data.get(
            "referencia"
        ),

        "notas": purchase_data.get(
            "notas"
        ),

        "usuario": (
            purchase_data.get("usuario")
            or "admin"
        ),

        "estado": "completada",

        "created_at": now,
    }

    await purchases.insert_one(
        purchase
    )

    purchase.pop(
        "_id",
        None,
    )

    return purchase


async def get_purchases_from_db(
    limit: int = 100,
) -> list[dict]:
    purchases = get_purchases_collection()

    cursor = purchases.find(
        {},
        {
            "_id": 0,
        },
    ).sort(
        "created_at",
        -1,
    ).limit(
        limit
    )

    return await cursor.to_list(
        length=limit
    )


async def get_purchase_by_id_from_db(
    purchase_id: str,
) -> Optional[dict]:
    purchases = get_purchases_collection()

    return await purchases.find_one(
        {
            "purchase_id": purchase_id,
        },
        {
            "_id": 0,
        },
    )


async def get_purchases_by_supplier_from_db(
    supplier_id: int,
    limit: int = 100,
) -> list[dict]:
    purchases = get_purchases_collection()

    cursor = purchases.find(
        {
            "supplier_id": supplier_id,
        },
        {
            "_id": 0,
        },
    ).sort(
        "created_at",
        -1,
    ).limit(
        limit
    )

    return await cursor.to_list(
        length=limit
    )


async def get_purchase_summary_from_db() -> dict:
    purchases = get_purchases_collection()

    cursor = purchases.find(
        {
            "estado": {
                "$ne": "cancelada",
            },
        },
        {
            "_id": 0,
        },
    )

    purchase_list = await cursor.to_list(
        None
    )

    total_compras = 0.0
    total_unidades = 0

    for purchase in purchase_list:
        total_compras += float(
            purchase.get(
                "total",
                0,
            )
        )

        for item in purchase.get(
            "items",
            [],
        ):
            total_unidades += int(
                item.get(
                    "cantidad",
                    0,
                )
            )

    return {
        "total_compras": round(
            total_compras,
            2,
        ),
        "numero_compras": len(
            purchase_list
        ),
        "total_unidades": total_unidades,
    }