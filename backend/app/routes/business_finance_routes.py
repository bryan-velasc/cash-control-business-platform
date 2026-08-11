from datetime import datetime
from typing import Literal, Optional

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
)

from app.models.business_finance_model import (
    BusinessFinanceSummary,
    FinanceTimelineResponse,
    TopProductsResponse,
)

from app.repositories.business_finance_repository import (
    get_business_finance_summary_from_db,
    get_business_finance_timeline_from_db,
    get_top_products_from_db,
)

from app.security import verify_admin_token


PeriodType = Literal[
    "today",
    "week",
    "month",
    "custom",
    "all",
]

GroupType = Literal[
    "day",
    "week",
    "month",
]


router = APIRouter(
    prefix="/business-finance",
    tags=["Business Finance"],
)


def _validate_custom_period(
    period: str,
    date_from: Optional[datetime],
    date_to: Optional[datetime],
):
    if period != "custom":
        return

    if date_from is None or date_to is None:
        raise HTTPException(
            status_code=400,
            detail=(
                "Para period=custom debes enviar "
                "date_from y date_to"
            ),
        )

    if date_from > date_to:
        raise HTTPException(
            status_code=400,
            detail=(
                "date_from no puede ser mayor "
                "que date_to"
            ),
        )


@router.get(
    "/summary",
    response_model=BusinessFinanceSummary,
)
async def get_business_finance_summary(
    period: PeriodType = Query(
        default="all",
    ),
    date_from: Optional[datetime] = Query(
        default=None,
    ),
    date_to: Optional[datetime] = Query(
        default=None,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    _validate_custom_period(
        period,
        date_from,
        date_to,
    )

    return await get_business_finance_summary_from_db(
        period=period,
        date_from=date_from,
        date_to=date_to,
    )


@router.get(
    "/timeline",
    response_model=FinanceTimelineResponse,
)
async def get_business_finance_timeline(
    period: PeriodType = Query(
        default="month",
    ),
    group_by: GroupType = Query(
        default="day",
    ),
    date_from: Optional[datetime] = Query(
        default=None,
    ),
    date_to: Optional[datetime] = Query(
        default=None,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    _validate_custom_period(
        period,
        date_from,
        date_to,
    )

    return await get_business_finance_timeline_from_db(
        period=period,
        group_by=group_by,
        date_from=date_from,
        date_to=date_to,
    )


@router.get(
    "/top-products",
    response_model=TopProductsResponse,
)
async def get_top_products(
    period: PeriodType = Query(
        default="all",
    ),
    limit: int = Query(
        default=10,
        ge=1,
        le=50,
    ),
    date_from: Optional[datetime] = Query(
        default=None,
    ),
    date_to: Optional[datetime] = Query(
        default=None,
    ),
    _: bool = Depends(
        verify_admin_token
    ),
):
    _validate_custom_period(
        period,
        date_from,
        date_to,
    )

    return await get_top_products_from_db(
        period=period,
        limit=limit,
        date_from=date_from,
        date_to=date_to,
    )