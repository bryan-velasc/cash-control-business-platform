from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
)

from app.models.purchase_model import (
    PurchaseCreate,
    PurchaseAdmin,
    PurchaseSummary,
)

from app.repositories.purchase_repository import (
    create_purchase_in_db,
    get_purchases_from_db,
    get_purchase_by_id_from_db,
    get_purchases_by_supplier_from_db,
    get_purchase_summary_from_db,
)

from app.security import verify_admin_token


router = APIRouter(
    prefix="/purchases",
    tags=["Purchases"],
)


@router.get(
    "/admin",
    response_model=list[PurchaseAdmin],
)
async def get_purchases(
    limit: int = Query(
        100,
        ge=1,
        le=500,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_purchases_from_db(
        limit=limit,
    )


@router.get(
    "/summary",
    response_model=PurchaseSummary,
)
async def get_purchase_summary(
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_purchase_summary_from_db()


@router.get(
    "/supplier/{supplier_id}",
    response_model=list[PurchaseAdmin],
)
async def get_supplier_purchases(
    supplier_id: int,
    limit: int = Query(
        100,
        ge=1,
        le=500,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_purchases_by_supplier_from_db(
        supplier_id,
        limit,
    )


@router.post(
    "/create",
    response_model=PurchaseAdmin,
)
async def create_purchase(
    purchase: PurchaseCreate,
    _: bool = Depends(
        verify_admin_token
    ),
):
    try:
        return await create_purchase_in_db(
            purchase.model_dump()
        )

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.get(
    "/{purchase_id}",
    response_model=PurchaseAdmin,
)
async def get_purchase(
    purchase_id: str,
    _: bool = Depends(
        verify_admin_token
    ),
):
    purchase = await get_purchase_by_id_from_db(
        purchase_id
    )

    if not purchase:
        raise HTTPException(
            status_code=404,
            detail="Compra no encontrada",
        )

    return purchase