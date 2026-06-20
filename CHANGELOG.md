# Changelog

Todos los cambios importantes del proyecto serán documentados en este archivo.

[0.7.0] - 2026-06-14
Agregado
Modelo StockAdjustment.
Modelo StockMovement.
Modelo StockHistoryResponse.
Endpoint POST /inventory/stock/adjust/{product_id}.
Endpoint GET /inventory/stock/history.
Endpoint GET /inventory/stock/low.
Repositorio inventory_repository.py.
Colección stock_movements en MongoDB Atlas.
Registro de movimientos de entrada.
Registro de movimientos de salida.
Registro de ajustes manuales.
Consulta de historial general y por producto.
Consulta de productos con stock bajo.
Índices para historial de movimientos.
Modificado
main.py ahora registra rutas de inventario.
La API cambió a versión 0.3.0.
El backend ahora puede auditar cambios de stock.
Seguridad
Los endpoints de inventario requieren x-admin-token.
El historial de stock queda protegido como información administrativa.
El sistema rechaza salidas de stock mayores al inventario disponible.
Pendiente
Conectar historial de stock con la app Flutter.
Crear pantalla de movimientos de inventario.
Registrar ventas reales como salidas automáticas.
Agregar reportes de pérdidas, ajustes y rotación.
Agregar usuario real autenticado en lugar de texto manual.

## [0.5.0] - 2026-06-14

### Agregado

- Conexión de FastAPI con MongoDB Atlas.
- Archivo `backend/app/database.py` para manejar conexión a base de datos.
- Repositorio `product_repository.py` para separar lógica de datos.
- Creación de índices para productos.
- Inserción inicial de productos si la colección está vacía.
- Lectura de productos desde la colección `products`.
- Uso de variables de entorno para credenciales.
- Archivo `.env.example` actualizado con variables de MongoDB.

### Modificado

- El endpoint `/products/public` ahora obtiene productos desde MongoDB Atlas.
- El endpoint `/products/admin` ahora obtiene productos desde MongoDB Atlas.
- El endpoint `/health` ahora verifica conexión con la base de datos.
- La API cambió de versión `0.1.0` a `0.2.0`.

### Seguridad

- Se protegió el archivo `backend/.env` mediante `.gitignore`.
- Las credenciales reales no se suben a GitHub.
- Se mantiene `backend/.env.example` como plantilla segura.

### Pendiente

- Proteger `/products/admin` con autenticación.
- Conectar productos administrativos con la app Flutter.
- Crear endpoints para crear, actualizar y eliminar productos.
- Configurar CORS seguro para producción.
- Desplegar backend en Render.

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