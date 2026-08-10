class CustomerModel {
  final int customerId;
  final String nombre;
  final String? telefono;
  final String? alias;
  final String? notas;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.customerId,
    required this.nombre,
    this.telefono,
    this.alias,
    this.notas,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      alias: json['alias']?.toString(),
      notas: json['notas']?.toString(),
      activo: json['activo'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  CustomerModel copyWith({
    int? customerId,
    String? nombre,
    String? telefono,
    String? alias,
    String? notas,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      alias: alias ?? this.alias,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CustomerSummaryModel {
  final int customerId;
  final String nombre;
  final String? telefono;
  final double totalFiado;
  final double totalPagado;
  final double saldoPendiente;
  final int creditosActivos;

  const CustomerSummaryModel({
    required this.customerId,
    required this.nombre,
    this.telefono,
    required this.totalFiado,
    required this.totalPagado,
    required this.saldoPendiente,
    required this.creditosActivos,
  });

  factory CustomerSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerSummaryModel(
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      totalFiado: (json['total_fiado'] as num?)?.toDouble() ?? 0,
      totalPagado: (json['total_pagado'] as num?)?.toDouble() ?? 0,
      saldoPendiente: (json['saldo_pendiente'] as num?)?.toDouble() ?? 0,
      creditosActivos: (json['creditos_activos'] as num?)?.toInt() ?? 0,
    );
  }
}
