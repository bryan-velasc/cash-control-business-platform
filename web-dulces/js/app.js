// ==========================================================
// ESTADO GLOBAL
// ==========================================================

let carrito = [];
let puntos = 0;
let calificacionActual = 0;


// ==========================================================
// CONFIGURACIÓN API
// ==========================================================
//
// DESARROLLO LOCAL
//
// Cuando hagamos deploy solamente tendremos que cambiar
// API_BASE_URL por la URL pública del backend.
//
// La página web SOLO consulta productos.
//
// NO registra ventas.
// NO crea clientes.
// NO descuenta inventario.
//
// Los pedidos se confirman manualmente por WhatsApp.
//
// ==========================================================

const API_BASE_URL = "http://127.0.0.1:8000";

const API_PRODUCTOS_URL =
    `${API_BASE_URL}/products/public`;


// ==========================================================
// CONFIGURACIÓN WHATSAPP
// ==========================================================

const WHATSAPP_TELEFONO = "526393160403";


// ==========================================================
// ELEMENTOS DEL DOM
// ==========================================================

const searchInput =
    document.getElementById("searchInput");

const categoryFilter =
    document.getElementById("categoryFilter");

const chips =
    document.querySelectorAll(".chip");

const productGrid =
    document.getElementById("productGrid");


// ==========================================================
// CARGA DE PRODUCTOS DESDE API
// ==========================================================

async function cargarProductosDesdeAPI() {
    try {
        mostrarEstadoCarga(
            "Cargando productos desde Cash Control API..."
        );

        const response =
            await fetch(API_PRODUCTOS_URL);

        if (!response.ok) {
            throw new Error(
                `Error HTTP: ${response.status}`
            );
        }

        const productosApi =
            await response.json();

        if (!Array.isArray(productosApi)) {
            throw new Error(
                "La API no devolvió una lista válida de productos"
            );
        }

        PRODUCTOS = productosApi;

        renderizarProductos(PRODUCTOS);
        actualizarCarrito();

        console.log(
            "Productos cargados desde API:",
            PRODUCTOS
        );

    } catch (error) {
        console.error(
            "No se pudo conectar con la API. "
            + "Usando productos locales.",
            error
        );

        renderizarProductos(PRODUCTOS);
        actualizarCarrito();

        mostrarAvisoAPI();
    }
}


// ==========================================================
// ESTADO DE CARGA
// ==========================================================

function mostrarEstadoCarga(mensaje) {
    if (!productGrid) {
        return;
    }

    productGrid.innerHTML = `
        <div class="sin-productos">
            <h3>${mensaje}</h3>
            <p>Espera un momento...</p>
        </div>
    `;
}


// ==========================================================
// AVISO API
// ==========================================================

function mostrarAvisoAPI() {
    const aviso =
        document.createElement("div");

    aviso.className = "api-aviso";

    aviso.innerHTML = `
        <strong>Modo local:</strong>
        No se pudo conectar con FastAPI.
        Se muestran productos desde JavaScript.
    `;

    const contenido =
        document.querySelector(".contenido");

    if (contenido) {
        contenido.prepend(aviso);

        setTimeout(() => {
            aviso.remove();
        }, 6000);
    }
}


// ==========================================================
// RENDER DE PRODUCTOS
// ==========================================================

function renderizarProductos(
    listaProductos = PRODUCTOS
) {
    if (!productGrid) {
        return;
    }

    productGrid.innerHTML = "";

    const productosActivos =
        listaProductos.filter(
            producto => producto.activo
        );

    if (productosActivos.length === 0) {
        productGrid.innerHTML = `
            <div class="sin-productos">

                <h3>
                    No se encontraron productos
                </h3>

                <p>
                    Intenta con otra búsqueda
                    o categoría.
                </p>

            </div>
        `;

        return;
    }

    productosActivos.forEach(producto => {
        const agotado =
            Number(producto.stock) <= 0;

        const article =
            document.createElement("article");

        article.className =
            agotado
                ? "producto producto-agotado"
                : "producto";

        article.dataset.name =
            producto.nombre;

        article.dataset.category =
            producto.categoria;

        article.dataset.price =
            producto.precio;

        article.innerHTML = `
            <img
                src="${producto.imagen}"
                alt="${producto.nombre}"
            >

            <h3>
                ${producto.nombre}
            </h3>

            <p class="producto-precio">
                $${Number(producto.precio).toFixed(2)}
            </p>

            <span class="producto-stock">
                ${
                    agotado
                        ? "Sin stock disponible"
                        : `Stock: ${producto.stock}`
                }
            </span>

            ${
                agotado
                    ? '<span class="badge-agotado">Agotado</span>'
                    : ""
            }

            <button
                ${agotado ? "disabled" : ""}
                onclick="agregarCarrito(${producto.id})"
            >
                ${
                    agotado
                        ? "Agotado"
                        : "Añadir al Carrito"
                }
            </button>
        `;

        productGrid.appendChild(article);
    });
}


