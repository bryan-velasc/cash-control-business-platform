# Contrato técnico de servicios HTTP en Flutter

## 1. Objetivo

Este documento define cómo se conectará la app Flutter Cash Control con el backend FastAPI del módulo **Mi Negocio**.

La finalidad es preparar los servicios HTTP antes de crear pantallas, para que la comunicación entre Flutter y FastAPI sea ordenada, segura y fácil de mantener.

---

## 2. Principio general

La app Flutter no debe conectarse directamente a MongoDB Atlas.

La comunicación correcta será:

```text
Flutter
   |
   v
Servicios HTTP
   |
   v
FastAPI
   |
   v
MongoDB Atlas
```

Cada pantalla de Flutter debe usar un servicio específico.
No se recomienda hacer llamadas HTTP directamente dentro de las pantallas.

---

## 3. Dependencia necesaria en Flutter

En `pubspec.yaml`, la app debe tener:

```yaml
dependencies:
  http: ^1.2.0
```

También puede requerirse más adelante:

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

`shared_preferences` servirá para guardar configuración local como URL base temporal o token de desarrollo.

---

## 4. Configuración de API

Se recomienda crear un archivo:

```text
lib/modules/business/services/api_config.dart
```

Código sugerido:

```dart
class ApiConfig {
  /*
    URLs según entorno:

    Web local:
    http://127.0.0.1:8000

    Emulador Android:
    http://10.0.2.2:8000

    Celular físico en la misma red:
    http://IP_DE_TU_PC:8000

    Producción:
    https://tu-backend-en-render.onrender.com
  */

  static const String baseUrl = 'http://10.0.2.2:8000';

  /*
    Token temporal de desarrollo.

    Este token NO debe ser la solución final en producción.
    Después debe reemplazarse por login real, JWT, roles y permisos.
  */
  static const String adminToken = 'CAMBIAR_TOKEN_LOCAL';

  static Map<String, String> get adminHeaders {
    return {
      'Content-Type': 'application/json',
      'x-admin-token': adminToken,
    };
  }

  static Map<String, String> get publicHeaders {
    return {
      'Content-Type': 'application/json',
    };
  }
}
```

---

## 5. Manejo recomendado de errores

Todos los servicios deben validar:

```text
Código de respuesta HTTP
Respuesta vacía
Error de conexión
Error de formato JSON
Token inválido
Servidor apagado
```

Códigos importantes:

```text
200 OK
201 Created
400 Error de validación
401 Token inválido
404 Recurso no encontrado
500 Error del servidor
```

Función sugerida:

```dart
Exception handleHttpError(int statusCode, String body) {
  if (statusCode == 400) {
    return Exception('Solicitud incorrecta: $body');
  }

  if (statusCode == 401) {
    return Exception('No autorizado. Revisa el token administrativo.');
  }

  if (statusCode == 404) {
    return Exception('Recurso no encontrado.');
  }

  if (statusCode >= 500) {
    return Exception('Error del servidor. Intenta más tarde.');
  }

  return Exception('Error HTTP $statusCode: $body');
}
```

---

# 6. ProductService

## 6.1 Ubicación sugerida

```text
lib/modules/business/services/product_service.dart
```

## 6.2 Responsabilidad

Este servicio manejará productos.

Funciones:

```text
Consultar productos públicos
Consultar productos administrativos
Crear producto
Actualizar producto
Actualizar stock simple
Desactivar producto
```

## 6.3 Endpoints relacionados

```text
GET    /products/public
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
PATCH  /products/stock/{product_id}
DELETE /products/delete/{product_id}
```

## 6.4 Código base sugerido

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/api_message_model.dart';
import 'api_config.dart';

class ProductService {
  static Future<List<ProductModel>> getPublicProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/public');

    final response = await http.get(
      url,
      headers: ApiConfig.publicHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al obtener productos públicos: ${response.body}');
  }

