import 'package:flutter/material.dart';

import '../models/purchase_model.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseDetailScreen({
    super.key,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de compra'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.folio,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _row(
                    'Proveedor',
                    purchase.supplierNombre,
                  ),
                  _row(
                    'Estado',
                    purchase.estado,
                  ),
                  _row(
                    'Usuario',
                    purchase.usuario,
                  ),
                  if (purchase.createdAt != null)
                    _row(
                      'Fecha',
                      _formatDate(purchase.createdAt!),
                    ),
                  if (purchase.referencia != null &&
                      purchase.referencia!.isNotEmpty)
                    _row(
                      'Referencia',
                      purchase.referencia!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Productos',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...purchase.items.map(
            (item) => Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productoNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _row(
                      'Cantidad',
                      '${item.cantidad}',
                    ),
                    _row(
                      'Costo unitario',
                      '\$${item.costoUnitario.toStringAsFixed(2)}',
                    ),
                    _row(
                      'Subtotal',
                      '\$${item.subtotal.toStringAsFixed(2)}',
                    ),
                    _row(
                      'Stock anterior',
                      '${item.stockAnterior}',
                    ),
                    _row(
                      'Stock nuevo',
                      '${item.stockNuevo}',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total reinvertido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${purchase.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (purchase.notas != null &&
              purchase.notas!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(purchase.notas!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) =>
        value.toString().padLeft(2, '0');

    return '${two(local.day)}/'
        '${two(local.month)}/'
        '${local.year} '
        '${two(local.hour)}:'
        '${two(local.minute)}';
  }
}