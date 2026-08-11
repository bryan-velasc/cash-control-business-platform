from datetime import datetime, timedelta, timezone
from typing import Optional

from app.database import get_database


SALES_COLLECTION = "sales"
PURCHASES_COLLECTION = "purchases"
EXPENSES_COLLECTION = "expenses"
CREDITS_COLLECTION = "credits"
PRODUCTS_COLLECTION = "products"


def get_sales_collection():
    db = get_database()
    return db[SALES_COLLECTION]


def get_purchases_collection():
    db = get_database()
    return db[PURCHASES_COLLECTION]


def get_expenses_collection():
    db = get_database()
    return db[EXPENSES_COLLECTION]


def get_credits_collection():
    db = get_database()
    return db[CREDITS_COLLECTION]


def get_products_collection():
    db = get_database()
    return db[PRODUCTS_COLLECTION]


def _normalize_datetime(
    value: datetime,
) -> datetime:
    if value.tzinfo is None:
        return value.replace(
            tzinfo=timezone.utc
        )

    return value.astimezone(
        timezone.utc
    )


def _get_period_range(
    period: str,
    date_from: Optional[datetime],
    date_to: Optional[datetime],
) -> tuple[
    Optional[datetime],
    Optional[datetime],
]:
    now = datetime.now(
        timezone.utc
    )

    if period == "all":
        return None, None

    if period == "today":
        start = datetime(
            year=now.year,
            month=now.month,
            day=now.day,
            tzinfo=timezone.utc,
        )

        end = start + timedelta(
            days=1
        )

        return start, end

    if period == "week":
        start_today = datetime(
            year=now.year,
            month=now.month,
            day=now.day,
            tzinfo=timezone.utc,
        )

        start = start_today - timedelta(
            days=start_today.weekday()
        )

        end = start + timedelta(
            days=7
        )

        return start, end

    if period == "month":
        start = datetime(
            year=now.year,
            month=now.month,
            day=1,
            tzinfo=timezone.utc,
        )

        if now.month == 12:
            end = datetime(
                year=now.year + 1,
                month=1,
                day=1,
                tzinfo=timezone.utc,
            )
        else:
            end = datetime(
                year=now.year,
                month=now.month + 1,
                day=1,
                tzinfo=timezone.utc,
            )

        return start, end

    if period == "custom":
        if date_from is None or date_to is None:
            return None, None

        start = _normalize_datetime(
            date_from
        )

        end = _normalize_datetime(
            date_to
        )

        return start, end

    return None, None


def _build_date_query(
    start: Optional[datetime],
    end: Optional[datetime],
) -> dict:
    if start is None or end is None:
        return {}

    return {
        "created_at": {
            "$gte": start,
            "$lt": end,
        }
    }


