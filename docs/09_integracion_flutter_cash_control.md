# Integración Flutter con Cash Control Business Platform

## 1. Objetivo del documento

Este documento define cómo se integrará la aplicación Flutter de Cash Control con el backend de negocio creado para manejar productos, inventario, clientes, fiados y abonos.

La finalidad es preparar la integración sin romper la app actual, manteniendo separados los módulos de desarrollo y conectando cada parte de forma controlada.

---

## 2. Estado actual del proyecto

Actualmente el proyecto cuenta con tres partes principales:

```text
cash-control-business-platform/
│
├── web-dulces/          Página web pública de catálogo
├── backend/             API FastAPI conectada a MongoDB Atlas
├── cash-control-app/    Espacio reservado para la app Flutter
├── docs/                Documentación técnica
└── evidencias/          Capturas, pruebas y diagramas
```

La página web ya puede consumir productos desde el backend mediante:

```text
GET /products/public
```

El backend ya cuenta con módulos para:

```text
Productos
Inventario
Historial de stock
Clientes
Fiados
Abonos
Resumen de cliente
```

La app Flutter todavía no ha sido modificada dentro de este repositorio.

---

## 3. Principio de integración

La app Flutter no debe conectarse directamente a MongoDB Atlas.

La arquitectura correcta será:

```text
Flutter Cash Control
        |
        v
Backend FastAPI
        |
        v
MongoDB Atlas
```

La app Flutter solo debe consumir endpoints del backend.
La base de datos debe permanecer protegida detrás de FastAPI.

---

## 4. Rol de cada componente

### 4.1 Página web pública

La página web será usada por clientes o compradores.

Funciones permitidas:

```text
Ver productos disponibles
Consultar precios públicos
Agregar productos al carrito
Enviar pedido por WhatsApp
Consultar información limitada en una fase futura
```

La web pública no debe tener acceso a:

```text
Precio de compra
Ganancia
Proveedor
Clientes internos
Fiados completos
Historial de pagos
Historial de inventario
Endpoints administrativos
```

---

### 4.2 Backend FastAPI

El backend será el centro de control.

Funciones actuales:

```text
Entregar productos públicos
Administrar productos
Actualizar inventario
Registrar movimientos de stock
Crear clientes
Crear fiados
Registrar abonos
Consultar saldos pendientes
Proteger endpoints administrativos con x-admin-token
```

Funciones futuras:

```text
Autenticación real
Usuarios y roles
Ventas completas
Reportes financieros
Recordatorios de pago
Notificaciones
Panel administrativo para Flutter
```

---

### 4.3 App Flutter Cash Control

La app Flutter será el panel administrativo del negocio.

Tendrá un nuevo módulo llamado:

```text
Mi Negocio
```

Este módulo permitirá administrar:

```text
Productos
Inventario
Clientes
Fiados
Abonos
Reportes
Resumen del negocio
```

---

## 5. Módulo propuesto en Flutter: Mi Negocio

Dentro de Cash Control se agregará una sección llamada **Mi Negocio**.

Estructura sugerida:

```text
Mi Negocio
│
├── Dashboard del negocio
├── Productos
├── Inventario
├── Movimientos de stock
├── Clientes
├── Fiados
├── Abonos
├── Reportes
└── Ajustes del negocio
```

---

## 6. Pantallas propuestas

### 6.1 Dashboard del negocio

Objetivo:

Mostrar un resumen general del negocio.

Datos sugeridos:

```text
Total de productos activos
Productos con stock bajo
Total pendiente por cobrar
Clientes con deuda
Fiados activos
Fiados pagados
Últimos movimientos de stock
Últimos abonos registrados
```

Endpoints relacionados:

```text
GET /products/admin
GET /inventory/stock/low
GET /customers/admin
GET /credits/admin
```

---

### 6.2 Pantalla de productos

Objetivo:

Administrar el catálogo de productos.

Acciones:

```text
Ver productos
Crear producto
Editar producto
Desactivar producto
Actualizar imagen
Actualizar precio
Actualizar categoría
```

Endpoints relacionados:

```text
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
DELETE /products/delete/{product_id}
```

---

### 6.3 Pantalla de inventario

Objetivo:

Controlar entradas, salidas y ajustes de stock.

Acciones:

