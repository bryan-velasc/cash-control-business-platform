let carrito = [];
let puntos = 0;
let calificacionActual = 0;

const API_PRODUCTOS_URL = "http://127.0.0.1:8000/products/public";

const searchInput = document.getElementById("searchInput");
const categoryFilter = document.getElementById("categoryFilter");
const chips = document.querySelectorAll(".chip");
const productGrid = document.getElementById("productGrid");

/* ==============================
   CARGA DE PRODUCTOS DESDE API
   ============================== */

async function cargarProductosDesdeAPI() {
    try {
        mostrarEstadoCarga("Cargando productos desde Cash Control API...");

        const response = await fetch(API_PRODUCTOS_URL);

        if (!response.ok) {
            throw new Error(`Error HTTP: ${response.status}`);
        }

        const productosApi = await response.json();

        if (!Array.isArray(productosApi)) {
            throw new Error("La API no devolvió una lista válida de productos");
        }

        PRODUCTOS = productosApi;

        renderizarProductos(PRODUCTOS);
        actualizarCarrito();

        console.log("Productos cargados desde API:", PRODUCTOS);
    } catch (error) {
        console.error("No se pudo conectar con la API. Usando productos locales.", error);

        renderizarProductos(PRODUCTOS);
        actualizarCarrito();

        mostrarAvisoAPI();
    }
}

function mostrarEstadoCarga(mensaje) {
    if (!productGrid) return;

    productGrid.innerHTML = `
        <div class="sin-productos">
            <h3>${mensaje}</h3>
            <p>Espera un momento...</p>
        </div>
    `;
}

function mostrarAvisoAPI() {
    const aviso = document.createElement("div");
    aviso.className = "api-aviso";
    aviso.innerHTML = `
        <strong>Modo local:</strong>
        No se pudo conectar con FastAPI. Se muestran productos desde JavaScript.
    `;

    const contenido = document.querySelector(".contenido");

    if (contenido) {
        contenido.prepend(aviso);

        setTimeout(() => {
            aviso.remove();
        }, 6000);
    }
}

/* ==============================
   RENDER DE PRODUCTOS
   ============================== */

function renderizarProductos(listaProductos = PRODUCTOS) {
    productGrid.innerHTML = "";

    const productosActivos = listaProductos.filter(producto => producto.activo);

    if (productosActivos.length === 0) {
        productGrid.innerHTML = `
            <div class="sin-productos">
                <h3>No se encontraron productos</h3>
                <p>Intenta con otra búsqueda o categoría.</p>
            </div>
        `;
        return;
    }

    productosActivos.forEach(producto => {
        const agotado = producto.stock <= 0;

        const article = document.createElement("article");
        article.className = agotado ? "producto producto-agotado" : "producto";
        article.dataset.name = producto.nombre;
        article.dataset.category = producto.categoria;
        article.dataset.price = producto.precio;

        article.innerHTML = `
            <img src="${producto.imagen}" alt="${producto.nombre}">
            <h3>${producto.nombre}</h3>

            <p class="producto-precio">$${Number(producto.precio).toFixed(2)}</p>

            <span class="producto-stock">
                ${agotado ? "Sin stock disponible" : `Stock: ${producto.stock}`}
            </span>

            ${agotado ? '<span class="badge-agotado">Agotado</span>' : ""}

            <button 
                ${agotado ? "disabled" : ""}
                onclick="agregarCarrito(${producto.id})">
                ${agotado ? "Agotado" : "Añadir al Carrito"}
            </button>
        `;

        productGrid.appendChild(article);
    });
}

/* ==============================
   CARRITO
   ============================== */

