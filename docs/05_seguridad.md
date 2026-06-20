# Seguridad del Proyecto

## Objetivo del documento

Este documento describe los riesgos de seguridad identificados en Cash Control Business Platform, así como los controles propuestos para proteger la información del negocio, los clientes, los pagos, el inventario y la comunicación entre la página web, el backend, la base de datos y la aplicación Cash Control.

---

## Importancia de la seguridad en el proyecto

El sistema manejará información sensible relacionada con clientes, ventas, pagos, deudas, inventario y ganancias. Por esta razón, la seguridad debe considerarse desde la etapa de diseño y no únicamente al final del desarrollo.

El objetivo principal es evitar exposición de datos, manipulación de pagos, acceso no autorizado, pérdida de información y errores que puedan afectar la operación del negocio.

---

## Datos sensibles identificados

El sistema puede manejar los siguientes datos sensibles:

* Nombre de clientes.
* Número de teléfono.
* Deudas activas.
* Historial de pagos.
* Métodos de pago.
* Historial de compras.
* Stock e inventario.
* Precios de compra.
* Precios de venta.
* Ganancias.
* Pérdidas.
* Información de proveedores.
* Tokens de autenticación.
* Claves de servicios externos.

---

## Principios de seguridad aplicados

### 1. Separación de responsabilidades

La página web será pública y limitada.
Cash Control será el panel administrativo.
FastAPI será la capa de validación y control.
MongoDB Atlas será la base de datos central.

La página web no debe tener acceso directo a la base de datos.

---

### 2. Mínimo privilegio

Cada parte del sistema debe acceder únicamente a la información que necesita.

Ejemplo:

* Un cliente solo puede ver su propia deuda.
* La página web solo puede leer productos públicos.
* Cash Control puede administrar productos, clientes y pagos.
* El backend valida qué operaciones están permitidas.

---

### 3. No confiar en el frontend

La información enviada desde HTML, CSS o JavaScript puede ser modificada por un usuario desde el navegador.

Por eso, el backend debe validar:

* Montos.
* Productos.
* Stock.
* Pagos.
* Clientes.
* Permisos.
* Fechas.
* Estados de deuda.

---

### 4. Protección de datos privados

La información de clientes no debe mostrarse públicamente.

La vista del cliente debe estar protegida mediante:

* Código privado.
* PIN.
* Token temporal.
* Teléfono validado.
* Inicio de sesión seguro en una fase futura.

---

## Riesgos identificados

### Riesgo 1: Exposición de datos de clientes

Si la página web muestra nombres, teléfonos o deudas sin protección, cualquier persona podría consultar información privada.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Crear una vista privada para clientes mediante PIN, token o código único.

---

### Riesgo 2: Manipulación de pagos desde el navegador

Un usuario podría modificar el total de una compra desde las herramientas del navegador.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Calcular y validar los montos en el backend, no confiar en el total enviado desde el frontend.

---

### Riesgo 3: Modificación no autorizada de stock

Un atacante o usuario no autorizado podría intentar modificar el inventario.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Proteger endpoints administrativos con autenticación y autorización.

---

### Riesgo 4: Exposición de variables de entorno

Si se suben claves privadas a GitHub, podrían ser utilizadas por terceros.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Usar archivo `.env`, variables de entorno en Render y `.gitignore`.

---

### Riesgo 5: Acceso directo a MongoDB

Si la base de datos se expone directamente, la información del negocio puede ser comprometida.

**Impacto:** Alto.
**Probabilidad:** Baja si se configura correctamente.
**Control propuesto:** Permitir acceso únicamente desde el backend y proteger la URI de conexión.

---

### Riesgo 6: Falta de validación de entradas

Los formularios pueden recibir datos incorrectos o maliciosos.

**Impacto:** Medio.
**Probabilidad:** Alta.
**Control propuesto:** Validar entradas con modelos en FastAPI y sanitizar datos antes de procesarlos.

---

### Riesgo 7: Falta de registro de eventos

Si no se registran acciones importantes, será difícil detectar errores, fraudes o accesos indebidos.

**Impacto:** Medio.
**Probabilidad:** Media.
**Control propuesto:** Registrar eventos como creación de ventas, pagos, cambios de stock y consultas de clientes.

---

### Riesgo 8: Confirmación falsa de pagos

Un pago podría marcarse como pagado sin haber sido confirmado correctamente.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Confirmar pagos desde backend y, en pagos con tarjeta, usar webhooks del proveedor de pago.

---

### Riesgo 9: Pérdida de historial financiero

Si las deudas pagadas se eliminan completamente, se pierde trazabilidad.

**Impacto:** Medio.
**Probabilidad:** Media.
**Control propuesto:** No borrar pagos ni deudas del historial; solo cambiar estado a pagado.

---

### Riesgo 10: Exceso de información en endpoints públicos

Un endpoint público podría devolver datos internos como precios de compra, proveedores o ganancias.

**Impacto:** Alto.
**Probabilidad:** Media.
**Control propuesto:** Separar endpoints públicos y administrativos.

---

## Endpoints públicos y privados

### Endpoints públicos permitidos

Los endpoints públicos solo deben devolver información limitada.

Ejemplos:

* Productos activos.
* Precio de venta.
* Stock disponible.
* Imagen del producto.
* Categoría.
* Consulta privada de cliente autenticado.

No deben devolver:

* Precio de compra.
* Proveedor.
* Ganancia.
* Historial interno.
* Todos los clientes.
* Todas las deudas.
* Tokens.
* Datos administrativos.