  static Future<List<ProductModel>> getAdminProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/admin');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al obtener productos administrativos: ${response.body}');
  }

  static Future<ProductModel> createProduct(ProductModel product) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/create');

    final response = await http.post(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al crear producto: ${response.body}');
  }

  static Future<ProductModel> updateProduct(
    int productId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/update/$productId');

    final response = await http.put(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al actualizar producto: ${response.body}');
  }

  static Future<ProductModel> updateStock(
    int productId,
    int stock,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/stock/$productId');

    final response = await http.patch(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'stock': stock,
      }),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al actualizar stock: ${response.body}');
  }

  static Future<ApiMessageModel> deleteProduct(int productId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/delete/$productId');

    final response = await http.delete(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return ApiMessageModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al desactivar producto: ${response.body}');
  }
}
```

---

# 7. InventoryService

## 7.1 Ubicación sugerida

```text
lib/modules/business/services/inventory_service.dart
```

## 7.2 Responsabilidad

Este servicio manejará inventario y movimientos de stock.

Funciones:

```text
Registrar entrada
Registrar salida
Registrar ajuste
Consultar historial
Consultar stock bajo
```

## 7.3 Endpoints relacionados

```text
POST /inventory/stock/adjust/{product_id}
GET  /inventory/stock/history
GET  /inventory/stock/history?product_id={id}
GET  /inventory/stock/low
```

## 7.4 Código base sugerido

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import 'api_config.dart';

class InventoryService {
  static Future<StockMovementModel> adjustStock({
    required int productId,
    required String tipo,
    required int cantidad,
    required String motivo,
    String usuario = 'admin',
    String? referencia,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/inventory/stock/adjust/$productId',
    );

    final response = await http.post(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'tipo': tipo,
        'cantidad': cantidad,
        'motivo': motivo,
        'usuario': usuario,
        'referencia': referencia,
      }),
    );

    if (response.statusCode == 200) {
      return StockMovementModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al ajustar stock: ${response.body}');
  }

  static Future<List<StockMovementModel>> getStockHistory({
    int? productId,
    int limit = 100,
  }) async {
    String endpoint = '${ApiConfig.baseUrl}/inventory/stock/history?limit=$limit';

    if (productId != null) {
      endpoint += '&product_id=$productId';
    }

    final url = Uri.parse(endpoint);

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List movimientos = data['movimientos'];

      return movimientos
          .map((item) => StockMovementModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al consultar historial de stock: ${response.body}');
  }

  static Future<List<ProductModel>> getLowStockProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/inventory/stock/low');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al consultar stock bajo: ${response.body}');
  }
}
```

---

# 8. CustomerService

## 8.1 Ubicación sugerida

```text
lib/modules/business/services/customer_service.dart
```

## 8.2 Responsabilidad

Este servicio manejará clientes.

Funciones:

```text
Consultar clientes
Crear cliente
Consultar cliente por ID
Actualizar cliente
Desactivar cliente
Consultar resumen financiero
```

## 8.3 Endpoints relacionados

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
GET    /customers/{customer_id}/summary
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

## 8.4 Código base sugerido

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/customer_model.dart';
import '../models/customer_summary_model.dart';
import '../models/api_message_model.dart';
import 'api_config.dart';

