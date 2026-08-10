class CreditPaymentModel {
  final String paymentId;
  final int creditId;
  final int customerId;
  final String customerNombre;
  final double monto;
  final String metodoPago;
  final String? nota;
  final String usuario;
  final DateTime createdAt;

  const CreditPaymentModel({
    required this.paymentId,
    required this.creditId,
    required this.customerId,
    required this.customerNombre,
    required this.monto,
    required this.metodoPago,
    required this.nota,
    required this.usuario,
    required this.createdAt,
  });

  factory CreditPaymentModel.fromJson(Map<String, dynamic> json) {
    return CreditPaymentModel(
      paymentId: json['payment_id']?.toString() ?? '',
      creditId: (json['credit_id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      customerNombre: json['customer_nombre']?.toString() ?? '',
      monto: (json['monto'] as num).toDouble(),
      metodoPago: json['metodo_pago']?.toString() ?? 'efectivo',
      nota: json['nota']?.toString(),
      usuario: json['usuario']?.toString() ?? 'admin',
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
