# Changelog

Todos los cambios importantes del proyecto serán documentados en este archivo.

## [0.4.1] - 2026-06-14

### Agregado

- Conexión de la página web con el endpoint `GET /products/public`.
- Carga de productos desde FastAPI.
- Respaldo local usando `js/productos.js` si la API no responde.
- Mensaje de aviso cuando la página entra en modo local.
- Variable `API_PRODUCTOS_URL` en `app.js`.

### Mejorado

- El catálogo ya no depende únicamente de productos locales.
- La web queda preparada para conectarse con backend en producción.
- El flujo de productos se acerca a la arquitectura final Netlify + FastAPI + Cash Control.

### Pendiente

- Cambiar URL local por URL pública de Render.
- Conectar productos con MongoDB Atlas.
- Administrar productos desde Cash Control.
- Proteger endpoints administrativos.
- Configurar CORS de forma segura para producción.

## [0.4.0] - 2026-06-14

### Agregado

- Backend inicial con FastAPI.
- Endpoint raíz `GET /`.
- Endpoint de salud `GET /health`.
- Endpoint público de productos `GET /products/public`.
- Endpoint administrativo demo `GET /products/admin`.
- Endpoint para consultar producto por ID `GET /products/{product_id}`.
- Modelo público de producto.
- Modelo administrativo de producto.
- Base temporal de productos en backend.
- Configuración inicial de CORS.
- Archivo `requirements.txt`.
- Archivo `.env.example`.

### Mejorado

- Se separó la información pública de productos respecto a la información administrativa.
- La página web queda preparada para consumir productos desde backend.
- Se agregó documentación automática mediante Swagger en `/docs`.

### Pendiente

- Conectar la página web con `GET /products/public`.
- Sustituir `js/productos.js` por consumo real de API.
- Proteger endpoint `/products/admin`.
- Conectar productos con MongoDB Atlas.
- Administrar productos desde Cash Control.

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