// ==========================================================
// CARRITO
// ==========================================================

function agregarCarrito(idProducto) {
    const producto =
        PRODUCTOS.find(
            item => item.id === idProducto
        );

    if (!producto) {
        alert("Producto no encontrado");
        return;
    }

    if (Number(producto.stock) <= 0) {
        alert("Producto agotado");
        return;
    }

    const existente =
        carrito.find(
            item => item.id === idProducto
        );

    if (existente) {

        if (
            existente.cantidad >=
            Number(producto.stock)
        ) {
            alert(
                "No hay más stock disponible "
                + "de este producto"
            );

            return;
        }

        existente.cantidad += 1;

    } else {
        carrito.push({
            id: producto.id,
            nombre: producto.nombre,
            precio: Number(producto.precio),
            cantidad: 1
        });
    }

    puntos += Math.floor(
        Number(producto.precio) / 10
    );

    actualizarCarrito();
}


// ==========================================================
// ACTUALIZAR CARRITO
// ==========================================================

function actualizarCarrito() {
    const cartItems =
        document.getElementById("cartItems");

    const subtotalElement =
        document.getElementById("subtotal");

    const totalElement =
        document.getElementById("total");

    const loyaltyPoints =
        document.getElementById("loyaltyPoints");

    const pointsView =
        document.getElementById("pointsView");

    const comprasCliente =
        document.getElementById("comprasCliente");

    const cartCountMobile =
        document.getElementById("cartCountMobile");

    if (cartItems) {
        cartItems.innerHTML = "";
    }

    if (
        carrito.length === 0 &&
        cartItems
    ) {
        cartItems.innerHTML = `
            <p class="carrito-vacio">
                Tu carrito está vacío
            </p>
        `;
    }

    let subtotal = 0;
    let totalProductos = 0;

    carrito.forEach(item => {
        const itemTotal =
            item.precio * item.cantidad;

        subtotal += itemTotal;
        totalProductos += item.cantidad;

        if (!cartItems) {
            return;
        }

        const div =
            document.createElement("div");

        div.className = "cart-item";

        div.innerHTML = `
            <div>

                <h4>
                    ${item.nombre}
                </h4>

                <p>
                    ${item.cantidad} item
                </p>

            </div>

            <div class="cart-item-actions">

                <strong>
                    $${itemTotal.toFixed(2)}
                </strong>

                <button
                    onclick="eliminarDelCarrito(${item.id})"
                >
                    ×
                </button>

            </div>
        `;

        cartItems.appendChild(div);
    });

    if (subtotalElement) {
        subtotalElement.textContent =
            `$${subtotal.toFixed(2)}`;
    }

    if (totalElement) {
        totalElement.textContent =
            `$${subtotal.toFixed(2)}`;
    }

    if (loyaltyPoints) {
        loyaltyPoints.textContent =
            puntos;
    }

    if (pointsView) {
        pointsView.textContent =
            `${puntos} points`;
    }

    if (comprasCliente) {
        comprasCliente.textContent =
            totalProductos;
    }

    if (cartCountMobile) {
        cartCountMobile.textContent =
            totalProductos;
    }
}


// ==========================================================
// ELIMINAR PRODUCTO DEL CARRITO
// ==========================================================

