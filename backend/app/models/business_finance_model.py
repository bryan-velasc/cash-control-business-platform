from pydantic import BaseModel


class BusinessFinanceSummary(BaseModel):
    total_ventas: float
    costo_mercancia_vendida: float
    utilidad_bruta: float

    total_gastos: float
    utilidad_neta: float

    total_reinversion: float
    cuentas_por_cobrar: float

    valor_inventario_costo: float
    valor_inventario_venta: float

    roi: float
    margen_bruto: float
    margen_neto: float

    numero_ventas: int
    numero_compras: int
    numero_gastos: int

    productos_activos: int
    unidades_inventario: int


class FinanceTimelinePoint(BaseModel):
    periodo: str

    ventas: float
    costo_mercancia: float
    utilidad_bruta: float

    gastos: float
    utilidad_neta: float

    reinversion: float

    numero_ventas: int
    numero_gastos: int
    numero_compras: int


class FinanceTimelineResponse(BaseModel):
    period: str
    group_by: str

    total_puntos: int

    puntos: list[FinanceTimelinePoint]


class TopProduct(BaseModel):
    product_id: int
    nombre: str

    unidades_vendidas: int
    ventas: float

    costo: float
    utilidad_bruta: float


class TopProductsResponse(BaseModel):
    total: int
    productos: list[TopProduct]