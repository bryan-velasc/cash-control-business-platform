# Plan de Pruebas del Proyecto

## Objetivo del documento

Este documento describe las pruebas que se realizarán en Cash Control Business Platform para validar el funcionamiento, seguridad, rendimiento y confiabilidad del sistema.

La finalidad es asegurar que la página web, el backend, la base de datos y la aplicación Cash Control funcionen correctamente antes de pasar a nuevas fases de desarrollo.

---

## Importancia de las pruebas

Las pruebas permiten verificar que el sistema cumple con sus objetivos y que los errores son detectados antes de afectar al usuario final.

También ayudan a documentar evidencia profesional para demostrar buenas prácticas de desarrollo, seguridad y control de calidad.

---

## Componentes a probar

El proyecto se divide en los siguientes componentes:

* Página web de dulces.
* Backend FastAPI.
* Base de datos MongoDB Atlas.
* Aplicación Cash Control.
* Módulo de clientes.
* Módulo de fiados.
* Módulo de inventario.
* Módulo de pagos.
* Módulo de SMS.
* Módulo de fidelidad.
* Módulo de reportes.

---

# Tipos de pruebas

## 1. Pruebas visuales de la página web

### Objetivo

Verificar que la página web se vea correctamente en computadoras y celulares.

### Elementos a revisar

* Diseño general.
* Colores.
* Imágenes.
* Botones.
* Catálogo.
* Precios.
* Responsive en celular.
* Legibilidad.
* Orden visual.
* Carga correcta de archivos CSS y JavaScript.

### Resultado esperado

La página debe verse clara, profesional y funcional en diferentes tamaños de pantalla.

---

## 2. Pruebas funcionales de la página web

### Objetivo

Validar que las funciones principales de la página web trabajen correctamente.

### Pruebas planeadas

* Cargar productos.
* Mostrar precios.
* Mostrar stock.
* Abrir botón de WhatsApp.
* Consultar información privada de cliente.
* Mostrar puntos de fidelidad.
* Mostrar métodos de pago.
* Evitar mostrar información no autorizada.

### Resultado esperado

La página debe mostrar únicamente la información permitida para el usuario.

---

## 3. Pruebas del backend

### Objetivo

Verificar que los endpoints de FastAPI funcionen correctamente.

### Herramientas sugeridas

* Navegador.
* Swagger UI de FastAPI.
* Postman.
* Thunder Client.
* PowerShell.
* Logs de Render.

### Pruebas planeadas

* Crear producto.
* Obtener productos públicos.
* Actualizar stock.
* Registrar cliente.
* Crear deuda.
* Registrar pago.
* Consultar deuda de cliente.
* Generar reporte de ganancias.
* Generar reporte de pérdidas.
* Consultar stock bajo.

### Resultado esperado

Cada endpoint debe responder con datos correctos y códigos HTTP adecuados.

---

## 4. Pruebas de base de datos

### Objetivo

Verificar que MongoDB Atlas almacene y recupere datos correctamente.

### Pruebas planeadas

* Insertar producto.
* Consultar producto.
* Actualizar stock.
* Registrar cliente.
* Registrar pago.
* Consultar historial de pagos.
* Verificar que las deudas pagadas no se eliminen del historial.
* Verificar que los datos sensibles no se expongan en consultas públicas.

### Resultado esperado

La base de datos debe guardar información consistente, actualizada y protegida.

---

## 5. Pruebas de seguridad

### Objetivo

Detectar riesgos relacionados con acceso no autorizado, exposición de datos y manipulación de información.

### Pruebas planeadas

* Intentar consultar información de otro cliente.
* Intentar modificar montos desde el frontend.
* Intentar acceder a endpoints administrativos sin autorización.
* Verificar que `.env` no esté en GitHub.
* Verificar que no existan claves privadas en el repositorio.
* Probar entradas inválidas en formularios.
* Probar IDs inexistentes.
* Probar montos negativos.
* Probar cantidades de stock negativas.

### Resultado esperado

El sistema debe rechazar operaciones inválidas o no autorizadas.

---

## 6. Pruebas de pagos

### Objetivo

Validar que los pagos se registren de forma correcta y segura.

### Métodos de pago a probar

* Efectivo.
* Transferencia.
* Tarjeta.

### Pruebas planeadas

#### Pago en efectivo

* Registrar pago manual desde Cash Control.
* Verificar que disminuya la deuda.
* Verificar que se guarde el historial.

#### Pago por transferencia

* Registrar pago pendiente.
* Confirmar pago.
* Rechazar pago si no coincide.
* Guardar referencia o comprobante si aplica.

#### Pago con tarjeta

* Crear orden de pago.
* Confirmar pago desde backend.
* Validar monto.
* Actualizar deuda solo si el pago fue confirmado.

