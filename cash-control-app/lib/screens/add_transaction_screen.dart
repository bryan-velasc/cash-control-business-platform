import 'package:flutter/material.dart';

import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String email;

  const AddTransactionScreen({
    super.key,
    required this.email,
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  String selectedType = "expense";

  String selectedCategory = "Comida";

  String sourceMode = "general";

  dynamic selectedIncomeSource;

  bool loading = false;

  bool loadingSources = false;

  List<dynamic> incomeSources = [];

  final List<String> expenseCategories = [
    "Comida",
    "Transporte",
    "Servicios",
    "Renta",
    "Salud",
    "Educación",
    "Entretenimiento",
    "Compras",
    "Deudas",
    "Otros",
  ];

  final List<String> incomeCategories = [
    "Sueldo",
    "Ventas",
    "Negocio",
    "Inversión",
    "Regalo",
    "Préstamo",
    "Otros",
  ];

  @override
  void initState() {
    super.initState();

    loadIncomeSources();
  }

  Future<void> loadIncomeSources() async {
    setState(() {
      loadingSources = true;
    });

    try {
      final data = await TransactionService.getIncomeSources(
        widget.email,
      );

      setState(() {
        incomeSources = data;
        loadingSources = false;
      });
    } catch (e) {
      print("ERROR INCOME SOURCES:");
      print(e);

      setState(() {
        loadingSources = false;
      });
    }
  }

  List<String> get currentCategories {
    if (selectedType == "income") {
      return incomeCategories;
    }

    return expenseCategories;
  }

  Future<void> saveTransaction() async {
    final amountText = amountController.text.trim();

    final description = descriptionController.text.trim();

    final note = noteController.text.trim();

    if (amountText.isEmpty || description.isEmpty) {
      showMessage(
        "Completa el monto y la descripción",
      );
      return;
    }

    final amount = double.tryParse(
      amountText,
    );

    if (amount == null || amount <= 0) {
      showMessage(
        "Ingresa un monto válido",
      );
      return;
    }

    String finalSourceMode = "general";
    String? sourceTransactionId;
    String? sourceTransactionName;

    if (selectedType == "expense") {
      finalSourceMode = sourceMode;

      if (sourceMode == "linked_income") {
        if (selectedIncomeSource == null) {
          showMessage(
            "Selecciona de qué entrada salió este gasto",
          );
          return;
        }

        final remaining =
            (selectedIncomeSource["remaining_amount"] as num)
                .toDouble();

        if (amount > remaining) {
          showMessage(
            "El gasto supera el saldo disponible de esa entrada",
          );
          return;
        }

        sourceTransactionId =
            selectedIncomeSource["id"]?.toString() ??
                selectedIncomeSource["_id"]?.toString();

        sourceTransactionName =
            selectedIncomeSource["description"]
                    ?.toString() ??
                selectedIncomeSource["category"]?.toString() ??
                "Ingreso";
      }
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await TransactionService.createTransaction(
        email: widget.email,
        type: selectedType,
        category: selectedCategory,
        amount: amount,
        description: description,
        note: note,
        sourceMode: finalSourceMode,
        sourceTransactionId: sourceTransactionId,
        sourceTransactionName: sourceTransactionName,
      );

      setState(() {
        loading = false;
      });

      final isOffline = result["offline"] == true;

      showMessage(
        isOffline
            ? "Movimiento guardado offline. Se sincronizará cuando tengas internet."
            : "Movimiento guardado correctamente",
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      setState(() {
        loading = false;
      });

      showMessage(
        e.toString(),
      );
    }
  }

  void showMessage(
    String message,
  ) {
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

  Widget buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedType = "income";
                selectedCategory = incomeCategories.first;
                sourceMode = "general";
                selectedIncomeSource = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: selectedType == "income"
                    ? Colors.greenAccent
                    : const Color(0xFF151515),
                borderRadius: BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: selectedType == "income"
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Text(
                "Entrada",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selectedType == "income"
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedType = "expense";
                selectedCategory = expenseCategories.first;
              });

              loadIncomeSources();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: selectedType == "expense"
                    ? Colors.redAccent
                    : const Color(0xFF151515),
                borderRadius: BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: selectedType == "expense"
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Text(
                "Salida",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selectedType == "expense"
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(
            0.65,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.greenAccent,
        ),
        filled: true,
        fillColor: const Color(0xFF151515),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(
              0.08,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: const BorderSide(
            color: Colors.greenAccent,
          ),
        ),
      ),
    );
  }

  Widget buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.08,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          dropdownColor: const Color(0xFF151515),
          iconEnabledColor: Colors.white,
          isExpanded: true,
          items: currentCategories.map(
            (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedCategory = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildSourceModeSelector() {
    if (selectedType != "expense") {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Origen del dinero",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sourceMode = "general";
                    selectedIncomeSource = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: sourceMode == "general"
                        ? Colors.blueAccent
                        : const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: sourceMode == "general"
                          ? Colors.blueAccent
                          : Colors.white.withOpacity(
                              0.12,
                            ),
                    ),
                  ),
                  child: Text(
                    "General",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sourceMode == "general"
                          ? Colors.white
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sourceMode = "linked_income";
                  });

                  loadIncomeSources();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: sourceMode == "linked_income"
                        ? Colors.purpleAccent
                        : const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: sourceMode == "linked_income"
                          ? Colors.purpleAccent
                          : Colors.white.withOpacity(
                              0.12,
                            ),
                    ),
                  ),
                  child: Text(
                    "Entrada específica",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sourceMode == "linked_income"
                          ? Colors.black
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (sourceMode == "linked_income")
          buildIncomeSourceDropdown(),
      ],
    );
  }

  Widget buildIncomeSourceDropdown() {
    if (loadingSources) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (incomeSources.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: Colors.orangeAccent.withOpacity(
              0.35,
            ),
          ),
        ),
        child: const Text(
          "No hay entradas disponibles. Registra primero un ingreso.",
          style: TextStyle(
            color: Colors.orangeAccent,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(
            0.35,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: selectedIncomeSource,
          dropdownColor: const Color(0xFF151515),
          iconEnabledColor: Colors.white,
          isExpanded: true,
          hint: const Text(
            "Selecciona una entrada",
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
          items: incomeSources.map(
            (source) {
              final description =
                  source["description"]?.toString() ??
                      "Ingreso";

              final category =
                  source["category"]?.toString() ??
                      "Ingreso";

              final remaining =
                  (source["remaining_amount"] as num)
                      .toDouble();

              return DropdownMenuItem<dynamic>(
                value: source,
                child: Text(
                  "$description • $category • Disponible: \$${remaining.toStringAsFixed(2)}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              selectedIncomeSource = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    if (selectedType == "income") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(
            0.12,
          ),
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(
              0.35,
            ),
          ),
        ),
        child: const Text(
          "Esta entrada se agregará como una fuente de dinero disponible. Después podrás indicar si un gasto salió de esta entrada.",
          style: TextStyle(
            color: Colors.greenAccent,
            height: 1.35,
          ),
        ),
      );
    }

    if (sourceMode == "linked_income") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.purpleAccent.withOpacity(
            0.12,
          ),
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(
              0.35,
            ),
          ),
        ),
        child: const Text(
          "Este gasto se descontará de una entrada específica. Así podrás saber de dónde salió realmente el dinero.",
          style: TextStyle(
            color: Colors.purpleAccent,
            height: 1.35,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(
          0.12,
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(
            0.35,
          ),
        ),
      ),
      child: const Text(
        "Este gasto se registrará como salida general, sin asociarse a una entrada específica.",
        style: TextStyle(
          color: Colors.lightBlueAccent,
          height: 1.35,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Nuevo movimiento",
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            buildTypeSelector(),

            const SizedBox(height: 24),

            buildInfoCard(),

            const SizedBox(height: 24),

            buildInput(
              controller: amountController,
              label: "Monto",
              icon: Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 18),

            buildInput(
              controller: descriptionController,
              label: selectedType == "income"
                  ? "Descripción de entrada"
                  : "Descripción de salida",
              icon: Icons.description,
            ),

            const SizedBox(height: 18),

            const Text(
              "Categoría",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildCategorySelector(),

            const SizedBox(height: 22),

            buildSourceModeSelector(),

            const SizedBox(height: 22),

            buildInput(
              controller: noteController,
              label:
                  "Nota opcional: de dónde salió o para qué se usó",
              icon: Icons.note_alt,
              maxLines: 3,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    loading ? null : saveTransaction,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  loading
                      ? "Guardando..."
                      : "Guardar movimiento",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedType == "income"
                          ? Colors.greenAccent
                          : Colors.redAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}