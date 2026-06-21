# Contrato técnico de modelos Dart para Flutter

## 1. Objetivo

Este documento define los modelos Dart que se usarán en la app Flutter Cash Control para consumir la API FastAPI del módulo **Mi Negocio**.

La finalidad es mantener una estructura clara entre:

```text
Flutter
FastAPI
MongoDB Atlas
```

Cada modelo Dart debe coincidir con las respuestas JSON del backend para evitar errores de serialización, nombres incorrectos o datos incompletos.

---

## 2. Principio general

Flutter no debe trabajar directamente con documentos de MongoDB.
Flutter debe trabajar con modelos Dart basados en las respuestas del backend.

La comunicación será:

```text
Flutter Service
        |
        v
Modelo Dart
        |
        v
JSON HTTP
        |
        v
FastAPI Endpoint
```

---

## 3. Modelos necesarios

El módulo **Mi Negocio** necesitará inicialmente estos modelos Dart:

```text
ProductModel
StockMovementModel
CustomerModel
CustomerSummaryModel
CreditModel
CreditPaymentModel
ApiMessageModel
```

---

# 4. ProductModel

## 4.1 Uso

Representa productos administrativos y públicos.

Se usará en:

```text
ProductsScreen
ProductFormScreen
InventoryScreen
Dashboard del negocio
```

## 4.2 Endpoints relacionados

```text
GET    /products/public
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
DELETE /products/delete/{product_id}
```

## 4.3 Código sugerido

```dart
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
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'] ?? '',
      stock: json['stock'] ?? 0,
      activo: json['activo'] ?? false,
      precioCompra: json['precio_compra'] != null
          ? (json['precio_compra']).toDouble()
          : null,
      proveedor: json['proveedor'],
      stockMinimo: json['stock_minimo'],
    );
  }

  Map<String, dynamic> toJson() {
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
}
```

---

# 5. StockMovementModel

## 5.1 Uso

Representa un movimiento de inventario.

Se usará en:

```text
InventoryScreen
StockMovementsScreen
Dashboard del negocio
```

## 5.2 Endpoints relacionados

```text
POST /inventory/stock/adjust/{product_id}
GET  /inventory/stock/history
GET  /inventory/stock/history?product_id={id}
```

## 5.3 Código sugerido

```dart
class StockMovementModel {
  final String movementId;
  final int productId;
  final String productoNombre;
  final String tipo;
  final int stockAnterior;
  final int cantidad;
  final int stockNuevo;
  final String motivo;
  final String usuario;
  final String? referencia;
  final DateTime createdAt;

  StockMovementModel({
    required this.movementId,
    required this.productId,
    required this.productoNombre,
    required this.tipo,
    required this.stockAnterior,
    required this.cantidad,
    required this.stockNuevo,
    required this.motivo,
    required this.usuario,
    this.referencia,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      movementId: json['movement_id'] ?? '',
      productId: json['product_id'] ?? 0,
      productoNombre: json['producto_nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      stockAnterior: json['stock_anterior'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      stockNuevo: json['stock_nuevo'] ?? 0,
      motivo: json['motivo'] ?? '',
      usuario: json['usuario'] ?? '',
      referencia: json['referencia'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

---

# 6. CustomerModel

## 6.1 Uso

Representa un cliente del negocio.

Se usará en:

```text
CustomersScreen
CustomerDetailScreen
CustomerFormScreen
CreditFormScreen
```

## 6.2 Endpoints relacionados

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

## 6.3 Código sugerido

```dart
class CustomerModel {
  final int customerId;
  final String nombre;
  final String? telefono;
  final String? alias;
  final String? notas;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.customerId,
    required this.nombre,
    this.telefono,
    this.alias,
    this.notas,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customer_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'],
      alias: json['alias'],
      notas: json['notas'],
      activo: json['activo'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'alias': alias,
      'notas': notas,
      'activo': activo,
    };
  }
}
```

---

# 7. CustomerSummaryModel

## 7.1 Uso

Representa el resumen financiero de un cliente.

Se usará en:

```text
CustomerDetailScreen
Dashboard del negocio
CreditsScreen
```

## 7.2 Endpoint relacionado

```text
GET /customers/{customer_id}/summary
```

## 7.3 Código sugerido

```dart
class CustomerSummaryModel {
  final int customerId;
  final String nombre;
  final String? telefono;
  final double totalFiado;
  final double totalPagado;
  final double saldoPendiente;
  final int creditosActivos;