### Resultado esperado

El sistema no debe marcar una deuda como pagada sin validación.

---

## 7. Pruebas de inventario

### Objetivo

Verificar que el stock se administre correctamente desde Cash Control y se refleje en la página web.

### Pruebas planeadas

* Crear producto con stock inicial.
* Aumentar stock.
* Reducir stock.
* Registrar venta y descontar stock.
* Detectar stock bajo.
* Evitar stock negativo.
* Mostrar stock actualizado en la web.

### Resultado esperado

El inventario debe mantenerse sincronizado entre Cash Control, backend, base de datos y página web.

---

## 8. Pruebas de clientes y fiados

### Objetivo

Validar el control de clientes, deudas, pagos y fechas de cobro.

### Pruebas planeadas

* Crear cliente.
* Crear deuda.
* Registrar pago parcial.
* Registrar pago completo.
* Verificar restante por pagar.
* Ocultar deuda activa cuando esté pagada.
* Mantener historial de pagos.
* Consultar datos del cliente desde la web con acceso privado.

### Resultado esperado

El cliente solo debe ver sus propios datos y las deudas deben actualizarse correctamente.

---

## 9. Pruebas de SMS

### Objetivo

Verificar que los recordatorios de pago funcionen correctamente.

### Pruebas planeadas

* Detectar clientes con deuda pendiente.
* Enviar recordatorio el viernes.
* Registrar SMS enviado.
* Verificar si el cliente pagó.
* Marcar estado como pendiente, pagado o atrasado.

### Resultado esperado

El sistema debe recordar pagos sin duplicar mensajes innecesarios.

---

## 10. Pruebas de fidelidad

### Objetivo

Validar que el programa de puntos funcione correctamente.

### Pruebas planeadas

* Sumar puntos por compra.
* Consultar puntos del cliente.
* Canjear puntos.
* Evitar canjear más puntos de los disponibles.
* Registrar historial de recompensas.

### Resultado esperado

Los puntos deben calcularse correctamente y no deben poder manipularse desde el frontend.

---

## 11. Pruebas de reportes

### Objetivo

Verificar que los reportes sean útiles y correctos.

### Reportes a probar

* Ventas diarias.
* Ventas semanales.
* Ganancias estimadas.
* Pérdidas.
* Productos más vendidos.
* Productos con bajo stock.
* Clientes frecuentes.
* Clientes con deuda pendiente.
* Predicción de ventas.

### Resultado esperado

Los reportes deben mostrar información correcta basada en datos reales del sistema.

---

# Formato para registrar pruebas

Cada prueba se documentará con el siguiente formato:

```text
ID de prueba:
Fecha:
Módulo:
Función probada:
Datos utilizados:
Pasos realizados:
Resultado esperado:
Resultado obtenido:
Estado:
Observaciones:
```

---

# Casos de prueba iniciales

## PRU-001: Verificar estado del repositorio

### ID de prueba

PRU-001

### Fecha

14/06/2026

### Módulo

Git / GitHub

### Función probada

Verificar que el repositorio local no tenga cambios pendientes después de subir documentación.

### Datos utilizados

Comando:

```powershell
git status
```

### Resultado esperado

```text
nothing to commit, working tree clean
```

### Resultado obtenido

Pendiente de registrar.

### Estado

Pendiente.

---

## PRU-002: Verificar estructura inicial de carpetas

### ID de prueba

PRU-002

### Fecha

14/06/2026

### Módulo

Estructura del proyecto

### Función probada

Validar que existan las carpetas principales del proyecto.

### Carpetas esperadas

* docs/
* web-dulces/
* backend/
* cash-control-app/
* evidencias/

### Resultado esperado

Todas las carpetas deben existir en el repositorio.

### Resultado obtenido

Pendiente de registrar.

### Estado

Pendiente.

---

## PRU-003: Verificar que el archivo .env esté ignorado

### ID de prueba

PRU-003

### Fecha

14/06/2026

### Módulo

Seguridad / Git

### Función probada

Confirmar que archivos `.env` no sean rastreados por Git.

### Resultado esperado

Git no debe subir archivos `.env` al repositorio.

### Estado

Pendiente.

---

## PRU-004: Verificar página web actual

### ID de prueba

PRU-004

### Fecha

14/06/2026

### Módulo

Página web

### Función probada

Confirmar que la página web actual carga correctamente como catálogo visual.

### Resultado esperado

La página debe mostrar productos, imágenes y precios.

### Estado

Pendiente.

---

## PRU-005: Verificar conexión futura con backend

### ID de prueba

PRU-005

### Fecha

14/06/2026

### Módulo

Página web / Backend

### Función probada

Validar que la página pueda consumir productos desde un endpoint público.