---

### Endpoints administrativos

Los endpoints administrativos deben requerir autenticación.

Ejemplos:

* Crear producto.
* Editar producto.
* Modificar stock.
* Registrar cliente.
* Registrar fiado.
* Registrar pago.
* Ver reportes.
* Ver ganancias.
* Ver proveedores.

---

## Seguridad en pagos

Los pagos deben manejarse con cuidado porque afectan directamente el dinero del negocio.

### Pago en efectivo

El administrador registra el pago desde Cash Control.

Controles:

* Registrar fecha.
* Registrar monto.
* Registrar cliente.
* Registrar usuario que confirmó.
* Guardar historial.

---

### Pago por transferencia

El administrador debe verificar la transferencia antes de marcarla como pagada.

Controles:

* Registrar referencia.
* Registrar comprobante si aplica.
* Registrar fecha.
* Registrar estado: pendiente, confirmado o rechazado.

---

### Pago con tarjeta

El pago con tarjeta debe confirmarse desde el backend.

Controles:

* No confiar en confirmaciones del frontend.
* Usar webhook del proveedor de pago.
* Validar monto.
* Validar estado del pago.
* Registrar operación.
* Actualizar deuda solo si el pago fue confirmado.

---

## Seguridad en clientes y fiados

La página web solo debe mostrar la información del cliente autenticado.

Datos visibles para el cliente:

* Nombre.
* Monto pendiente.
* Pagos realizados.
* Fecha límite de pago.
* Puntos de fidelidad.
* Estado de deuda.

Datos no visibles para el cliente:

* Lista de todos los clientes.
* Teléfonos de otros clientes.
* Ganancias.
* Precios de compra.
* Proveedores.
* Reportes internos.

---

## Seguridad en inventario

El inventario debe modificarse únicamente desde Cash Control o desde endpoints administrativos protegidos.

Cada movimiento de inventario debe registrar:

* Producto.
* Cantidad agregada o retirada.
* Motivo.
* Fecha.
* Usuario responsable.
* Stock anterior.
* Stock nuevo.

Esto permite auditoría y detección de errores.

---

## Seguridad en variables de entorno

No deben subirse a GitHub:

* URI de MongoDB.
* Claves de API.
* Tokens.
* Credenciales.
* Claves de pagos.
* Claves de SMS.
* Archivos `.env`.

El archivo `.gitignore` debe contener:

```gitignore
.env
*.env
credentials.json
secrets.json
serviceAccountKey.json
```

---

## Seguridad en GitHub

Antes de subir cambios se debe revisar que no existan:

* Contraseñas dentro del código.
* Tokens visibles.
* Archivos `.env`.
* Capturas con datos sensibles.
* Datos reales de clientes.
* Credenciales de servicios externos.

Los commits deben ser claros y profesionales.

Ejemplos:

```text
docs: documentar controles de seguridad
security: agregar riesgos iniciales del sistema
fix: corregir validacion de pagos
feat: agregar autenticacion para clientes
```

---

## Registro de errores y eventos

El sistema deberá registrar eventos importantes como:

* Creación de productos.
* Actualización de stock.
* Registro de clientes.
* Creación de fiados.
* Pagos realizados.
* Recordatorios enviados.
* Errores de autenticación.
* Intentos de consulta inválida.
* Confirmaciones de pago.

Estos registros ayudan a detectar fallos, fraudes o comportamientos anormales.

---

## Buenas prácticas iniciales

* Separar frontend público del backend.
* No confiar en datos enviados desde el navegador.
* Validar datos en FastAPI.
* Proteger endpoints administrativos.
* Usar variables de entorno.
* No subir claves a GitHub.
* No mostrar información sensible públicamente.
* Registrar errores y soluciones.
* Mantener historial de pagos.
* Documentar decisiones técnicas.
* Realizar pruebas antes de subir cambios.

---

## Checklist de seguridad inicial

* [ ] Revisar que `.env` esté en `.gitignore`.
* [ ] Separar endpoints públicos y privados.
* [ ] Definir autenticación para clientes.
* [ ] Definir autenticación para administrador.
* [ ] Validar productos desde backend.
* [ ] Validar pagos desde backend.
* [ ] Evitar exponer precios de compra en la web.
* [ ] Evitar exponer todos los clientes en la web.
* [ ] Registrar movimientos de inventario.
* [ ] Registrar historial de pagos.
* [ ] Documentar errores.
* [ ] Documentar pruebas.
* [ ] Revisar el repositorio antes de hacerlo público.

---

## Nota de seguridad: CORS en desarrollo

Durante la fase de desarrollo, el backend FastAPI permite orígenes amplios para facilitar pruebas locales entre la página web y la API.

Esto no debe mantenerse igual en producción.

### Riesgo

Permitir `*` en CORS puede permitir que otros sitios intenten consumir la API desde navegadores externos.

### Control para producción

Antes de desplegar el backend, se debe limitar CORS únicamente a dominios autorizados, por ejemplo:

- Página web oficial en Netlify.
- Dominio autorizado de Cash Control.
- Entorno local solo para desarrollo.

### Estado

Pendiente de endurecimiento antes de producción.

---

## Conclusión

La seguridad del proyecto debe aplicarse desde el diseño. Cash Control Business Platform manejará información sensible del negocio y de clientes, por lo que es necesario separar responsabilidades, proteger datos privados, validar operaciones desde el backend y mantener trazabilidad.

Este enfoque permite que el proyecto sea más confiable, escalable y útil como evidencia profesional para áreas de ciberseguridad.
