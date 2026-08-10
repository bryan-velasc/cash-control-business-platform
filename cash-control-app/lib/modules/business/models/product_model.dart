class ProductModel {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final String imagen;
  final int stock;
  final bool activo;
  final double? precioCompra;
  final String? proveedor;
  final int? stockMinimo;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.imagen,
    required this.stock,
    required this.activo,
    this.precioCompra,
    this.proveedor,
    this.stockMinimo,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      precio: _toDouble(json['precio']),
      imagen: json['imagen']?.toString() ?? '',
      stock: _toInt(json['stock']),
      activo: json['activo'] == true,
      precioCompra: _toNullableDouble(json['precio_compra']),
      proveedor: json['proveedor']?.toString(),
      stockMinimo: _toNullableInt(json['stock_minimo']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
