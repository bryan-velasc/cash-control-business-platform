# Plan de implementación Flutter: Módulo Mi Negocio

## 1. Objetivo

Este documento define el orden real de implementación del módulo **Mi Negocio** dentro de la app Flutter Cash Control.

El objetivo es integrar productos, inventario, clientes, fiados y abonos sin romper la app actual.

---

## 2. Principio principal

La app Flutter no debe modificarse de golpe.

La integración se hará por fases:

```text
1. Crear estructura de carpetas.
2. Crear configuración de API.
3. Crear modelos Dart.
4. Crear servicios HTTP.
5. Probar servicios.
6. Crear pantallas de lectura.
7. Crear formularios.
8. Conectar acciones administrativas.
9. Mejorar seguridad.
```

---

## 3. Estructura final sugerida

Dentro del proyecto Flutter:

```text
lib/
├── modules/
│   └── business/
│       ├── models/
│       │   ├── product_model.dart
│       │   ├── stock_movement_model.dart
│       │   ├── customer_model.dart
│       │   ├── customer_summary_model.dart
│       │   ├── credit_model.dart
│       │   ├── credit_payment_model.dart
│       │   └── api_message_model.dart
│       │
│       ├── services/
│       │   ├── api_config.dart
│       │   ├── product_service.dart
│       │   ├── inventory_service.dart
│       │   ├── customer_service.dart
│       │   ├── credit_service.dart
│       │   └── business_dashboard_service.dart
│       │
│       ├── screens/
│       │   ├── business_dashboard_screen.dart
│       │   ├── products_screen.dart
│       │   ├── product_form_screen.dart
│       │   ├── inventory_screen.dart
│       │   ├── stock_movements_screen.dart
│       │   ├── customers_screen.dart
│       │   ├── customer_detail_screen.dart
│       │   ├── customer_form_screen.dart
│       │   ├── credits_screen.dart
│       │   ├── credit_form_screen.dart
│       │   ├── payment_form_screen.dart
│       │   └── credit_payments_screen.dart
│       │
│       └── widgets/
│           ├── business_summary_card.dart
│           ├── product_card.dart
│           ├── customer_card.dart
│           ├── credit_card.dart
│           ├── stock_movement_tile.dart
│           ├── payment_tile.dart
│           ├── empty_state_widget.dart
│           ├── loading_widget.dart
│           └── error_message_widget.dart
```

---

## 4. Dependencias necesarias

En `pubspec.yaml` se debe verificar que exista:

```yaml
dependencies:
  http: ^1.2.0
```

Más adelante se puede agregar:

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

`shared_preferences` servirá para guardar configuración local, como URL base de API o token temporal de desarrollo.

---

## 5. URLs por entorno

### Flutter Web

```text
http://127.0.0.1:8000
```

### Emulador Android

```text
http://10.0.2.2:8000
```

### Celular físico

```text
http://IP_DE_LA_PC:8000
```

Ejemplo:

```text
http://192.168.1.50:8000
```

### Producción

```text
https://backend-en-render.onrender.com
```

---

## 6. Fase 1: Preparar estructura de carpetas

### Objetivo

Crear el módulo sin afectar pantallas existentes.

### Archivos/carpetas a crear

```text
lib/modules/business/
lib/modules/business/models/
lib/modules/business/services/
lib/modules/business/screens/
lib/modules/business/widgets/
```

### Commit sugerido

```text
feat: crear estructura base del modulo Mi Negocio
```

---

## 7. Fase 2: Crear configuración de API

### Archivo

```text
lib/modules/business/services/api_config.dart
```

### Contenido esperado

Debe contener:

```text
baseUrl
adminToken temporal
headers públicos
headers administrativos
```

### Riesgo

No se debe quemar un token real definitivo dentro del código.

### Commit sugerido

```text
feat: agregar configuracion de API para modulo negocio
```

---

## 8. Fase 3: Crear modelos Dart

### Archivos

```text
product_model.dart
stock_movement_model.dart
customer_model.dart
customer_summary_model.dart
credit_model.dart
credit_payment_model.dart
api_message_model.dart
```

### Objetivo

Permitir que Flutter convierta JSON del backend en objetos Dart.

