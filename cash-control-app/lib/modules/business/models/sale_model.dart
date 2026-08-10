class SaleItemModel {
  final int productId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final double precioCompraUnitario;
  final double subtotal;
  final double costoTotal;
  final double utilidadBruta;

  const SaleItemModel({
    required this.productId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioCompraUnitario,
    required this.subtotal,
    required this.costoTotal,
    required this.utilidadBruta,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productoNombre: json['producto_nombre']?.toString() ?? '',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      precioUnitario:
          (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      precioCompraUnitario:
          (json['precio_compra_unitario'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      costoTotal: (json['costo_total'] as num?)?.toDouble() ?? 0,
      utilidadBruta:
          (json['utilidad_bruta'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SaleModel {
  final String saleId;
  final String folio;
  final int? customerId;
  final String? customerNombre;
  final List<SaleItemModel> items;
  final double total;
  final double costoTotal;
  final double utilidadBruta;
  final String metodoPago;
  final int? creditId;
  final String? notas;
  final String usuario;
  final String estado;
  final DateTime? createdAt;

  const SaleModel({
    required this.saleId,
    required this.folio,
    this.customerId,
    this.customerNombre,
    required this.items,
    required this.total,
    required this.costoTotal,
    required this.utilidadBruta,
    required this.metodoPago,
    this.creditId,
    this.notas,
    required this.usuario,
    required this.estado,
    this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    return SaleModel(
      saleId: json['sale_id']?.toString() ?? '',
      folio: json['folio']?.toString() ?? '',
      customerId: (json['customer_id'] as num?)?.toInt(),
      customerNombre: json['customer_nombre']?.toString(),
      items: rawItems
          .map(
            (item) => SaleItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      costoTotal: (json['costo_total'] as num?)?.toDouble() ?? 0,
      utilidadBruta:
          (json['utilidad_bruta'] as num?)?.toDouble() ?? 0,
      metodoPago: json['metodo_pago']?.toString() ?? '',
      creditId: (json['credit_id'] as num?)?.toInt(),
      notas: json['notas']?.toString(),
      usuario: json['usuario']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class SalesSummaryModel {
  final double totalVentas;
  final double totalCosto;
  final double utilidadBruta;
  final int numeroVentas;
  final double efectivo;
  final double transferencia;
  final double tarjeta;
  final double fiado;

  const SalesSummaryModel({
    required this.totalVentas,
    required this.totalCosto,
    required this.utilidadBruta,
    required this.numeroVentas,
    required this.efectivo,
    required this.transferencia,
    required this.tarjeta,
    required this.fiado,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesSummaryModel(
      totalVentas: (json['total_ventas'] as num?)?.toDouble() ?? 0,
      totalCosto: (json['total_costo'] as num?)?.toDouble() ?? 0,
      utilidadBruta:
          (json['utilidad_bruta'] as num?)?.toDouble() ?? 0,
      numeroVentas: (json['numero_ventas'] as num?)?.toInt() ?? 0,
      efectivo: (json['efectivo'] as num?)?.toDouble() ?? 0,
      transferencia:
          (json['transferencia'] as num?)?.toDouble() ?? 0,
      tarjeta: (json['tarjeta'] as num?)?.toDouble() ?? 0,
      fiado: (json['fiado'] as num?)?.toDouble() ?? 0,
    );
  }
}