function eliminarDelCarrito(idProducto) {
    const productoEnCarrito =
        carrito.find(
            item => item.id === idProducto
        );

    if (!productoEnCarrito) {
        return;
    }

    const productoBase =
        PRODUCTOS.find(
            item => item.id === idProducto
        );

    if (
        productoEnCarrito.cantidad > 1
    ) {
        productoEnCarrito.cantidad -= 1;

    } else {
        carrito =
            carrito.filter(
                item =>
                    item.id !== idProducto
            );
    }

    if (productoBase) {
        const puntosARestar =
            Math.floor(
                Number(
                    productoBase.precio
                ) / 10
            );

        puntos =
            Math.max(
                0,
                puntos - puntosARestar
            );
    }

    actualizarCarrito();
}


// ==========================================================
// VACIAR CARRITO
// ==========================================================

function vaciarCarrito() {
    carrito = [];
    puntos = 0;

    actualizarCarrito();
}


// ==========================================================
// CALCULAR TOTAL
// ==========================================================

function calcularTotalCarrito() {
    return carrito.reduce(
        (sum, item) =>
            sum +
            (
                item.precio *
                item.cantidad
            ),
        0
    );
}


// ==========================================================
// BOTÓN PAGAR AHORA
// ==========================================================
//
// Este botón NO registra una venta.
//
// Únicamente abre el checkout para:
//
// 1. revisar total,
// 2. elegir método de pago,
// 3. enviar el pedido por WhatsApp.
//
// ==========================================================

function enviarWhatsApp() {
    if (carrito.length === 0) {
        alert(
            "Tu carrito está vacío"
        );

        return;
    }

    abrirModal("pagos");
}


// ==========================================================
// FORMATEAR MÉTODO DE PAGO
// ==========================================================

function formatearMetodoPago(
    metodo
) {
    switch (metodo) {

        case "efectivo":
            return "Efectivo";

        case "transferencia":
            return "Transferencia";

        case "tarjeta":
            return "Tarjeta";

        default:
            return metodo;
    }
}


// ==========================================================
// GENERAR MENSAJE DEL PEDIDO
// ==========================================================

function generarMensajePedido(
    metodoPago
) {
    const total =
        calcularTotalCarrito();

    let mensaje =
        "Hola, quiero realizar el siguiente "
        + "pedido en Velasco Dulces.\n\n";

    mensaje +=
        "PEDIDO\n";

    mensaje +=
        "------------------------------\n";

    carrito.forEach(item => {
        const subtotal =
            item.precio *
            item.cantidad;

        mensaje +=
            `${item.nombre}\n`;

        mensaje +=
            `Cantidad: ${item.cantidad}\n`;

        mensaje +=
            `Precio unitario: `
            + `$${item.precio.toFixed(2)} MXN\n`;

        mensaje +=
            `Subtotal: `
            + `$${subtotal.toFixed(2)} MXN\n\n`;
    });

    mensaje +=
        "------------------------------\n";

    mensaje +=
        `TOTAL: $${total.toFixed(2)} MXN\n\n`;

    mensaje +=
        `Método de pago: `
        + `${formatearMetodoPago(metodoPago)}\n\n`;

    mensaje +=
        "Este pedido está pendiente "
        + "de confirmación.";

    return mensaje;
}


// ==========================================================
// ENVIAR PEDIDO A WHATSAPP
// ==========================================================
//
// IMPORTANTE:
//
// Esta función:
//
// NO registra una venta.
// NO modifica inventario.
// NO crea un cliente.
// NO modifica MongoDB.
//
// ==========================================================

function enviarPedidoWhatsApp(
    metodoPago
) {
    if (carrito.length === 0) {
        alert(
            "Tu carrito está vacío"
        );

        return;
    }

    const mensaje =
        generarMensajePedido(
            metodoPago
        );

    const url =
        `https://wa.me/${WHATSAPP_TELEFONO}`
        + `?text=${encodeURIComponent(mensaje)}`;

    window.open(
        url,
        "_blank"
    );
}


// ==========================================================
// BUSCADOR
// ==========================================================

if (searchInput) {
    searchInput.addEventListener(
        "input",
        function () {
            filtrarProductos();
        }
    );
}


// ==========================================================
// CHIPS
// ==========================================================