  CustomerSummaryModel({
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
      customerId: json['customer_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'],
      totalFiado: (json['total_fiado'] ?? 0).toDouble(),
      totalPagado: (json['total_pagado'] ?? 0).toDouble(),
      saldoPendiente: (json['saldo_pendiente'] ?? 0).toDouble(),
      creditosActivos: json['creditos_activos'] ?? 0,
    );
  }
}
```

---

# 8. CreditModel

## 8.1 Uso

Representa un fiado o deuda registrada a un cliente.

Se usará en:

```text
CreditsScreen
CreditFormScreen
CustomerDetailScreen
PaymentFormScreen
```

## 8.2 Endpoints relacionados

```text
GET    /credits/admin
POST   /credits/create
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

## 8.3 Código sugerido

```dart
class CreditModel {
  final int creditId;
  final int customerId;
  final String customerNombre;
  final String concepto;
  final double montoTotal;
  final double montoPagado;
  final double saldoPendiente;
  final String? fechaLimite;
  final String estado;
  final String? notas;
  final String usuario;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreditModel({
    required this.creditId,
    required this.customerId,
    required this.customerNombre,
    required this.concepto,
    required this.montoTotal,
    required this.montoPagado,
    required this.saldoPendiente,
    this.fechaLimite,
    required this.estado,
    this.notas,
    required this.usuario,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      creditId: json['credit_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerNombre: json['customer_nombre'] ?? '',
      concepto: json['concepto'] ?? '',
      montoTotal: (json['monto_total'] ?? 0).toDouble(),
      montoPagado: (json['monto_pagado'] ?? 0).toDouble(),
      saldoPendiente: (json['saldo_pendiente'] ?? 0).toDouble(),
      fechaLimite: json['fecha_limite'],
      estado: json['estado'] ?? '',
      notas: json['notas'],
      usuario: json['usuario'] ?? '',
      activo: json['activo'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'concepto': concepto,
      'monto_total': montoTotal,
      'fecha_limite': fechaLimite,
      'notas': notas,
      'usuario': usuario,
    };
  }
}
```

---

# 9. CreditPaymentModel

## 9.1 Uso

Representa un abono realizado a un fiado.

Se usará en:

```text
PaymentFormScreen
CreditPaymentsScreen
CustomerDetailScreen
```

## 9.2 Endpoints relacionados

```text
POST /credits/pay/{credit_id}
GET  /credits/payments/{credit_id}
```

## 9.3 Código sugerido

```dart
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

  CreditPaymentModel({
    required this.paymentId,
    required this.creditId,
    required this.customerId,
    required this.customerNombre,
    required this.monto,
    required this.metodoPago,
    this.nota,
    required this.usuario,
    required this.createdAt,
  });

  factory CreditPaymentModel.fromJson(Map<String, dynamic> json) {
    return CreditPaymentModel(
      paymentId: json['payment_id'] ?? '',
      creditId: json['credit_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerNombre: json['customer_nombre'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      metodoPago: json['metodo_pago'] ?? '',
      nota: json['nota'],
      usuario: json['usuario'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monto': monto,
      'metodo_pago': metodoPago,
      'nota': nota,
      'usuario': usuario,
    };
  }
}
```

---

# 10. ApiMessageModel

## 10.1 Uso

Representa respuestas simples del backend.

Se usará en operaciones como:

```text
Eliminar producto
Cancelar fiado
Desactivar cliente
Actualizar estado
```

