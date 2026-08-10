import 'package:flutter/material.dart';

import '../services/credit_service.dart';

class CreditFormScreen extends StatefulWidget {
  final int customerId;
  final String customerName;

  const CreditFormScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CreditFormScreen> createState() => _CreditFormScreenState();
}

class _CreditFormScreenState extends State<CreditFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _conceptoController = TextEditingController();

  final _montoController = TextEditingController();

  final _notasController = TextEditingController();

  DateTime? _fechaLimite;

  bool _saving = false;

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _notasController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _fechaLimite = date;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final monto = double.tryParse(
      _montoController.text.replaceAll(',', '').trim(),
    );

    if (monto == null || monto <= 0) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await CreditService.createCredit(
        customerId: widget.customerId,
        concepto: _conceptoController.text.trim(),
        montoTotal: monto,
        fechaLimite: _fechaLimite,
        notas: _notasController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiado creado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el fiado: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo fiado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(widget.customerName),
                    subtitle: Text('Cliente #${widget.customerId}'),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _conceptoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Concepto del fiado',
                    hintText: 'Ej. pantalón, pedido, mercancía...',
                    prefixIcon: Icon(Icons.receipt_long_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Escribe el concepto del fiado';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _montoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto total',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final monto = double.tryParse(
                      value?.replaceAll(',', '').trim() ?? '',
                    );

                    if (monto == null || monto <= 0) {
                      return 'Ingresa un monto válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Fecha límite'),
                    subtitle: Text(
                      _fechaLimite == null
                          ? 'Sin fecha límite'
                          : _formatDate(_fechaLimite!),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDate,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _notasController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    hintText: 'Información adicional...',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Guardando...' : 'Registrar fiado'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
