class CreditModel {
  final int creditId;
  final int customerId;
  final String customerNombre;
  final String concepto;
  final double montoTotal;
  final double montoPagado;
  final double saldoPendiente;
  final DateTime? fechaLimite;
  final String estado;
  final String? notas;
  final String usuario;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditModel({
    required this.creditId,
    required this.customerId,
    required this.customerNombre,
    required this.concepto,
    required this.montoTotal,
    required this.montoPagado,
    required this.saldoPendiente,
    required this.fechaLimite,
    required this.estado,
    required this.notas,
    required this.usuario,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      creditId: (json['credit_id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      customerNombre: json['customer_nombre']?.toString() ?? '',
      concepto: json['concepto']?.toString() ?? '',
      montoTotal: (json['monto_total'] as num).toDouble(),
      montoPagado: (json['monto_pagado'] as num).toDouble(),
      saldoPendiente: (json['saldo_pendiente'] as num).toDouble(),
      fechaLimite: json['fecha_limite'] == null
          ? null
          : DateTime.tryParse(json['fecha_limite'].toString()),
      estado: json['estado']?.toString() ?? 'pendiente',
      notas: json['notas']?.toString(),
      usuario: json['usuario']?.toString() ?? 'admin',
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  bool get estaPagado => estado == 'pagado';

  bool get estaCancelado => estado == 'cancelado';

  bool get aceptaAbonos => activo && !estaPagado && !estaCancelado;

  double get progreso {
    if (montoTotal <= 0) {
      return 0;
    }

    return (montoPagado / montoTotal).clamp(0.0, 1.0);
  }
}
