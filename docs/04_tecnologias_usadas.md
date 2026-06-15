# Tecnologías Usadas en el Proyecto

## Objetivo del documento

Este documento describe las tecnologías utilizadas y planeadas para el desarrollo de Cash Control Business Platform, explicando el motivo de su elección, su función dentro del sistema y su relación con la escalabilidad, rendimiento y seguridad del proyecto.

---

## Tecnologías principales

El proyecto se divide en cuatro áreas principales:

1. Página web pública.
2. Backend.
3. Base de datos.
4. Aplicación móvil administrativa.

---

## HTML

### Uso en el proyecto

HTML se utiliza para construir la estructura base de la página web de venta de dulces.

Actualmente, la página web está desarrollada principalmente con HTML y muestra imágenes, nombres y precios de productos.

### Motivo de elección

HTML es una tecnología estándar para crear páginas web. Es ligera, rápida y compatible con todos los navegadores modernos.

### Ventajas

* Es fácil de mantener.
* Tiene buen rendimiento.
* No requiere instalación del lado del cliente.
* Permite crear una página estática rápida.
* Funciona correctamente con Netlify.

### Relación con seguridad

HTML no debe contener información sensible como claves, tokens o datos privados. La información sensible debe mantenerse en el backend.

---

## CSS

### Uso en el proyecto

CSS se utiliza para dar diseño visual a la página web, incluyendo colores, tamaños, distribución, botones, tarjetas de productos y diseño responsive.

### Motivo de elección

CSS permite mejorar la apariencia del sitio sin afectar directamente la lógica del sistema.

### Ventajas

* Mejora la experiencia del usuario.
* Permite adaptar la página a celulares.
* Mantiene separado el diseño de la estructura.
* Ayuda a crear una identidad visual para el negocio.

### Relación con rendimiento

Un CSS bien organizado permite que la página cargue rápido y sea fácil de mantener.

---

## JavaScript

### Uso en el proyecto

JavaScript se utilizará para agregar interacción a la página web.

Sus funciones planeadas incluyen:

* Cargar productos desde el backend.
* Mostrar stock actualizado.
* Enviar pedidos.
* Consultar datos del cliente.
* Mostrar puntos de fidelidad.
* Redirigir a métodos de pago.
* Conectar la página con FastAPI.

### Motivo de elección

JavaScript permite que una página estática tenga comportamiento dinámico sin necesidad de convertir todo el proyecto a un framework más pesado.

### Ventajas

* Es compatible con navegadores modernos.
* Permite consumir APIs.
* Mejora la experiencia del cliente.
* Mantiene la página ligera.

### Relación con seguridad

No se debe confiar completamente en JavaScript porque el usuario puede modificarlo desde el navegador. Toda validación importante debe realizarse en el backend.

---

## Netlify

### Uso en el proyecto

Netlify se utiliza para alojar la página web de venta de dulces.

### Motivo de elección

Netlify permite publicar páginas web estáticas de forma rápida, sencilla y con buen rendimiento.

### Ventajas

* Despliegue sencillo.
* Buen rendimiento para sitios estáticos.
* Integración con GitHub.
* Certificados HTTPS.
* Actualización automática al subir cambios.

### Relación con escalabilidad

Netlify permite mantener la página pública separada del backend. Esto ayuda a que el sitio siga siendo rápido aunque el sistema crezca.

### Relación con seguridad

La página en Netlify no debe contener claves privadas. Las operaciones sensibles deben enviarse al backend.

---

## Flutter

### Uso en el proyecto

Flutter se utiliza para desarrollar la aplicación Cash Control.

Cash Control funcionará como panel administrativo del negocio.

Desde la app se podrán administrar:

* Productos.
* Stock.
* Inventario.
* Clientes.
* Fiados.
* Pagos.
* Proveedores.
* Ganancias.
* Pérdidas.
* Reportes.
* Predicciones de venta.

### Motivo de elección

Flutter permite crear aplicaciones móviles con una sola base de código, manteniendo una interfaz moderna y adaptable.

### Ventajas

* Desarrollo móvil rápido.
* Interfaz personalizable.
* Buen rendimiento.
* Permite crear pantallas administrativas completas.
* Se puede conectar fácilmente con APIs mediante HTTP.

### Relación con seguridad

La app no debe conectarse directamente a MongoDB. Debe comunicarse con FastAPI, que será el encargado de validar permisos y operaciones.

---

## FastAPI

### Uso en el proyecto

FastAPI funciona como backend principal del sistema.

Sus funciones serán:

