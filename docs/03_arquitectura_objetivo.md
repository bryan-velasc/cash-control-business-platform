# Arquitectura Objetivo del Proyecto

## Objetivo

Diseñar una arquitectura escalable, segura y ordenada que permita conectar la página web de venta de dulces con la aplicación Cash Control, utilizando un backend centralizado y una base de datos en la nube.

El objetivo principal es que la página web funcione como vista pública y de consulta limitada, mientras Cash Control funciona como panel administrativo del negocio.

---

## Componentes principales

La arquitectura objetivo estará compuesta por los siguientes elementos:

- Página web alojada en Netlify.
- Backend desarrollado con FastAPI.
- Base de datos MongoDB Atlas.
- Aplicación móvil Cash Control.
- Servicios externos para pagos y SMS.
- Repositorio GitHub para control de versiones y documentación.

---

## Rol de cada componente

### Página web en Netlify

La página web será la parte pública del sistema.

Sus funciones serán:

- Mostrar productos.
- Mostrar precios.
- Mostrar stock disponible.
- Mostrar métodos de pago.
- Mostrar programa de fidelidad.
- Permitir consulta privada de clientes.
- Permitir pedidos o compras.
- Redirigir a WhatsApp si se requiere.

La página web no deberá administrar información sensible directamente.

---

### Backend FastAPI

FastAPI funcionará como el puente principal entre la página web, Cash Control y la base de datos.

Sus funciones serán:

- Recibir solicitudes desde la página web.
- Recibir solicitudes desde Cash Control.
- Validar datos.
- Consultar MongoDB.
- Registrar ventas.
- Registrar pagos.
- Actualizar stock.
- Proteger endpoints administrativos.
- Controlar acceso a información privada.
- Generar reportes.

---

### MongoDB Atlas

MongoDB Atlas será la base de datos central del sistema.

Almacenará información como:

- Productos.
- Stock.
- Inventario.
- Clientes.
- Fiados.
- Pagos.
- Proveedores.
- Ventas.
- Ganancias.
- Pérdidas.
- Recordatorios.
- Programa de fidelidad.
- Reportes.

---

### Cash Control

Cash Control funcionará como el panel administrativo del negocio.

Desde la app se podrá:

- Agregar productos.
- Actualizar stock.
- Registrar proveedores.
- Registrar precios de compra.
- Registrar precios de venta.
- Administrar clientes.
- Crear fiados.
- Registrar pagos.
- Consultar ganancias.
- Consultar pérdidas.
- Ver reportes predictivos.
- Revisar clientes con deuda pendiente.

---

## Diagrama general

```text
Cliente
  |
  v
Página web Netlify
  |
  v
Backend FastAPI
  |
  v
MongoDB Atlas
  ^
  |
Cash Control App