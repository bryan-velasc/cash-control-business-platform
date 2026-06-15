# Bitácora de Errores y Soluciones

## Objetivo del documento

Este documento registra los errores, problemas técnicos, conflictos, decisiones correctivas y soluciones aplicadas durante el desarrollo de Cash Control Business Platform.

La finalidad es mantener trazabilidad del proyecto, mejorar el aprendizaje técnico y generar evidencia profesional para portafolio, especialmente en áreas relacionadas con desarrollo seguro, análisis de fallos y ciberseguridad.

---

## Importancia de documentar errores

Documentar errores permite:

* Entender qué falló.
* Identificar la causa raíz.
* Registrar la solución aplicada.
* Evitar repetir el mismo problema.
* Mejorar la calidad del proyecto.
* Demostrar capacidad de resolución técnica.
* Crear evidencia para entrevistas o vacantes.

En un entorno profesional, los errores no se ocultan; se analizan y se corrigen de forma controlada.

---

## Formato estándar para registrar errores

Cada error será documentado usando el siguiente formato:

```text
ID del error:
Fecha:
Módulo:
Entorno:
Descripción:
Síntoma:
Causa probable:
Impacto:
Solución aplicada:
Comandos utilizados:
Resultado:
Cómo se verificó:
Cómo se evitará en el futuro:
Estado:
```

---

## ERR-001: Conflicto al subir proyecto inicial a GitHub

### ID del error

ERR-001

### Fecha

14/06/2026

### Módulo

Git / GitHub

### Entorno

Repositorio local en Windows PowerShell y repositorio remoto en GitHub.

### Descripción

Al intentar subir el proyecto inicial a GitHub, el comando `git push` fue rechazado porque el repositorio remoto ya contenía archivos o commits que no existían en el repositorio local.

### Síntoma

Git mostró el siguiente mensaje:

```text
! [rejected] main -> main (fetch first)
error: failed to push some refs
Updates were rejected because the remote contains work that you do not have locally.
```

### Causa probable

El repositorio de GitHub fue creado con algún archivo inicial, como `README.md`, `.gitignore` o licencia. Esto generó una diferencia entre el historial local y el historial remoto.

### Impacto

El proyecto no podía subirse a GitHub hasta integrar o resolver las diferencias entre ambos repositorios.

### Solución aplicada

Se ejecutó un `git pull` permitiendo integrar historiales no relacionados:

```powershell
git pull origin main --allow-unrelated-histories
```

Después Git detectó un conflicto en el archivo `README.md`, porque existía tanto en local como en remoto.

Se resolvió conservando la versión local:

```powershell
git checkout --ours README.md
git add README.md
git commit -m "merge: resolver conflicto inicial de README"
git push -u origin main
```

### Resultado

El conflicto fue resuelto correctamente y el proyecto pudo subirse al repositorio remoto de GitHub.

### Cómo se verificó

Se ejecutó:

```powershell
git status
```

El resultado esperado fue:

```text
nothing to commit, working tree clean
```

### Cómo se evitará en el futuro

Al crear repositorios en GitHub, se evitará seleccionar archivos iniciales como README, `.gitignore` o licencia cuando ya existan localmente.

También se verificará el estado del repositorio remoto antes de hacer el primer push.

### Estado

Resuelto.

---

## ERR-002: Rama inicial creada como master

### ID del error

ERR-002

### Fecha

14/06/2026

### Módulo

Git

### Entorno

Repositorio local en Windows PowerShell.

### Descripción

Al inicializar el repositorio con `git init`, Git creó la rama inicial con el nombre `master`.

### Síntoma

El comando `git status` mostraba:

```text
On branch master
```

### Causa probable

La configuración local de Git todavía utiliza `master` como nombre por defecto para la rama inicial.

### Impacto

No afecta el funcionamiento del proyecto, pero actualmente se recomienda usar `main` como nombre de rama principal en muchos repositorios modernos.

### Solución aplicada

Se cambió el nombre de la rama principal:

```powershell
git branch -M main
```

### Resultado

La rama principal quedó nombrada como `main`.

### Cómo se verificó

Se ejecutó:

```powershell
git branch
```

El resultado esperado fue:

```text
* main
```

### Cómo se evitará en el futuro

Configurar Git para crear repositorios nuevos con `main` por defecto:

```powershell
git config --global init.defaultBranch main
```

### Estado

Resuelto.

---

