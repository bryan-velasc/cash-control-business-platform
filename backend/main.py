import os

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import (
    ping_database,
    close_database,
)

from app.routes.product_routes import (
    router as product_router,
)

from app.routes.inventory_routes import (
    router as inventory_router,
)

from app.routes.customer_routes import (
    router as customer_router,
)

from app.routes.credit_routes import (
    router as credit_router,
)

from app.routes.sale_routes import (
    router as sale_router,
)

from app.routes.supplier_routes import (
    router as supplier_router,
)

from app.routes.purchase_routes import (
    router as purchase_router,
)

from app.routes.expense_routes import (
    router as expense_router,
)

from app.routes.business_finance_routes import (
    router as business_finance_router,
)

from app.repositories.product_repository import (
    seed_products_if_empty,
)

from app.repositories.inventory_repository import (
    create_inventory_indexes,
)

from app.repositories.customer_repository import (
    create_customer_indexes,
)

from app.repositories.credit_repository import (
    create_credit_indexes,
)

from app.repositories.sale_repository import (
    create_sales_indexes,
)

from app.repositories.supplier_repository import (
    create_supplier_indexes,
)

from app.repositories.purchase_repository import (
    create_purchase_indexes,
)

from app.repositories.expense_repository import (
    create_expense_indexes,
)


# ==========================================================
# CONFIGURACIÓN GENERAL
# ==========================================================

APP_VERSION = "1.0.0"

ENVIRONMENT = os.getenv(
    "ENVIRONMENT",
    "development",
)

ALLOWED_ORIGINS_ENV = os.getenv(
    "ALLOWED_ORIGINS",
    (
        "http://localhost:5500,"
        "http://127.0.0.1:5500,"
        "http://localhost:3000,"
        "http://127.0.0.1:3000"
    ),
)

ALLOWED_ORIGINS = [
    origin.strip()
    for origin in ALLOWED_ORIGINS_ENV.split(",")
    if origin.strip()
]


# ==========================================================
# LIFESPAN
# ==========================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    print(
        f"Iniciando Cash Control Business API "
        f"v{APP_VERSION}"
    )

    print(
        f"Entorno: {ENVIRONMENT}"
    )

    # ------------------------------------------------------
    # Verificar MongoDB
    # ------------------------------------------------------

    await ping_database()

    print(
        "MongoDB conectado correctamente"
    )

    # ------------------------------------------------------
    # Semilla inicial
    # ------------------------------------------------------

    seed_result = (
        await seed_products_if_empty()
    )

    print(
        f"Seed productos: {seed_result}"
    )

    # ------------------------------------------------------
    # Crear índices
    # ------------------------------------------------------

    await create_inventory_indexes()

    print(
        "Índices de inventario creados"
    )

    await create_customer_indexes()

    print(
        "Índices de clientes creados"
    )

    await create_credit_indexes()

    print(
        "Índices de créditos creados"
    )

    await create_sales_indexes()

    print(
        "Índices de ventas creados"
    )

    await create_supplier_indexes()

    print(
        "Índices de proveedores creados"
    )

    await create_purchase_indexes()

    print(
        "Índices de compras creados"
    )

    await create_expense_indexes()

    print(
        "Índices de gastos creados"
    )

    print(
        "Dashboard financiero disponible"
    )

    print(
        "Cash Control Business API lista"
    )

    yield

    # ------------------------------------------------------
    # Cierre
    # ------------------------------------------------------

    await close_database()

    print(
        "Conexión MongoDB cerrada"
    )


# ==========================================================
# FASTAPI
# ==========================================================

app = FastAPI(
    title=(
        "Cash Control Business Platform API"
    ),
    description=(
        "API de Cash Control para administrar "
        "productos, inventario, clientes, "
        "fiados, ventas, proveedores, compras, "
        "gastos y analítica financiera."
    ),
    version=APP_VERSION,
    lifespan=lifespan,
)


# ==========================================================
# CORS
# ==========================================================
#
# DESARROLLO:
#
# ALLOWED_ORIGINS=
# http://localhost:5500,
# http://127.0.0.1:5500
#
#
# PRODUCCIÓN:
#
# ALLOWED_ORIGINS=
# https://tu-web.netlify.app,
# https://tudominio.com
#
#
# IMPORTANTE:
#
# Ya no usamos:
#
# allow_origins=["*"]
#
# para evitar exponer innecesariamente
# el backend a cualquier origen.
#
# ==========================================================

app.add_middleware(
    CORSMiddleware,

    allow_origins=ALLOWED_ORIGINS,

    allow_credentials=False,

    allow_methods=[
        "GET",
        "POST",
        "PUT",
        "PATCH",
        "DELETE",
        "OPTIONS",
    ],

    allow_headers=[
        "Content-Type",
        "x-admin-token",
    ],
)


# ==========================================================
# ENDPOINT PRINCIPAL
# ==========================================================

@app.get("/")
async def root():
    return {
        "message": (
            "Cash Control Business Platform API"
        ),

        "status": "ok",

        "version": APP_VERSION,

        "environment": ENVIRONMENT,

        "database": "mongodb-atlas",

        "modules": [
            "products",
            "inventory",
            "customers",
            "credits",
            "sales",
            "suppliers",
            "purchases",
            "expenses",
            "business-finance",
        ],
    }


# ==========================================================
# HEALTH CHECK
# ==========================================================

@app.get("/health")
async def health_check():
    await ping_database()

    return {
        "status": "healthy",

        "service": (
            "cash-control-business-api"
        ),

        "database": (
            "mongodb-atlas"
        ),

        "version": APP_VERSION,

        "environment": ENVIRONMENT,
    }


# ==========================================================
# ROUTERS
# ==========================================================

app.include_router(
    product_router
)

app.include_router(
    inventory_router
)

app.include_router(
    customer_router
)

app.include_router(
    credit_router
)

app.include_router(
    sale_router
)

app.include_router(
    supplier_router
)

app.include_router(
    purchase_router
)

app.include_router(
    expense_router
)

app.include_router(
    business_finance_router
)