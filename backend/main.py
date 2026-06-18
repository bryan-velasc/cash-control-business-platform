from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.product_routes import router as product_router

app = FastAPI(
    title="Cash Control Business Platform API",
    description="API para conectar la página web de dulces con Cash Control.",
    version="0.1.0"
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
        "message": "Cash Control Business Platform API funcionando",
        "status": "ok",
        "version": "0.1.0"
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "products-api"
    }


app.include_router(product_router)