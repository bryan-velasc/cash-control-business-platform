import os

from dotenv import load_dotenv
from pymongo import AsyncMongoClient
from pymongo.errors import PyMongoError


load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "cash_control_business")


if not MONGODB_URI:
    raise RuntimeError(
        "Falta MONGODB_URI. Crea backend/.env y agrega tu cadena de conexión de MongoDB Atlas."
    )


client = AsyncMongoClient(
    MONGODB_URI,
    serverSelectionTimeoutMS=5000
)

database = client[MONGODB_DB_NAME]


def get_database():
    return database


async def ping_database():
    try:
        await client.admin.command("ping")
        return True
    except PyMongoError as error:
        raise RuntimeError(f"No se pudo conectar con MongoDB Atlas: {error}")


async def close_database():
    await client.close()
    