### Pruebas mínimas

Validar que cada modelo tenga:

```text
fromJson
toJson cuando aplique
manejo de valores nulos
conversión de double
conversión de DateTime
```

### Commit sugerido

```text
feat: agregar modelos Dart para modulo negocio
```

---

## 9. Fase 4: Crear servicios HTTP

### Archivos

```text
product_service.dart
inventory_service.dart
customer_service.dart
credit_service.dart
business_dashboard_service.dart
```

### Objetivo

Separar la lógica HTTP de las pantallas.

Las pantallas no deben llamar directamente a `http.get`, `http.post`, `http.put` o `http.delete`.

### Commit sugerido

```text
feat: agregar servicios HTTP para modulo negocio
```

---

## 10. Fase 5: Probar servicios sin interfaz compleja

Antes de crear pantallas completas, se deben probar los servicios.

### Orden recomendado

```text
1. ProductService.getPublicProducts()
2. ProductService.getAdminProducts()
3. CustomerService.getCustomers()
4. CustomerService.createCustomer()
5. CreditService.createCredit()
6. CreditService.registerPayment()
7. InventoryService.getLowStockProducts()
8. InventoryService.adjustStock()
9. BusinessDashboardService.getDashboardData()
```

### Objetivo

Confirmar que Flutter sí se comunica correctamente con FastAPI.

### Commit sugerido

```text
test: validar conexion de servicios Flutter con backend
```

---

## 11. Fase 6: Crear pantalla Dashboard Mi Negocio

### Archivo

```text
business_dashboard_screen.dart
```

### Elementos

```text
Total pendiente por cobrar
Productos activos
Productos con stock bajo
Clientes registrados
Fiados activos
Fiados pagados
Últimos movimientos de stock
Botones de navegación
```

### Endpoints usados

```text
GET /products/admin
GET /inventory/stock/low
GET /customers/admin
GET /credits/admin
GET /inventory/stock/history
```

### Commit sugerido

```text
feat: crear dashboard inicial de Mi Negocio
```

---

## 12. Fase 7: Crear pantalla de productos

### Archivos

```text
products_screen.dart
product_card.dart
product_form_screen.dart
```

### Funciones

```text
Listar productos
Buscar productos
Filtrar por categoría
Crear producto
Editar producto
Desactivar producto
```

### Endpoints usados

```text
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
DELETE /products/delete/{product_id}
```

### Commit sugerido

```text
feat: implementar administracion de productos en Flutter
```

---

## 13. Fase 8: Crear pantalla de clientes

### Archivos

```text
customers_screen.dart
customer_card.dart
customer_form_screen.dart
customer_detail_screen.dart
```

### Funciones

```text
Listar clientes
Crear cliente
Editar cliente
Desactivar cliente
Ver detalle
Ver resumen financiero
```

### Endpoints usados

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
GET    /customers/{customer_id}/summary
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

### Commit sugerido

```text
feat: implementar gestion de clientes en Flutter
```

---

## 14. Fase 9: Crear pantalla de fiados

### Archivos

```text
credits_screen.dart
credit_card.dart
credit_form_screen.dart
```

### Funciones

```text
Listar fiados
Crear fiado
Ver fiados por cliente
Editar fiado
Cancelar fiado
Ver estado
```

### Endpoints usados

