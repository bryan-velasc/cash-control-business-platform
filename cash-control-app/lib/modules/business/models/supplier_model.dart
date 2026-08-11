class SupplierModel {
  final int supplierId;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? notas;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierModel({
    required this.supplierId,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    this.notas,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierId: (json['supplier_id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      contacto: json['contacto']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      direccion: json['direccion']?.toString(),
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
}

class SupplierSummaryModel {
  final int supplierId;
  final String nombre;
  final double totalCompras;
  final int numeroCompras;

  const SupplierSummaryModel({
    required this.supplierId,
    required this.nombre,
    required this.totalCompras,
    required this.numeroCompras,
  });

  factory SupplierSummaryModel.fromJson(Map<String, dynamic> json) {
    return SupplierSummaryModel(
      supplierId: (json['supplier_id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      totalCompras: (json['total_compras'] as num?)?.toDouble() ?? 0,
      numeroCompras: (json['numero_compras'] as num?)?.toInt() ?? 0,
    );
  }
}
