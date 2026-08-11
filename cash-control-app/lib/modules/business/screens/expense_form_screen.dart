import 'package:flutter/material.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  bool _saving = false;

  String _category = 'otros';
  String _paymentMethod = 'efectivo';

  bool get _editing => widget.expense != null;

  static const List<String> _categories = [
    'transporte',
    'publicidad',
    'servicios',
    'comisiones',
    'empaques',
    'mantenimiento',
    'otros',
  ];

  static const List<String> _paymentMethods = [
    'efectivo',
    'tarjeta',
    'transferencia',
    'otro',
  ];

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    _descriptionController = TextEditingController(
      text: expense?.descripcion ?? '',
    );

    _amountController = TextEditingController(
      text: expense == null ? '' : expense.monto.toStringAsFixed(2),
    );

    _referenceController = TextEditingController(
      text: expense?.referencia ?? '',
    );

    _notesController = TextEditingController(text: expense?.notas ?? '');

    if (expense != null) {
      if (_categories.contains(expense.categoria)) {
        _category = expense.categoria;
      }

      if (_paymentMethods.contains(expense.metodoPago)) {
        _paymentMethod = expense.metodoPago;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '').trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido.')));

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (_editing) {
        await ExpenseService.updateExpense(
          expenseId: widget.expense!.expenseId,
          categoria: _category,
          descripcion: _descriptionController.text,
          monto: amount,
          metodoPago: _paymentMethod,
          referencia: _referenceController.text,
          notas: _notesController.text,
        );
      } else {
        await ExpenseService.createExpense(
          categoria: _category,
          descripcion: _descriptionController.text,
          monto: amount,
          metodoPago: _paymentMethod,
          referencia: _referenceController.text,
          notas: _notesController.text,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el gasto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Editar gasto' : 'Nuevo gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(_capitalize(category)),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _category = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Gasolina para recoger mercancía',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').replaceAll(',', '').trim(),
                );

                if (amount == null || amount <= 0) {
                  return 'Ingresa un monto mayor a 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Método de pago',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(_capitalize(method)),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _paymentMethod = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Referencia',
                hintText: 'Ticket, factura, transferencia...',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _saving
                      ? 'Guardando...'
                      : _editing
                      ? 'Actualizar gasto'
                      : 'Registrar gasto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
