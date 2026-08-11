import 'package:flutter/material.dart';

import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

import 'new_purchase_screen.dart';
import 'purchase_detail_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() =>
      _PurchasesScreenState();
}

class _PurchasesScreenState
    extends State<PurchasesScreen> {
  bool _loading = true;
  String? _error;

  List<PurchaseModel> _purchases = [];
  PurchaseSummaryModel? _summary;

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
        PurchaseService.getPurchases(),
        PurchaseService.getSummary(),
      ]);

      if (!mounted) return;

      setState(() {
        _purchases =
            results[0] as List<PurchaseModel>;

        _summary =
            results[1] as PurchaseSummaryModel;

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

  Future<void> _newPurchase() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const NewPurchaseScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compras / Reinversión',
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _newPurchase,
        icon: const Icon(
          Icons.add_shopping_cart,
        ),
        label: const Text(
          'Nueva compra',
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text(
                  'Reintentar',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        children: [
          if (_summary != null)
            _SummarySection(
              summary: _summary!,
            ),

          const SizedBox(height: 20),

          const Text(
            'Historial de compras',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (_purchases.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'Todavía no hay compras registradas.',
                ),
              ),
            )
          else
            ..._purchases.map(
              (purchase) => Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PurchaseDetailScreen(
                          purchase: purchase,
                        ),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                    ),
                  ),
                  title: Text(
                    purchase.supplierNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(purchase.folio),
                      Text(
                        '${purchase.items.length} producto(s)',
                      ),
                      Text(
                        'Estado: ${purchase.estado}',
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${purchase.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final PurchaseSummaryModel summary;

  const _SummarySection({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryCard(
          title: 'Total reinvertido',
          value:
              '\$${summary.totalCompras.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Compras',
                value:
                    '${summary.numeroCompras}',
                icon:
                    Icons.shopping_cart_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Unidades',
                value:
                    '${summary.totalUnidades}',
                icon:
                    Icons.inventory_2_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}