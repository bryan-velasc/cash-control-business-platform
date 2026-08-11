class PurchaseItemModel {
  final int productId;
  final String productoNombre;
  final int cantidad;
  final double costoUnitario;
  final double subtotal;
  final int stockAnterior;
  final int stockNuevo;

  const PurchaseItemModel({
    required this.productId,
    required this.productoNombre,
    required this.cantidad,
    required this.costoUnitario,
    required this.subtotal,
    required this.stockAnterior,
    required this.stockNuevo,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productoNombre: json['producto_nombre']?.toString() ?? '',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      costoUnitario: (json['costo_unitario'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      stockAnterior: (json['stock_anterior'] as num?)?.toInt() ?? 0,
      stockNuevo: (json['stock_nuevo'] as num?)?.toInt() ?? 0,
    );
  }
}

class PurchaseModel {
  final String purchaseId;
  final String folio;

  final int supplierId;
  final String supplierNombre;

  final List<PurchaseItemModel> items;

  final double total;

  final String? referencia;
  final String? notas;

  final String usuario;
  final String estado;

  final DateTime? createdAt;

  const PurchaseModel({
    required this.purchaseId,
    required this.folio,
    required this.supplierId,
    required this.supplierNombre,
    required this.items,
    required this.total,
    this.referencia,
    this.notas,
    required this.usuario,
    required this.estado,
    this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    return PurchaseModel(
      purchaseId: json['purchase_id']?.toString() ?? '',
      folio: json['folio']?.toString() ?? '',
      supplierId: (json['supplier_id'] as num?)?.toInt() ?? 0,
      supplierNombre: json['supplier_nombre']?.toString() ?? '',
      items: rawItems
          .map(
            (item) =>
                PurchaseItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      referencia: json['referencia']?.toString(),
      notas: json['notas']?.toString(),
      usuario: json['usuario']?.toString() ?? 'admin',
      estado: json['estado']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class PurchaseSummaryModel {
  final double totalCompras;
  final int numeroCompras;
  final int totalUnidades;

  const PurchaseSummaryModel({
    required this.totalCompras,
    required this.numeroCompras,
    required this.totalUnidades,
  });

  factory PurchaseSummaryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSummaryModel(
      totalCompras: (json['total_compras'] as num?)?.toDouble() ?? 0,
      numeroCompras: (json['numero_compras'] as num?)?.toInt() ?? 0,
      totalUnidades: (json['total_unidades'] as num?)?.toInt() ?? 0,
    );
  }
}