### Endpoint esperado

```text
GET /products/public
```

### Resultado esperado

La página debe mostrar productos obtenidos desde el backend.

### Estado

Pendiente de implementación.

---

# Evidencias de pruebas

Las evidencias se guardarán en:

```text
evidencias/pruebas_api/
evidencias/capturas/
evidencias/diagramas/
```

Ejemplos de evidencias:

* Capturas de pantalla.
* Respuestas de API.
* Logs de errores.
* Capturas de Postman.
* Capturas de MongoDB.
* Capturas de Netlify.
* Capturas de Render.
* Resultados de pruebas de seguridad.

---

---

## PRU-007: Verificar botones funcionales del dashboard web

### ID de prueba

PRU-007

### Fecha

14/06/2026

### Módulo

Página web / Interactividad

### Función probada

Verificar que los botones principales del dashboard web tengan comportamiento funcional mediante JavaScript.

### Archivos modificados

- `web-dulces/index.html`
- `web-dulces/css/estilos.css`
- `web-dulces/js/app.js`

### Botones probados

- Products.
- Catalog.
- Clientes.
- Fidelidad.
- Pagos.
- Rate Servicio.
- Comentarios.
- Pagar Ahora.
- Añadir al Carrito.
- Vaciar carrito.

### Pasos realizados

1. Se abrió la página localmente desde `web-dulces/index.html`.
2. Se seleccionó el botón `Products`.
3. Se seleccionó el botón `Catalog`.
4. Se abrió el modal de `Clientes`.
5. Se abrió el modal de `Fidelidad`.
6. Se abrió el modal de `Pagos`.
7. Se abrió el modal de `Rate Servicio`.
8. Se seleccionó una calificación con estrellas.
9. Se abrió el modal de `Comentarios`.
10. Se agregaron productos al carrito.
11. Se verificó el total del carrito.
12. Se probó el botón `Pagar Ahora`.

### Resultado esperado

Los botones deben responder correctamente sin recargar la página ni romper el diseño.

### Resultado obtenido

Los botones principales quedaron funcionales mediante JavaScript. Las secciones de clientes, fidelidad, pagos, calificación y comentarios funcionan mediante ventanas modales. El carrito permite agregar productos, calcular totales, generar puntos de fidelidad y enviar el pedido por WhatsApp.

### Estado

Completado.

### Observaciones

Las funciones actuales son demostrativas. En una fase posterior se conectarán con FastAPI y Cash Control para usar datos reales de clientes, pagos, fidelidad y ventas.

---

## PRU-008: Verificar diseño responsive móvil

### ID de prueba

PRU-008

### Fecha

14/06/2026

### Módulo

Página web / Responsive

### Función probada

Verificar que la página web tipo dashboard funcione correctamente en dispositivos móviles.

### Archivos modificados

- `web-dulces/index.html`
- `web-dulces/css/estilos.css`
- `web-dulces/js/app.js`

### Elementos probados

- Header móvil.
- Menú inferior móvil.
- Botón de carrito móvil.
- Apertura y cierre del carrito.
- Catálogo en dos columnas.
- Buscador.
- Filtros.
- Modales.
- Botón de pago por WhatsApp.

### Pasos realizados

1. Se abrió la página desde `web-dulces/index.html`.
2. Se activó el modo responsive del navegador.
3. Se probó el diseño en tamaño celular.
4. Se agregaron productos al carrito.
5. Se abrió el carrito desde el botón superior.
6. Se cerró el carrito desde el botón `×`.
7. Se probaron los botones del menú inferior.
8. Se verificó que los modales funcionaran correctamente.
9. Se verificó que el catálogo se acomodara en dos columnas.

### Resultado esperado

La página debe adaptarse correctamente a celular sin romper el diseño ni ocultar funciones importantes.

### Resultado obtenido

La página ahora cuenta con versión móvil funcional. Se agregó encabezado móvil, menú inferior, carrito desplegable y ajustes responsive para catálogo, filtros, buscador y modales.

### Estado

Completado.

### Observaciones

El diseño móvil mantiene la estética dashboard oscuro, pero adapta la navegación para que sea más usable en celulares.

---

## PRU-009: Verificar catálogo dinámico con JavaScript

### ID de prueba

PRU-009

### Fecha

14/06/2026

### Módulo

Página web / Catálogo dinámico

### Función probada

Verificar que los productos se carguen dinámicamente desde el archivo `js/productos.js` y que el carrito funcione con la nueva estructura.

### Archivos modificados

- `web-dulces/index.html`
- `web-dulces/js/productos.js`
- `web-dulces/js/app.js`
- `web-dulces/css/estilos.css`

### Elementos probados