async def get_business_finance_summary_from_db(
    period: str = "all",
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
) -> dict:
    sales = get_sales_collection()
    purchases = get_purchases_collection()
    expenses = get_expenses_collection()
    credits = get_credits_collection()
    products = get_products_collection()

    start, end = _get_period_range(
        period,
        date_from,
        date_to,
    )

    date_query = _build_date_query(
        start,
        end,
    )

    # ======================================================
    # VENTAS
    # ======================================================

    sales_query = {
        "estado": "completada",
        **date_query,
    }

    sale_list = await sales.find(
        sales_query,
        {
            "_id": 0,
        },
    ).to_list(None)

    total_ventas = 0.0
    costo_mercancia_vendida = 0.0

    for sale in sale_list:
        total_ventas += float(
            sale.get(
                "total",
                0,
            )
        )

        costo_mercancia_vendida += float(
            sale.get(
                "costo_total",
                0,
            )
        )

    utilidad_bruta = (
        total_ventas
        - costo_mercancia_vendida
    )

    # ======================================================
    # GASTOS
    # ======================================================

    expenses_query = {
        "activo": True,
        **date_query,
    }

    expense_list = await expenses.find(
        expenses_query,
        {
            "_id": 0,
        },
    ).to_list(None)

    total_gastos = sum(
        float(
            expense.get(
                "monto",
                0,
            )
        )
        for expense in expense_list
    )

    utilidad_neta = (
        utilidad_bruta
        - total_gastos
    )

    # ======================================================
    # COMPRAS / REINVERSIÓN
    # ======================================================

    purchases_query = {
        "estado": {
            "$ne": "cancelada",
        },
        **date_query,
    }

    purchase_list = await purchases.find(
        purchases_query,
        {
            "_id": 0,
        },
    ).to_list(None)

    total_reinversion = sum(
        float(
            purchase.get(
                "total",
                0,
            )
        )
        for purchase in purchase_list
    )

    # ======================================================
    # CUENTAS POR COBRAR
    # ======================================================
    #
    # Se deja como saldo ACTUAL, no filtrado por fecha.
    # Así el dashboard muestra lo que realmente deben hoy.
    # ======================================================

    credit_list = await credits.find(
        {
            "activo": True,
            "estado": {
                "$in": [
                    "pendiente",
                    "parcial",
                    "vencido",
                ]
            },
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    cuentas_por_cobrar = sum(
        float(
            credit.get(
                "saldo_pendiente",
                0,
            )
        )
        for credit in credit_list
    )

    # ======================================================
    # INVENTARIO
    # ======================================================
    #
    # También es estado ACTUAL y no se filtra por período.
    # ======================================================

    product_list = await products.find(
        {
            "activo": True,
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    valor_inventario_costo = 0.0
    valor_inventario_venta = 0.0
    unidades_inventario = 0

    for product in product_list:
        stock = int(
            product.get(
                "stock",
                0,
            )
        )

        precio_compra = float(
            product.get(
                "precio_compra",
                0,
            )
            or 0
        )

        precio_venta = float(
            product.get(
                "precio",
                0,
            )
            or 0
        )

        unidades_inventario += stock

        valor_inventario_costo += (
            stock * precio_compra
        )

        valor_inventario_venta += (
            stock * precio_venta
        )

    # ======================================================
    # MÁRGENES
    # ======================================================

    if total_ventas > 0:
        margen_bruto = (
            utilidad_bruta
            / total_ventas
        ) * 100

        margen_neto = (
            utilidad_neta
            / total_ventas
        ) * 100
    else:
        margen_bruto = 0.0
        margen_neto = 0.0

    # ======================================================
    # ROI
    # ======================================================

    if total_reinversion > 0:
        roi = (
            utilidad_neta
            / total_reinversion
        ) * 100
    else:
        roi = 0.0

    return {
        "total_ventas": round(
            total_ventas,
            2,
        ),

        "costo_mercancia_vendida": round(
            costo_mercancia_vendida,
            2,
        ),

        "utilidad_bruta": round(
            utilidad_bruta,
            2,
        ),

        "total_gastos": round(
            total_gastos,
            2,
        ),

        "utilidad_neta": round(
            utilidad_neta,
            2,
        ),

        "total_reinversion": round(
            total_reinversion,
            2,
        ),

        "cuentas_por_cobrar": round(
            cuentas_por_cobrar,
            2,
        ),

        "valor_inventario_costo": round(
            valor_inventario_costo,
            2,
        ),

        "valor_inventario_venta": round(
            valor_inventario_venta,
            2,
        ),

        "roi": round(
            roi,
            2,
        ),

        "margen_bruto": round(
            margen_bruto,
            2,
        ),

        "margen_neto": round(
            margen_neto,
            2,
        ),

        "numero_ventas": len(
            sale_list
        ),

        "numero_compras": len(
            purchase_list
        ),

        "numero_gastos": len(
            expense_list
        ),

        "productos_activos": len(
            product_list
        ),

        "unidades_inventario":
            unidades_inventario,
    }

def _timeline_key(
    date: datetime,
    group_by: str,
) -> str:
    date = _normalize_datetime(date)

    if group_by == "month":
        return date.strftime("%Y-%m")

    if group_by == "week":
        iso = date.isocalendar()

        return (
            f"{iso.year}-W"
            f"{iso.week:02d}"
        )

    return date.strftime("%Y-%m-%d")


def _empty_timeline_point() -> dict:
    return {
        "ventas": 0.0,
        "costo_mercancia": 0.0,
        "utilidad_bruta": 0.0,
        "gastos": 0.0,
        "utilidad_neta": 0.0,
        "reinversion": 0.0,
        "numero_ventas": 0,
        "numero_gastos": 0,
        "numero_compras": 0,
    }

async def get_business_finance_timeline_from_db(
    period: str = "month",
    group_by: str = "day",
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
) -> dict:
    sales = get_sales_collection()
    purchases = get_purchases_collection()
    expenses = get_expenses_collection()

    start, end = _get_period_range(
        period,
        date_from,
        date_to,
    )

    date_query = _build_date_query(
        start,
        end,
    )

    # ======================================================
    # VENTAS
    # ======================================================

    sale_list = await sales.find(
        {
            "estado": "completada",
            **date_query,
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    # ======================================================
    # GASTOS
    # ======================================================

    expense_list = await expenses.find(
        {
            "activo": True,
            **date_query,
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    # ======================================================
    # COMPRAS
    # ======================================================

    purchase_list = await purchases.find(
        {
            "estado": {
                "$ne": "cancelada",
            },
            **date_query,
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    timeline = {}

    # ======================================================
    # AGRUPAR VENTAS
    # ======================================================

    for sale in sale_list:
        created_at = sale.get(
            "created_at"
        )

        if not created_at:
            continue

        key = _timeline_key(
            created_at,
            group_by,
        )

        if key not in timeline:
            timeline[key] = (
                _empty_timeline_point()
            )

        total = float(
            sale.get(
                "total",
                0,
            )
        )

        costo = float(
            sale.get(
                "costo_total",
                0,
            )
        )

        timeline[key][
            "ventas"
        ] += total

        timeline[key][
            "costo_mercancia"
        ] += costo

        timeline[key][
            "numero_ventas"
        ] += 1

    # ======================================================
    # AGRUPAR GASTOS
    # ======================================================

    for expense in expense_list:
        created_at = expense.get(
            "created_at"
        )

        if not created_at:
            continue

        key = _timeline_key(
            created_at,
            group_by,
        )

        if key not in timeline:
            timeline[key] = (
                _empty_timeline_point()
            )

        timeline[key][
            "gastos"
        ] += float(
            expense.get(
                "monto",
                0,
            )
        )

        timeline[key][
            "numero_gastos"
        ] += 1

    # ======================================================
    # AGRUPAR COMPRAS
    # ======================================================

    for purchase in purchase_list:
        created_at = purchase.get(
            "created_at"
        )

        if not created_at:
            continue

        key = _timeline_key(
            created_at,
            group_by,
        )

        if key not in timeline:
            timeline[key] = (
                _empty_timeline_point()
            )

        timeline[key][
            "reinversion"
        ] += float(
            purchase.get(
                "total",
                0,
            )
        )

        timeline[key][
            "numero_compras"
        ] += 1

    # ======================================================
    # CALCULAR UTILIDADES
    # ======================================================

    points = []

    for key in sorted(
        timeline.keys()
    ):
        item = timeline[key]

        utilidad_bruta = (
            item["ventas"]
            - item["costo_mercancia"]
        )

        utilidad_neta = (
            utilidad_bruta
            - item["gastos"]
        )

        points.append(
            {
                "periodo": key,

                "ventas": round(
                    item["ventas"],
                    2,
                ),

                "costo_mercancia": round(
                    item[
                        "costo_mercancia"
                    ],
                    2,
                ),

                "utilidad_bruta": round(
                    utilidad_bruta,
                    2,
                ),

                "gastos": round(
                    item["gastos"],
                    2,
                ),

                "utilidad_neta": round(
                    utilidad_neta,
                    2,
                ),

                "reinversion": round(
                    item[
                        "reinversion"
                    ],
                    2,
                ),

                "numero_ventas":
                    item[
                        "numero_ventas"
                    ],

                "numero_gastos":
                    item[
                        "numero_gastos"
                    ],

                "numero_compras":
                    item[
                        "numero_compras"
                    ],
            }
        )

    return {
        "period": period,
        "group_by": group_by,
        "total_puntos": len(
            points
        ),
        "puntos": points,
    }


async def get_top_products_from_db(
    period: str = "all",
    limit: int = 10,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
) -> dict:
    sales = get_sales_collection()

    start, end = _get_period_range(
        period,
        date_from,
        date_to,
    )

    date_query = _build_date_query(
        start,
        end,
    )

    sale_list = await sales.find(
        {
            "estado": "completada",
            **date_query,
        },
        {
            "_id": 0,
        },
    ).to_list(None)

    products = {}

    for sale in sale_list:
        items = sale.get(
            "items",
            [],
        )

        for item in items:
            product_id = int(
                item.get(
                    "product_id",
                    0,
                )
            )

            if product_id <= 0:
                continue

            if product_id not in products:
                products[
                    product_id
                ] = {
                    "product_id":
                        product_id,

                    "nombre":
                        item.get(
                            "producto_nombre",
                            "Producto",
                        ),

                    "unidades_vendidas":
                        0,

                    "ventas":
                        0.0,

                    "costo":
                        0.0,

                    "utilidad_bruta":
                        0.0,
                }

            quantity = int(
                item.get(
                    "cantidad",
                    0,
                )
            )

            subtotal = float(
                item.get(
                    "subtotal",
                    0,
                )
            )

            cost = float(
                item.get(
                    "costo_total",
                    0,
                )
            )

            profit = float(
                item.get(
                    "utilidad_bruta",
                    subtotal - cost,
                )
            )

            products[
                product_id
            ][
                "unidades_vendidas"
            ] += quantity

            products[
                product_id
            ][
                "ventas"
            ] += subtotal

            products[
                product_id
            ][
                "costo"
            ] += cost

            products[
                product_id
            ][
                "utilidad_bruta"
            ] += profit

    results = list(
        products.values()
    )

    results.sort(
        key=lambda product: (
            product[
                "unidades_vendidas"
            ],
            product[
                "ventas"
            ],
        ),
        reverse=True,
    )

    results = results[
        :limit
    ]

    for product in results:
        product["ventas"] = round(
            product["ventas"],
            2,
        )

        product["costo"] = round(
            product["costo"],
            2,
        )

        product[
            "utilidad_bruta"
        ] = round(
            product[
                "utilidad_bruta"
            ],
            2,
        )

    return {
        "total": len(
            results
        ),
        "productos": results,
    }