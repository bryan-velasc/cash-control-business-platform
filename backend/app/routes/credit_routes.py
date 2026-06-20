from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.models.credit_model import (
    CreditCreate,
    CreditUpdate,
    CreditAdmin,
    CreditPaymentCreate,
    CreditPayment,
    CreditPaymentsResponse,
    ApiMessage
)
from app.repositories.credit_repository import (
    create_credit_in_db,
    get_credits_from_db,
    get_credit_by_id_from_db,
    get_customer_credits_from_db,
    update_credit_in_db,
    register_credit_payment_in_db,
    get_credit_payments_from_db,
    cancel_credit_in_db
)
from app.security import verify_admin_token


router = APIRouter(
    prefix="/credits",
    tags=["Credits"]
)


@router.get("/admin", response_model=List[CreditAdmin])
async def get_credits(_: bool = Depends(verify_admin_token)):
    return await get_credits_from_db()


@router.post("/create", response_model=CreditAdmin)
async def create_credit(
    credit: CreditCreate,
    _: bool = Depends(verify_admin_token)
):
    new_credit = await create_credit_in_db(credit.model_dump(mode="json"))

    if not new_credit:
        raise HTTPException(status_code=404, detail="Cliente no encontrado o inactivo")

    return new_credit


@router.get("/customer/{customer_id}", response_model=List[CreditAdmin])
async def get_customer_credits(
    customer_id: int,
    _: bool = Depends(verify_admin_token)
):
    return await get_customer_credits_from_db(customer_id)


@router.get("/payments/{credit_id}", response_model=CreditPaymentsResponse)
async def get_credit_payments(
    credit_id: int,
    _: bool = Depends(verify_admin_token)
):
    return await get_credit_payments_from_db(credit_id)


@router.post("/pay/{credit_id}", response_model=CreditPayment)
async def register_credit_payment(
    credit_id: int,
    payment: CreditPaymentCreate,
    _: bool = Depends(verify_admin_token)
):
    try:
        new_payment = await register_credit_payment_in_db(
            credit_id,
            payment.model_dump()
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))

    if not new_payment:
        raise HTTPException(status_code=404, detail="Fiado no encontrado")

    return new_payment


@router.put("/update/{credit_id}", response_model=CreditAdmin)
async def update_credit(
    credit_id: int,
    credit: CreditUpdate,
    _: bool = Depends(verify_admin_token)
):
    updated_credit = await update_credit_in_db(
    credit_id,
    credit.model_dump(mode="json")
)

    if not updated_credit:
        raise HTTPException(status_code=404, detail="Fiado no encontrado")

    return updated_credit


@router.delete("/cancel/{credit_id}", response_model=ApiMessage)
async def cancel_credit(
    credit_id: int,
    _: bool = Depends(verify_admin_token)
):
    cancelled = await cancel_credit_in_db(credit_id)

    if not cancelled:
        raise HTTPException(status_code=404, detail="Fiado no encontrado")

    return {
        "message": "Fiado cancelado correctamente",
        "credit_id": credit_id
    }


@router.get("/{credit_id}", response_model=CreditAdmin)
async def get_credit(
    credit_id: int,
    _: bool = Depends(verify_admin_token)
):
    credit = await get_credit_by_id_from_db(credit_id)

    if not credit:
        raise HTTPException(status_code=404, detail="Fiado no encontrado")

    return credit