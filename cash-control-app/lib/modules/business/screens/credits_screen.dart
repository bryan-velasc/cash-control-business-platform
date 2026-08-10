import 'package:flutter/material.dart';

import '../models/credit_model.dart';
import '../models/customer_model.dart';

import '../services/credit_service.dart';
import '../services/customer_service.dart';

import 'credit_detail_screen.dart';
import 'credit_form_screen.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  bool _loading = true;
  String? _error;

  List<CreditModel> _credits = [];

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credits = await CreditService.getCredits();

      if (!mounted) return;

      setState(() {
        _credits = credits;
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

  double get _totalFiado {
    return _credits.fold(0, (total, credit) => total + credit.montoTotal);
  }

  double get _totalPagado {
    return _credits.fold(0, (total, credit) => total + credit.montoPagado);
  }

  double get _totalPendiente {
    return _credits.fold(0, (total, credit) => total + credit.saldoPendiente);
  }

  Future<void> _openCredit(CreditModel credit) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreditDetailScreen(creditId: credit.creditId),
      ),
    );

    if (changed == true) {
      await _loadCredits();
    }
  }

  Future<void> _newCredit() async {
    try {
      final customers = await CustomerService.getCustomers();

      if (!mounted) return;

      final activeCustomers = customers
          .where((customer) => customer.activo)
          .toList();

      if (activeCustomers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No hay clientes activos. '
              'Primero registra un cliente.',
            ),
          ),
        );

        return;
      }

      final selectedCustomer = await showModalBottomSheet<CustomerModel>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return _CustomerSelectorSheet(customers: activeCustomers);
        },
      );

      if (selectedCustomer == null) {
        return;
      }

      if (!mounted) return;

      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreditFormScreen(
            customerId: selectedCustomer.customerId,
            customerName: selectedCustomer.nombre,
          ),
        ),
      );

      if (changed == true) {
        await _loadCredits();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los clientes: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiados'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loadCredits,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newCredit,
        icon: const Icon(Icons.add_card),
        label: const Text('Nuevo fiado'),
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
              FilledButton.icon(
                onPressed: _loadCredits,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCredits,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Fiado',
                  value: '\$${_totalFiado.toStringAsFixed(2)}',
                  icon: Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: 'Pagado',
                  value: '\$${_totalPagado.toStringAsFixed(2)}',
                  icon: Icons.payments,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _SummaryCard(
            title: 'Pendiente',
            value: '\$${_totalPendiente.toStringAsFixed(2)}',
            icon: Icons.schedule,
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fiados registrados',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_credits.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_credits.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 50),
                    SizedBox(height: 12),
                    Text(
                      'Todavía no hay fiados registrados.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presiona "Nuevo fiado" para comenzar.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._credits.map(
              (credit) =>
                  _CreditCard(credit: credit, onTap: () => _openCredit(credit)),
            ),
        ],
      ),
    );
  }
}

class _CustomerSelectorSheet extends StatefulWidget {
  final List<CustomerModel> customers;

  const _CustomerSelectorSheet({required this.customers});

  @override
  State<_CustomerSelectorSheet> createState() => _CustomerSelectorSheetState();
}

class _CustomerSelectorSheetState extends State<_CustomerSelectorSheet> {
  String _search = '';

  List<CustomerModel> get _filtered {
    final search = _search.trim().toLowerCase();

    if (search.isEmpty) {
      return widget.customers;
    }

    return widget.customers.where((customer) {
      final name = customer.nombre.toLowerCase();

      final alias = customer.alias?.toLowerCase() ?? '';

      final phone = customer.telefono?.toLowerCase() ?? '';

      return name.contains(search) ||
          alias.contains(search) ||
          phone.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecciona un cliente',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Buscar cliente',
                  hintText: 'Nombre, alias o teléfono',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No se encontraron clientes.'))
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final customer = _filtered[index];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                customer.nombre.isEmpty
                                    ? '?'
                                    : customer.nombre[0].toUpperCase(),
                              ),
                            ),
                            title: Text(customer.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customer.alias != null &&
                                    customer.alias!.isNotEmpty)
                                  Text('Alias: ${customer.alias}'),
                                if (customer.telefono != null &&
                                    customer.telefono!.isNotEmpty)
                                  Text('Tel: ${customer.telefono}'),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(context, customer);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final CreditModel credit;
  final VoidCallback onTap;

  const _CreditCard({required this.credit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(
            credit.estaPagado
                ? Icons.check
                : credit.estaCancelado
                ? Icons.close
                : Icons.receipt,
          ),
        ),
        title: Text(
          credit.customerNombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(credit.concepto),

            const SizedBox(height: 8),

            LinearProgressIndicator(value: credit.progreso),

            const SizedBox(height: 6),

            Text(
              'Total: '
              '\$${credit.montoTotal.toStringAsFixed(2)}',
            ),

            Text(
              'Pagado: '
              '\$${credit.montoPagado.toStringAsFixed(2)}',
            ),

            Text(
              'Pendiente: '
              '\$${credit.saldoPendiente.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              'Estado: '
              '${_statusLabel(credit.estado)}',
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';

      case 'parcial':
        return 'Pago parcial';

      case 'pagado':
        return 'Pagado';

      case 'vencido':
        return 'Vencido';

      case 'cancelado':
        return 'Cancelado';

      default:
        return status;
    }
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
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(title),
          ],
        ),
      ),
    );
  }
}
