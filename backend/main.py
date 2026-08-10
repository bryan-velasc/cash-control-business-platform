from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import ping_database, close_database

from app.routes.product_routes import router as product_router
from app.routes.inventory_routes import router as inventory_router
from app.routes.customer_routes import router as customer_router
from app.routes.credit_routes import router as credit_router
from app.routes.sale_routes import router as sale_router

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


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Verificar conexión con MongoDB
    await ping_database()

    # Semilla inicial de productos
    seed_result = await seed_products_if_empty()

    # Crear índices
    await create_inventory_indexes()
    await create_customer_indexes()
    await create_credit_indexes()
    await create_sales_indexes()

    print("MongoDB conectado correctamente")
    print(f"Seed productos: {seed_result}")
    print("Índices de inventario creados")
    print("Índices de clientes creados")
    print("Índices de créditos creados")
    print("Índices de ventas creados")

    yield

    await close_database()

    print("Conexión MongoDB cerrada")


app = FastAPI(
    title="Cash Control Business Platform API",
    description=(
        "API para conectar la página web de dulces "
        "con Cash Control."
    ),
    version="0.5.0",
    lifespan=lifespan,
)


# ==========================================================
# CORS
# ==========================================================
#
# DESARROLLO LOCAL:
# Flutter Web normalmente usa un puerto dinámico.
# Por eso permitimos cualquier origen temporalmente.
#
# IMPORTANTE:
# Antes de producción cambia esta configuración
# por los dominios reales autorizados.
# ==========================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==========================================================
# ENDPOINT PRINCIPAL
# ==========================================================

@app.get("/")
async def root():
    return {
        "message": (
            "Cash Control Business Platform API "
            "funcionando con MongoDB Atlas"
        ),
        "status": "ok",
        "version": "0.5.0",
        "environment": "development",
        "modules": [
            "products",
            "inventory",
            "customers",
            "credits",
            "sales",
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
        "service": "cash-control-business-api",
        "database": "mongodb-atlas",
        "version": "0.5.0",
        "environment": "development",
    }


# ==========================================================
# ROUTERS
# ==========================================================

app.include_router(product_router)
app.include_router(inventory_router)
app.include_router(customer_router)
app.include_router(credit_router)
app.include_router(sale_router)