```text
Registrar entrada de stock
Registrar salida de stock
Registrar ajuste manual
Consultar productos con stock bajo
```

Endpoints relacionados:

```text
POST /inventory/stock/adjust/{product_id}
GET  /inventory/stock/low
```

---

### 6.4 Pantalla de movimientos de stock

Objetivo:

Auditar cambios de inventario.

Datos mostrados:

```text
Producto
Tipo de movimiento
Stock anterior
Cantidad
Stock nuevo
Motivo
Usuario
Referencia
Fecha
```

Endpoints relacionados:

```text
GET /inventory/stock/history
GET /inventory/stock/history?product_id={id}
```

---

### 6.5 Pantalla de clientes

Objetivo:

Administrar clientes del negocio.

Acciones:

```text
Crear cliente
Editar cliente
Desactivar cliente
Ver detalle del cliente
Ver resumen financiero
```

Endpoints relacionados:

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
GET    /customers/{customer_id}/summary
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

---

### 6.6 Pantalla de fiados

Objetivo:

Registrar y controlar deudas de clientes.

Acciones:

```text
Crear fiado
Consultar fiados
Ver fiados por cliente
Editar fiado
Cancelar fiado
Ver estado del fiado
```

Endpoints relacionados:

```text
GET    /credits/admin
POST   /credits/create
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

---

### 6.7 Pantalla de abonos

Objetivo:

Registrar pagos parciales o completos de un fiado.

Acciones:

```text
Registrar abono
Consultar historial de pagos
Ver saldo restante
Ver método de pago
```

Endpoints relacionados:

```text
POST /credits/pay/{credit_id}
GET  /credits/payments/{credit_id}
GET  /customers/{customer_id}/summary
```

---

## 7. Endpoints públicos y administrativos

### 7.1 Endpoints públicos

Estos endpoints pueden ser usados por la web pública:

```text
GET /products/public
GET /products/{product_id}
```

No requieren token administrativo.

---

### 7.2 Endpoints administrativos

Estos endpoints serán usados por Flutter:

```text
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
PATCH  /products/stock/{product_id}
DELETE /products/delete/{product_id}

POST   /inventory/stock/adjust/{product_id}
GET    /inventory/stock/history
GET    /inventory/stock/low

GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
GET    /customers/{customer_id}/summary
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}

