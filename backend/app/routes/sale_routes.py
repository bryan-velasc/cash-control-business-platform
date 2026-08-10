from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
)

from app.models.sale_model import (
    SaleCreate,
    SaleAdmin,
    SalesSummary,
)

from app.repositories.sale_repository import (
    create_sale_in_db,
    get_sales_from_db,
    get_sale_by_id_from_db,
    get_sales_summary_from_db,
)

from app.security import (
    verify_admin_token,
)


router = APIRouter(
    prefix="/sales",
    tags=["Sales"],
)


@router.get(
    "/admin",
    response_model=list[SaleAdmin],
)
async def get_sales(
    limit: int = Query(
        100,
        ge=1,
        le=500,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_sales_from_db(
        limit=limit,
    )


@router.get(
    "/summary",
    response_model=SalesSummary,
)
async def get_sales_summary(
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_sales_summary_from_db()


@router.post(
    "/create",
    response_model=SaleAdmin,
)
async def create_sale(
    sale: SaleCreate,
    _: bool = Depends(
        verify_admin_token
    ),
):
    try:

        return await create_sale_in_db(
            sale.model_dump()
        )

    except ValueError as error:

        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.get(
    "/{sale_id}",
    response_model=SaleAdmin,
)
async def get_sale(
    sale_id: str,
    _: bool = Depends(
        verify_admin_token
    ),
):

    sale = await get_sale_by_id_from_db(
        sale_id
    )

    if not sale:

        raise HTTPException(
            status_code=404,
            detail="Venta no encontrada",
        )

    return sale