* Recibir solicitudes de la página web.
* Recibir solicitudes desde Cash Control.
* Validar datos.
* Consultar MongoDB.
* Registrar ventas.
* Registrar pagos.
* Actualizar inventario.
* Proteger endpoints administrativos.
* Generar reportes.

### Motivo de elección

FastAPI es un framework moderno de Python para construir APIs rápidas, organizadas y escalables.

### Ventajas

* Alto rendimiento.
* Código limpio.
* Validación de datos con modelos.
* Documentación automática de endpoints.
* Buena integración con MongoDB.
* Fácil despliegue en Render.

### Relación con seguridad

FastAPI será la capa principal de seguridad del sistema. Desde ahí se validarán entradas, permisos, pagos, clientes, stock y operaciones administrativas.

---

## MongoDB Atlas

### Uso en el proyecto

MongoDB Atlas será la base de datos en la nube.

Almacenará información como:

* Productos.
* Clientes.
* Fiados.
* Pagos.
* Ventas.
* Proveedores.
* Inventario.
* Fidelidad.
* Recordatorios.
* Reportes.

### Motivo de elección

MongoDB permite trabajar con documentos flexibles, lo cual es útil para un sistema que puede crecer con nuevos módulos.

### Ventajas

* Base de datos flexible.
* Escalable.
* Funciona en la nube.
* Permite guardar documentos complejos.
* Buena integración con Python y FastAPI.

### Relación con seguridad

MongoDB no debe exponerse directamente al frontend. El acceso debe estar protegido mediante variables de entorno y controlado desde el backend.

---

## Render

### Uso en el proyecto

Render se utiliza para alojar el backend FastAPI.

### Motivo de elección

Render permite desplegar APIs de forma sencilla y conectarlas con servicios externos como MongoDB Atlas.

### Ventajas

* Despliegue rápido.
* Compatible con Python y FastAPI.
* Permite variables de entorno.
* Puede conectarse con GitHub.
* Facilita mantener el backend en línea.

### Relación con seguridad

Las claves del backend, base de datos, pagos y SMS deben guardarse como variables de entorno en Render y no dentro del código.

---

## Git

### Uso en el proyecto

Git se utiliza para llevar control de versiones del proyecto.

### Motivo de elección

Git permite registrar cada cambio realizado en el código y la documentación.

### Ventajas

* Historial de cambios.
* Control de versiones.
* Posibilidad de regresar a versiones anteriores.
* Trabajo ordenado por commits.
* Mejor documentación del avance.

### Relación con ciberseguridad

Git permite demostrar trazabilidad, control de cambios, análisis de errores y disciplina técnica.

---

## GitHub

### Uso en el proyecto

GitHub se utiliza para alojar el repositorio del proyecto.

### Motivo de elección

GitHub permite mostrar el proyecto como portafolio profesional, mantener documentación, evidencias y control de versiones.

### Ventajas

* Portafolio público.
* Integración con Netlify y Render.
* Documentación visible.
* Control de ramas.
* Historial profesional de commits.
* Evidencia para vacantes.

### Relación con seguridad

No deben subirse contraseñas, tokens, API keys ni archivos `.env`.

---

## Servicios externos planeados

### Proveedor de pagos

Se planea integrar un proveedor de pagos para aceptar tarjeta.

El flujo será:

1. Cliente elige pagar con tarjeta.
2. La página solicita crear pago al backend.
3. El backend genera la orden.
4. El proveedor procesa el pago.
5. El backend confirma el estado.
6. Cash Control actualiza la deuda o venta.

### Servicio de SMS

Se planea usar un servicio de SMS para enviar recordatorios de pago.

El flujo será:

1. Cada viernes se revisan clientes con deuda.
2. El sistema envía recordatorio.
3. Se registra el envío.
4. Si el cliente paga, se marca como cumplido.
5. Si no paga, se mantiene como pendiente o atrasado.

---

## Justificación general de la arquitectura

La combinación de estas tecnologías permite separar responsabilidades:

* Netlify muestra la página pública.
* FastAPI valida y procesa datos.
* MongoDB almacena la información.
* Cash Control administra el negocio.
* GitHub documenta y registra el avance.

Esta separación mejora el rendimiento, la seguridad y la escalabilidad del sistema.

---

## Conclusión

Las tecnologías seleccionadas permiten construir una plataforma ligera, escalable y segura. La página web se mantiene rápida, el backend centraliza la lógica, la base de datos guarda la información y Cash Control funciona como panel administrativo.

Además, el uso de GitHub y documentación técnica fortalece el proyecto como evidencia profesional para áreas de desarrollo seguro y ciberseguridad.
