import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/inventory_service.dart';

class InventoryAdjustScreen extends StatefulWidget {
  final ProductModel product;

  const InventoryAdjustScreen({
    super.key,
    required this.product,
  });

  @override
  State<InventoryAdjustScreen> createState() =>
      _InventoryAdjustScreenState();
}

class _InventoryAdjustScreenState
    extends State<InventoryAdjustScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  final _referenciaController = TextEditingController();

  String _tipo = 'entrada';
  bool _saving = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await InventoryService.adjustStock(
        productId: widget.product.id,
        tipo: _tipo,
        cantidad: int.parse(
          _cantidadController.text.trim(),
        ),
        motivo: _motivoController.text.trim(),
        referencia:
            _referenciaController.text.trim().isEmpty
                ? null
                : _referenciaController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Movimiento de inventario registrado',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _cantidadLabel() {
    if (_tipo == 'ajuste') {
      return 'Nuevo stock final';
    }

    return 'Cantidad';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        title: const Text('Movimiento de inventario'),
        backgroundColor: const Color(0xFF181820),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory_2_rounded,
                  ),
                  title: Text(
                    widget.product.nombre,
                  ),
                  subtitle: Text(
                    'Stock actual: ${widget.product.stock}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de movimiento',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'entrada',
                    child: Text('Entrada'),
                  ),
                  DropdownMenuItem(
                    value: 'salida',
                    child: Text('Salida'),
                  ),
                  DropdownMenuItem(
                    value: 'ajuste',
                    child: Text('Ajuste manual'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _tipo = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _cantidadLabel(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (amount == null || amount < 0) {
                    return 'Ingresa una cantidad válida';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText:
                      'Compra, venta, corrección, devolución...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 3) {
                    return 'Describe el motivo';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia opcional',
                  hintText:
                      'Factura, pedido, venta, proveedor...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_rounded,
                        ),
                  label: Text(
                    _saving
                        ? 'Guardando...'
                        : 'Registrar movimiento',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}