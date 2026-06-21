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

  const ProductModel({
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
      precioCompra: json['precio_compra'] == null ? null : _toDouble(json['precio_compra']),
      proveedor: json['proveedor']?.toString(),
      stockMinimo: json['stock_minimo'] == null ? null : _toInt(json['stock_minimo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'imagen': imagen,
      'stock': stock,
      'activo': activo,
      'precio_compra': precioCompra,
      'proveedor': proveedor,
      'stock_minimo': stockMinimo,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'imagen': imagen,
      'stock': stock,
      'activo': activo,
      'precio_compra': precioCompra,
      'proveedor': proveedor,
      'stock_minimo': stockMinimo,
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
}