- Carga dinámica de productos.
- Visualización de precio.
- Visualización de stock.
- Producto agotado.
- Buscador.
- Filtros por categoría.
- Agregar producto al carrito.
- Evitar agregar productos sin stock.
- Eliminar productos del carrito.
- Calcular subtotal y total.
- Generar pedido por WhatsApp.

### Resultado esperado

Los productos deben mostrarse automáticamente desde JavaScript sin estar escritos directamente en el HTML.

### Resultado obtenido

El catálogo se cargó correctamente desde `js/productos.js`. Los productos muestran nombre, imagen, precio y stock. El producto sin stock aparece como agotado y no puede agregarse al carrito. El buscador, filtros, carrito y WhatsApp funcionan correctamente.

### Estado

Completado.

### Observaciones

Esta estructura prepara el proyecto para que en una fase posterior los productos se carguen desde el backend FastAPI y sean administrados desde Cash Control.

---

## PRU-010: Verificar API pública de productos

### ID de prueba

PRU-010

### Fecha

14/06/2026

### Módulo

Backend / Productos

### Función probada

Verificar que el backend FastAPI entregue productos públicos mediante el endpoint `/products/public`.

### Archivos modificados

- `backend/main.py`
- `backend/requirements.txt`
- `backend/.env.example`
- `backend/app/routes/product_routes.py`
- `backend/app/models/product_model.py`
- `backend/app/data/products_seed.py`

### Endpoints probados

- `GET /`
- `GET /health`
- `GET /products/public`
- `GET /products/admin`
- `GET /products/{product_id}`
- `GET /docs`

### Pasos realizados

1. Se creó entorno virtual en `backend/`.
2. Se instalaron dependencias con `pip install -r requirements.txt`.
3. Se ejecutó el backend con `uvicorn main:app --reload`.
4. Se abrió `http://127.0.0.1:8000`.
5. Se probó `http://127.0.0.1:8000/health`.
6. Se probó `http://127.0.0.1:8000/products/public`.
7. Se verificó la documentación automática en `http://127.0.0.1:8000/docs`.

### Resultado esperado

El endpoint `/products/public` debe devolver una lista de productos activos sin exponer información administrativa como precio de compra, proveedor o ganancia.

### Resultado obtenido

El backend respondió correctamente. El endpoint `/products/public` devolvió la lista de productos públicos con nombre, categoría, precio, imagen, stock y estado activo.

### Estado

Completado.

### Observaciones

El endpoint `/products/admin` todavía es demostrativo y deberá protegerse con autenticación antes de usarse en producción.

---

## PRU-011: Verificar conexión de página web con API de productos

### ID de prueba

PRU-011

### Fecha

14/06/2026

### Módulo

Página web / Backend / Productos

### Función probada

Verificar que la página web cargue productos desde el endpoint público `GET /products/public` del backend FastAPI.

### Archivos modificados

- `web-dulces/js/productos.js`
- `web-dulces/js/app.js`
- `backend/main.py`
- `backend/app/routes/product_routes.py`

### Endpoint utilizado

```text
http://127.0.0.1:8000/products/public

---

## PRU-012: Verificar conexión de FastAPI con MongoDB Atlas

### ID de prueba

PRU-012

### Fecha

14/06/2026

### Módulo

Backend / Base de datos / Productos

### Función probada

Verificar que el backend FastAPI se conecte correctamente con MongoDB Atlas y obtenga productos desde la colección `products`.

### Archivos modificados

- `backend/main.py`
- `backend/requirements.txt`
- `backend/.env.example`
- `backend/app/database.py`
- `backend/app/routes/product_routes.py`
- `backend/app/repositories/product_repository.py`

### Elementos probados

- Lectura de variables de entorno.
- Conexión a MongoDB Atlas.
- Ping de base de datos.
- Creación de índices.
- Inserción inicial de productos si la colección está vacía.
- Consulta pública de productos desde MongoDB.
- Endpoint `/health`.
- Endpoint `/products/public`.

### Resultado esperado

El backend debe iniciar correctamente, conectarse a MongoDB Atlas y devolver productos desde la colección `products`.

### Resultado obtenido

El backend se conectó correctamente con MongoDB Atlas. El endpoint `/health` respondió con estado saludable y el endpoint `/products/public` devolvió los productos desde la colección `products`.

### Estado

Completado.

### Observaciones

El archivo `backend/.env` contiene credenciales reales y no debe subirse a GitHub. Solo debe subirse `backend/.env.example`.

# Conclusión

El plan de pruebas permitirá validar cada parte del sistema antes de avanzar a nuevas fases. Esto reduce errores, mejora la seguridad y genera evidencia profesional del proceso de desarrollo.

Este documento se actualizará conforme se implementen nuevos módulos y se realicen nuevas pruebas.
