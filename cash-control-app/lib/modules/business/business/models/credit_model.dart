class CreditModel {
  final int creditId;
  final int customerId;
  final String customerNombre;
  final String concepto;
  final double montoTotal;
  final double montoPagado;
  final double saldoPendiente;
  final String estado;
  final String? fechaLimite;
  final String? notas;
  final String usuario;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CreditModel({
    required this.creditId,
    required this.customerId,
    required this.customerNombre,
    required this.concepto,
    required this.montoTotal,
    required this.montoPagado,
    required this.saldoPendiente,
    required this.estado,
    this.fechaLimite,
    this.notas,
    required this.usuario,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      creditId: _toInt(json['credit_id']),
      customerId: _toInt(json['customer_id']),
      customerNombre: json['customer_nombre']?.toString() ?? '',
      concepto: json['concepto']?.toString() ?? '',
      montoTotal: _toDouble(json['monto_total']),
      montoPagado: _toDouble(json['monto_pagado']),
      saldoPendiente: _toDouble(json['saldo_pendiente']),
      estado: json['estado']?.toString() ?? 'pendiente',
      fechaLimite: json['fecha_limite']?.toString(),
      notas: json['notas']?.toString(),
      usuario: json['usuario']?.toString() ?? '',
      activo: json['activo'] == true,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'customer_id': customerId,
      'concepto': concepto,
      'monto_total': montoTotal,
      'fecha_limite': fechaLimite,
      'notas': notas,
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
