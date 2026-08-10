import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ProductService.getAdminProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      _filterProducts();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
      return;
    }

    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product.nombre.toLowerCase();
        final category = product.categoria.toLowerCase();
        final provider = product.proveedor?.toLowerCase() ?? '';

        return name.contains(query) ||
            category.contains(query) ||
            provider.contains(query);
      }).toList();
    });
  }

  void _showPendingFeature(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature se implementará en la siguiente fase.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStock = _products.fold<int>(
      0,
      (total, product) => total + product.stock,
    );

    final activeProducts = _products.where((product) => product.activo).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPendingFeature('Crear producto'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProductsHeader(
              totalProducts: _products.length,
              activeProducts: activeProducts,
              totalStock: totalStock,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                hintText: 'Nombre, categoría o proveedor',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const _LoadingState()
            else if (_errorMessage != null)
              _ErrorState(message: _errorMessage!, onRetry: _loadProducts)
            else if (_filteredProducts.isEmpty)
              const _EmptyState()
            else
              ..._filteredProducts.map(
                (product) => ProductCard(
                  product: product,
                  onTap: () => _showProductDetails(product),
                  onEdit: () => _showPendingFeature('Editar producto'),
                  onStock: () => _showPendingFeature('Ajustar stock'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _DetailRow(label: 'Categoría', value: product.categoria),
              _DetailRow(
                label: 'Precio venta',
                value: '\$${product.precio.toStringAsFixed(2)}',
              ),
              _DetailRow(label: 'Stock', value: product.stock.toString()),
              _DetailRow(
                label: 'Estado',
                value: product.activo ? 'Activo' : 'Inactivo',
              ),
              if (product.precioCompra != null)
                _DetailRow(
                  label: 'Precio compra',
                  value: '\$${product.precioCompra!.toStringAsFixed(2)}',
                ),
              if (product.proveedor != null)
                _DetailRow(label: 'Proveedor', value: product.proveedor!),
              if (product.stockMinimo != null)
                _DetailRow(
                  label: 'Stock mínimo',
                  value: product.stockMinimo.toString(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  final int totalProducts;
  final int activeProducts;
  final int totalStock;

  const _ProductsHeader({
    required this.totalProducts,
    required this.activeProducts,
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: 'Productos',
            value: totalProducts.toString(),
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryBox(
            title: 'Activos',
            value: activeProducts.toString(),
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryBox(
            title: 'Stock',
            value: totalStock.toString(),
            icon: Icons.inventory_2_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 54),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar los productos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(child: Text('No hay productos para mostrar.')),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
