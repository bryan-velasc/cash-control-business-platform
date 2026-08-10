from datetime import datetime, timezone
from typing import List, Optional

from app.database import get_database


SUPPLIERS_COLLECTION = "suppliers"
PURCHASES_COLLECTION = "purchases"


def get_suppliers_collection():
    db = get_database()
    return db[SUPPLIERS_COLLECTION]


def get_purchases_collection():
    db = get_database()
    return db[PURCHASES_COLLECTION]


async def create_supplier_indexes():
    suppliers = get_suppliers_collection()

    await suppliers.create_index(
        "supplier_id",
        unique=True,
    )

    await suppliers.create_index("nombre")
    await suppliers.create_index("telefono")
    await suppliers.create_index("email")
    await suppliers.create_index("activo")


async def get_next_supplier_id() -> int:
    suppliers = get_suppliers_collection()

    last_supplier = await suppliers.find_one(
        {},
        {
            "_id": 0,
            "supplier_id": 1,
        },
        sort=[
            ("supplier_id", -1),
        ],
    )

    if not last_supplier:
        return 1

    return int(
        last_supplier["supplier_id"]
    ) + 1


async def create_supplier_in_db(
    supplier_data: dict,
) -> dict:
    suppliers = get_suppliers_collection()

    supplier_id = await get_next_supplier_id()

    now = datetime.now(timezone.utc)

    supplier = {
        "supplier_id": supplier_id,
        "nombre": supplier_data["nombre"].strip(),
        "contacto": supplier_data.get("contacto"),
        "telefono": supplier_data.get("telefono"),
        "email": supplier_data.get("email"),
        "direccion": supplier_data.get("direccion"),
        "notas": supplier_data.get("notas"),
        "activo": supplier_data.get("activo", True),
        "created_at": now,
        "updated_at": now,
    }

    await suppliers.insert_one(supplier)

    supplier.pop("_id", None)

    return supplier


async def get_suppliers_from_db() -> List[dict]:
    suppliers = get_suppliers_collection()

    cursor = suppliers.find(
        {},
        {"_id": 0},
    ).sort(
        "supplier_id",
        1,
    )

    return await cursor.to_list(None)


async def get_supplier_by_id_from_db(
    supplier_id: int,
) -> Optional[dict]:
    suppliers = get_suppliers_collection()

    return await suppliers.find_one(
        {
            "supplier_id": supplier_id,
        },
        {
            "_id": 0,
        },
    )


async def update_supplier_in_db(
    supplier_id: int,
    supplier_data: dict,
) -> Optional[dict]:
    suppliers = get_suppliers_collection()

    clean_data = {
        key: value
        for key, value in supplier_data.items()
        if value is not None
    }

    clean_data["updated_at"] = datetime.now(
        timezone.utc
    )

    result = await suppliers.update_one(
        {
            "supplier_id": supplier_id,
        },
        {
            "$set": clean_data,
        },
    )

    if result.matched_count == 0:
        return None

    return await get_supplier_by_id_from_db(
        supplier_id
    )


async def soft_delete_supplier_in_db(
    supplier_id: int,
) -> bool:
    suppliers = get_suppliers_collection()

    result = await suppliers.update_one(
        {
            "supplier_id": supplier_id,
        },
        {
            "$set": {
                "activo": False,
                "updated_at": datetime.now(
                    timezone.utc
                ),
            }
        },
    )

    return result.matched_count > 0


async def get_supplier_summary_from_db(
    supplier_id: int,
) -> Optional[dict]:
    supplier = await get_supplier_by_id_from_db(
        supplier_id
    )

    if not supplier:
        return None

    purchases = get_purchases_collection()

    cursor = purchases.find(
        {
            "supplier_id": supplier_id,
            "estado": {
                "$ne": "cancelada",
            },
        },
        {
            "_id": 0,
        },
    )

    purchase_list = await cursor.to_list(None)

    total_compras = sum(
        float(
            purchase.get(
                "total",
                0,
            )
        )
        for purchase in purchase_list
    )

    return {
        "supplier_id": supplier["supplier_id"],
        "nombre": supplier["nombre"],
        "total_compras": round(
            total_compras,
            2,
        ),
        "numero_compras": len(
            purchase_list
        ),
    }