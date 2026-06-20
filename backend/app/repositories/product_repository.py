from typing import List, Optional

from app.database import get_database
from app.data.products_seed import PRODUCTS


COLLECTION_NAME = "products"

PUBLIC_PROJECTION = {
    "_id": 0,
    "id": 1,
    "nombre": 1,
    "categoria": 1,
    "precio": 1,
    "imagen": 1,
    "stock": 1,
    "activo": 1
}

ADMIN_PROJECTION = {
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


def get_products_collection():
    db = get_database()
    return db[COLLECTION_NAME]


async def seed_products_if_empty():
    collection = get_products_collection()

    await collection.create_index("id", unique=True)
    await collection.create_index("categoria")
    await collection.create_index("activo")

    total = await collection.count_documents({})

    if total == 0:
        await collection.insert_many(PRODUCTS)
        return {
            "inserted": len(PRODUCTS),
            "existing": 0
        }

    return {
        "inserted": 0,
        "existing": total
    }


async def get_public_products_from_db() -> List[dict]:
    collection = get_products_collection()

    cursor = collection.find(
        {"activo": True},
        PUBLIC_PROJECTION
    ).sort("id", 1)

    return await cursor.to_list(None)


async def get_admin_products_from_db() -> List[dict]:
    collection = get_products_collection()

    cursor = collection.find(
        {},
        ADMIN_PROJECTION
    ).sort("id", 1)

    return await cursor.to_list(None)


async def get_public_product_by_id_from_db(product_id: int) -> Optional[dict]:
    collection = get_products_collection()

    product = await collection.find_one(
        {
            "id": product_id,
            "activo": True
        },
        PUBLIC_PROJECTION
    )

    return product
    