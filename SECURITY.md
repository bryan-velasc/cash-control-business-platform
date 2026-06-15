# Seguridad del Proyecto

## Objetivo

Documentar los riesgos, controles y buenas prácticas de seguridad aplicadas en Cash Control Business Platform.

## Datos sensibles considerados

El sistema puede manejar:

- Nombres de clientes.
- Teléfonos.
- Deudas.
- Historial de pagos.
- Métodos de pago.
- Inventario.
- Ganancias.
- Proveedores.

## Riesgos iniciales identificados

### Riesgo 1: Exposición de datos de clientes

La página web no debe mostrar información de todos los clientes de forma pública.

**Control propuesto:**  
Cada cliente solo podrá consultar su información mediante autenticación, PIN, token o código privado.

### Riesgo 2: Manipulación de pagos desde el frontend

Un cliente podría intentar modificar valores desde el navegador.

**Control propuesto:**  
Los pagos deben validarse siempre desde el backend, nunca confiar en datos enviados directamente desde JavaScript.

### Riesgo 3: Exposición de claves privadas

API keys, tokens y credenciales no deben subirse a GitHub.

**Control propuesto:**  
Usar archivos `.env` y agregarlos al `.gitignore`.

### Riesgo 4: Acceso no autorizado al inventario

El stock solo debe modificarse desde Cash Control o desde usuarios autorizados.

**Control propuesto:**  
Crear endpoints administrativos protegidos.

## Buenas prácticas iniciales

- Separar frontend público del backend.
- No guardar claves en el código.
- Validar entradas del usuario.
- Registrar errores y soluciones.
- Mantener documentación actualizada.
- Usar control de versiones con GitHub.