## 10.2 Código sugerido

```dart
class ApiMessageModel {
  final String message;
  final int? productId;
  final int? customerId;
  final int? creditId;

  ApiMessageModel({
    required this.message,
    this.productId,
    this.customerId,
    this.creditId,
  });

  factory ApiMessageModel.fromJson(Map<String, dynamic> json) {
    return ApiMessageModel(
      message: json['message'] ?? '',
      productId: json['product_id'],
      customerId: json['customer_id'],
      creditId: json['credit_id'],
    );
  }
}
```

---

# 11. Respuestas tipo lista

Algunos endpoints devuelven listas directas.

Ejemplo:

```text
GET /products/admin
```

Respuesta esperada:

```json
[
  {
    "id": 1,
    "nombre": "Mazapán",
    "categoria": "dulces",
    "precio": 6,
    "imagen": "img/dulces/mazapan.jpg",
    "stock": 30,
    "activo": true
  }
]
```

Conversión sugerida en Flutter:

```dart
final List data = jsonDecode(response.body);

final productos = data
    .map((item) => ProductModel.fromJson(item))
    .toList();
```

---

# 12. Respuestas tipo contenedor

Algunos endpoints devuelven objetos con lista interna.

Ejemplo:

```text
GET /inventory/stock/history
```

Respuesta esperada:

```json
{
  "total": 1,
  "movimientos": [
    {
      "movement_id": "...",
      "product_id": 8,
      "producto_nombre": "Mazapán",
      "tipo": "entrada",
      "stock_anterior": 30,
      "cantidad": 10,
      "stock_nuevo": 40,
      "motivo": "Compra",
      "usuario": "Bryan",
      "referencia": "COMPRA-001",
      "created_at": "2026-06-20T00:00:00"
    }
  ]
}
```

Conversión sugerida:

```dart
final Map<String, dynamic> data = jsonDecode(response.body);

final movimientos = (data['movimientos'] as List)
    .map((item) => StockMovementModel.fromJson(item))
    .toList();
```

---

# 13. Manejo de fechas

El backend puede devolver fechas en formato ISO.

Ejemplo:

```text
2026-06-20T12:30:00.000Z
```

En Flutter se debe convertir con:

```dart
DateTime.parse(json['created_at'])
```

Para fechas simples como `fecha_limite`, se puede manejar inicialmente como `String?` para evitar errores.

Ejemplo:

```dart
final String? fechaLimite;
```

Más adelante puede convertirse a `DateTime?` si se requiere calendario avanzado.

---

# 14. Manejo de dinero

Los montos deben manejarse como `double` en Flutter.

Campos monetarios:

```text
precio
precioCompra
montoTotal
montoPagado
saldoPendiente
monto
totalFiado
totalPagado
```

Conversión recomendada:

```dart
(json['precio'] ?? 0).toDouble()
```

---

# 15. Manejo de estados

Estados de fiado:

```text
pendiente
parcial
pagado
vencido
cancelado
```

Tipos de movimiento de stock:

```text
entrada
salida
ajuste
```

Métodos de pago:

```text
efectivo
transferencia
tarjeta
otro
```

Inicialmente se manejarán como `String`.
Más adelante pueden convertirse a `enum` en Dart.

---

# 16. Recomendación de ubicación en Flutter

Los modelos se deben guardar en:

```text
lib/modules/business/models/
```

Estructura sugerida:

```text
lib/modules/business/models/
├── product_model.dart
├── stock_movement_model.dart
├── customer_model.dart
├── customer_summary_model.dart
├── credit_model.dart
├── credit_payment_model.dart
└── api_message_model.dart
```

---

# 17. Conclusión

Los modelos Dart definidos en este documento serán la base para conectar la app Flutter con el backend FastAPI.

Antes de construir pantallas, se deben implementar y probar estos modelos junto con los servicios HTTP para asegurar que la app pueda recibir, interpretar y enviar datos correctamente.
