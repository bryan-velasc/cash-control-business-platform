from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
)

from app.models.supplier_model import (
    SupplierCreate,
    SupplierUpdate,
    SupplierAdmin,
    SupplierSummary,
)

from app.repositories.supplier_repository import (
    create_supplier_in_db,
    get_suppliers_from_db,
    get_supplier_by_id_from_db,
    update_supplier_in_db,
    soft_delete_supplier_in_db,
    get_supplier_summary_from_db,
)

from app.security import verify_admin_token


router = APIRouter(
    prefix="/suppliers",
    tags=["Suppliers"],
)


@router.get(
    "/admin",
    response_model=list[SupplierAdmin],
)
async def get_suppliers(
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await get_suppliers_from_db()


@router.post(
    "/create",
    response_model=SupplierAdmin,
)
async def create_supplier(
    supplier: SupplierCreate,
    _: bool = Depends(
        verify_admin_token
    ),
):
    return await create_supplier_in_db(
        supplier.model_dump()
    )


@router.get(
    "/{supplier_id}",
    response_model=SupplierAdmin,
)
async def get_supplier(
    supplier_id: int,
    _: bool = Depends(
        verify_admin_token
    ),
):
    supplier = await get_supplier_by_id_from_db(
        supplier_id
    )

    if not supplier:
        raise HTTPException(
            status_code=404,
            detail="Proveedor no encontrado",
        )

    return supplier


@router.get(
    "/{supplier_id}/summary",
    response_model=SupplierSummary,
)
async def get_supplier_summary(
    supplier_id: int,
    _: bool = Depends(
        verify_admin_token
    ),
):
    summary = await get_supplier_summary_from_db(
        supplier_id
    )

    if not summary:
        raise HTTPException(
            status_code=404,
            detail="Proveedor no encontrado",
        )

    return summary


@router.put(
    "/update/{supplier_id}",
    response_model=SupplierAdmin,
)
async def update_supplier(
    supplier_id: int,
    supplier: SupplierUpdate,
    _: bool = Depends(
        verify_admin_token
    ),
):
    updated_supplier = await update_supplier_in_db(
        supplier_id,
        supplier.model_dump(),
    )

    if not updated_supplier:
        raise HTTPException(
            status_code=404,
            detail="Proveedor no encontrado",
        )

    return updated_supplier


@router.delete(
    "/delete/{supplier_id}",
)
async def delete_supplier(
    supplier_id: int,
    _: bool = Depends(
        verify_admin_token
    ),
):
    deleted = await soft_delete_supplier_in_db(
        supplier_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Proveedor no encontrado",
        )

    return {
        "message": "Proveedor desactivado correctamente",
        "supplier_id": supplier_id,
    }