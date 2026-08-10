class CustomerSummaryModel {
  final int customerId;
  final String nombre;
  final String telefono;
  final double totalFiado;
  final double totalPagado;
  final double saldoPendiente;
  final int creditosActivos;

  const CustomerSummaryModel({
    required this.customerId,
    required this.nombre,
    required this.telefono,
    required this.totalFiado,
    required this.totalPagado,
    required this.saldoPendiente,
    required this.creditosActivos,
  });

  factory CustomerSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerSummaryModel(
      customerId: _toInt(json['customer_id']),
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      totalFiado: _toDouble(json['total_fiado']),
      totalPagado: _toDouble(json['total_pagado']),
      saldoPendiente: _toDouble(json['saldo_pendiente']),
      creditosActivos: _toInt(json['creditos_activos']),
    );
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
}
