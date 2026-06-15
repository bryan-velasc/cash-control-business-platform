# Decisiones Técnicas del Proyecto

## Objetivo del documento

Este documento registra las decisiones técnicas tomadas durante el desarrollo de Cash Control Business Platform.

La finalidad es explicar por qué se eligieron ciertas tecnologías, estructuras, flujos y medidas de seguridad, permitiendo mantener trazabilidad del proyecto y justificar su evolución técnica.

---

## Importancia de documentar decisiones técnicas

Documentar decisiones técnicas permite:

* Explicar por qué se eligió una solución.
* Comparar alternativas.
* Entender ventajas y desventajas.
* Evitar confusión en el futuro.
* Facilitar mantenimiento.
* Demostrar criterio profesional.
* Generar evidencia para portafolio técnico.

---

# ADR-001: Usar GitHub como repositorio principal

## Estado

Aceptada.

## Contexto

El proyecto necesitaba una forma profesional de llevar control de versiones, documentación, errores, pruebas y avances.

## Decisión

Se decidió utilizar GitHub como repositorio principal del proyecto.

## Alternativas consideradas

* Guardar archivos solo en la computadora.
* Usar Google Drive.
* Usar carpetas locales sin control de versiones.
* Usar otro sistema de repositorios.

## Motivo de la decisión

GitHub permite mantener historial de cambios, documentación visible, control de ramas, evidencia profesional y trazabilidad del proyecto.

## Ventajas

* Historial de commits.
* Portafolio profesional.
* Control de versiones.
* Integración futura con Netlify y Render.
* Mejor organización del proyecto.
* Evidencia para vacantes de ciberseguridad.

## Riesgos

* Subir accidentalmente archivos sensibles.
* Exponer claves privadas.
* Publicar datos reales de clientes.

## Controles

* Usar `.gitignore`.
* No subir archivos `.env`.
* Revisar cambios antes de hacer commit.
* No subir credenciales.
* Documentar riesgos en `SECURITY.md`.

---

# ADR-002: Mantener la página web en Netlify

## Estado

Aceptada.

## Contexto

La página web de dulces ya se encuentra alojada en Netlify y actualmente funciona como catálogo visual estático con HTML.

## Decisión

Se decidió mantener Netlify como plataforma para alojar la página pública.

## Alternativas consideradas

* Migrar la página a otro hosting.
* Crear una página completa con backend integrado.
* Migrar a React.
* Crear una versión en Flutter Web.

## Motivo de la decisión

Netlify es adecuado para sitios estáticos, permite buen rendimiento, despliegue rápido e integración con GitHub.

## Ventajas

* Página rápida.
* Fácil publicación.
* Buena integración con GitHub.
* HTTPS automático.
* Bajo costo.
* Escalable para frontend público.

## Riesgos

* La página no debe manejar lógica sensible.
* No se deben guardar claves privadas en JavaScript.
* El frontend puede ser manipulado por el usuario.

## Controles

* Mantener lógica sensible en FastAPI.
* No exponer variables privadas.
* Usar endpoints públicos limitados.
* Validar operaciones críticas en backend.

---

# ADR-003: Usar FastAPI como backend central

## Estado

Aceptada.

## Contexto

El sistema necesita conectar la página web, Cash Control y la base de datos mediante una API central.

## Decisión

Se decidió usar FastAPI como backend principal.

## Alternativas consideradas

* Flask.
* Node.js con Express.
* Firebase Functions.
* Backend directo desde Flutter.
* Conexión directa del frontend a MongoDB.

## Motivo de la decisión

FastAPI ya forma parte de la estructura de Cash Control y permite construir APIs rápidas, limpias y documentadas.

## Ventajas

* Buen rendimiento.
* Validación de datos.
* Documentación automática.
* Organización por rutas.
* Integración con MongoDB.
* Compatible con Render.
* Código claro en Python.

## Riesgos

* Endpoints mal protegidos.
* Falta de validación de datos.
* Exposición de errores internos.
* Dependencia del backend para todas las operaciones.

## Controles

* Separar rutas públicas y administrativas.
* Validar modelos con Pydantic.
* Usar variables de entorno.
* Proteger endpoints administrativos.
* Registrar errores de forma controlada.

---

# ADR-004: Usar MongoDB Atlas como base de datos

## Estado

Aceptada.

## Contexto

El proyecto necesita almacenar productos, clientes, pagos, deudas, stock, proveedores, ventas y reportes.

## Decisión

Se decidió utilizar MongoDB Atlas como base de datos central.

## Alternativas consideradas

* MySQL.
* PostgreSQL.
* Firebase Firestore.
* SQLite.
* Archivos JSON.

## Motivo de la decisión

MongoDB permite almacenar documentos flexibles y adaptarse al crecimiento del sistema.

## Ventajas

