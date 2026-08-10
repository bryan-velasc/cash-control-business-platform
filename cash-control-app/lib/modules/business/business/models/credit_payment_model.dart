class CreditPaymentModel {
  final int paymentId;
  final int creditId;
  final int customerId;
  final double monto;
  final String metodoPago;
  final String? nota;
  final String usuario;
  final DateTime? createdAt;

  const CreditPaymentModel({
    required this.paymentId,
    required this.creditId,
    required this.customerId,
    required this.monto,
    required this.metodoPago,
    this.nota,
    required this.usuario,
    this.createdAt,
  });

  factory CreditPaymentModel.fromJson(Map<String, dynamic> json) {
    return CreditPaymentModel(
      paymentId: _toInt(json['payment_id']),
      creditId: _toInt(json['credit_id']),
      customerId: _toInt(json['customer_id']),
      monto: _toDouble(json['monto']),
      metodoPago: json['metodo_pago']?.toString() ?? 'efectivo',
      nota: json['nota']?.toString(),
      usuario: json['usuario']?.toString() ?? '',
      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'monto': monto,
      'metodo_pago': metodoPago,
      'nota': nota,
      'usuario': usuario,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
