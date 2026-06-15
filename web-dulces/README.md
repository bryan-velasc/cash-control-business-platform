# Página Web de Venta de Dulces

## Descripción

Esta carpeta contiene la página web pública del proyecto Cash Control Business Platform.

La página web funciona actualmente como catálogo visual de productos, mostrando imágenes y precios de dulces. Está pensada para ser alojada en Netlify y posteriormente conectarse con el backend de Cash Control.

## Estado actual

La página web cuenta con:

* Archivo principal `index.html`.
* Carpeta de estilos `css/`.
* Carpeta de scripts `js/`.
* Carpeta de imágenes `img/`.
* Productos mostrados de forma estática.
* Precios visibles para los clientes.

## Limitaciones actuales

Actualmente la página todavía no cuenta con:

* Carrito de compras.
* Conexión con backend.
* Consulta privada de clientes.
* Control de stock dinámico.
* Pagos con tarjeta.
* Registro de pedidos.
* Programa de fidelidad dinámico.

## Objetivo de esta sección

El objetivo de la página web es funcionar como la vista pública del negocio de dulces.

Sus funciones futuras serán:

* Mostrar productos actualizados desde Cash Control.
* Mostrar stock disponible.
* Permitir pedidos.
* Mostrar métodos de pago.
* Permitir consulta privada de clientes.
* Mostrar puntos de fidelidad.
* Conectarse con el backend FastAPI.

## Relación con Cash Control

Cash Control funcionará como panel administrativo. Desde la app se podrán administrar productos, stock, clientes, fiados, pagos, proveedores, ganancias, pérdidas y reportes.

La página web solo mostrará información pública o información limitada del cliente autenticado.

## Seguridad

La página web no debe guardar claves privadas, tokens, credenciales ni información sensible.

Toda operación importante deberá validarse desde el backend.