* Flexible.
* Escalable.
* Funciona en la nube.
* Compatible con FastAPI.
* Permite manejar documentos complejos.
* Útil para módulos variables como ventas, productos y clientes.

## Riesgos

* Mala estructura de colecciones.
* Consultas públicas con demasiada información.
* Exposición de URI de conexión.
* Falta de índices para consultas grandes.

## Controles

* Acceder solo desde backend.
* Guardar URI en variables de entorno.
* Crear colecciones organizadas.
* No exponer datos internos en endpoints públicos.
* Crear índices conforme crezca el sistema.

---

# ADR-005: Cash Control como panel administrativo

## Estado

Aceptada.

## Contexto

Cash Control ya existe como aplicación financiera. El nuevo objetivo es que también administre el negocio de venta de dulces.

## Decisión

Se decidió que Cash Control será el panel administrativo del negocio.

## Alternativas consideradas

* Crear un panel web nuevo.
* Administrar todo desde la página pública.
* Usar hojas de cálculo.
* Administrar manualmente los datos.

## Motivo de la decisión

Cash Control ya tiene una base construida y puede crecer como una aplicación más completa para controlar finanzas personales y negocio.

## Ventajas

* Centraliza administración.
* Permite controlar stock.
* Permite registrar clientes.
* Permite gestionar fiados.
* Permite ver ganancias y pérdidas.
* Fortalece el valor del proyecto.

## Riesgos

* Aumentar demasiado la complejidad de la app.
* Mezclar finanzas personales con negocio sin organización.
* Acceso no autorizado a funciones administrativas.

## Controles

* Separar módulos dentro de la app.
* Crear sección específica llamada “Mi Negocio”.
* Proteger acciones administrativas.
* Mantener documentación por módulo.

---

# ADR-006: Página web como vista pública limitada

## Estado

Aceptada.

## Contexto

La página web será visitada por clientes y público general. No debe mostrar información administrativa ni sensible.

## Decisión

Se decidió que la página web solo funcionará como catálogo, vista pública y consulta limitada para clientes.

## Alternativas consideradas

* Permitir administración desde la página pública.
* Mostrar lista completa de clientes.
* Mostrar inventario completo.
* Permitir edición directa desde la web.

## Motivo de la decisión

Separar lo público de lo administrativo reduce riesgos de seguridad y mantiene la página ligera.

## Ventajas

* Mayor seguridad.
* Mejor rendimiento.
* Menor complejidad.
* Menos exposición de datos.
* Mejor experiencia para clientes.

## Riesgos

* Consulta de cliente mal protegida.
* Exposición accidental de datos.
* Manipulación de información desde navegador.

## Controles

* Crear vista privada por cliente.
* Usar PIN, token o código único.
* No mostrar listas públicas de clientes.
* Validar toda consulta desde backend.

---

# ADR-007: No borrar deudas pagadas, solo cambiar estado

## Estado

Aceptada.

## Contexto

Cuando un cliente pague una deuda, se planteó que desaparezca lo que debe.

## Decisión

Se decidió no borrar completamente las deudas pagadas. En su lugar, se cambiará su estado a `pagado`.

## Alternativas consideradas

* Borrar deuda al pagar.
* Guardar solo el total.
* Mantener historial manual.
* Ocultar deuda activa sin conservar registro.

## Motivo de la decisión

Mantener historial permite auditoría, reportes, control financiero y análisis de clientes.

## Ventajas

* Conserva trazabilidad.
* Permite reportes.
* Evita pérdida de información.
* Ayuda en auditoría.
* Permite detectar errores.

## Riesgos

* Acumulación de datos históricos.
* Exposición de historial si el endpoint no está protegido.

## Controles

* Mostrar al cliente solo deuda activa o resumen permitido.
* Proteger historial completo en endpoints administrativos.
* Filtrar datos según permisos.

---

# ADR-008: Validar pagos desde backend

## Estado

Aceptada.

## Contexto

La página web permitirá pagos o registros relacionados con efectivo, transferencia y tarjeta.

## Decisión

Se decidió que los pagos siempre deben validarse desde el backend.

## Alternativas consideradas

* Confiar en el total enviado desde JavaScript.
* Marcar pagos directamente desde frontend.
* Confirmar pagos manualmente sin registro.
* Guardar pagos sin validación.

## Motivo de la decisión

El navegador puede ser manipulado por el usuario. El backend debe recalcular y confirmar montos, productos, stock y estado del pago.

## Ventajas

* Reduce fraude.
* Evita manipulación de montos.
* Permite auditoría.
* Mejora seguridad.
* Mantiene consistencia de datos.

## Riesgos

* Mala implementación de validación.
* Confirmar pagos incompletos.
* No verificar correctamente webhooks.

## Controles

