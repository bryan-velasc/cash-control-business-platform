let carrito = [];
let puntos = 0;

function agregarCarrito(nombre, precio) {
    const existente = carrito.find(item => item.nombre === nombre);

    if (existente) {
        existente.cantidad += 1;
    } else {
        carrito.push({
            nombre,
            precio,
            cantidad: 1
        });
    }

    puntos += Math.floor(precio / 10);
    actualizarCarrito();
}

function actualizarCarrito() {
    const cartItems = document.getElementById("cartItems");
    const subtotalElement = document.getElementById("subtotal");
    const totalElement = document.getElementById("total");
    const loyaltyPoints = document.getElementById("loyaltyPoints");
    const pointsView = document.getElementById("pointsView");

    cartItems.innerHTML = "";

    if (carrito.length === 0) {
        cartItems.innerHTML = '<p class="carrito-vacio">Tu carrito está vacío</p>';
    }

    let subtotal = 0;

    carrito.forEach(item => {
        const itemTotal = item.precio * item.cantidad;
        subtotal += itemTotal;

        const div = document.createElement("div");
        div.className = "cart-item";
        div.innerHTML = `
            <div>
                <h4>${item.nombre}</h4>
                <p>${item.cantidad} item</p>
            </div>
            <strong>$${itemTotal.toFixed(2)}</strong>
        `;

        cartItems.appendChild(div);
    });

    subtotalElement.textContent = `$${subtotal.toFixed(2)}`;
    totalElement.textContent = `$${subtotal.toFixed(2)}`;
    loyaltyPoints.textContent = puntos;
    pointsView.textContent = `${puntos} points`;
}

function vaciarCarrito() {
    carrito = [];
    puntos = 0;
    actualizarCarrito();
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

    const total = carrito.reduce((sum, item) => sum + item.precio * item.cantidad, 0);

    mensaje += `%0ATotal: $${total.toFixed(2)} MXN`;
    mensaje += `%0APuntos generados: ${puntos}`;

    const telefono = "526393160403";
    const url = `https://wa.me/${telefono}?text=${mensaje}`;

    window.open(url, "_blank");
}

/* Buscador */
const searchInput = document.getElementById("searchInput");

searchInput.addEventListener("input", function () {
    filtrarProductos();
});

/* Filtros */
const chips = document.querySelectorAll(".chip");
const categoryFilter = document.getElementById("categoryFilter");

chips.forEach(chip => {
    chip.addEventListener("click", function () {
        chips.forEach(c => c.classList.remove("activo"));
        this.classList.add("activo");
        categoryFilter.value = this.dataset.category;
        filtrarProductos();
    });
});

categoryFilter.addEventListener("change", function () {
    chips.forEach(c => c.classList.remove("activo"));

    const chipActivo = document.querySelector(`.chip[data-category="${this.value}"]`);
    if (chipActivo) {
        chipActivo.classList.add("activo");
    }

    filtrarProductos();
});

function filtrarProductos() {
    const texto = searchInput.value.toLowerCase();
    const categoria = categoryFilter.value;
    const productos = document.querySelectorAll(".producto");

    productos.forEach(producto => {
        const nombre = producto.dataset.name.toLowerCase();
        const productoCategoria = producto.dataset.category;

        const coincideTexto = nombre.includes(texto);
        const coincideCategoria = categoria === "all" || productoCategoria === categoria;

        producto.style.display = coincideTexto && coincideCategoria ? "block" : "none";
    });
}