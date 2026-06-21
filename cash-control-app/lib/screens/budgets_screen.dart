import 'package:flutter/material.dart';

import '../services/budget_service.dart';

class BudgetsScreen extends StatefulWidget {
  final String email;

  const BudgetsScreen({
    super.key,
    required this.email,
  });

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List budgets = [];

  bool isLoading = true;

  final TextEditingController categoryController =
      TextEditingController();

  final TextEditingController limitController =
      TextEditingController();

  final TextEditingController spentController =
      TextEditingController();

  final List<String> defaultCategories = [
    "Comida",
    "Supermercado",
    "Transporte",
    "Salud",
    "Entretenimiento",
    "Servicios",
    "Compras",
    "Educación",
    "Hogar",
    "Otros",
  ];

  String selectedCategory = "Comida";

  @override
  void initState() {
    super.initState();

    loadBudgets();
  }

  Future<void> loadBudgets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await BudgetService.getBudgets(
        widget.email,
      );

      setState(() {
        budgets = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD BUDGETS:");
      print(e);

      setState(() {
        isLoading = false;
      });

      showMessage(
        e.toString(),
      );
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

  void showCreateBudgetDialog() {
    limitController.clear();
    selectedCategory = defaultCategories.first;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                "Nuevo presupuesto",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Categoría",
                    ),
                    items: defaultCategories.map(
                      (category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Límite mensual",
                      prefixText: "\$",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final limit = double.tryParse(
                          limitController.text,
                        ) ??
                        0;

                    if (limit <= 0) {
                      showMessage(
                        "Ingresa un límite válido",
                      );
                      return;
                    }

                    try {
                      await BudgetService.createBudget(
                        email: widget.email,
                        category: selectedCategory,
                        monthlyLimit: limit,
                      );

                      Navigator.pop(context);

                      await loadBudgets();

                      showMessage(
                        "Presupuesto creado correctamente",
                      );
                    } catch (e) {
                      showMessage(
                        e.toString(),
                      );
                    }
                  },
                  child: const Text(
                    "Guardar",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddSpentDialog(
    String budgetId,
    String category,
  ) {
    spentController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Agregar gasto a $category",
        ),
        content: TextField(
          controller: spentController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Cantidad gastada",
            prefixText: "\$",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              "Cancelar",
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(
                    spentController.text,
                  ) ??
                  0;

              if (amount <= 0) {
                showMessage(
                  "Ingresa una cantidad válida",
                );
                return;
              }

              try {
                await BudgetService.addSpent(
                  budgetId: budgetId,
                  amount: amount,
                );

                Navigator.pop(context);

                await loadBudgets();

                showMessage(
                  "Gasto agregado correctamente",
                );
              } catch (e) {
                showMessage(
                  e.toString(),
                );
              }
            },
            child: const Text(
              "Agregar",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteBudget(
    String budgetId,
  ) async {
    if (budgetId.isEmpty) {
      showMessage(
        "ID de presupuesto vacío",
      );
      return;
    }

    try {
      await BudgetService.deleteBudget(
        budgetId,
      );

      await loadBudgets();

      showMessage(
        "Presupuesto eliminado",
      );
    } catch (e) {
      showMessage(
        e.toString(),
      );
    }
  }

  Color getStatusColor(
    String status,
  ) {
    if (status == "exceeded") {
      return Colors.red;
    }

    if (status == "warning") {
      return Colors.orange;
    }

    return Colors.green;
  }

  IconData getCategoryIcon(
    String category,
  ) {
    final lower = category.toLowerCase();

    if (lower.contains("comida")) {
      return Icons.restaurant;
    }

    if (lower.contains("super")) {
      return Icons.shopping_cart;
    }

    if (lower.contains("transporte")) {
      return Icons.directions_car;
    }

    if (lower.contains("salud")) {
      return Icons.local_hospital;
    }

    if (lower.contains("entretenimiento")) {
      return Icons.movie;
    }

    if (lower.contains("servicios")) {
      return Icons.lightbulb;
    }

    if (lower.contains("educación")) {
      return Icons.school;
    }

    if (lower.contains("hogar")) {
      return Icons.home;
    }

    return Icons.account_balance_wallet;
  }

  String getStatusText(
    String status,
  ) {
    if (status == "exceeded") {
      return "Límite superado";
    }

    if (status == "warning") {
      return "Cuidado: cerca del límite";
    }

    return "Controlado";
  }

  Widget buildBudgetCard(
    dynamic budget,
  ) {
    final String budgetId =
        budget["id"]?.toString() ??
            budget["_id"]?.toString() ??
            "";

    final String category =
        budget["category"]?.toString() ??
            "General";

    final double monthlyLimit =
        double.tryParse(
              budget["monthly_limit"].toString(),
            ) ??
            0;

    final double currentSpent =
        double.tryParse(
              budget["current_spent"].toString(),
            ) ??
            0;

    final double remaining =
        double.tryParse(
              budget["remaining"].toString(),
            ) ??
            0;

    final double progress =
        monthlyLimit > 0
            ? (currentSpent / monthlyLimit)
                .clamp(0.0, 1.0)
            : 0.0;

    final double percentage =
        progress * 100;

    final String status =
        budget["status"]?.toString() ??
            "normal";

    final Color statusColor =
        getStatusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(
        22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: statusColor.withOpacity(
            0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(
              0.18,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor:
                    statusColor.withOpacity(
                  0.18,
                ),
                child: Icon(
                  getCategoryIcon(category),
                  color: statusColor,
                  size: 30,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      getStatusText(status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () =>
                    deleteBudget(
                  budgetId,
                ),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Text(
            "Gastado",
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "\$${currentSpent.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Límite mensual: \$${monthlyLimit.toStringAsFixed(2)}",
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.8),
              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            "Disponible: \$${remaining.toStringAsFixed(2)}",
            style: TextStyle(
              color: statusColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor:
                  Colors.white.withOpacity(
                0.12,
              ),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                statusColor,
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${percentage.toStringAsFixed(1)}% usado",
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status == "exceeded"
                    ? "EXCEDIDO"
                    : status == "warning"
                        ? "ALERTA"
                        : "OK",
                style: TextStyle(
                  color: statusColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: budgetId.isEmpty
                  ? null
                  : () {
                      showAddSpentDialog(
                        budgetId,
                        category,
                      );
                    },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                "Agregar gasto",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 90,
              color: Colors.blue.shade300,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Aún no tienes presupuestos",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Crea límites mensuales por categoría para controlar tus gastos.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton.icon(
              onPressed: showCreateBudgetDialog,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                "Crear presupuesto",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        4,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Presupuestos inteligentes",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "Controla tus límites mensuales y evita gastos excesivos.",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "Presupuestos",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadBudgets,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: showCreateBudgetDialog,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          "Nuevo",
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : budgets.isEmpty
              ? buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadBudgets,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      bottom: 90,
                    ),
                    itemCount: budgets.length + 1,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      if (index == 0) {
                        return buildHeader();
                      }

                      return buildBudgetCard(
                        budgets[index - 1],
                      );
                    },
                  ),
                ),
    );
  }
}