class CustomerService {
  static Future<List<CustomerModel>> getCustomers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customers/admin');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => CustomerModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al obtener clientes: ${response.body}');
  }

  static Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customers/create');

    final response = await http.post(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CustomerModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al crear cliente: ${response.body}');
  }

  static Future<CustomerModel> getCustomerById(int customerId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customers/$customerId');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return CustomerModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al consultar cliente: ${response.body}');
  }

  static Future<CustomerSummaryModel> getCustomerSummary(int customerId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/customers/$customerId/summary',
    );

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return CustomerSummaryModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al consultar resumen de cliente: ${response.body}');
  }

  static Future<CustomerModel> updateCustomer(
    int customerId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customers/update/$customerId');

    final response = await http.put(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return CustomerModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al actualizar cliente: ${response.body}');
  }

  static Future<ApiMessageModel> deleteCustomer(int customerId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customers/delete/$customerId');

    final response = await http.delete(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return ApiMessageModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al desactivar cliente: ${response.body}');
  }
}
```

---

# 9. CreditService

## 9.1 Ubicación sugerida

```text
lib/modules/business/services/credit_service.dart
```

## 9.2 Responsabilidad

Este servicio manejará fiados y abonos.

Funciones:

```text
Consultar fiados
Crear fiado
Consultar fiados por cliente
Registrar abono
Consultar pagos de un fiado
Actualizar fiado
Cancelar fiado
```

## 9.3 Endpoints relacionados

```text
GET    /credits/admin
POST   /credits/create
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
POST   /credits/pay/{credit_id}
GET    /credits/payments/{credit_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

## 9.4 Código base sugerido

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';
import '../models/api_message_model.dart';
import 'api_config.dart';

class CreditService {
  static Future<List<CreditModel>> getCredits() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/admin');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => CreditModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al obtener fiados: ${response.body}');
  }

  static Future<CreditModel> createCredit(CreditModel credit) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/create');

    final response = await http.post(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(credit.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreditModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al crear fiado: ${response.body}');
  }

  static Future<CreditModel> getCreditById(int creditId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/$creditId');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return CreditModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al consultar fiado: ${response.body}');
  }

  static Future<List<CreditModel>> getCreditsByCustomer(int customerId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/credits/customer/$customerId',
    );

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => CreditModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al consultar fiados del cliente: ${response.body}');
  }

  static Future<CreditPaymentModel> registerPayment({
    required int creditId,
    required double monto,
    required String metodoPago,
    String? nota,
    String usuario = 'admin',
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/pay/$creditId');

    final response = await http.post(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'monto': monto,
        'metodo_pago': metodoPago,
        'nota': nota,
        'usuario': usuario,
      }),
    );

    if (response.statusCode == 200) {
      return CreditPaymentModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al registrar abono: ${response.body}');
  }

  static Future<List<CreditPaymentModel>> getCreditPayments(int creditId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/payments/$creditId');

    final response = await http.get(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List pagos = data['pagos'];

      return pagos
          .map((item) => CreditPaymentModel.fromJson(item))
          .toList();
    }

    throw Exception('Error al consultar pagos del fiado: ${response.body}');
  }

  static Future<CreditModel> updateCredit(
    int creditId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/update/$creditId');

    final response = await http.put(
      url,
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return CreditModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al actualizar fiado: ${response.body}');
  }

  static Future<ApiMessageModel> cancelCredit(int creditId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/credits/cancel/$creditId');

    final response = await http.delete(
      url,
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return ApiMessageModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error al cancelar fiado: ${response.body}');
  }
}
```

---

# 10. BusinessDashboardService

## 10.1 Ubicación sugerida

```text
lib/modules/business/services/business_dashboard_service.dart
```

## 10.2 Responsabilidad

Este servicio reunirá información para el dashboard del negocio.

Inicialmente puede hacer varias consultas al backend y combinar resultados en Flutter.

Endpoints usados:

```text
GET /products/admin
GET /inventory/stock/low
GET /customers/admin
GET /credits/admin
GET /inventory/stock/history
```

## 10.3 Datos sugeridos

```text
Total de productos
Productos con stock bajo
Total pendiente por cobrar
Clientes registrados
Fiados activos
Fiados pagados
Últimos movimientos de stock
```

## 10.4 Código base sugerido

```dart
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/credit_model.dart';
import '../models/stock_movement_model.dart';
import 'product_service.dart';
import 'inventory_service.dart';
import 'customer_service.dart';
import 'credit_service.dart';

class BusinessDashboardData {
  final List<ProductModel> products;
  final List<ProductModel> lowStockProducts;
  final List<CustomerModel> customers;
  final List<CreditModel> credits;
  final List<StockMovementModel> recentStockMovements;

  BusinessDashboardData({
    required this.products,
    required this.lowStockProducts,
    required this.customers,
    required this.credits,
    required this.recentStockMovements,
  });

  double get totalPendiente {
    return credits.fold(
      0,
      (sum, credit) => sum + credit.saldoPendiente,
    );
  }

  int get fiadosActivos {
    return credits
        .where((credit) =>
            credit.estado == 'pendiente' ||
            credit.estado == 'parcial' ||
            credit.estado == 'vencido')
        .length;
  }

  int get fiadosPagados {
    return credits
        .where((credit) => credit.estado == 'pagado')
        .length;
  }
}

class BusinessDashboardService {
  static Future<BusinessDashboardData> getDashboardData() async {
    final results = await Future.wait([
      ProductService.getAdminProducts(),
      InventoryService.getLowStockProducts(),
      CustomerService.getCustomers(),
      CreditService.getCredits(),
      InventoryService.getStockHistory(limit: 10),
    ]);

    return BusinessDashboardData(
      products: results[0] as List<ProductModel>,
      lowStockProducts: results[1] as List<ProductModel>,
      customers: results[2] as List<CustomerModel>,
      credits: results[3] as List<CreditModel>,
      recentStockMovements: results[4] as List<StockMovementModel>,
    );
  }
}
```

---

# 11. Recomendación de estructura en Flutter

```text
lib/modules/business/services/
├── api_config.dart
├── product_service.dart
├── inventory_service.dart
├── customer_service.dart
├── credit_service.dart
└── business_dashboard_service.dart
```

---

# 12. Orden recomendado para probar servicios

Antes de crear pantallas, se recomienda probar en este orden:

```text
1. ApiConfig
2. ProductService.getPublicProducts()
3. ProductService.getAdminProducts()
4. CustomerService.getCustomers()
5. CustomerService.createCustomer()
6. CreditService.createCredit()
7. CreditService.registerPayment()
8. InventoryService.getLowStockProducts()
9. InventoryService.adjustStock()
10. BusinessDashboardService.getDashboardData()
```

---

# 13. Consideraciones para Android

Si el backend corre localmente en la computadora y Flutter en emulador Android, usar:

```text
http://10.0.2.2:8000
```

Si Flutter corre en navegador web, usar:

```text
http://127.0.0.1:8000
```

Si Flutter corre en celular físico, usar la IP local de la computadora:

```text
http://192.168.X.X:8000
```

---

# 14. Seguridad

El token `x-admin-token` es temporal.

No debe usarse como seguridad final en producción.

Antes de publicar la app se debe implementar:

```text
Login
JWT
Roles
Permisos
Expiración de sesión
Refresh token
Protección de endpoints administrativos
```

---

# 15. Conclusión

Los servicios HTTP definidos en este documento serán la capa intermedia entre Flutter y FastAPI.

La app Flutter debe consumir estos servicios desde sus pantallas, evitando lógica HTTP directamente dentro de la interfaz.

Este diseño permite mantener código limpio, facilitar pruebas y preparar la integración segura con Cash Control.
