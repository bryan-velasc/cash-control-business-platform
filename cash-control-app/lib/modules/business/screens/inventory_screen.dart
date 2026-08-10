import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/inventory_service.dart';
import '../services/product_service.dart';
import 'inventory_adjust_screen.dart';
import 'stock_movements_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _loading = true;
  String? _error;

  List<ProductModel> _products = [];
  List<ProductModel> _lowStock = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ProductService.getAdminProducts(),
        InventoryService.getLowStockProducts(),
      ]);

      if (!mounted) return;

      setState(() {
        _products = results[0] as List<ProductModel>;
        _lowStock = results[1] as List<ProductModel>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _adjust(ProductModel product) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryAdjustScreen(product: product),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  void _openHistory({int? productId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockMovementsScreen(productId: productId),
      ),
    );
  }

  bool _isLow(ProductModel product) {
    return _lowStock.any((item) => item.id == product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: const Color(0xFF181820),
        actions: [
          IconButton(
            tooltip: 'Historial',
            onPressed: () => _openHistory(),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InventorySummary(
                    totalProducts: _products.length,
                    lowStock: _lowStock.length,
                    totalUnits: _products.fold<int>(
                      0,
                      (total, product) => total + product.stock,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_lowStock.isNotEmpty) ...[
                    const Text(
                      'Stock bajo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._lowStock.map(
                      (product) => _ProductStockCard(
                        product: product,
                        lowStock: true,
                        onAdjust: () => _adjust(product),
                        onHistory: () => _openHistory(productId: product.id),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Todos los productos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._products.map(
                    (product) => _ProductStockCard(
                      product: product,
                      lowStock: _isLow(product),
                      onAdjust: () => _adjust(product),
                      onHistory: () => _openHistory(productId: product.id),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final int totalProducts;
  final int lowStock;
  final int totalUnits;

  const _InventorySummary({
    required this.totalProducts,
    required this.lowStock,
    required this.totalUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Productos',
            value: totalProducts.toString(),
            icon: Icons.inventory_2_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Stock bajo',
            value: lowStock.toString(),
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Unidades',
            value: totalUnits.toString(),
            icon: Icons.warehouse_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ProductStockCard extends StatelessWidget {
  final ProductModel product;
  final bool lowStock;
  final VoidCallback onAdjust;
  final VoidCallback onHistory;

  const _ProductStockCard({
    required this.product,
    required this.lowStock,
    required this.onAdjust,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(product.stock.toString())),
        title: Text(product.nombre),
        subtitle: Text(
          lowStock
              ? 'Stock bajo · mínimo ${product.stockMinimo ?? 0}'
              : 'Stock disponible: ${product.stock}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'adjust') {
              onAdjust();
            }

            if (value == 'history') {
              onHistory();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'adjust', child: Text('Registrar movimiento')),
            PopupMenuItem(value: 'history', child: Text('Ver historial')),
          ],
        ),
      ),
    );
  }
}
