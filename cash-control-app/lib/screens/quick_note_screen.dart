import 'package:flutter/material.dart';

import '../services/quick_note_service.dart';

class QuickNoteScreen extends StatefulWidget {
  const QuickNoteScreen({
    super.key,
  });

  @override
  State<QuickNoteScreen> createState() =>
      _QuickNoteScreenState();
}

class _QuickNoteScreenState
    extends State<QuickNoteScreen> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController contentController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  bool saving = false;

  Future<void> saveNote() async {
    final content = contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Escribe una nota antes de guardar.",
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    await QuickNoteService.addNote(
      title: titleController.text,
      content: contentController.text,
      category: categoryController.text,
    );

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Nota rápida guardada.",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    categoryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Nota rápida",
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.greenAccent.withOpacity(0.95),
                    Colors.tealAccent.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_rounded,
                    color: Colors.black,
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Captura una nota al instante",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Puedes guardar ideas, recordatorios, gastos pendientes o notas de control sin entrar al dashboard completo.",
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            buildTextField(
              controller: titleController,
              label: "Título",
              icon: Icons.title_rounded,
              hint: "Ejemplo: Pago pendiente",
            ),

            const SizedBox(height: 16),

            buildTextField(
              controller: categoryController,
              label: "Categoría",
              icon: Icons.category_rounded,
              hint: "Ejemplo: Venta, gasto, recordatorio",
            ),

            const SizedBox(height: 16),

            buildTextField(
              controller: contentController,
              label: "Nota",
              icon: Icons.edit_note_rounded,
              hint: "Escribe tu nota rápida aquí...",
              maxLines: 7,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saving ? null : saveNote,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.save_rounded,
                      ),
                label: Text(
                  saving ? "Guardando..." : "Guardar nota",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.greenAccent,
        ),
        labelStyle: const TextStyle(
          color: Colors.white70,
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        filled: true,
        fillColor: const Color(0xFF111111),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.greenAccent,
          ),
        ),
      ),
    );
  }
}