class StockMovementModel {
  final int movementId;
  final int productId;
  final String productoNombre;
  final String tipo;
  final int stockAnterior;
  final int cantidad;
  final int stockNuevo;
  final String motivo;
  final String usuario;
  final String? referencia;
  final DateTime? createdAt;

  const StockMovementModel({
    required this.movementId,
    required this.productId,
    required this.productoNombre,
    required this.tipo,
    required this.stockAnterior,
    required this.cantidad,
    required this.stockNuevo,
    required this.motivo,
    required this.usuario,
    this.referencia,
    this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      movementId: _toInt(json['movement_id']),
      productId: _toInt(json['product_id']),
      productoNombre: json['producto_nombre']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      stockAnterior: _toInt(json['stock_anterior']),
      cantidad: _toInt(json['cantidad']),
      stockNuevo: _toInt(json['stock_nuevo']),
      motivo: json['motivo']?.toString() ?? '',
      usuario: json['usuario']?.toString() ?? '',
      referencia: json['referencia']?.toString(),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
