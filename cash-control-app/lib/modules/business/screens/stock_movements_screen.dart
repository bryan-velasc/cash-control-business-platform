import 'package:flutter/material.dart';

import '../models/stock_movement_model.dart';
import '../services/inventory_service.dart';

class StockMovementsScreen extends StatefulWidget {
  final int? productId;

  const StockMovementsScreen({super.key, this.productId});

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  bool _loading = true;
  String? _error;

  List<StockMovementModel> _movements = [];

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
      final movements = await InventoryService.getHistory(
        productId: widget.productId,
      );

      if (!mounted) return;

      setState(() {
        _movements = movements;
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'entrada':
        return Icons.add_circle_rounded;

      case 'salida':
        return Icons.remove_circle_rounded;

      default:
        return Icons.tune_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'entrada':
        return Colors.greenAccent;

      case 'salida':
        return Colors.redAccent;

      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('Historial de inventario'),
        backgroundColor: const Color(0xFF181820),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, textAlign: TextAlign.center))
          : _movements.isEmpty
          ? const Center(child: Text('No hay movimientos registrados.'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _movements.length,
                itemBuilder: (context, index) {
                  final movement = _movements[index];

                  final color = _colorForType(movement.tipo);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(_iconForType(movement.tipo), color: color),
                      title: Text(movement.productoNombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${movement.tipo.toUpperCase()} · ${movement.motivo}',
                          ),
                          Text(
                            'Stock: ${movement.stockAnterior} → ${movement.stockNuevo}',
                          ),
                          if (movement.referencia != null)
                            Text('Ref: ${movement.referencia}'),
                          Text(
                            movement.createdAt.toLocal().toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
