from datetime import datetime, timezone
from typing import Optional

from app.database import get_database

try:
    from app.data.products_seed import PRODUCTS
except Exception:
    PRODUCTS = []


PRODUCTS_COLLECTION = "products"


def _products_collection():
    database = get_database()
    return database[PRODUCTS_COLLECTION]


def _clean_product(product: Optional[dict]) -> Optional[dict]:
    if not product:
        return None

    product.pop("_id", None)
    return product


async def create_product_indexes():
    collection = _products_collection()

    await collection.create_index("id", unique=True)
    await collection.create_index("categoria")
    await collection.create_index("activo")


async def seed_products_if_empty():
    collection = _products_collection()

    await create_product_indexes()

    count = await collection.count_documents({})

    if count > 0:
        return {
            "seeded": False,
            "message": "La colección products ya contiene datos."
        }

    if not PRODUCTS:
        return {
            "seeded": False,
            "message": "No hay productos seed configurados."
        }

    now = datetime.now(timezone.utc)

    docs = []
    for product in PRODUCTS:
        item = dict(product)
        item["created_at"] = now
        item["updated_at"] = now
        docs.append(item)

    await collection.insert_many(docs)

    return {
        "seeded": True,
        "inserted": len(docs)
    }


async def get_public_products_from_db():
    collection = _products_collection()

    cursor = collection.find(
        {"activo": True},
        {
            "_id": 0,
            "precio_compra": 0,
            "proveedor": 0,
            "stock_minimo": 0,
            "created_at": 0,
            "updated_at": 0,
        },
    ).sort("id", 1)

    return await cursor.to_list(length=None)


async def get_admin_products_from_db():
    collection = _products_collection()

    cursor = collection.find(
        {},
        {"_id": 0},
    ).sort("id", 1)

    return await cursor.to_list(length=None)


async def get_public_product_by_id_from_db(product_id: int):
    collection = _products_collection()

    product = await collection.find_one(
        {
            "id": product_id,
            "activo": True,
        },
        {
            "_id": 0,
            "precio_compra": 0,
            "proveedor": 0,
            "stock_minimo": 0,
            "created_at": 0,
            "updated_at": 0,
        },
    )

    return product


async def get_admin_product_by_id_from_db(product_id: int):
    collection = _products_collection()

    product = await collection.find_one(
        {"id": product_id},
        {"_id": 0},
    )

    return product


async def get_next_product_id():
    collection = _products_collection()

    last_product = await collection.find_one(
        {},
        sort=[("id", -1)],
    )

    if not last_product:
        return 1

    return int(last_product.get("id", 0)) + 1


async def create_product_in_db(product_data: dict):
    collection = _products_collection()

    now = datetime.now(timezone.utc)

    product_id = await get_next_product_id()

    new_product = {
        "id": product_id,
        "nombre": product_data.get("nombre", "").strip(),
        "categoria": product_data.get("categoria", "").strip(),
        "precio": float(product_data.get("precio", 0)),
        "imagen": product_data.get("imagen") or "",
        "stock": int(product_data.get("stock", 0)),
        "activo": bool(product_data.get("activo", True)),
        "precio_compra": product_data.get("precio_compra"),
        "proveedor": product_data.get("proveedor"),
        "stock_minimo": product_data.get("stock_minimo", 0),
        "created_at": now,
        "updated_at": now,
    }

    await collection.insert_one(new_product)

    return _clean_product(new_product)


async def update_product_in_db(product_id: int, product_data: dict):
    collection = _products_collection()

    clean_data = {
        key: value
        for key, value in product_data.items()
        if value is not None
    }

    if not clean_data:
        return await get_admin_product_by_id_from_db(product_id)

    clean_data["updated_at"] = datetime.now(timezone.utc)

    await collection.update_one(
        {"id": product_id},
        {"$set": clean_data},
    )

    return await get_admin_product_by_id_from_db(product_id)


async def update_product_stock_in_db(product_id: int, stock: int):
    collection = _products_collection()

    await collection.update_one(
        {"id": product_id},
        {
            "$set": {
                "stock": stock,
                "updated_at": datetime.now(timezone.utc),
            }
        },
    )

    return await get_admin_product_by_id_from_db(product_id)


async def delete_product_in_db(product_id: int):
    collection = _products_collection()

    result = await collection.update_one(
        {"id": product_id},
        {
            "$set": {
                "activo": False,
                "updated_at": datetime.now(timezone.utc),
            }
        },
    )

    return result.modified_count > 0