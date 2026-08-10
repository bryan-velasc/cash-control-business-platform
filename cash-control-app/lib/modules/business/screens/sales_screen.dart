import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/sale_service.dart';

import 'cash_summary_screen.dart';
import 'new_sale_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  bool _loading = true;
  String? _error;

  List<SaleModel> _sales = [];

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
      final sales = await SaleService.getSales();

      if (!mounted) return;

      setState(() {
        _sales = sales;
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

  Future<void> _newSale() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewSaleScreen(),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas / Caja'),
        actions: [
          IconButton(
            tooltip: 'Caja',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CashSummaryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_balance_wallet_outlined,
            ),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newSale,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva venta'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: FilledButton(
          onPressed: _load,
          child: const Text('Reintentar'),
        ),
      );
    }

    if (_sales.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no hay ventas registradas.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SaleDetailScreen(
                      saleId: sale.saleId,
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                child: Icon(
                  sale.metodoPago == 'fiado'
                      ? Icons.receipt_long
                      : Icons.shopping_cart_outlined,
                ),
              ),
              title: Text(
                '\$${sale.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.folio),
                  Text(
                    sale.customerNombre ??
                        'Venta sin cliente',
                  ),
                  Text(
                    'Pago: ${sale.metodoPago}',
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          );
        },
      ),
    );
  }
}