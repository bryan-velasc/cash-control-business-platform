import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'customer_form_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _loading = true;
  String? _error;

  List<CustomerModel> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final customers = await CustomerService.getCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
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

  Future<void> _openForm({CustomerModel? customer}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
    );

    if (changed == true) {
      await _loadCustomers();
    }
  }

  Future<void> _showSummary(CustomerModel customer) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final summary = await CustomerService.getCustomerSummary(
        customer.customerId,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(summary.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.telefono != null && summary.telefono!.isNotEmpty)
                Text('Teléfono: ${summary.telefono}'),

              const SizedBox(height: 16),

              _summaryRow('Total fiado', summary.totalFiado),

              _summaryRow('Total pagado', summary.totalPagado),

              _summaryRow('Saldo pendiente', summary.saldoPendiente),

              const SizedBox(height: 8),

              Text('Créditos activos: ${summary.creditosActivos}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el resumen: $error')),
      );
    }
  }

  Widget _summaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivate(CustomerModel customer) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Desactivar cliente'),
            content: Text('¿Deseas desactivar a ${customer.nombre}?'),
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
                child: const Text('Desactivar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await CustomerService.deleteCustomer(customer.customerId);

      await _loadCustomers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente desactivado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desactivar cliente: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFF181820),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loadCustomers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo cliente'),
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
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _loadCustomers,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_customers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadCustomers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(Icons.people_outline, size: 64),
            SizedBox(height: 12),
            Center(child: Text('Todavía no hay clientes')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final CustomerModel customer = _customers[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () {
                _showSummary(customer);
              },
              leading: CircleAvatar(
                child: Text(
                  customer.nombre.isEmpty
                      ? '?'
                      : customer.nombre[0].toUpperCase(),
                ),
              ),
              title: Text(
                customer.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: customer.activo ? null : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customer.alias != null && customer.alias!.isNotEmpty)
                    Text('Alias: ${customer.alias}'),

                  if (customer.telefono != null &&
                      customer.telefono!.isNotEmpty)
                    Text('Tel: ${customer.telefono}'),

                  Text(
                    customer.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: customer.activo ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'summary':
                      _showSummary(customer);
                      break;

                    case 'edit':
                      _openForm(customer: customer);
                      break;

                    case 'deactivate':
                      _deactivate(customer);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem<String>(
                    value: 'summary',
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined),
                      title: Text('Ver resumen'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  if (customer.activo)
                    const PopupMenuItem<String>(
                      value: 'deactivate',
                      child: ListTile(
                        leading: Icon(Icons.person_off_outlined),
                        title: Text('Desactivar'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