chips.forEach(chip => {
    chip.addEventListener(
        "click",
        function () {

            chips.forEach(
                c =>
                    c.classList.remove(
                        "activo"
                    )
            );

            this.classList.add(
                "activo"
            );

            if (categoryFilter) {
                categoryFilter.value =
                    this.dataset.category;
            }

            filtrarProductos();
        }
    );
});


// ==========================================================
// SELECT DE CATEGORÍAS
// ==========================================================

if (categoryFilter) {
    categoryFilter.addEventListener(
        "change",
        function () {

            chips.forEach(
                c =>
                    c.classList.remove(
                        "activo"
                    )
            );

            const chipActivo =
                document.querySelector(
                    `.chip[data-category="${this.value}"]`
                );

            if (chipActivo) {
                chipActivo.classList.add(
                    "activo"
                );
            }

            filtrarProductos();
        }
    );
}


// ==========================================================
// FILTRAR PRODUCTOS
// ==========================================================

function filtrarProductos() {
    const texto =
        searchInput
            ? searchInput.value
                .trim()
                .toLowerCase()
            : "";

    const categoria =
        categoryFilter
            ? categoryFilter.value
            : "all";

    const productosFiltrados =
        PRODUCTOS.filter(
            producto => {

                const nombre =
                    String(
                        producto.nombre ||
                        ""
                    ).toLowerCase();

                const coincideTexto =
                    nombre.includes(
                        texto
                    );

                const coincideCategoria =
                    categoria === "all" ||
                    producto.categoria ===
                        categoria;

                return (
                    producto.activo &&
                    coincideTexto &&
                    coincideCategoria
                );
            }
        );

    renderizarProductos(
        productosFiltrados
    );
}


// ==========================================================
// NAVEGACIÓN
// ==========================================================

function navegarSeccion(
    elemento,
    seccion
) {
    const items =
        document.querySelectorAll(
            ".sidebar li"
        );

    items.forEach(
        item =>
            item.classList.remove(
                "activo"
            )
    );

    if (elemento) {
        elemento.classList.add(
            "activo"
        );
    }

    if (
        seccion === "productos" ||
        seccion === "catalogo"
    ) {
        reiniciarCatalogo();
    }
}


// ==========================================================
// REINICIAR CATÁLOGO
// ==========================================================

function reiniciarCatalogo() {
    if (categoryFilter) {
        categoryFilter.value =
            "all";
    }

    if (searchInput) {
        searchInput.value = "";
    }

    chips.forEach(
        c =>
            c.classList.remove(
                "activo"
            )
    );

    const chipAll =
        document.querySelector(
            '.chip[data-category="all"]'
        );

    if (chipAll) {
        chipAll.classList.add(
            "activo"
        );
    }

    renderizarProductos(
        PRODUCTOS
    );
}


// ==========================================================
// MODALES
// ==========================================================

