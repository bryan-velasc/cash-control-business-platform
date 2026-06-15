# Arquitectura Actual del Proyecto

## Estado actual de la página web

La página web de venta de dulces se encuentra alojada en Netlify. Actualmente está desarrollada con HTML, CSS y posiblemente JavaScript básico.

La función principal de la página es mostrar productos mediante imágenes y precios. No cuenta todavía con conexión a base de datos, carrito de compras, pagos, control de clientes, inventario dinámico ni redirecciones funcionales.

## Funciones actuales de la página

- Mostrar imágenes de productos.
- Mostrar precios.
- Funcionar como catálogo visual.
- Estar publicada en Netlify.

## Limitaciones actuales de la página

- No registra pedidos.
- No registra ventas.
- No actualiza stock.
- No tiene control de clientes.
- No muestra información personalizada.
- No tiene integración con Cash Control.
- No tiene conexión con backend.
- No tiene sistema de pagos.
- No tiene programa de fidelidad.
- No tiene protección de datos de clientes.

## Estado actual de Cash Control

Cash Control conserva su estructura original como aplicación móvil con backend y base de datos.

El objetivo es ampliar sus funciones para convertirla también en un panel administrativo para el negocio de venta de dulces.

## Funciones actuales relacionadas

Actualmente Cash Control ya cuenta con una base para manejar información financiera. La intención es integrar nuevos módulos de negocio como:

- Productos.
- Stock.
- Inventario.
- Clientes.
- Fiados.
- Pagos.
- Ganancias.
- Pérdidas.
- Reportes predictivos.

## Arquitectura actual general

```text
Página web en Netlify
        |
        v
Muestra productos estáticos
        |
        v
No existe conexión directa con Cash Control todavía

---

## Actualización: importación de página web actual

La página web actual de venta de dulces fue importada al repositorio dentro de la carpeta `web-dulces/`.

Esta importación permite trabajar el rediseño, control de versiones, documentación y futuras conexiones con Cash Control desde un entorno organizado.

La página se mantiene como frontend estático y será modificada por fases para evitar romper su funcionamiento actual.

## Estado después de la importación

- La página ya forma parte del repositorio.
- La página se encuentra dentro de `web-dulces/`.
- El proyecto ya puede controlar cambios mediante Git y GitHub.
- Se creó una rama específica para importar la página.
- La rama fue fusionada con `main`.

## Próxima fase

La siguiente fase consiste en rediseñar la página web, mejorar colores, estructura visual, presentación de productos y preparar la base para futuras conexiones con el backend.