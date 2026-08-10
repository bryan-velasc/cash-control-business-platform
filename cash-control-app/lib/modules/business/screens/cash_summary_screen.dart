import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/sale_service.dart';

class CashSummaryScreen extends StatefulWidget {
  const CashSummaryScreen({super.key});

  @override
  State<CashSummaryScreen> createState() =>
      _CashSummaryScreenState();
}

class _CashSummaryScreenState extends State<CashSummaryScreen> {
  SalesSummaryModel? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
    });

    try {
      final summary = await SaleService.getSummary();

      if (!mounted) return;

      setState(() {
        _summary = summary;
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
        title: const Text('Caja'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final summary = _summary;

    if (summary == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _metric(
          'Ventas',
          summary.totalVentas,
          Icons.point_of_sale,
        ),
        _metric(
          'Costo de mercancía',
          summary.totalCosto,
          Icons.inventory_2_outlined,
        ),
        _metric(
          'Utilidad bruta',
          summary.utilidadBruta,
          Icons.trending_up,
        ),

        const SizedBox(height: 20),

        Text(
          '${summary.numeroVentas} ventas registradas',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const Divider(height: 32),

        _metric(
          'Efectivo',
          summary.efectivo,
          Icons.payments_outlined,
        ),
        _metric(
          'Transferencia',
          summary.transferencia,
          Icons.account_balance,
        ),
        _metric(
          'Tarjeta',
          summary.tarjeta,
          Icons.credit_card,
        ),
        _metric(
          'Fiado',
          summary.fiado,
          Icons.receipt_long,
        ),
      ],
    );
  }

  Widget _metric(
    String title,
    double value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}