function abrirModal(tipo) {
    const modal =
        document.getElementById(
            "modal"
        );

    const modalBody =
        document.getElementById(
            "modalBody"
        );

    if (
        !modal ||
        !modalBody
    ) {
        console.error(
            "No se encontró "
            + "el modal principal"
        );

        return;
    }

    let contenido = "";


    // ======================================================
    // CLIENTES
    // ======================================================
    //
    // Se mantiene DEMO.
    //
    // No se conecta todavía al backend.
    //
    // ======================================================

    if (tipo === "clientes") {
        contenido = `
            <h2>
                Consulta de Cliente
            </h2>

            <p>
                La consulta de clientes
                será atendida manualmente.
            </p>

            <div class="modal-form">

                <input
                    type="text"
                    id="clienteNombre"
                    placeholder="Nombre del cliente"
                >

                <input
                    type="tel"
                    id="clienteCodigo"
                    placeholder="Teléfono o código de cliente"
                >

                <button
                    onclick="consultarClienteDemo()"
                >
                    Consultar Cliente
                </button>

            </div>

            <div
                id="resultadoCliente"
            ></div>
        `;
    }


    // ======================================================
    // FIDELIDAD
    // ======================================================

    if (tipo === "fidelidad") {
        contenido = `
            <h2>
                Programa de Fidelidad
            </h2>

            <p>
                Actualmente tienes
                <strong>
                    ${puntos}
                </strong>
                puntos generados
                en este carrito.
            </p>

            <p>
                Regla inicial:
                por cada $10 MXN
                de compra,
                ganas 1 punto.
            </p>

            <div
                class="resultado-cliente"
            >

                <div>

                    <span>
                        Puntos actuales
                    </span>

                    <strong>
                        ${puntos}
                    </strong>

                </div>

                <div>

                    <span>
                        Recompensa próxima
                    </span>

                    <strong>
                        50 puntos
                    </strong>

                </div>

                <div>

                    <span>
                        Estado
                    </span>

                    <strong>
                        ${
                            puntos >= 50
                                ? "Recompensa disponible"
                                : "Sigue acumulando"
                        }
                    </strong>

                </div>

            </div>
        `;
    }


    // ======================================================
    // PAGOS / CHECKOUT
    // ======================================================

    if (tipo === "pagos") {
        const total =
            calcularTotalCarrito();

        if (
            carrito.length === 0
        ) {
            contenido = `
                <h2>
                    Métodos de Pago
                </h2>

                <div
                    class="resultado-cliente"
                >

                    <strong>
                        Tu carrito está vacío.
                    </strong>

                    <p>
                        Agrega productos
                        antes de continuar.
                    </p>

                </div>
            `;

        } else {
            contenido = `
                <h2>
                    Confirmar Pedido
                </h2>

                <p>
                    Total actual
                    del carrito:
                    <strong>
                        $${total.toFixed(2)}
                        MXN
                    </strong>
                </p>

                <p>
                    Selecciona el método
                    de pago que deseas utilizar.
                </p>

                <p>
                    El pedido será enviado
                    por WhatsApp para
                    confirmación manual.
                </p>

                <div class="modal-form">

                    <select
                        id="metodoPago"
                    >

                        <option
                            value="efectivo"
                        >
                            Efectivo
                        </option>

                        <option
                            value="transferencia"
                        >
                            Transferencia
                        </option>

                        <option
                            value="tarjeta"
                        >
                            Tarjeta
                        </option>

                    </select>

                    <button
                        id="btnProcesarPago"
                        onclick="seleccionarPago()"
                    >
                        Continuar por WhatsApp
                    </button>

                </div>

                <div
                    id="resultadoPago"
                ></div>
            `;
        }
    }


    // ======================================================
    // COMENTARIOS
    // ======================================================

    if (tipo === "comentarios") {
        contenido = `
            <h2>
                Comentarios
            </h2>

            <p>
                Déjanos tu opinión
                para mejorar el servicio.
            </p>

            <div class="modal-form">

                <input
                    type="text"
                    id="comentarioNombre"
                    placeholder="Tu nombre"
                >

                <textarea
                    id="comentarioTexto"
                    placeholder="Escribe tu comentario"
                ></textarea>

                <button
                    onclick="enviarComentarioDemo()"
                >
                    Enviar comentario
                </button>

            </div>

            <div
                id="resultadoComentario"
            ></div>
        `;
    }


    // ======================================================
    // CALIFICACIÓN
    // ======================================================

    if (
        tipo ===
        "calificacion"
    ) {
        contenido = `
            <h2>
                Calificar Servicio
            </h2>

            <p>
                Selecciona una
                calificación para
                el servicio.
            </p>

            <div
                class="estrellas"
            >

                <span
                    onclick="calificarServicio(1)"
                >
                    ☆
                </span>

                <span
                    onclick="calificarServicio(2)"
                >
                    ☆
                </span>

                <span
                    onclick="calificarServicio(3)"
                >
                    ☆
                </span>

                <span
                    onclick="calificarServicio(4)"
                >
                    ☆
                </span>

                <span
                    onclick="calificarServicio(5)"
                >
                    ☆
                </span>

            </div>

            <p id="ratingText">
                Sin calificación
                seleccionada
            </p>

            <div class="modal-form">

                <button
                    onclick="guardarCalificacionDemo()"
                >
                    Guardar calificación
                </button>

            </div>
        `;
    }


    modalBody.innerHTML =
        contenido;

    modal.classList.add(
        "activo"
    );
}


// ==========================================================
// CERRAR MODAL
// ==========================================================