```text
GET    /credits/admin
POST   /credits/create
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

### Commit sugerido

```text
feat: implementar gestion de fiados en Flutter
```

---

## 15. Fase 10: Crear pantalla de abonos

### Archivos

```text
payment_form_screen.dart
credit_payments_screen.dart
payment_tile.dart
```

### Funciones

```text
Registrar abono
Consultar pagos por fiado
Mostrar saldo pendiente
Validar monto antes de enviar
```

### Endpoints usados

```text
POST /credits/pay/{credit_id}
GET  /credits/payments/{credit_id}
GET  /credits/{credit_id}
```

### Commit sugerido

```text
feat: implementar registro de abonos en Flutter
```

---

## 16. Fase 11: Crear pantalla de inventario

### Archivos

```text
inventory_screen.dart
stock_movements_screen.dart
stock_movement_tile.dart
```

### Funciones

```text
Registrar entrada de stock
Registrar salida de stock
Registrar ajuste manual
Consultar historial de movimientos
Consultar stock bajo
```

### Endpoints usados

```text
POST /inventory/stock/adjust/{product_id}
GET  /inventory/stock/history
GET  /inventory/stock/low
```

### Commit sugerido

```text
feat: implementar control de inventario en Flutter
```

---

## 17. Fase 12: Integrar navegación en Cash Control

### Objetivo

Agregar acceso al módulo **Mi Negocio** desde el menú principal de la app.

### Reglas

```text
No eliminar pantallas existentes
No romper login actual
No modificar módulos financieros existentes
Agregar Mi Negocio como módulo separado
```

### Commit sugerido

```text
feat: integrar modulo Mi Negocio en navegacion principal
```

---

## 18. Fase 13: Mejorar experiencia visual

### Elementos

```text
Tarjetas limpias
Indicadores de estado
Colores para stock bajo
Colores para fiados pagados/parciales/pendientes
Mensajes de carga
Mensajes de error
Confirmaciones antes de eliminar o cancelar
```

### Commit sugerido

```text
style: mejorar interfaz visual del modulo Mi Negocio
```

---

## 19. Fase 14: Seguridad final

### Estado actual

Durante desarrollo se usa:

```text
x-admin-token
```

### Seguridad final recomendada

```text
Login real
JWT
Roles
Permisos
Refresh token
Expiración de sesión
Validación en backend
```

### Roles sugeridos

```text
admin
vendedor
consulta
cliente
```

### Commit sugerido

```text
feat: preparar autenticacion real para modulo negocio
```

---

## 20. Fase 15: Pruebas finales

### Pruebas necesarias

```text
Crear producto desde Flutter
Editar producto desde Flutter
Registrar entrada de stock
Registrar salida de stock
Crear cliente
Crear fiado
Registrar abono
Consultar resumen de cliente
Ver historial de stock
Ver stock bajo
Validar errores de conexión
Validar token incorrecto
```

### Commit sugerido

```text
test: validar flujo completo de Mi Negocio en Flutter
```

---

## 21. Orden de commits recomendado

```text
feat: crear estructura base del modulo Mi Negocio
feat: agregar configuracion de API para modulo negocio
feat: agregar modelos Dart para modulo negocio
feat: agregar servicios HTTP para modulo negocio
test: validar conexion de servicios Flutter con backend
feat: crear dashboard inicial de Mi Negocio
feat: implementar administracion de productos en Flutter
feat: implementar gestion de clientes en Flutter
feat: implementar gestion de fiados en Flutter
feat: implementar registro de abonos en Flutter
feat: implementar control de inventario en Flutter
feat: integrar modulo Mi Negocio en navegacion principal
style: mejorar interfaz visual del modulo Mi Negocio
test: validar flujo completo de Mi Negocio en Flutter
```

---

## 22. Riesgos principales

### Riesgo 1: Romper app existente

Control:

```text
Crear módulo separado
No tocar pantallas existentes al inicio
Integrar navegación al final
Probar por partes
```

### Riesgo 2: Errores de conexión local

Control:

```text
Usar 10.0.2.2 para emulador Android
Usar 127.0.0.1 para Flutter Web
Usar IP local para celular físico
```

### Riesgo 3: Token expuesto

Control:

```text
Usar token temporal solo para desarrollo
No subir tokens a GitHub
Migrar a autenticación real
```

### Riesgo 4: Pantallas con demasiada lógica

Control:

```text
Servicios HTTP separados
Modelos separados
Widgets reutilizables
Pantallas enfocadas solo en UI
```

---

## 23. Criterio para empezar a programar

Antes de programar Flutter se debe confirmar:

```text
Backend FastAPI funcionando
MongoDB Atlas conectado
Endpoints administrativos probados
x-admin-token funcionando
App Flutter respaldada
Rama nueva creada
Dependencia http instalada
```

---

## 24. Conclusión

El módulo **Mi Negocio** debe integrarse de forma gradual, comenzando por modelos y servicios HTTP antes de crear pantallas complejas.

Este plan permite conectar Cash Control Flutter con FastAPI y MongoDB Atlas sin romper la app actual.