## ERR-003: Página web sin conexión a backend

### ID del error

ERR-003

### Fecha

14/06/2026

### Módulo

Página web / Arquitectura

### Entorno

Página web alojada en Netlify, desarrollada con HTML.

### Descripción

La página web actual solo muestra imágenes y precios de productos. No cuenta con conexión a backend, base de datos, Cash Control ni servicios externos.

### Síntoma

La página funciona como catálogo estático, pero no permite:

* Registrar ventas.
* Controlar stock.
* Registrar clientes.
* Registrar pagos.
* Mostrar datos personalizados.
* Actualizar productos dinámicamente.

### Causa probable

La primera versión de la página fue creada como catálogo visual básico.

### Impacto

El negocio depende de procesos manuales para administrar productos, clientes, pagos y stock.

### Solución propuesta

Crear una arquitectura donde la página web consulte datos desde FastAPI y FastAPI se conecte con MongoDB Atlas.

Cash Control funcionará como panel administrativo.

### Resultado

Pendiente de implementación.

### Cómo se verificará

Se verificará cuando la página web pueda consumir datos desde un endpoint público como:

```text
GET /products/public
```

### Cómo se evitará en el futuro

Antes de agregar nuevas funciones, se documentará la arquitectura y los flujos de datos.

### Estado

Pendiente.

---

## ERR-004: Riesgo de exposición de datos de clientes

### ID del error

ERR-004

### Fecha

14/06/2026

### Módulo

Seguridad / Clientes

### Entorno

Página web pública.

### Descripción

Se identificó que, si la página web permite consultar información de clientes sin autenticación, podrían exponerse nombres, teléfonos, deudas o historial de pagos.

### Síntoma

El riesgo todavía no ocurre porque la función no está implementada, pero fue detectado durante la planeación.

### Causa probable

Diseñar una vista de clientes como solo lectura sin proteger el acceso podría permitir que cualquier persona vea datos privados.

### Impacto

Alto. Podría afectar la privacidad de clientes y la confianza en el sistema.

### Solución propuesta

Crear acceso privado por cliente mediante:

* Código único.
* PIN.
* Token temporal.
* Teléfono validado.
* Login en una fase futura.

La página solo debe mostrar la información del cliente autenticado.

### Resultado

Pendiente de implementación.

### Cómo se verificará

Se probará que un cliente no pueda acceder a información de otro cliente.

### Cómo se evitará en el futuro

Separar endpoints públicos y privados desde el diseño del backend.

### Estado

Pendiente.

---

## ERR-005: Riesgo de manipulación de pagos desde frontend

### ID del error

ERR-005

### Fecha

14/06/2026

### Módulo

Pagos / Seguridad

### Entorno

Página web pública con JavaScript.

### Descripción

Un usuario podría modificar datos enviados desde la página web, como montos, productos o estado de pago.

### Síntoma

El riesgo fue detectado durante la planeación de pagos con tarjeta, transferencia y efectivo.

### Causa probable

Los datos enviados desde el navegador pueden ser manipulados con herramientas de desarrollador.

### Impacto

Alto. Podría generar pagos falsos, montos incorrectos o alteración de deudas.

### Solución propuesta

El backend deberá validar:

* Precio real del producto.
* Stock disponible.
* Total calculado.
* Estado del pago.
* Cliente asociado.
* Confirmación del proveedor de pago.

No se debe confiar en el total enviado desde el frontend.

### Resultado

Pendiente de implementación.

### Cómo se verificará

Se harán pruebas intentando modificar el monto desde el navegador y verificando que el backend rechace valores inválidos.

### Cómo se evitará en el futuro

Toda operación crítica será recalculada y validada desde FastAPI.

### Estado

Pendiente.

---

## Registro de errores futuros

Los siguientes errores deberán agregarse conforme aparezcan durante el desarrollo.

### Plantilla

```text
ID del error:
Fecha:
Módulo:
Entorno:
Descripción:
Síntoma:
Causa probable:
Impacto:
Solución aplicada:
Comandos utilizados:
Resultado:
Cómo se verificó:
Cómo se evitará en el futuro:
Estado:
```

---

## Conclusión

La bitácora de errores permite mantener control técnico sobre el desarrollo del proyecto. Cada problema registrado representa una oportunidad de mejora y una evidencia de aprendizaje.

Este documento será actualizado durante todo el ciclo de vida del proyecto.
