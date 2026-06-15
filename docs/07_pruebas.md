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

# Conclusión

El plan de pruebas permitirá validar cada parte del sistema antes de avanzar a nuevas fases. Esto reduce errores, mejora la seguridad y genera evidencia profesional del proceso de desarrollo.

Este documento se actualizará conforme se implementen nuevos módulos y se realicen nuevas pruebas.