function cerrarModal() {
    const modal =
        document.getElementById(
            "modal"
        );

    if (modal) {
        modal.classList.remove(
            "activo"
        );
    }
}


// ==========================================================
// CALIFICACIÓN
// ==========================================================

function calificarServicio(
    valor
) {
    calificacionActual =
        valor;

    const estrellas =
        document.querySelectorAll(
            ".estrellas span"
        );

    const ratingText =
        document.getElementById(
            "ratingText"
        );

    estrellas.forEach(
        (
            estrella,
            index
        ) => {

            if (
                index < valor
            ) {
                estrella.textContent =
                    "★";

                estrella.classList.add(
                    "activa"
                );

            } else {
                estrella.textContent =
                    "☆";

                estrella.classList.remove(
                    "activa"
                );
            }
        }
    );

    if (ratingText) {
        ratingText.textContent =
            `Calificación seleccionada: `
            + `${valor} de 5 estrellas`;
    }
}


// ==========================================================
// CONSULTA CLIENTE DEMO
// ==========================================================
//
// No consulta MongoDB.
//
// No crea cliente.
//
// No modifica información.
//
// ==========================================================

function consultarClienteDemo() {
    const nombreElement =
        document.getElementById(
            "clienteNombre"
        );

    const codigoElement =
        document.getElementById(
            "clienteCodigo"
        );

    const resultado =
        document.getElementById(
            "resultadoCliente"
        );

    if (
        !nombreElement ||
        !codigoElement ||
        !resultado
    ) {
        return;
    }

    const nombre =
        nombreElement.value
            .trim();

    const codigo =
        codigoElement.value
            .trim();

    if (
        !nombre ||
        !codigo
    ) {
        resultado.innerHTML = `
            <div
                class="resultado-cliente"
            >

                <strong>
                    Completa nombre
                    y teléfono para
                    continuar.
                </strong>

            </div>
        `;

        return;
    }

    const mensaje =
        `Hola, soy ${nombre}. `
        + `Quiero consultar mi información. `
        + `Mi teléfono o código es: ${codigo}`;

    const url =
        `https://wa.me/${WHATSAPP_TELEFONO}`
        + `?text=${encodeURIComponent(mensaje)}`;

    resultado.innerHTML = `
        <div
            class="resultado-cliente"
        >

            <strong>
                La consulta se realizará
                por WhatsApp.
            </strong>

            <p>
                No se modificó información
                de clientes.
            </p>

            <button
                onclick="window.open('${url}', '_blank')"
            >
                Consultar por WhatsApp
            </button>

        </div>
    `;
}


// ==========================================================
// CONFIRMAR PEDIDO POR WHATSAPP
// ==========================================================
//
// ESTE ES EL FLUJO ACTUAL:
//
// Web
//   ↓
// Carrito
//   ↓
// Método de pago
//   ↓
// WhatsApp
//   ↓
// Confirmación manual
//   ↓
// Registro manual en Cash Control
//
// ==========================================================

function seleccionarPago() {
    const metodoPagoElement =
        document.getElementById(
            "metodoPago"
        );

    const resultado =
        document.getElementById(
            "resultadoPago"
        );

    const boton =
        document.getElementById(
            "btnProcesarPago"
        );

    if (
        !metodoPagoElement ||
        !resultado
    ) {
        console.error(
            "No se encontraron "
            + "los elementos del checkout"
        );

        return;
    }


    // ======================================================
    // VALIDAR CARRITO
    // ======================================================

    if (
        carrito.length === 0
    ) {
        resultado.innerHTML = `
            <div
                class="resultado-cliente"
            >

                <strong>
                    Tu carrito está vacío.
                </strong>

                <p>
                    Agrega productos
                    antes de continuar.
                </p>

            </div>
        `;

        return;
    }


    const metodo =
        metodoPagoElement.value;

    const total =
        calcularTotalCarrito();


    // ======================================================
    // MOSTRAR RESUMEN
    // ======================================================

    resultado.innerHTML = `
        <div
            class="resultado-cliente"
        >

            <div>

                <span>
                    Total del pedido
                </span>

                <strong>
                    $${total.toFixed(2)}
                    MXN
                </strong>

            </div>

            <div>

                <span>
                    Método
                </span>

                <strong>
                    ${formatearMetodoPago(metodo)}
                </strong>

            </div>

            <p>
                El pedido aún
                no se ha registrado
                como venta.
            </p>

            <p>
                Confirma tu pedido
                por WhatsApp.
            </p>

        </div>
    `;


    // ======================================================
    // EVITAR DOBLE CLIC
    // ======================================================

    if (boton) {
        boton.disabled = true;

        boton.textContent =
            "Abriendo WhatsApp...";
    }


    // ======================================================
    // ABRIR WHATSAPP
    // ======================================================

    enviarPedidoWhatsApp(
        metodo
    );


    // ======================================================
    // CONSERVAR CARRITO
    // ======================================================
    //
    // NO vaciamos el carrito.
    //
    // Mandar un mensaje de WhatsApp
    // NO significa que la venta
    // haya sido confirmada.
    //
    // ======================================================

    setTimeout(
        () => {

            if (boton) {
                boton.disabled = false;

                boton.textContent =
                    "Continuar por WhatsApp";
            }

        },
        1000
    );
}


