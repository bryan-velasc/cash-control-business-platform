import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/sale_service.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleDetailScreen> createState() =>
      _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  SaleModel? _sale;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sale = await SaleService.getSale(widget.saleId);

      if (!mounted) return;

      setState(() {
        _sale = sale;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de venta'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final sale = _sale;

    if (sale == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          sale.folio,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text('Método: ${sale.metodoPago}'),

        if (sale.customerNombre != null)
          Text('Cliente: ${sale.customerNombre}'),

        if (sale.creditId != null)
          Text('Fiado: #${sale.creditId}'),

        const Divider(height: 32),

        const Text(
          'Productos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        ...sale.items.map(
          (item) => Card(
            child: ListTile(
              title: Text(item.productoNombre),
              subtitle: Text(
                '${item.cantidad} × '
                '\$${item.precioUnitario.toStringAsFixed(2)}',
              ),
              trailing: Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
              ),
            ),
          ),
        ),

        const Divider(height: 32),

        _row('Venta', sale.total),
        _row('Costo', sale.costoTotal),
        _row('Utilidad bruta', sale.utilidadBruta),

        if (sale.notas != null &&
            sale.notas!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Notas: ${sale.notas}'),
        ],
      ],
    );
  }

  Widget _row(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}