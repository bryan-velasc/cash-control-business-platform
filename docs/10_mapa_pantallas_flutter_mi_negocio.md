# Mapa de pantallas Flutter: Módulo Mi Negocio

## 1. Objetivo

Este documento define el mapa de pantallas que tendrá el módulo **Mi Negocio** dentro de la app Flutter Cash Control.

El objetivo es planear la interfaz antes de programarla, evitando romper la app actual y permitiendo conectar cada pantalla con los endpoints del backend FastAPI.

---

## 2. Módulo principal

Nombre del módulo:

```text
Mi Negocio
```

Función principal:

Permitir que el usuario administre su negocio desde Cash Control, incluyendo productos, inventario, clientes, fiados, abonos y reportes.

---

## 3. Flujo general de navegación

```text
Inicio Cash Control
        |
        v
Menú principal
        |
        v
Mi Negocio
        |
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

## 4. Pantalla: Dashboard del negocio

### Nombre sugerido del archivo

```text
business_dashboard_screen.dart
```

### Objetivo

Mostrar un resumen rápido del estado del negocio.

### Elementos visuales

```text
Tarjeta: Total pendiente por cobrar
Tarjeta: Productos activos
Tarjeta: Productos con stock bajo
Tarjeta: Fiados activos
Tarjeta: Últimos abonos
Tarjeta: Últimos movimientos de stock
Botón: Ver productos
Botón: Ver clientes
Botón: Ver fiados
Botón: Registrar abono
```

### Datos necesarios

```text
Productos administrativos
Stock bajo
Clientes
Fiados
Pagos recientes
Movimientos recientes
```

### Endpoints relacionados

```text
GET /products/admin
GET /inventory/stock/low
GET /customers/admin
GET /credits/admin
GET /inventory/stock/history
```

### Prioridad

Alta.

---

## 5. Pantalla: Productos

### Nombre sugerido del archivo

```text
products_screen.dart
```

### Objetivo

Permitir consultar y administrar productos.

### Elementos visuales

```text
Buscador de productos
Filtro por categoría
Lista de productos
Tarjeta por producto
Botón flotante: Agregar producto
Botón editar
Botón desactivar
Indicador de stock
Indicador de producto activo/inactivo
```

### Campos por producto

```text
ID
Nombre
Categoría
Precio de venta
Imagen
Stock
Activo
Proveedor
Precio de compra
Stock mínimo
```

### Acciones

```text
Ver productos
Crear producto
Editar producto
Desactivar producto
Actualizar datos
```

### Endpoints relacionados

```text
GET    /products/admin
POST   /products/create
PUT    /products/update/{product_id}
DELETE /products/delete/{product_id}
```

### Prioridad

Alta.

---

## 6. Pantalla: Formulario de producto

### Nombre sugerido del archivo

```text
product_form_screen.dart
```

### Objetivo

Crear o editar un producto.

### Campos del formulario

```text
Nombre
Categoría
Precio de venta
Imagen o ruta de imagen
Stock inicial
Precio de compra
Proveedor
Stock mínimo
Activo
```

### Validaciones

```text
Nombre obligatorio
Categoría obligatoria
Precio mayor a 0
Stock no negativo
Stock mínimo no negativo
```

### Endpoints relacionados

```text
POST /products/create
PUT  /products/update/{product_id}
```

### Prioridad

Alta.

---

## 7. Pantalla: Inventario

### Nombre sugerido del archivo

```text
inventory_screen.dart
```

### Objetivo

Registrar entradas, salidas y ajustes de inventario.

### Elementos visuales

```text
Selector de producto
Stock actual
Tipo de movimiento
Campo cantidad
Campo motivo
Campo referencia
Botón registrar movimiento
```

### Tipos de movimiento

```text
entrada
salida
ajuste
```

### Endpoints relacionados

```text
POST /inventory/stock/adjust/{product_id}
GET  /products/admin
```

### Prioridad

Alta.

---

## 8. Pantalla: Movimientos de stock

### Nombre sugerido del archivo

```text
stock_movements_screen.dart
```

### Objetivo

Consultar historial de movimientos de inventario.

### Elementos visuales

```text
Lista de movimientos
Filtro por producto
Filtro por tipo
Fecha del movimiento
Producto
Stock anterior
Cantidad
Stock nuevo
Motivo
Usuario
Referencia
```

### Endpoints relacionados

```text
GET /inventory/stock/history
GET /inventory/stock/history?product_id={id}
```

### Prioridad

Media.

---

## 9. Pantalla: Clientes

### Nombre sugerido del archivo

```text
customers_screen.dart
```

### Objetivo

Administrar clientes del negocio.

### Elementos visuales

```text
Buscador de clientes
Lista de clientes
Tarjeta por cliente
Botón flotante: Agregar cliente
Botón ver detalle
Botón editar
Botón desactivar
```

### Campos por cliente

```text
ID
Nombre
Teléfono
Alias
Notas
Estado activo/inactivo
Fecha de creación
```

### Endpoints relacionados

```text
GET    /customers/admin
POST   /customers/create
GET    /customers/{customer_id}
PUT    /customers/update/{customer_id}
DELETE /customers/delete/{customer_id}
```

### Prioridad

Alta.

---

## 10. Pantalla: Detalle de cliente

### Nombre sugerido del archivo

```text
customer_detail_screen.dart
```

### Objetivo

Ver la información completa de un cliente y su resumen financiero.

### Elementos visuales

```text
Datos del cliente
Total fiado
Total pagado
Saldo pendiente
Créditos activos
Lista de fiados del cliente
Botón crear fiado
Botón registrar abono
```

### Endpoints relacionados

```text
GET /customers/{customer_id}
GET /customers/{customer_id}/summary
GET /credits/customer/{customer_id}
```

### Prioridad

Alta.

---

## 11. Pantalla: Formulario de cliente

### Nombre sugerido del archivo

```text
customer_form_screen.dart
```

### Objetivo

Crear o editar clientes.

### Campos del formulario

```text
Nombre
Teléfono
Alias
Notas
Activo
```

### Validaciones

```text
Nombre obligatorio
Nombre mínimo de 2 caracteres
Teléfono opcional
```

### Endpoints relacionados

```text
POST /customers/create
PUT  /customers/update/{customer_id}
```

### Prioridad

Alta.

---

## 12. Pantalla: Fiados

### Nombre sugerido del archivo

```text
credits_screen.dart
```

### Objetivo

Consultar todos los fiados registrados.

### Elementos visuales

```text
Lista de fiados
Filtro por estado
Filtro por cliente
Filtro por fecha límite
Indicador de saldo pendiente
Indicador de estado
Botón crear fiado
Botón registrar abono
Botón cancelar fiado
```

### Estados posibles

```text
pendiente
parcial
pagado
vencido
cancelado
```

### Endpoints relacionados

```text
GET    /credits/admin
GET    /credits/{credit_id}
GET    /credits/customer/{customer_id}
PUT    /credits/update/{credit_id}
DELETE /credits/cancel/{credit_id}
```

### Prioridad

Alta.

---

## 13. Pantalla: Crear fiado

### Nombre sugerido del archivo

```text
credit_form_screen.dart
```

### Objetivo

Registrar una nueva deuda o fiado para un cliente.

### Campos del formulario

```text
Cliente
Concepto
Monto total
Fecha límite
Notas
Usuario responsable
```

### Validaciones

```text
Cliente obligatorio
Concepto obligatorio
Monto mayor a 0
Fecha límite opcional
```

### Endpoints relacionados

```text
POST /credits/create
```

### Prioridad

Alta.

---

## 14. Pantalla: Registrar abono

### Nombre sugerido del archivo

```text
payment_form_screen.dart
```

### Objetivo

Registrar un pago parcial o total de un fiado.

### Campos del formulario

```text
Fiado
Cliente
Saldo pendiente
Monto del abono
Método de pago
Nota
Usuario responsable
```

### Métodos de pago

```text
efectivo
transferencia
tarjeta
otro
```

### Validaciones

```text
Monto mayor a 0
Monto no debe exceder saldo pendiente
Fiado no debe estar pagado
Fiado no debe estar cancelado
```

### Endpoints relacionados

```text
POST /credits/pay/{credit_id}
GET  /credits/{credit_id}
GET  /credits/payments/{credit_id}
```

### Prioridad

Alta.

---

## 15. Pantalla: Historial de pagos

### Nombre sugerido del archivo

```text
credit_payments_screen.dart
```

### Objetivo

Consultar los pagos realizados sobre un fiado.

### Elementos visuales

```text
Lista de pagos
Monto pagado
Método de pago
Nota
Usuario
Fecha
```

### Endpoints relacionados

```text
GET /credits/payments/{credit_id}
```

### Prioridad

Media.

---

## 16. Pantalla: Reportes

### Nombre sugerido del archivo

```text
business_reports_screen.dart
```

### Objetivo

Mostrar reportes generales del negocio.

### Reportes iniciales sugeridos

```text
Total pendiente por cobrar
Clientes con deuda
Productos con stock bajo
Movimientos recientes de stock
Fiados activos
Fiados pagados
Pagos recibidos
```

### Endpoints relacionados

```text
GET /customers/admin
GET /credits/admin
GET /inventory/stock/low
GET /inventory/stock/history
```

### Prioridad

Media.

---

## 17. Pantalla: Ajustes del negocio

### Nombre sugerido del archivo

```text
business_settings_screen.dart
```

### Objetivo

Configurar datos generales del módulo.

### Configuraciones sugeridas

```text
Nombre del negocio
Teléfono de contacto
Mensaje base de WhatsApp
Categorías de productos
Token temporal de desarrollo
URL base de API
Modo local / producción
```

### Prioridad

Baja.

---

## 18. Servicios necesarios en Flutter

```text
ProductService
InventoryService
CustomerService
CreditService
BusinessDashboardService
```

---

## 19. Modelos necesarios en Flutter

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

## 20. Widgets reutilizables

```text
BusinessSummaryCard
ProductCard
CustomerCard
CreditCard
StockMovementTile
PaymentTile
EmptyStateWidget
LoadingWidget
ErrorMessageWidget
ConfirmDialog
```

---

## 21. Orden recomendado de programación

```text
1. Crear configuración de API.
2. Crear modelos Dart.
3. Crear servicios HTTP.
4. Probar ProductService.
5. Crear ProductsScreen en modo lectura.
6. Crear CustomerService.
7. Crear CustomersScreen.
8. Crear CreditService.
9. Crear CreditsScreen.
10. Crear PaymentFormScreen.
11. Crear InventoryService.
12. Crear InventoryScreen.
13. Crear StockMovementsScreen.
14. Crear Dashboard del negocio.
15. Crear reportes.
16. Mejorar seguridad y autenticación.
```

---

## 22. Riesgos

### Riesgo: Pantallas demasiado grandes

Control:

```text
Separar pantallas por responsabilidad.
Usar widgets reutilizables.
No meter toda la lógica dentro de un solo archivo.
```

### Riesgo: Romper app actual

Control:

```text
Crear módulo separado.
No modificar pantallas existentes al inicio.
Conectar navegación de forma gradual.
```

### Riesgo: Token expuesto

Control:

```text
Usar token solo en desarrollo.
No subirlo a GitHub.
Reemplazarlo por autenticación real.
```

### Riesgo: Errores de conexión local

Control:

```text
Usar http://10.0.2.2:8000 en emulador Android.
Usar IP local en dispositivo físico.
Usar URL pública en producción.
```

---

## 23. Conclusión

El módulo **Mi Negocio** será integrado a Cash Control como una sección administrativa independiente.
Primero se construirán modelos y servicios, después pantallas de lectura y finalmente formularios administrativos.

Este enfoque permite conectar Flutter con FastAPI sin romper la app actual y manteniendo una arquitectura limpia.