// ==========================================================
// COMENTARIOS DEMO
// ==========================================================

function enviarComentarioDemo() {
    const nombreElement =
        document.getElementById(
            "comentarioNombre"
        );

    const comentarioElement =
        document.getElementById(
            "comentarioTexto"
        );

    const resultado =
        document.getElementById(
            "resultadoComentario"
        );

    if (
        !nombreElement ||
        !comentarioElement ||
        !resultado
    ) {
        return;
    }

    const nombre =
        nombreElement.value
            .trim();

    const comentario =
        comentarioElement.value
            .trim();

    if (
        !nombre ||
        !comentario
    ) {
        resultado.innerHTML = `
            <div
                class="resultado-cliente"
            >

                <strong>
                    Escribe tu nombre
                    y comentario.
                </strong>

            </div>
        `;

        return;
    }

    resultado.innerHTML = `
        <div
            class="resultado-cliente"
        >

            <strong>
                Gracias, ${nombre}.
                Tu comentario fue
                recibido de forma demo.
            </strong>

        </div>
    `;
}


// ==========================================================
// GUARDAR CALIFICACIÓN
// ==========================================================

function guardarCalificacionDemo() {
    if (
        calificacionActual === 0
    ) {
        alert(
            "Selecciona una "
            + "calificación primero"
        );

        return;
    }

    alert(
        `Gracias por calificar `
        + `el servicio con `
        + `${calificacionActual} estrellas`
    );
}


// ==========================================================
// MOBILE - ABRIR CARRITO
// ==========================================================

function abrirCarritoMobile() {
    const carritoPanel =
        document.getElementById(
            "carritoPanel"
        );

    if (carritoPanel) {
        carritoPanel.classList.add(
            "carrito-abierto"
        );
    }
}


// ==========================================================
// MOBILE - CERRAR CARRITO
// ==========================================================

function cerrarCarritoMobile() {
    const carritoPanel =
        document.getElementById(
            "carritoPanel"
        );

    if (carritoPanel) {
        carritoPanel.classList.remove(
            "carrito-abierto"
        );
    }
}


// ==========================================================
// MOBILE - NAVEGACIÓN
// ==========================================================

function navegarMobile(
    seccion
) {
    cerrarCarritoMobile();

    if (
        seccion === "productos" ||
        seccion === "catalogo"
    ) {
        reiniciarCatalogo();

        const contenido =
            document.querySelector(
                ".contenido"
            );

        if (contenido) {
            contenido.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
        }
    }
}


// ==========================================================
// EVENTOS GLOBALES
// ==========================================================

const modal =
    document.getElementById(
        "modal"
    );


if (modal) {
    modal.addEventListener(
        "click",
        function (event) {

            if (
                event.target.id ===
                "modal"
            ) {
                cerrarModal();
            }
        }
    );
}


document.addEventListener(
    "keydown",
    function (event) {

        if (
            event.key ===
            "Escape"
        ) {
            cerrarModal();
            cerrarCarritoMobile();
        }
    }
);


// ==========================================================
// INICIALIZACIÓN
// ==========================================================

cargarProductosDesdeAPI();