import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

import 'supplier_form_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  bool _loading = true;
  String? _error;

  List<SupplierModel> _suppliers = [];

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
      final suppliers = await SupplierService.getSuppliers();

      if (!mounted) return;

      setState(() {
        _suppliers = suppliers;
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

  Future<void> _openForm({
    SupplierModel? supplier,
  }) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierFormScreen(
          supplier: supplier,
        ),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  Future<void> _showSummary(
    SupplierModel supplier,
  ) async {
    try {
      final summary = await SupplierService.getSummary(
        supplier.supplierId,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(summary.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(
                'Compras',
                '${summary.numeroCompras}',
              ),
              _row(
                'Total comprado',
                '\$${summary.totalCompras.toStringAsFixed(2)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cargar el resumen: $error',
          ),
        ),
      );
    }
  }

  Future<void> _deactivate(
    SupplierModel supplier,
  ) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Desactivar proveedor'),
            content: Text(
              '¿Deseas desactivar a ${supplier.nombre}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Desactivar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await SupplierService.deleteSupplier(
        supplier.supplierId,
      );

      await _load();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al desactivar proveedor: $error',
          ),
        ),
      );
    }
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_business),
        label: const Text('Nuevo proveedor'),
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

    if (_suppliers.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no hay proveedores registrados.',
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
        itemCount: _suppliers.length,
        itemBuilder: (context, index) {
          final supplier = _suppliers[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => _showSummary(supplier),
              leading: CircleAvatar(
                child: Icon(
                  supplier.activo
                      ? Icons.business
                      : Icons.business_outlined,
                ),
              ),
              title: Text(
                supplier.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: supplier.activo ? null : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (supplier.contacto != null &&
                      supplier.contacto!.isNotEmpty)
                    Text(
                      'Contacto: ${supplier.contacto}',
                    ),
                  if (supplier.telefono != null &&
                      supplier.telefono!.isNotEmpty)
                    Text(
                      'Tel: ${supplier.telefono}',
                    ),
                  if (supplier.email != null &&
                      supplier.email!.isNotEmpty)
                    Text(
                      supplier.email!,
                    ),
                  Text(
                    supplier.activo ? 'Activo' : 'Inactivo',
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'summary':
                      _showSummary(supplier);
                      break;
                    case 'edit':
                      _openForm(supplier: supplier);
                      break;
                    case 'deactivate':
                      _deactivate(supplier);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'summary',
                    child: Text('Ver resumen'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  if (supplier.activo)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Text('Desactivar'),
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