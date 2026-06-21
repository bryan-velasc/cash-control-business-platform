import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../services/ocr_service.dart';
import '../services/transaction_service.dart';

class OCRScreen extends StatefulWidget {
  final String email;

  const OCRScreen({
    super.key,
    required this.email,
  });

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final ImagePicker imagePicker = ImagePicker();

  File? selectedImage;

  String extractedText = "";

  bool isProcessing = false;
  bool isSaving = false;

  double? detectedAmount;
  String? detectedStore;
  String? detectedDate;
  String detectedCategory = "Compras";
  String detectedDescription = "OCR - Ticket detectado";

  Future<void> pickImageFromCamera() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      await processImage(File(image.path));
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      await processImage(File(image.path));
    }
  }

  Future<void> processImage(File imageFile) async {
    setState(() {
      selectedImage = imageFile;
      isProcessing = true;
      extractedText = "";
      detectedAmount = null;
      detectedStore = null;
      detectedDate = null;
      detectedCategory = "Compras";
      detectedDescription = "OCR - Ticket detectado";
    });

    try {
      final inputImage = InputImage.fromFile(imageFile);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      final text = recognizedText.text;

      double? amount;
      String? store;
      String? date;
      String category = "Compras";
      String description = "OCR - Ticket detectado";

      try {
        final analyzed = await OCRService.analyzeText(text);

        amount = analyzed["amount"] != null
            ? double.tryParse(analyzed["amount"].toString())
            : null;

        store = analyzed["store"]?.toString();

        date = analyzed["date"]?.toString();

        category = analyzed["category"]?.toString() ?? "Compras";

        description = analyzed["description"]?.toString() ??
            "OCR - ${store ?? "Ticket detectado"}";
      } catch (e) {
        print("ERROR OCR BACKEND:");
        print(e);

        amount = extractAmount(text);
        store = extractStore(text);
        date = extractDate(text);
        category = detectCategory(text);
        description =
            "OCR - ${store ?? "Ticket detectado"}${date != null ? " - $date" : ""}";
      }

      setState(() {
        extractedText = text;
        detectedAmount = amount;
        detectedStore = store;
        detectedDate = date;
        detectedCategory = category;
        detectedDescription = description;
        isProcessing = false;
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      showMessage("Error OCR: $e");
    }
  }

  double? extractAmount(String text) {
    final regex = RegExp(
      r'(\$?\s?\d{1,6}([,.]\d{2}))',
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return null;
    }

    double highest = 0;

    for (final match in matches) {
      String value = match.group(0) ?? "";

      value = value
          .replaceAll("\$", "")
          .replaceAll(" ", "")
          .replaceAll(",", ".");

      final number = double.tryParse(value);

      if (number != null && number > highest) {
        highest = number;
      }
    }

    return highest > 0 ? highest : null;
  }

  String? extractStore(String text) {
    final lines = text
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return null;
    }

    return lines.first;
  }

  String? extractDate(String text) {
    final regex = RegExp(
      r'(\d{2}[\/\-]\d{2}[\/\-]\d{2,4})',
    );

    final match = regex.firstMatch(text);

    return match?.group(0);
  }

  String detectCategory(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("oxxo") ||
        lower.contains("walmart") ||
        lower.contains("soriana") ||
        lower.contains("super") ||
        lower.contains("mercado")) {
      return "Supermercado";
    }

    if (lower.contains("gasolina") ||
        lower.contains("pemex") ||
        lower.contains("gas")) {
      return "Transporte";
    }

    if (lower.contains("farmacia") ||
        lower.contains("similares") ||
        lower.contains("guadalajara")) {
      return "Salud";
    }

    if (lower.contains("cine") ||
        lower.contains("netflix") ||
        lower.contains("spotify")) {
      return "Entretenimiento";
    }

    if (lower.contains("restaurant") ||
        lower.contains("restaurante") ||
        lower.contains("cafe") ||
        lower.contains("pizza") ||
        lower.contains("burger")) {
      return "Comida";
    }

    return "Compras";
  }

  Future<void> registerExpense() async {
    if (detectedAmount == null || detectedAmount! <= 0) {
      showMessage("No se detectó un monto válido");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await TransactionService.createTransaction(
        email: widget.email,
        type: "expense",
        category: detectedCategory,
        amount: detectedAmount!,
        description: detectedDescription,
      );

      setState(() {
        isSaving = false;
      });

      showMessage("Gasto registrado correctamente");

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      showMessage("Error al registrar gasto: $e");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.greenAccent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePreview() {
    if (selectedImage == null) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.white54,
                size: 70,
              ),
              SizedBox(height: 12),
              Text(
                "Toma foto de un ticket o factura",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.file(
        selectedImage!,
        width: double.infinity,
        height: 260,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildExtractedData() {
    if (extractedText.isEmpty && !isProcessing) {
      return const SizedBox();
    }

    if (isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Datos detectados",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        buildInfoCard(
          icon: Icons.store,
          title: "Comercio detectado",
          value: detectedStore ?? "No detectado",
        ),

        buildInfoCard(
          icon: Icons.attach_money,
          title: "Monto probable",
          value: detectedAmount != null
              ? "\$${detectedAmount!.toStringAsFixed(2)}"
              : "No detectado",
        ),

        buildInfoCard(
          icon: Icons.category,
          title: "Categoría",
          value: detectedCategory,
        ),

        buildInfoCard(
          icon: Icons.calendar_month,
          title: "Fecha detectada",
          value: detectedDate ?? "No detectada",
        ),

        const SizedBox(height: 20),

        const Text(
          "Texto OCR completo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            extractedText,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                detectedAmount == null || isSaving ? null : registerExpense,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              isSaving ? "Guardando..." : "Registrar como gasto",
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("OCR Inteligente"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildImagePreview(),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Cámara"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : pickImageFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text("Galería"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            buildExtractedData(),
          ],
        ),
      ),
    );
  }
}