* Recalcular total en backend.
* Validar productos contra base de datos.
* Confirmar pago antes de marcar como pagado.
* Registrar cada pago.
* Mantener estados: pendiente, confirmado, rechazado.

---

# ADR-009: Crear documentación antes de modificar código

## Estado

Aceptada.

## Contexto

El proyecto busca ser funcional, escalable y útil como evidencia profesional para vacantes de ciberseguridad.

## Decisión

Se decidió documentar arquitectura, tecnologías, seguridad, errores, pruebas y decisiones técnicas antes de modificar el código principal.

## Alternativas consideradas

* Empezar a programar directamente.
* Documentar al final.
* Documentar solo errores importantes.
* No usar documentación formal.

## Motivo de la decisión

Documentar desde el inicio permite mantener orden, justificar decisiones y construir un portafolio profesional.

## Ventajas

* Mejor organización.
* Menos errores.
* Mayor claridad.
* Mejor evidencia profesional.
* Facilita mantenimiento.
* Mejora preparación para entrevistas.

## Riesgos

* Avanzar más lento al principio.
* Documentación desactualizada si no se mantiene.

## Controles

* Actualizar documentación en cada fase.
* Usar commits claros.
* Registrar cambios en `CHANGELOG.md`.
* Documentar errores en bitácora.

---

---

# ADR-011: Usar modales para funciones iniciales del dashboard web

## Estado

Aceptada.

## Contexto

El dashboard web necesitaba botones funcionales para clientes, fidelidad, pagos, comentarios y calificación. Sin embargo, todavía no se ha conectado la página con FastAPI ni con Cash Control.

## Decisión

Se decidió implementar ventanas modales con JavaScript para simular las funciones principales sin depender todavía del backend.

## Alternativas consideradas

- Crear páginas separadas para cada sección.
- Conectar inmediatamente con backend.
- Dejar los botones sin función.
- Usar una librería externa de interfaz.

## Motivo de la decisión

Los modales permiten validar la experiencia visual y funcional antes de conectar datos reales. Además, mantienen la página ligera usando HTML, CSS y JavaScript puro.

## Ventajas

- No requiere frameworks externos.
- Mantiene buen rendimiento.
- Permite probar la experiencia del usuario.
- Prepara la estructura para conexión futura.
- Evita modificar todavía el backend.
- Reduce riesgo de romper la página.

## Riesgos

- Las funciones actuales son demostrativas.
- Los datos no se guardan todavía en base de datos.
- El frontend no debe manejar datos sensibles reales sin backend.

## Controles

- Documentar que las funciones son demo.
- No guardar datos sensibles reales en el frontend.
- Conectar operaciones críticas posteriormente con FastAPI.
- Validar clientes, pagos y fidelidad desde backend en futuras fases.

## Resultado

La página ahora cuenta con botones funcionales, modales interactivos y una estructura preparada para integrarse con Cash Control.

---

# ADR-012: Adaptar dashboard web a versión móvil

## Estado

Aceptada.

## Contexto

El diseño dashboard oscuro funciona bien en computadora, pero la página también debe poder usarse desde celulares, ya que los clientes probablemente consultarán productos y pedidos desde el teléfono.

## Decisión

Se decidió implementar una versión responsive con encabezado móvil, menú inferior, catálogo adaptado y carrito desplegable.

## Alternativas consideradas

- Mantener solo diseño de escritorio.
- Crear una página móvil separada.
- Migrar a framework frontend.
- Reducir funciones en celular.

## Motivo de la decisión

Una tienda web debe funcionar correctamente en celular. Adaptar el diseño actual permite mantener una sola base de código y mejorar la experiencia del cliente sin aumentar demasiado la complejidad.

## Ventajas

- Mejor experiencia en celular.
- No requiere framework externo.
- Mantiene el diseño dashboard.
- Permite comprar desde móvil.
- Mejora presentación profesional del proyecto.
- Prepara el sitio para clientes reales.

## Riesgos

- El diseño puede requerir ajustes adicionales en pantallas muy pequeñas.
- El carrito móvil debe probarse bien para evitar errores de interacción.
- El frontend sigue siendo demostrativo hasta conectar backend.

## Controles

- Probar con modo responsive del navegador.
- Mantener funciones críticas fuera del frontend.
- Documentar pruebas visuales.
- Ajustar CSS por media queries.

## Resultado

La página web ahora cuenta con una experiencia móvil más usable, incluyendo navegación inferior, carrito lateral y catálogo adaptado a pantallas pequeñas.

## Conclusión

Las decisiones técnicas registradas en este documento permiten entender la evolución del proyecto y justificar su arquitectura. Cada decisión fue tomada considerando escalabilidad, seguridad, rendimiento, mantenimiento y valor profesional para portafolio.

Este documento será actualizado conforme el proyecto crezca y se integren nuevos módulos.