function agregarCarrito(idProducto) {
    const producto = PRODUCTOS.find(item => item.id === idProducto);

    if (!producto) {
        alert("Producto no encontrado");
        return;
    }

    if (producto.stock <= 0) {
        alert("Producto agotado");
        return;
    }

    const existente = carrito.find(item => item.id === idProducto);

    if (existente) {
        if (existente.cantidad >= producto.stock) {
            alert("No hay más stock disponible de este producto");
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

    puntos += Math.floor(Number(producto.precio) / 10);
    actualizarCarrito();
}

function actualizarCarrito() {
    const cartItems = document.getElementById("cartItems");
    const subtotalElement = document.getElementById("subtotal");
    const totalElement = document.getElementById("total");
    const loyaltyPoints = document.getElementById("loyaltyPoints");
    const pointsView = document.getElementById("pointsView");
    const comprasCliente = document.getElementById("comprasCliente");
    const cartCountMobile = document.getElementById("cartCountMobile");

    cartItems.innerHTML = "";

    if (carrito.length === 0) {
        cartItems.innerHTML = '<p class="carrito-vacio">Tu carrito está vacío</p>';
    }

    let subtotal = 0;
    let totalProductos = 0;

    carrito.forEach(item => {
        const itemTotal = item.precio * item.cantidad;
        subtotal += itemTotal;
        totalProductos += item.cantidad;

        const div = document.createElement("div");
        div.className = "cart-item";

        div.innerHTML = `
            <div>
                <h4>${item.nombre}</h4>
                <p>${item.cantidad} item</p>
            </div>

            <div class="cart-item-actions">
                <strong>$${itemTotal.toFixed(2)}</strong>
                <button onclick="eliminarDelCarrito(${item.id})">×</button>
            </div>
        `;

        cartItems.appendChild(div);
    });

    subtotalElement.textContent = `$${subtotal.toFixed(2)}`;
    totalElement.textContent = `$${subtotal.toFixed(2)}`;

    if (loyaltyPoints) {
        loyaltyPoints.textContent = puntos;
    }

    if (pointsView) {
        pointsView.textContent = `${puntos} points`;
    }

    if (comprasCliente) {
        comprasCliente.textContent = totalProductos;
    }

    if (cartCountMobile) {
        cartCountMobile.textContent = totalProductos;
    }
}

function eliminarDelCarrito(idProducto) {
    const productoEnCarrito = carrito.find(item => item.id === idProducto);

    if (!productoEnCarrito) return;

    const productoBase = PRODUCTOS.find(item => item.id === idProducto);

    if (productoEnCarrito.cantidad > 1) {
        productoEnCarrito.cantidad -= 1;
    } else {
        carrito = carrito.filter(item => item.id !== idProducto);
    }

    if (productoBase) {
        const puntosARestar = Math.floor(Number(productoBase.precio) / 10);
        puntos = Math.max(0, puntos - puntosARestar);
    }

    actualizarCarrito();
}

function vaciarCarrito() {
    carrito = [];
    puntos = 0;
    actualizarCarrito();
}

function calcularTotalCarrito() {
    return carrito.reduce((sum, item) => sum + item.precio * item.cantidad, 0);
}

function enviarWhatsApp() {
    if (carrito.length === 0) {
        alert("Tu carrito está vacío");
        return;
    }

    let mensaje = "Hola, quiero hacer este pedido:%0A%0A";

    carrito.forEach(item => {
        mensaje += `- ${item.nombre} x${item.cantidad} = $${(item.precio * item.cantidad).toFixed(2)}%0A`;
    });

    const total = calcularTotalCarrito();

    mensaje += `%0ATotal: $${total.toFixed(2)} MXN`;
    mensaje += `%0APuntos generados: ${puntos}`;

    const telefono = "526393160403";
    const url = `https://wa.me/${telefono}?text=${mensaje}`;

    window.open(url, "_blank");
}

/* ==============================
   BUSCADOR Y FILTROS
   ============================== */

if (searchInput) {
    searchInput.addEventListener("input", function () {
        filtrarProductos();
    });
}

chips.forEach(chip => {
    chip.addEventListener("click", function () {
        chips.forEach(c => c.classList.remove("activo"));
        this.classList.add("activo");

        if (categoryFilter) {
            categoryFilter.value = this.dataset.category;
        }

        filtrarProductos();
    });
});

if (categoryFilter) {
    categoryFilter.addEventListener("change", function () {
        chips.forEach(c => c.classList.remove("activo"));

        const chipActivo = document.querySelector(`.chip[data-category="${this.value}"]`);

        if (chipActivo) {
            chipActivo.classList.add("activo");
        }

        filtrarProductos();
    });
}

function filtrarProductos() {
    const texto = searchInput ? searchInput.value.toLowerCase() : "";
    const categoria = categoryFilter ? categoryFilter.value : "all";

    const productosFiltrados = PRODUCTOS.filter(producto => {
        const coincideTexto = producto.nombre.toLowerCase().includes(texto);
        const coincideCategoria = categoria === "all" || producto.categoria === categoria;

        return producto.activo && coincideTexto && coincideCategoria;
    });

    renderizarProductos(productosFiltrados);
}

/* ==============================
   NAVEGACIÓN
   ============================== */

function navegarSeccion(elemento, seccion) {
    const items = document.querySelectorAll(".sidebar li");

    items.forEach(item => item.classList.remove("activo"));

    if (elemento) {
        elemento.classList.add("activo");
    }

    if (seccion === "productos" || seccion === "catalogo") {
        reiniciarCatalogo();
    }
}

function reiniciarCatalogo() {
    if (categoryFilter) {
        categoryFilter.value = "all";
    }

    if (searchInput) {
        searchInput.value = "";
    }

    chips.forEach(c => c.classList.remove("activo"));

    const chipAll = document.querySelector('.chip[data-category="all"]');

    if (chipAll) {
        chipAll.classList.add("activo");
    }

    renderizarProductos(PRODUCTOS);
}

/* ==============================
   MODALES
   ============================== */

function abrirModal(tipo) {
    const modal = document.getElementById("modal");
    const modalBody = document.getElementById("modalBody");

    let contenido = "";

    if (tipo === "clientes") {
        contenido = `
            <h2>Consulta de Cliente</h2>
            <p>Esta sección permitirá consultar deuda, pagos realizados, restante por pagar y fecha límite.</p>

            <div class="modal-form">
                <input type="text" id="clienteNombre" placeholder="Nombre del cliente">
                <input type="tel" id="clienteCodigo" placeholder="Teléfono o código de cliente">

                <button onclick="consultarClienteDemo()">
                    Consultar Cliente
                </button>
            </div>

            <div id="resultadoCliente"></div>
        `;
    }

    if (tipo === "fidelidad") {
        contenido = `
            <h2>Programa de Fidelidad</h2>
            <p>Actualmente tienes <strong>${puntos}</strong> puntos generados en esta compra.</p>
            <p>Regla inicial: por cada $10 MXN de compra, ganas 1 punto.</p>

            <div class="resultado-cliente">
                <div>
                    <span>Puntos actuales</span>
                    <strong>${puntos}</strong>
                </div>
                <div>
                    <span>Recompensa próxima</span>
                    <strong>50 puntos</strong>
                </div>
                <div>
                    <span>Estado</span>
                    <strong>${puntos >= 50 ? "Recompensa disponible" : "Sigue acumulando"}</strong>
                </div>
            </div>
        `;
    }

    if (tipo === "pagos") {
        const total = calcularTotalCarrito();

        contenido = `
            <h2>Métodos de Pago</h2>
            <p>Total actual del carrito: <strong>$${total.toFixed(2)} MXN</strong></p>
            <p>Selecciona el método de pago que deseas usar.</p>

            <div class="modal-form">
                <select id="metodoPago">
                    <option value="efectivo">Efectivo</option>
                    <option value="transferencia">Transferencia</option>
                    <option value="tarjeta">Tarjeta</option>
                </select>

                <button onclick="seleccionarPago()">
                    Continuar
                </button>
            </div>

            <div id="resultadoPago"></div>
        `;
    }

    if (tipo === "comentarios") {
        contenido = `
            <h2>Comentarios</h2>
            <p>Déjanos tu opinión para mejorar el servicio.</p>

            <div class="modal-form">
                <input type="text" id="comentarioNombre" placeholder="Tu nombre">
                <textarea id="comentarioTexto" placeholder="Escribe tu comentario"></textarea>

                <button onclick="enviarComentarioDemo()">
                    Enviar comentario
                </button>
            </div>

            <div id="resultadoComentario"></div>
        `;
    }

    if (tipo === "calificacion") {
        contenido = `
            <h2>Calificar Servicio</h2>
            <p>Selecciona una calificación para el servicio.</p>

            <div class="estrellas">
                <span onclick="calificarServicio(1)">☆</span>
                <span onclick="calificarServicio(2)">☆</span>
                <span onclick="calificarServicio(3)">☆</span>
                <span onclick="calificarServicio(4)">☆</span>
                <span onclick="calificarServicio(5)">☆</span>
            </div>

            <p id="ratingText">Sin calificación seleccionada</p>

            <div class="modal-form">
                <button onclick="guardarCalificacionDemo()">
                    Guardar calificación
                </button>
            </div>
        `;
    }

    modalBody.innerHTML = contenido;
    modal.classList.add("activo");
}

function cerrarModal() {
    const modal = document.getElementById("modal");

    if (modal) {
        modal.classList.remove("activo");
    }
}

function calificarServicio(valor) {
    calificacionActual = valor;

    const estrellas = document.querySelectorAll(".estrellas span");
    const ratingText = document.getElementById("ratingText");

    estrellas.forEach((estrella, index) => {
        if (index < valor) {
            estrella.textContent = "★";
            estrella.classList.add("activa");
        } else {
            estrella.textContent = "☆";
            estrella.classList.remove("activa");
        }
    });

    if (ratingText) {
        ratingText.textContent = `Calificación seleccionada: ${valor} de 5 estrellas`;
    }
}

/* ==============================
   FUNCIONES DEMO
   ============================== */

function consultarClienteDemo() {
    const nombre = document.getElementById("clienteNombre").value.trim();
    const codigo = document.getElementById("clienteCodigo").value.trim();
    const resultado = document.getElementById("resultadoCliente");

    if (!nombre || !codigo) {
        resultado.innerHTML = `
            <div class="resultado-cliente">
                <strong>Completa nombre y código para consultar.</strong>
            </div>
        `;
        return;
    }

    resultado.innerHTML = `
        <div class="resultado-cliente">
            <div>
                <span>Cliente</span>
                <strong>${nombre}</strong>
            </div>
            <div>
                <span>Debe</span>
                <strong>$0.00</strong>
            </div>
            <div>
                <span>Próximo pago</span>
                <strong>Viernes</strong>
            </div>
            <div>
                <span>Estado</span>
                <strong>Consulta demo</strong>
            </div>
        </div>
    `;
}

function seleccionarPago() {
    const metodo = document.getElementById("metodoPago").value;
    const resultado = document.getElementById("resultadoPago");
    const total = calcularTotalCarrito();

    let mensaje = "";

    if (metodo === "efectivo") {
        mensaje = "Pago en efectivo seleccionado. Se confirmará al entregar el pedido.";
    }

    if (metodo === "transferencia") {
        mensaje = "Pago por transferencia seleccionado. Próximamente se mostrarán los datos bancarios.";
    }

    if (metodo === "tarjeta") {
        mensaje = "Pago con tarjeta seleccionado. Próximamente se conectará con pasarela de pago.";
    }

    resultado.innerHTML = `
        <div class="resultado-cliente">
            <div>
                <span>Método</span>
                <strong>${metodo}</strong>
            </div>
            <div>
                <span>Total</span>
                <strong>$${total.toFixed(2)} MXN</strong>
            </div>
            <p>${mensaje}</p>
        </div>
    `;
}

function enviarComentarioDemo() {
    const nombre = document.getElementById("comentarioNombre").value.trim();
    const comentario = document.getElementById("comentarioTexto").value.trim();
    const resultado = document.getElementById("resultadoComentario");

    if (!nombre || !comentario) {
        resultado.innerHTML = `
            <div class="resultado-cliente">
                <strong>Escribe tu nombre y comentario.</strong>
            </div>
        `;
        return;
    }

    resultado.innerHTML = `
        <div class="resultado-cliente">
            <strong>Gracias, ${nombre}. Tu comentario fue registrado de forma demo.</strong>
        </div>
    `;
}

function guardarCalificacionDemo() {
    if (calificacionActual === 0) {
        alert("Selecciona una calificación primero");
        return;
    }

    alert(`Gracias por calificar el servicio con ${calificacionActual} estrellas`);
}

/* ==============================
   FUNCIONES MOBILE
   ============================== */

function abrirCarritoMobile() {
    const carritoPanel = document.getElementById("carritoPanel");

    if (carritoPanel) {
        carritoPanel.classList.add("carrito-abierto");
    }
}

function cerrarCarritoMobile() {
    const carritoPanel = document.getElementById("carritoPanel");

    if (carritoPanel) {
        carritoPanel.classList.remove("carrito-abierto");
    }
}

function navegarMobile(seccion) {
    cerrarCarritoMobile();

    if (seccion === "productos" || seccion === "catalogo") {
        reiniciarCatalogo();

        const contenido = document.querySelector(".contenido");

        if (contenido) {
            contenido.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
        }
    }
}

/* ==============================
   EVENTOS GLOBALES
   ============================== */

const modal = document.getElementById("modal");

if (modal) {
    modal.addEventListener("click", function (event) {
        if (event.target.id === "modal") {
            cerrarModal();
        }
    });
}

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        cerrarModal();
        cerrarCarritoMobile();
    }
});

/* ==============================
   INICIALIZACIÓN
   ============================== */

cargarProductosDesdeAPI();