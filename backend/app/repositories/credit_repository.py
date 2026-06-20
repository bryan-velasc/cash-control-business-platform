from datetime import datetime, timezone
from typing import List, Optional
from uuid import uuid4

from app.database import get_database


CUSTOMERS_COLLECTION = "customers"
CREDITS_COLLECTION = "credits"
PAYMENTS_COLLECTION = "credit_payments"


def get_customers_collection():
    db = get_database()
    return db[CUSTOMERS_COLLECTION]


def get_credits_collection():
    db = get_database()
    return db[CREDITS_COLLECTION]


def get_credit_payments_collection():
    db = get_database()
    return db[PAYMENTS_COLLECTION]


async def create_credit_indexes():
    credits = get_credits_collection()
    payments = get_credit_payments_collection()

    await credits.create_index("credit_id", unique=True)
    await credits.create_index("customer_id")
    await credits.create_index("estado")
    await credits.create_index("fecha_limite")
    await credits.create_index("activo")

    await payments.create_index("payment_id", unique=True)
    await payments.create_index("credit_id")
    await payments.create_index("customer_id")
    await payments.create_index("created_at")


async def get_next_credit_id() -> int:
    credits = get_credits_collection()

    last_credit = await credits.find_one(
        {},
        {"_id": 0, "credit_id": 1},
        sort=[("credit_id", -1)]
    )

    if not last_credit:
        return 1

    return int(last_credit["credit_id"]) + 1


async def create_credit_in_db(credit_data: dict) -> Optional[dict]:
    customers = get_customers_collection()
    credits = get_credits_collection()

    customer = await customers.find_one(
        {
            "customer_id": credit_data["customer_id"],
            "activo": True
        },
        {"_id": 0}
    )

    if not customer:
        return None

    now = datetime.now(timezone.utc)
    credit_id = await get_next_credit_id()
    monto_total = float(credit_data["monto_total"])

    new_credit = {
        "credit_id": credit_id,
        "customer_id": customer["customer_id"],
        "customer_nombre": customer["nombre"],
        "concepto": credit_data["concepto"],
        "monto_total": monto_total,
        "monto_pagado": 0.0,
        "saldo_pendiente": monto_total,
        "fecha_limite": credit_data.get("fecha_limite"),
        "estado": "pendiente",
        "notas": credit_data.get("notas"),
        "usuario": credit_data.get("usuario") or "admin",
        "activo": True,
        "created_at": now,
        "updated_at": now
    }

    await credits.insert_one(new_credit)

    new_credit.pop("_id", None)

    return new_credit


async def get_credits_from_db() -> List[dict]:
    credits = get_credits_collection()

    cursor = credits.find(
        {},
        {"_id": 0}
    ).sort("credit_id", -1)

    return await cursor.to_list(None)


async def get_credit_by_id_from_db(credit_id: int) -> Optional[dict]:
    credits = get_credits_collection()

    return await credits.find_one(
        {"credit_id": credit_id},
        {"_id": 0}
    )


async def get_customer_credits_from_db(customer_id: int) -> List[dict]:
    credits = get_credits_collection()

    cursor = credits.find(
        {"customer_id": customer_id},
        {"_id": 0}
    ).sort("credit_id", -1)

    return await cursor.to_list(None)


async def update_credit_in_db(credit_id: int, credit_data: dict) -> Optional[dict]:
    credits = get_credits_collection()

    clean_data = {
        key: value
        for key, value in credit_data.items()
        if value is not None
    }

    clean_data["updated_at"] = datetime.now(timezone.utc)

    result = await credits.update_one(
        {"credit_id": credit_id},
        {"$set": clean_data}
    )

    if result.matched_count == 0:
        return None

    return await get_credit_by_id_from_db(credit_id)


async def register_credit_payment_in_db(credit_id: int, payment_data: dict) -> Optional[dict]:
    credits = get_credits_collection()
    payments = get_credit_payments_collection()

    credit = await get_credit_by_id_from_db(credit_id)

    if not credit or not credit.get("activo"):
        return None

    if credit["estado"] in ["pagado", "cancelado"]:
        raise ValueError("Este fiado ya no acepta pagos porque está pagado o cancelado")

    saldo_actual = float(credit.get("saldo_pendiente", 0))
    monto = float(payment_data["monto"])

    if monto > saldo_actual:
        raise ValueError(
            f"El abono excede el saldo pendiente. Pendiente: {saldo_actual}, abono: {monto}"
        )

    nuevo_pagado = float(credit.get("monto_pagado", 0)) + monto
    nuevo_saldo = max(0, saldo_actual - monto)

    nuevo_estado = "pagado" if nuevo_saldo == 0 else "parcial"

    now = datetime.now(timezone.utc)

    await credits.update_one(
        {"credit_id": credit_id},
        {
            "$set": {
                "monto_pagado": nuevo_pagado,
                "saldo_pendiente": nuevo_saldo,
                "estado": nuevo_estado,
                "updated_at": now
            }
        }
    )

    payment = {
        "payment_id": str(uuid4()),
        "credit_id": credit_id,
        "customer_id": credit["customer_id"],
        "customer_nombre": credit["customer_nombre"],
        "monto": monto,
        "metodo_pago": payment_data.get("metodo_pago", "efectivo"),
        "nota": payment_data.get("nota"),
        "usuario": payment_data.get("usuario") or "admin",
        "created_at": now
    }

    await payments.insert_one(payment)

    payment.pop("_id", None)

    return payment


async def get_credit_payments_from_db(credit_id: int) -> dict:
    payments = get_credit_payments_collection()

    cursor = payments.find(
        {"credit_id": credit_id},
        {"_id": 0}
    ).sort("created_at", -1)

    payment_list = await cursor.to_list(None)

    return {
        "total": len(payment_list),
        "pagos": payment_list
    }


async def cancel_credit_in_db(credit_id: int) -> bool:
    credits = get_credits_collection()

    result = await credits.update_one(
        {"credit_id": credit_id},
        {
            "$set": {
                "estado": "cancelado",
                "activo": False,
                "updated_at": datetime.now(timezone.utc)
            }
        }
    )

    return result.matched_count > 0