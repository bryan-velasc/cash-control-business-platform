class BusinessFinanceModel {
  final double totalVentas;
  final double costoMercanciaVendida;
  final double utilidadBruta;
  final double totalGastos;
  final double utilidadNeta;
  final double totalReinversion;
  final double cuentasPorCobrar;
  final double valorInventarioCosto;
  final double valorInventarioVenta;

  final double roi;
  final double margenBruto;
  final double margenNeto;

  final int numeroVentas;
  final int numeroCompras;
  final int numeroGastos;
  final int productosActivos;
  final int unidadesInventario;

  const BusinessFinanceModel({
    required this.totalVentas,
    required this.costoMercanciaVendida,
    required this.utilidadBruta,
    required this.totalGastos,
    required this.utilidadNeta,
    required this.totalReinversion,
    required this.cuentasPorCobrar,
    required this.valorInventarioCosto,
    required this.valorInventarioVenta,
    required this.roi,
    required this.margenBruto,
    required this.margenNeto,
    required this.numeroVentas,
    required this.numeroCompras,
    required this.numeroGastos,
    required this.productosActivos,
    required this.unidadesInventario,
  });

  factory BusinessFinanceModel.fromJson(Map<String, dynamic> json) {
    return BusinessFinanceModel(
      totalVentas: _toDouble(json['total_ventas']),
      costoMercanciaVendida: _toDouble(json['costo_mercancia_vendida']),
      utilidadBruta: _toDouble(json['utilidad_bruta']),
      totalGastos: _toDouble(json['total_gastos']),
      utilidadNeta: _toDouble(json['utilidad_neta']),
      totalReinversion: _toDouble(json['total_reinversion']),
      cuentasPorCobrar: _toDouble(json['cuentas_por_cobrar']),
      valorInventarioCosto: _toDouble(json['valor_inventario_costo']),
      valorInventarioVenta: _toDouble(json['valor_inventario_venta']),
      roi: _toDouble(json['roi']),
      margenBruto: _toDouble(json['margen_bruto']),
      margenNeto: _toDouble(json['margen_neto']),
      numeroVentas: _toInt(json['numero_ventas']),
      numeroCompras: _toInt(json['numero_compras']),
      numeroGastos: _toInt(json['numero_gastos']),
      productosActivos: _toInt(json['productos_activos']),
      unidadesInventario: _toInt(json['unidades_inventario']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}

// ============================================================
// TIMELINE FINANCIERO
// ============================================================

class BusinessFinanceTimelineModel {
  final String period;
  final String groupBy;
  final int totalPuntos;
  final List<BusinessFinanceTimelinePoint> puntos;

  const BusinessFinanceTimelineModel({
    required this.period,
    required this.groupBy,
    required this.totalPuntos,
    required this.puntos,
  });

  factory BusinessFinanceTimelineModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['puntos'];

    final points = rawPoints is List
        ? rawPoints
              .map(
                (item) => BusinessFinanceTimelinePoint.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <BusinessFinanceTimelinePoint>[];

    return BusinessFinanceTimelineModel(
      period: json['period']?.toString() ?? '',
      groupBy: json['group_by']?.toString() ?? '',
      totalPuntos: BusinessFinanceModel._toInt(json['total_puntos']),
      puntos: points,
    );
  }
}

class BusinessFinanceTimelinePoint {
  final String periodo;

  final double ventas;
  final double costoMercancia;
  final double utilidadBruta;
  final double gastos;
  final double utilidadNeta;
  final double reinversion;

  final int numeroVentas;
  final int numeroGastos;
  final int numeroCompras;

  const BusinessFinanceTimelinePoint({
    required this.periodo,
    required this.ventas,
    required this.costoMercancia,
    required this.utilidadBruta,
    required this.gastos,
    required this.utilidadNeta,
    required this.reinversion,
    required this.numeroVentas,
    required this.numeroGastos,
    required this.numeroCompras,
  });

  factory BusinessFinanceTimelinePoint.fromJson(Map<String, dynamic> json) {
    return BusinessFinanceTimelinePoint(
      periodo:
          json['periodo']?.toString() ??
          json['period']?.toString() ??
          json['fecha']?.toString() ??
          '',

      ventas: BusinessFinanceModel._toDouble(json['ventas']),

      costoMercancia: BusinessFinanceModel._toDouble(json['costo_mercancia']),

      utilidadBruta: BusinessFinanceModel._toDouble(json['utilidad_bruta']),

      gastos: BusinessFinanceModel._toDouble(json['gastos']),

      utilidadNeta: BusinessFinanceModel._toDouble(json['utilidad_neta']),

      reinversion: BusinessFinanceModel._toDouble(json['reinversion']),

      numeroVentas: BusinessFinanceModel._toInt(json['numero_ventas']),

      numeroGastos: BusinessFinanceModel._toInt(json['numero_gastos']),

      numeroCompras: BusinessFinanceModel._toInt(json['numero_compras']),
    );
  }
}

// ============================================================
// TOP PRODUCTOS
// ============================================================

class BusinessTopProductsModel {
  final int total;
  final List<BusinessTopProductModel> productos;

  const BusinessTopProductsModel({
    required this.total,
    required this.productos,
  });

  factory BusinessTopProductsModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['productos'];

    final products = rawProducts is List
        ? rawProducts
              .map(
                (item) => BusinessTopProductModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <BusinessTopProductModel>[];

    return BusinessTopProductsModel(
      total: BusinessFinanceModel._toInt(json['total']),
      productos: products,
    );
  }
}

class BusinessTopProductModel {
  final int productId;
  final String nombre;

  final int unidadesVendidas;

  final double ventas;
  final double costo;
  final double utilidadBruta;

  const BusinessTopProductModel({
    required this.productId,
    required this.nombre,
    required this.unidadesVendidas,
    required this.ventas,
    required this.costo,
    required this.utilidadBruta,
  });

  factory BusinessTopProductModel.fromJson(Map<String, dynamic> json) {
    return BusinessTopProductModel(
      productId: BusinessFinanceModel._toInt(json['product_id']),

      nombre:
          json['nombre']?.toString() ??
          json['producto_nombre']?.toString() ??
          'Producto',

      unidadesVendidas: BusinessFinanceModel._toInt(json['unidades_vendidas']),

      ventas: BusinessFinanceModel._toDouble(json['ventas']),

      costo: BusinessFinanceModel._toDouble(json['costo']),

      utilidadBruta: BusinessFinanceModel._toDouble(json['utilidad_bruta']),
    );
  }
}
