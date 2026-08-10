class StockMovementModel {
  final String movementId;
  final int productId;
  final String productoNombre;
  final String tipo;
  final int stockAnterior;
  final int cantidad;
  final int stockNuevo;
  final String motivo;
  final String usuario;
  final String? referencia;
  final DateTime createdAt;

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
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      movementId: json['movement_id']?.toString() ?? '',
      productId: _toInt(json['product_id']),
      productoNombre: json['producto_nombre']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      stockAnterior: _toInt(json['stock_anterior']),
      cantidad: _toInt(json['cantidad']),
      stockNuevo: _toInt(json['stock_nuevo']),
      motivo: json['motivo']?.toString() ?? '',
      usuario: json['usuario']?.toString() ?? 'admin',
      referencia: json['referencia']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
