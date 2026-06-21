class CustomerModel {
  final int customerId;
  final String nombre;
  final String telefono;
  final String? alias;
  final String? notas;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.customerId,
    required this.nombre,
    required this.telefono,
    this.alias,
    this.notas,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: _toInt(json['customer_id']),
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      alias: json['alias']?.toString(),
      notas: json['notas']?.toString(),
      activo: json['activo'] == true,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'alias': alias,
      'notas': notas,
      'activo': activo,
    };
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
