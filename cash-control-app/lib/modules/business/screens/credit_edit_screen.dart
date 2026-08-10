import 'package:flutter/material.dart';

import '../models/credit_model.dart';
import '../services/credit_service.dart';

class CreditEditScreen extends StatefulWidget {
  final CreditModel credit;

  const CreditEditScreen({super.key, required this.credit});

  @override
  State<CreditEditScreen> createState() => _CreditEditScreenState();
}

class _CreditEditScreenState extends State<CreditEditScreen> {
  late final TextEditingController _conceptController;
  late final TextEditingController _notesController;

  DateTime? _deadline;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _conceptController = TextEditingController(text: widget.credit.concepto);

    _notesController = TextEditingController(text: widget.credit.notas ?? '');

    _deadline = widget.credit.fechaLimite;
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() {
        _deadline = date;
      });
    }
  }

  Future<void> _save() async {
    if (_conceptController.text.trim().length < 2) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await CreditService.updateCredit(
        creditId: widget.credit.creditId,
        concepto: _conceptController.text,
        fechaLimite: _deadline,
        notas: _notesController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
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
      appBar: AppBar(title: const Text('Editar fiado')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _conceptController,
            decoration: const InputDecoration(
              labelText: 'Concepto',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month),
            title: const Text('Fecha límite'),
            subtitle: Text(
              _deadline == null
                  ? 'Sin fecha límite'
                  : '${_deadline!.day.toString().padLeft(2, '0')}/'
                        '${_deadline!.month.toString().padLeft(2, '0')}/'
                        '${_deadline!.year}',
            ),
            onTap: _selectDate,
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
