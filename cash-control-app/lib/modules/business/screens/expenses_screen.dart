import 'package:flutter/material.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _loading = true;

  String? _error;

  List<ExpenseModel> _expenses = [];

  ExpenseSummaryModel? _summary;

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
        ExpenseService.getExpenses(),
        ExpenseService.getSummary(),
      ]);

      if (!mounted) return;

      setState(() {
        _expenses = results[0] as List<ExpenseModel>;

        _summary = results[1] as ExpenseSummaryModel;

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

  Future<void> _openForm({ExpenseModel? expense}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)),
    );

    if (changed == true) {
      await _load();
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar gasto'),
            content: Text(
              '¿Deseas eliminar el gasto '
              '"${expense.descripcion}" por '
              '\$${expense.monto.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await ExpenseService.deleteExpense(expense.expenseId);

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto eliminado correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (_summary != null) _buildSummary(_summary!),

          const SizedBox(height: 22),

          const Text(
            'Historial de gastos',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (_expenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text('Todavía no hay gastos registrados.'),
                ),
              ),
            )
          else
            ..._expenses.map(_buildExpenseCard),
        ],
      ),
    );
  }

  Widget _buildSummary(ExpenseSummaryModel summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.money_off_csred_outlined)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total de gastos'),
                      Text(
                        '\$${summary.totalGastos.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('${summary.numeroGastos} movimientos'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Por categoría',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _CategoryChip(label: 'Transporte', amount: summary.transporte),
            _CategoryChip(label: 'Publicidad', amount: summary.publicidad),
            _CategoryChip(label: 'Servicios', amount: summary.servicios),
            _CategoryChip(label: 'Comisiones', amount: summary.comisiones),
            _CategoryChip(label: 'Empaques', amount: summary.empaques),
            _CategoryChip(
              label: 'Mantenimiento',
              amount: summary.mantenimiento,
            ),
            _CategoryChip(label: 'Otros', amount: summary.otros),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_categoryIcon(expense.categoria))),
        title: Text(
          expense.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_capitalize(expense.categoria)),
            Text(_formatDate(expense.createdAt)),
            Text('Pago: ${_capitalize(expense.metodoPago)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _openForm(expense: expense);
                break;

              case 'delete':
                _deleteExpense(expense);
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                '\$${expense.monto.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'transporte':
        return Icons.local_shipping_outlined;

      case 'publicidad':
        return Icons.campaign_outlined;

      case 'servicios':
        return Icons.receipt_long_outlined;

      case 'comisiones':
        return Icons.percent;

      case 'empaques':
        return Icons.inventory_2_outlined;

      case 'mantenimiento':
        return Icons.build_outlined;

      default:
        return Icons.payments_outlined;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${two(local.day)}/'
        '${two(local.month)}/'
        '${local.year} '
        '${two(local.hour)}:'
        '${two(local.minute)}';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final double amount;

  const _CategoryChip({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: \$${amount.toStringAsFixed(2)}'));
  }
}
