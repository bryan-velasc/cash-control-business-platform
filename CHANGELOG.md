# Changelog

Todos los cambios importantes del proyecto serán documentados en este archivo.

## [0.3.0] - 2026-06-14

### Agregado

- Archivo `js/productos.js` como base temporal de productos.
- Carga dinámica del catálogo desde JavaScript.
- Visualización de precio por producto.
- Visualización de stock por producto.
- Estado de producto agotado.
- Botón para eliminar productos del carrito.
- Mensaje cuando no hay productos encontrados.

### Modificado

- El archivo `index.html` dejó de contener productos escritos manualmente.
- El catálogo ahora se renderiza desde `app.js`.
- El carrito ahora trabaja con IDs de productos.
- Los filtros y buscador ahora usan la base temporal `PRODUCTOS`.

### Pendiente

- Conectar productos con FastAPI.
- Administrar stock desde Cash Control.
- Sustituir `js/productos.js` por datos reales del backend.
- Descontar stock real al confirmar una venta.

## [0.2.2] - 2026-06-14

### Agregado

- Header móvil para la página web.
- Menú inferior móvil.
- Botón de carrito en versión celular.
- Carrito desplegable lateral en móvil.
- Contador de productos en carrito.
- Funciones JavaScript para abrir y cerrar carrito móvil.

### Mejorado

- Adaptación responsive del dashboard.
- Catálogo en dos columnas para celular.
- Mejor visualización de filtros en móvil.
- Mejor comportamiento de modales en pantallas pequeñas.

### Pendiente

- Optimizar detalles visuales finales en móvil.
- Conectar catálogo con backend.
- Conectar stock real con Cash Control.
- Conectar clientes, pagos y fidelidad con datos reales.

## [0.2.1] - 2026-06-14

### Agregado

- Funcionalidad para botones del menú lateral.
- Modal de consulta de clientes.
- Modal de programa de fidelidad.
- Modal de métodos de pago.
- Modal de comentarios.
- Modal de calificación con estrellas.
- Funciones demo para futuras conexiones con Cash Control.

### Mejorado

- El botón `Products` y `Catalog` reinician filtros y buscador.
- El carrito actualiza compras, puntos y total.
- El botón `Pagar Ahora` genera pedido por WhatsApp.

### Pendiente

- Conectar clientes reales desde backend.
- Conectar fidelidad real desde Cash Control.
- Conectar pagos reales.
- Guardar comentarios en base de datos.
- Guardar calificaciones en base de datos.

## [0.1.1] - 2026-06-14

### Agregado

- Importación de la página web actual de venta de dulces.
- Integración de la web dentro de la carpeta `web-dulces/`.
- Fusión de la rama `feature/importar-web-dulces` con `main`.
- Creación de base para iniciar el rediseño web.

### Pendiente

- Revisar estructura real de archivos HTML, CSS, JavaScript e imágenes.
- Mejorar diseño visual.
- Preparar catálogo para conexión futura con backend.
- Documentar cambios visuales y técnicos.

## [0.1.0] - 2026-06-14

### Agregado

- Creación de estructura inicial del proyecto.
- Documentación base.
- Archivo README.
- Archivo SECURITY.
- Archivo ROADMAP.
- Archivo CHANGELOG.
- Carpeta para documentación.
- Carpeta para evidencias.
- Separación inicial entre web, backend y app móvil.

### Pendiente

- Subir proyecto a GitHub.
- Importar página web actual.
- Documentar arquitectura actual.
- Iniciar rediseño de página web.