from datetime import datetime, timezone
from typing import Optional
from uuid import uuid4

from app.database import get_database

from app.repositories.inventory_repository import (
    adjust_product_stock_in_db,
)

from app.repositories.credit_repository import (
    create_credit_in_db,
)


SALES_COLLECTION = "sales"
PRODUCTS_COLLECTION = "products"
CUSTOMERS_COLLECTION = "customers"


def get_sales_collection():
    db = get_database()
    return db[SALES_COLLECTION]


def get_products_collection():
    db = get_database()
    return db[PRODUCTS_COLLECTION]


def get_customers_collection():
    db = get_database()
    return db[CUSTOMERS_COLLECTION]


async def create_sales_indexes():
    sales = get_sales_collection()

    await sales.create_index(
        "sale_id",
        unique=True,
    )

    await sales.create_index(
        "folio",
        unique=True,
    )

    await sales.create_index(
        "customer_id",
    )

    await sales.create_index(
        "metodo_pago",
    )

    await sales.create_index(
        "created_at",
    )

    await sales.create_index(
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

    return f"VTA-{timestamp}-{suffix}"


async def create_sale_in_db(
    sale_data: dict,
) -> dict:

    sales = get_sales_collection()

    products = get_products_collection()

    customers = get_customers_collection()

    items_received = sale_data[
        "items"
    ]

    metodo_pago = sale_data[
        "metodo_pago"
    ]

    customer_id = sale_data.get(
        "customer_id"
    )

    # ------------------------------------
    # 1. VALIDAR CLIENTE
    # ------------------------------------

    customer = None

    if customer_id is not None:

        customer = await customers.find_one(
            {
                "customer_id": customer_id,
                "activo": True,
            },
            {
                "_id": 0,
            },
        )

        if not customer:

            raise ValueError(
                "Cliente no encontrado o inactivo"
            )

    if metodo_pago == "fiado":

        if customer_id is None:

            raise ValueError(
                "Una venta fiada requiere un cliente"
            )

        if not customer:

            raise ValueError(
                "Cliente no encontrado o inactivo"
            )

    # ------------------------------------
    # 2. AGRUPAR PRODUCTOS REPETIDOS
    # ------------------------------------

    quantities = {}

    for item in items_received:

        product_id = int(
            item["product_id"]
        )

        cantidad = int(
            item["cantidad"]
        )

        if cantidad <= 0:

            raise ValueError(
                "La cantidad debe ser mayor a cero"
            )

        quantities[
            product_id
        ] = (
            quantities.get(
                product_id,
                0,
            )
            + cantidad
        )

    # ------------------------------------
    # 3. VALIDAR PRODUCTOS Y STOCK
    # ------------------------------------

    sale_items = []

    total = 0.0

    costo_total = 0.0

    utilidad_total = 0.0

    validated_products = []

    for product_id, cantidad in quantities.items():

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

        stock_actual = int(
            product.get(
                "stock",
                0,
            )
        )

        if cantidad > stock_actual:

            raise ValueError(
                (
                    f"Stock insuficiente para "
                    f"{product.get('nombre', 'producto')}. "
                    f"Disponible: {stock_actual}, "
                    f"solicitado: {cantidad}"
                )
            )

        precio = float(
            product.get(
                "precio",
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

        subtotal = round(
            precio * cantidad,
            2,
        )

        costo = round(
            precio_compra
            * cantidad,
            2,
        )

        utilidad = round(
            subtotal - costo,
            2,
        )

        total += subtotal

        costo_total += costo

        utilidad_total += utilidad

        sale_item = {
            "product_id": product_id,

            "producto_nombre":
                product.get(
                    "nombre",
                    "Producto",
                ),

            "cantidad": cantidad,

            "precio_unitario":
                precio,

            "precio_compra_unitario":
                precio_compra,

            "subtotal":
                subtotal,

            "costo_total":
                costo,

            "utilidad_bruta":
                utilidad,
        }

        sale_items.append(
            sale_item
        )

        validated_products.append(
            {
                "product_id":
                    product_id,

                "cantidad":
                    cantidad,
            }
        )

    total = round(
        total,
        2,
    )

    costo_total = round(
        costo_total,
        2,
    )

    utilidad_total = round(
        utilidad_total,
        2,
    )

    # ------------------------------------
    # 4. GENERAR ID Y FOLIO
    # ------------------------------------

    sale_id = str(
        uuid4()
    )

    folio = _generate_folio()

    # ------------------------------------
    # 5. SI ES FIADO CREAR CRÉDITO
    # ------------------------------------

    credit_id = None

    if metodo_pago == "fiado":

        credit = await create_credit_in_db(
            {
                "customer_id":
                    customer_id,

                "concepto":
                    f"Venta {folio}",

                "monto_total":
                    total,

                "fecha_limite":
                    None,

                "notas":
                    sale_data.get(
                        "notas"
                    ),

                "usuario":
                    sale_data.get(
                        "usuario"
                    )
                    or "admin",
            }
        )

        if not credit:

            raise ValueError(
                "No se pudo crear el fiado"
            )

        credit_id = credit[
            "credit_id"
        ]

    # ------------------------------------
    # 6. DESCONTAR INVENTARIO
    # ------------------------------------

    for product_data in validated_products:

        await adjust_product_stock_in_db(
            product_data[
                "product_id"
            ],
            {
                "tipo":
                    "salida",

                "cantidad":
                    product_data[
                        "cantidad"
                    ],

                "motivo":
                    "Venta",

                "usuario":
                    sale_data.get(
                        "usuario"
                    )
                    or "admin",

                "referencia":
                    folio,
            },
        )

    # ------------------------------------
    # 7. GUARDAR VENTA
    # ------------------------------------

    now = datetime.now(
        timezone.utc,
    )

    sale = {
        "sale_id":
            sale_id,

        "folio":
            folio,

        "customer_id":
            customer_id,

        "customer_nombre":
            (
                customer.get(
                    "nombre"
                )
                if customer
                else None
            ),

        "items":
            sale_items,

        "total":
            total,

        "costo_total":
            costo_total,

        "utilidad_bruta":
            utilidad_total,

        "metodo_pago":
            metodo_pago,

        "credit_id":
            credit_id,

        "notas":
            sale_data.get(
                "notas"
            ),

        "usuario":
            sale_data.get(
                "usuario"
            )
            or "admin",

        "estado":
            "completada",

        "created_at":
            now,
    }

    await sales.insert_one(
        sale
    )

    sale.pop(
        "_id",
        None,
    )

    return sale


async def get_sales_from_db(
    limit: int = 100,
) -> list[dict]:

    sales = get_sales_collection()

    cursor = sales.find(
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


async def get_sale_by_id_from_db(
    sale_id: str,
) -> Optional[dict]:

    sales = get_sales_collection()

    return await sales.find_one(
        {
            "sale_id":
                sale_id,
        },
        {
            "_id": 0,
        },
    )


async def get_sales_summary_from_db() -> dict:

    sales = get_sales_collection()

    cursor = sales.find(
        {
            "estado":
                "completada",
        },
        {
            "_id": 0,
        },
    )

    sale_list = await cursor.to_list(
        None
    )

    total_ventas = 0.0

    total_costo = 0.0

    utilidad_bruta = 0.0

    efectivo = 0.0

    transferencia = 0.0

    tarjeta = 0.0

    fiado = 0.0

    for sale in sale_list:

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

        utilidad = float(
            sale.get(
                "utilidad_bruta",
                0,
            )
        )

        total_ventas += total

        total_costo += costo

        utilidad_bruta += utilidad

        metodo = sale.get(
            "metodo_pago"
        )

        if metodo == "efectivo":

            efectivo += total

        elif metodo == "transferencia":

            transferencia += total

        elif metodo == "tarjeta":

            tarjeta += total

        elif metodo == "fiado":

            fiado += total

    return {
        "total_ventas":
            round(
                total_ventas,
                2,
            ),

        "total_costo":
            round(
                total_costo,
                2,
            ),

        "utilidad_bruta":
            round(
                utilidad_bruta,
                2,
            ),

        "numero_ventas":
            len(
                sale_list
            ),

        "efectivo":
            round(
                efectivo,
                2,
            ),

        "transferencia":
            round(
                transferencia,
                2,
            ),

        "tarjeta":
            round(
                tarjeta,
                2,
            ),

        "fiado":
            round(
                fiado,
                2,
            ),
    }