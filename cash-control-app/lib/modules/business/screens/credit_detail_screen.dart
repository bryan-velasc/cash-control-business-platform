import 'package:flutter/material.dart';

import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';
import '../services/credit_service.dart';

import 'credit_edit_screen.dart';
import 'credit_payment_screen.dart';

class CreditDetailScreen extends StatefulWidget {
  final int creditId;

  const CreditDetailScreen({super.key, required this.creditId});

  @override
  State<CreditDetailScreen> createState() => _CreditDetailScreenState();
}

class _CreditDetailScreenState extends State<CreditDetailScreen> {
  CreditModel? _credit;
  List<CreditPaymentModel> _payments = [];

  bool _loading = true;
  String? _error;

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
      final credit = await CreditService.getCredit(widget.creditId);

      final payments = await CreditService.getPayments(widget.creditId);

      if (!mounted) return;

      setState(() {
        _credit = credit;
        _payments = payments;
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

  Future<void> _openPayment() async {
    final credit = _credit;

    if (credit == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreditPaymentScreen(credit: credit)),
    );

    if (result == true) {
      await _load();
    }
  }

  Future<void> _openEdit() async {
    final credit = _credit;

    if (credit == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreditEditScreen(credit: credit)),
    );

    if (result == true) {
      await _load();
    }
  }

  Future<void> _cancelCredit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar fiado'),
          content: const Text(
            '¿Seguro que deseas cancelar este fiado? '
            'El registro permanecerá en el historial.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await CreditService.cancelCredit(widget.creditId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiado cancelado correctamente.')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del fiado'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final credit = _credit!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credit.customerNombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(credit.concepto),
                  const SizedBox(height: 18),

                  LinearProgressIndicator(value: credit.progreso),

                  const SizedBox(height: 16),

                  _InfoRow(
                    title: 'Monto total',
                    value: '\$${credit.montoTotal.toStringAsFixed(2)}',
                  ),
                  _InfoRow(
                    title: 'Pagado',
                    value: '\$${credit.montoPagado.toStringAsFixed(2)}',
                  ),
                  _InfoRow(
                    title: 'Pendiente',
                    value: '\$${credit.saldoPendiente.toStringAsFixed(2)}',
                  ),
                  _InfoRow(title: 'Estado', value: credit.estado),

                  if (credit.fechaLimite != null)
                    _InfoRow(
                      title: 'Fecha límite',
                      value: _formatDate(credit.fechaLimite!),
                    ),

                  if (credit.notas != null && credit.notas!.isNotEmpty) ...[
                    const Divider(),
                    Text('Notas: ${credit.notas}'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (credit.aceptaAbonos)
            FilledButton.icon(
              onPressed: _openPayment,
              icon: const Icon(Icons.add_card),
              label: const Text('Registrar abono'),
            ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar'),
          ),

          if (!credit.estaCancelado && !credit.estaPagado) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _cancelCredit,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar fiado'),
            ),
          ],

          const SizedBox(height: 24),

          const Text(
            'Historial de abonos',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (_payments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Todavía no hay abonos registrados.'),
                ),
              ),
            )
          else
            ..._payments.map(
              (payment) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.payments_outlined),
                  ),
                  title: Text('\$${payment.monto.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${_paymentMethodName(payment.metodoPago)}'
                    '\n${_formatDateTime(payment.createdAt)}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _paymentMethodName(String value) {
    switch (value) {
      case 'efectivo':
        return 'Efectivo';
      case 'transferencia':
        return 'Transferencia';
      case 'tarjeta':
        return 'Tarjeta';
      default:
        return 'Otro';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
