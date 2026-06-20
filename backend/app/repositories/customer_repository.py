from datetime import datetime, timezone
from typing import List, Optional

from app.database import get_database


CUSTOMERS_COLLECTION = "customers"
CREDITS_COLLECTION = "credits"


def get_customers_collection():
    db = get_database()
    return db[CUSTOMERS_COLLECTION]


def get_credits_collection():
    db = get_database()
    return db[CREDITS_COLLECTION]


async def create_customer_indexes():
    customers = get_customers_collection()

    await customers.create_index("customer_id", unique=True)
    await customers.create_index("nombre")
    await customers.create_index("telefono")
    await customers.create_index("activo")


async def get_next_customer_id() -> int:
    customers = get_customers_collection()

    last_customer = await customers.find_one(
        {},
        {"_id": 0, "customer_id": 1},
        sort=[("customer_id", -1)]
    )

    if not last_customer:
        return 1

    return int(last_customer["customer_id"]) + 1


async def create_customer_in_db(customer_data: dict) -> dict:
    customers = get_customers_collection()

    now = datetime.now(timezone.utc)
    customer_id = await get_next_customer_id()

    new_customer = {
        "customer_id": customer_id,
        "nombre": customer_data["nombre"],
        "telefono": customer_data.get("telefono"),
        "alias": customer_data.get("alias"),
        "notas": customer_data.get("notas"),
        "activo": customer_data.get("activo", True),
        "created_at": now,
        "updated_at": now
    }

    await customers.insert_one(new_customer)

    new_customer.pop("_id", None)

    return new_customer


async def get_customers_from_db() -> List[dict]:
    customers = get_customers_collection()

    cursor = customers.find(
        {},
        {"_id": 0}
    ).sort("customer_id", 1)

    return await cursor.to_list(None)


async def get_customer_by_id_from_db(customer_id: int) -> Optional[dict]:
    customers = get_customers_collection()

    return await customers.find_one(
        {"customer_id": customer_id},
        {"_id": 0}
    )


async def update_customer_in_db(customer_id: int, customer_data: dict) -> Optional[dict]:
    customers = get_customers_collection()

    clean_data = {
        key: value
        for key, value in customer_data.items()
        if value is not None
    }

    clean_data["updated_at"] = datetime.now(timezone.utc)

    result = await customers.update_one(
        {"customer_id": customer_id},
        {"$set": clean_data}
    )

    if result.matched_count == 0:
        return None

    return await get_customer_by_id_from_db(customer_id)


async def soft_delete_customer_in_db(customer_id: int) -> bool:
    customers = get_customers_collection()

    result = await customers.update_one(
        {"customer_id": customer_id},
        {
            "$set": {
                "activo": False,
                "updated_at": datetime.now(timezone.utc)
            }
        }
    )

    return result.matched_count > 0


async def get_customer_summary_from_db(customer_id: int) -> Optional[dict]:
    customer = await get_customer_by_id_from_db(customer_id)

    if not customer:
        return None

    credits = get_credits_collection()

    cursor = credits.find(
        {
            "customer_id": customer_id,
            "activo": True,
            "estado": {"$in": ["pendiente", "parcial", "vencido"]}
        },
        {"_id": 0}
    )

    credit_list = await cursor.to_list(None)

    total_fiado = sum(float(item.get("monto_total", 0)) for item in credit_list)
    total_pagado = sum(float(item.get("monto_pagado", 0)) for item in credit_list)
    saldo_pendiente = sum(float(item.get("saldo_pendiente", 0)) for item in credit_list)

    return {
        "customer_id": customer["customer_id"],
        "nombre": customer["nombre"],
        "telefono": customer.get("telefono"),
        "total_fiado": total_fiado,
        "total_pagado": total_pagado,
        "saldo_pendiente": saldo_pendiente,
        "creditos_activos": len(credit_list)
    }