GET    /credits/admin
POST   /credits/create
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
POST   /credits/pay/{credit_id}
GET    /credits/payments/{credit_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

Todos requieren:

```text
x-admin-token
```

---

## 8. Seguridad temporal

Actualmente los endpoints administrativos están protegidos con:

```text
x-admin-token
```

Este token se guarda en:

```text
backend/.env
```

Y no debe subirse a GitHub.

Ejemplo de header:

```text
x-admin-token: token_administrativo
```

Este mecanismo es temporal para desarrollo.

---

## 9. Seguridad final recomendada

Antes de producción se debe reemplazar el token simple por autenticación real.

La seguridad final debe incluir:

```text
Login de usuario
JWT o sesión segura
Roles
Permisos por módulo
Expiración de token
Revocación de sesiones
Validación desde backend
Logs de acciones administrativas
```

Roles sugeridos:

```text
admin
vendedor
consulta
cliente
```

Permisos sugeridos:

```text
admin: acceso total
vendedor: ventas, abonos, clientes, inventario limitado
consulta: solo lectura
cliente: acceso limitado a su propia información
```

---

## 10. URLs según entorno

### 10.1 Web local con Live Server

```text
http://127.0.0.1:8000
```

### 10.2 Flutter en emulador Android

Cuando Flutter corra en un emulador Android y el backend esté en la misma computadora, se debe usar:

```text
http://10.0.2.2:8000
```

No se debe usar `127.0.0.1` dentro del emulador Android, porque ahí representa al propio emulador, no a la computadora.

### 10.3 Flutter en dispositivo físico

Cuando Flutter corra en un celular físico conectado a la misma red, se debe usar la IP local de la computadora.

Ejemplo:

```text
http://192.168.1.50:8000
```

### 10.4 Producción

Cuando el backend se despliegue en Render, Flutter y la web deberán usar la URL pública.

Ejemplo:

```text
https://cash-control-business-api.onrender.com
```

---

## 11. Estructura sugerida en Flutter

Dentro de la app Flutter se recomienda crear una carpeta para el módulo de negocio.

Estructura sugerida:

```text
lib/
├── modules/
│   └── business/
│       ├── screens/
│       │   ├── business_dashboard_screen.dart
│       │   ├── products_screen.dart
│       │   ├── inventory_screen.dart
│       │   ├── stock_movements_screen.dart
│       │   ├── customers_screen.dart
│       │   ├── credits_screen.dart
│       │   └── payments_screen.dart
│       │
│       ├── services/
│       │   ├── product_service.dart
│       │   ├── inventory_service.dart
│       │   ├── customer_service.dart
│       │   └── credit_service.dart
│       │
│       ├── models/
│       │   ├── product_model.dart
│       │   ├── stock_movement_model.dart
│       │   ├── customer_model.dart
│       │   ├── credit_model.dart
│       │   └── payment_model.dart
│       │
│       └── widgets/
│           ├── business_summary_card.dart
│           ├── product_card.dart
│           ├── customer_card.dart
│           └── credit_card.dart
```

---

## 12. Servicios Flutter sugeridos

### 12.1 ProductService

Responsabilidad:

```text
Consultar productos
Crear productos
Actualizar productos
Desactivar productos
```

Endpoints:

```text
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
DELETE /products/delete/{product_id}
```

---

### 12.2 InventoryService

Responsabilidad:

```text
Registrar movimientos de stock
Consultar historial
Consultar stock bajo
```

Endpoints:

```text
POST /inventory/stock/adjust/{product_id}
GET  /inventory/stock/history
GET  /inventory/stock/low
```

---

### 12.3 CustomerService

Responsabilidad:

```text
Crear clientes
Consultar clientes
Actualizar clientes
Consultar resumen financiero
```

Endpoints:

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
GET    /customers/{customer_id}/summary
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

---

### 12.4 CreditService

Responsabilidad:

```text
Crear fiados
Consultar fiados
Registrar abonos
Consultar pagos
Cancelar fiados
```

Endpoints:

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

---

## 13. Orden recomendado de implementación en Flutter

La integración no debe hacerse de golpe.

Orden recomendado:

```text
1. Crear modelos Dart.
2. Crear servicios HTTP.
3. Probar servicios sin interfaz compleja.
4. Crear pantalla Dashboard Mi Negocio.
5. Crear pantalla de productos en modo lectura.
6. Agregar crear y editar productos.
7. Crear pantalla de clientes.
8. Crear pantalla de fiados.
9. Crear registro de abonos.
10. Crear pantalla de inventario.
11. Crear historial de stock.
12. Agregar reportes.
13. Reemplazar x-admin-token por autenticación real.
```

---

## 14. Riesgos de integración

### Riesgo 1: Romper la app Flutter actual

Control:

```text
Crear módulo separado
No modificar pantallas existentes al inicio
Agregar rutas nuevas gradualmente
Probar cada servicio antes de conectarlo a UI
```

### Riesgo 2: Exponer token administrativo

Control:

```text
No quemar tokens definitivos en código
Usar variables de entorno o configuración local
No subir credenciales a GitHub
Reemplazar token por autenticación real
```

### Riesgo 3: Duplicar backend

Control:

```text
Usar un solo backend FastAPI central
Evitar crear APIs separadas para web y Flutter
Mantener endpoints públicos y administrativos separados
```

### Riesgo 4: Inconsistencia de datos

Control:

```text
Todas las operaciones críticas deben pasar por backend
No modificar MongoDB directamente desde Flutter
Validar saldos y stock en FastAPI
Registrar historial de movimientos
```

---

## 15. Decisión técnica

La integración con Flutter se hará después de estabilizar el backend.

Primero se conectarán servicios HTTP y pantallas de lectura.
Después se habilitarán acciones administrativas.
Finalmente se reemplazará el token temporal por autenticación real con usuarios, roles y permisos.

---

## 16. Conclusión

La app Flutter de Cash Control debe funcionar como panel administrativo del negocio, mientras que FastAPI será el punto central de conexión con MongoDB Atlas.

La integración debe realizarse de forma modular para no afectar la app existente y para permitir que web, backend y Flutter compartan la misma lógica de negocio de forma segura.
