from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.models.customer_model import (
    CustomerCreate,
    CustomerUpdate,
    CustomerAdmin,
    CustomerSummary
)
from app.models.credit_model import ApiMessage
from app.repositories.customer_repository import (
    create_customer_in_db,
    get_customers_from_db,
    get_customer_by_id_from_db,
    update_customer_in_db,
    soft_delete_customer_in_db,
    get_customer_summary_from_db
)
from app.security import verify_admin_token


router = APIRouter(
    prefix="/customers",
    tags=["Customers"]
)


@router.get("/admin", response_model=List[CustomerAdmin])
async def get_customers(_: bool = Depends(verify_admin_token)):
    return await get_customers_from_db()


@router.post("/create", response_model=CustomerAdmin)
async def create_customer(
    customer: CustomerCreate,
    _: bool = Depends(verify_admin_token)
):
    return await create_customer_in_db(customer.model_dump())


@router.get("/{customer_id}", response_model=CustomerAdmin)
async def get_customer(
    customer_id: int,
    _: bool = Depends(verify_admin_token)
):
    customer = await get_customer_by_id_from_db(customer_id)

    if not customer:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")

    return customer


@router.get("/{customer_id}/summary", response_model=CustomerSummary)
async def get_customer_summary(
    customer_id: int,
    _: bool = Depends(verify_admin_token)
):
    summary = await get_customer_summary_from_db(customer_id)

    if not summary:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")

    return summary


@router.put("/update/{customer_id}", response_model=CustomerAdmin)
async def update_customer(
    customer_id: int,
    customer: CustomerUpdate,
    _: bool = Depends(verify_admin_token)
):
    updated_customer = await update_customer_in_db(
        customer_id,
        customer.model_dump()
    )

    if not updated_customer:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")

    return updated_customer


@router.delete("/delete/{customer_id}", response_model=ApiMessage)
async def delete_customer(
    customer_id: int,
    _: bool = Depends(verify_admin_token)
):
    deleted = await soft_delete_customer_in_db(customer_id)

    if not deleted:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")

    return {
        "message": "Cliente desactivado correctamente",
        "customer_id": customer_id
    }