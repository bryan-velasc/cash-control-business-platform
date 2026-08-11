from datetime import datetime, timezone
from typing import Optional
from uuid import uuid4

from app.database import get_database


EXPENSES_COLLECTION = "expenses"


def get_expenses_collection():
    db = get_database()
    return db[EXPENSES_COLLECTION]


async def create_expense_indexes():
    expenses = get_expenses_collection()

    await expenses.create_index(
        "expense_id",
        unique=True,
    )

    await expenses.create_index("categoria")
    await expenses.create_index("created_at")
    await expenses.create_index("activo")


async def create_expense_in_db(
    expense_data: dict,
) -> dict:
    expenses = get_expenses_collection()

    now = datetime.now(timezone.utc)

    expense = {
        "expense_id": str(uuid4()),
        "categoria": (
            expense_data["categoria"]
            .strip()
            .lower()
        ),
        "descripcion": (
            expense_data["descripcion"]
            .strip()
        ),
        "monto": float(
            expense_data["monto"]
        ),
        "metodo_pago": (
            expense_data
            .get(
                "metodo_pago",
                "efectivo",
            )
            .strip()
            .lower()
        ),
        "referencia": expense_data.get(
            "referencia"
        ),
        "notas": expense_data.get(
            "notas"
        ),
        "usuario": (
            expense_data.get(
                "usuario"
            )
            or "admin"
        ),
        "activo": True,
        "created_at": now,
        "updated_at": None,
    }

    await expenses.insert_one(
        expense
    )

    expense.pop(
        "_id",
        None,
    )

    return expense


async def get_expenses_from_db(
    limit: int = 100,
    categoria: Optional[str] = None,
) -> list:
    expenses = get_expenses_collection()

    query = {
        "activo": True,
    }

    if categoria:
        query["categoria"] = (
            categoria
            .strip()
            .lower()
        )

    cursor = (
        expenses.find(
            query,
            {
                "_id": 0,
            },
        )
        .sort(
            "created_at",
            -1,
        )
        .limit(
            limit
        )
    )

    return await cursor.to_list(
        length=limit
    )


async def get_expense_by_id_from_db(
    expense_id: str,
) -> Optional[dict]:
    expenses = get_expenses_collection()

    return await expenses.find_one(
        {
            "expense_id": expense_id,
            "activo": True,
        },
        {
            "_id": 0,
        },
    )


async def update_expense_in_db(
    expense_id: str,
    expense_data: dict,
) -> Optional[dict]:
    expenses = get_expenses_collection()

    existing = await expenses.find_one(
        {
            "expense_id": expense_id,
            "activo": True,
        }
    )

    if not existing:
        return None

    update_data = {
        key: value
        for key, value in expense_data.items()
        if value is not None
    }

    if "categoria" in update_data:
        update_data["categoria"] = (
            update_data["categoria"]
            .strip()
            .lower()
        )

    if "descripcion" in update_data:
        update_data["descripcion"] = (
            update_data["descripcion"]
            .strip()
        )

    if "metodo_pago" in update_data:
        update_data["metodo_pago"] = (
            update_data["metodo_pago"]
            .strip()
            .lower()
        )

    if "monto" in update_data:
        update_data["monto"] = float(
            update_data["monto"]
        )

    update_data["updated_at"] = (
        datetime.now(
            timezone.utc
        )
    )

    await expenses.update_one(
        {
            "expense_id": expense_id,
        },
        {
            "$set": update_data,
        },
    )

    return await expenses.find_one(
        {
            "expense_id": expense_id,
        },
        {
            "_id": 0,
        },
    )


async def delete_expense_from_db(
    expense_id: str,
) -> bool:
    expenses = get_expenses_collection()

    result = await expenses.update_one(
        {
            "expense_id": expense_id,
            "activo": True,
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

    return result.modified_count > 0


async def get_expense_summary_from_db() -> dict:
    expenses = get_expenses_collection()

    pipeline = [
        {
            "$match": {
                "activo": True,
            }
        },
        {
            "$group": {
                "_id": "$categoria",
                "total": {
                    "$sum": "$monto",
                },
                "cantidad": {
                    "$sum": 1,
                },
            }
        },
    ]

    # PyMongo async:
    # 1. Esperar aggregate()
    # 2. Después convertir el cursor a lista
    cursor = await expenses.aggregate(
        pipeline
    )

    results = await cursor.to_list()

    summary = {
        "numero_gastos": 0,
        "total_gastos": 0.0,
        "transporte": 0.0,
        "publicidad": 0.0,
        "servicios": 0.0,
        "comisiones": 0.0,
        "empaques": 0.0,
        "mantenimiento": 0.0,
        "otros": 0.0,
    }

    known_categories = {
        "transporte",
        "publicidad",
        "servicios",
        "comisiones",
        "empaques",
        "mantenimiento",
    }

    for item in results:
        category = (
            item.get("_id")
            or "otros"
        )

        amount = float(
            item.get(
                "total",
                0,
            )
        )

        count = int(
            item.get(
                "cantidad",
                0,
            )
        )

        summary[
            "numero_gastos"
        ] += count

        summary[
            "total_gastos"
        ] += amount

        if category in known_categories:
            summary[
                category
            ] += amount
        else:
            summary[
                "otros"
            ] += amount

    summary["total_gastos"] = round(
        summary["total_gastos"],
        2,
    )

    for category in known_categories:
        summary[category] = round(
            summary[category],
            2,
        )

    summary["otros"] = round(
        summary["otros"],
        2,
    )

    return summary