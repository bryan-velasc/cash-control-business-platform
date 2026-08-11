from fastapi import APIRouter, HTTPException, Query, status

from app.models.expense_model import (
    ExpenseCreate,
    ExpenseUpdate,
    ExpenseResponse,
    ExpenseSummary,
)

from app.repositories.expense_repository import (
    create_expense_in_db,
    get_expenses_from_db,
    get_expense_by_id_from_db,
    update_expense_in_db,
    delete_expense_from_db,
    get_expense_summary_from_db,
)


router = APIRouter(
    prefix="/expenses",
    tags=["Expenses"],
)


@router.post(
    "/create",
    response_model=ExpenseResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_expense(
    expense: ExpenseCreate,
):
    return await create_expense_in_db(
        expense.model_dump()
    )


@router.get(
    "/admin",
    response_model=list[ExpenseResponse],
)
async def get_expenses(
    limit: int = Query(
        default=100,
        ge=1,
        le=1000,
    ),
    categoria: str | None = None,
):
    return await get_expenses_from_db(
        limit=limit,
        categoria=categoria,
    )


@router.get(
    "/summary",
    response_model=ExpenseSummary,
)
async def get_expense_summary():
    return await get_expense_summary_from_db()


@router.get(
    "/{expense_id}",
    response_model=ExpenseResponse,
)
async def get_expense(
    expense_id: str,
):
    expense = await get_expense_by_id_from_db(
        expense_id
    )

    if not expense:
        raise HTTPException(
            status_code=404,
            detail="Gasto no encontrado",
        )

    return expense


@router.put(
    "/update/{expense_id}",
    response_model=ExpenseResponse,
)
async def update_expense(
    expense_id: str,
    expense: ExpenseUpdate,
):
    updated = await update_expense_in_db(
        expense_id,
        expense.model_dump(
            exclude_unset=True
        ),
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Gasto no encontrado",
        )

    return updated


@router.delete(
    "/delete/{expense_id}",
)
async def delete_expense(
    expense_id: str,
):
    deleted = await delete_expense_from_db(
        expense_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Gasto no encontrado",
        )

    return {
        "message": "Gasto eliminado correctamente",
        "expense_id": expense_id,
    }