class ExpenseModel {
  final String expenseId;
  final String categoria;
  final String descripcion;
  final double monto;
  final String metodoPago;
  final String? referencia;
  final String? notas;
  final String usuario;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    required this.expenseId,
    required this.categoria,
    required this.descripcion,
    required this.monto,
    required this.metodoPago,
    required this.referencia,
    required this.notas,
    required this.usuario,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expense_id']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      monto: _toDouble(json['monto']),
      metodoPago: json['metodo_pago']?.toString() ?? 'efectivo',
      referencia: json['referencia']?.toString(),
      notas: json['notas']?.toString(),
      usuario: json['usuario']?.toString() ?? 'admin',
      activo: json['activo'] == true,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toNullableDateTime(json['updated_at']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class ExpenseSummaryModel {
  final int numeroGastos;
  final double totalGastos;
  final double transporte;
  final double publicidad;
  final double servicios;
  final double comisiones;
  final double empaques;
  final double mantenimiento;
  final double otros;

  const ExpenseSummaryModel({
    required this.numeroGastos,
    required this.totalGastos,
    required this.transporte,
    required this.publicidad,
    required this.servicios,
    required this.comisiones,
    required this.empaques,
    required this.mantenimiento,
    required this.otros,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      numeroGastos: _toInt(json['numero_gastos']),
      totalGastos: _toDouble(json['total_gastos']),
      transporte: _toDouble(json['transporte']),
      publicidad: _toDouble(json['publicidad']),
      servicios: _toDouble(json['servicios']),
      comisiones: _toDouble(json['comisiones']),
      empaques: _toDouble(json['empaques']),
      mantenimiento: _toDouble(json['mantenimiento']),
      otros: _toDouble(json['otros']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}
