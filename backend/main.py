from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import ping_database, close_database
from app.routes.product_routes import router as product_router
from app.repositories.product_repository import seed_products_if_empty
from app.routes.inventory_routes import router as inventory_router
from app.repositories.inventory_repository import create_inventory_indexes
from app.routes.customer_routes import router as customer_router
from app.routes.credit_routes import router as credit_router
from app.repositories.customer_repository import create_customer_indexes
from app.repositories.credit_repository import create_credit_indexes

@asynccontextmanager
async def lifespan(app: FastAPI):
    await ping_database()
    seed_result = await seed_products_if_empty()
    await create_inventory_indexes()
    await create_customer_indexes()
    await create_credit_indexes()

    print("MongoDB conectado correctamente")
    print(f"Seed productos: {seed_result}")

    yield

    await close_database()
    print("Conexión MongoDB cerrada")


app = FastAPI(
    title="Cash Control Business Platform API",
    description="API para conectar la página web de dulces con Cash Control.",
    version="0.4.0",
    lifespan=lifespan
)

origins = [
    "http://localhost",
    "http://localhost:5500",
    "http://127.0.0.1:5500",
    "https://localhost",
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {
        "message": "Cash Control Business Platform API funcionando con MongoDB Atlas",
        "status": "ok",
        "version": "0.4.0"
    }


@app.get("/health")
async def health_check():
    await ping_database()

    return {
        "status": "healthy",
        "service": "products-api",
        "database": "mongodb-atlas"
    }


app.include_router(product_router)
app.include_router(inventory_router)
app.include_router(customer_router)
app.include_router(credit_router)