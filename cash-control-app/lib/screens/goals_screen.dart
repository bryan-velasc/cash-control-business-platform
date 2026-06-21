import 'package:flutter/material.dart';
import '../services/goal_service.dart';

class GoalsScreen extends StatefulWidget {
  final String userEmail;

  const GoalsScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List goals = [];
  bool isLoading = true;

  final TextEditingController goalNameController =
      TextEditingController();

  final TextEditingController targetAmountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await GoalService.getGoals(
        widget.userEmail,
      );

      setState(() {
        goals = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD GOALS:");
      print(e);

      setState(() {
        isLoading = false;
      });

      showMessage(e.toString());
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

  void showCreateGoalDialog() {
    goalNameController.clear();
    targetAmountController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva meta de ahorro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: goalNameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la meta",
                hintText: "Ej. Comprar laptop",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cantidad objetivo",
                prefixText: "\$",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final goalName = goalNameController.text.trim();

              final targetAmount =
                  double.tryParse(targetAmountController.text) ?? 0;

              if (goalName.isEmpty || targetAmount <= 0) {
                showMessage("Completa los datos correctamente");
                return;
              }

              try {
                await GoalService.createGoal(
                  widget.userEmail,
                  goalName,
                  targetAmount,
                );

                Navigator.pop(context);

                await loadGoals();

                showMessage("Meta creada correctamente");
              } catch (e) {
                print("ERROR CREATE GOAL:");
                print(e);

                showMessage(e.toString());
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void showAddSavingDialog(String goalId) {
    final TextEditingController amountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar ahorro"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Cantidad ahorrada",
            prefixText: "\$",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount =
                  double.tryParse(amountController.text) ?? 0;

              if (amount <= 0) {
                showMessage("Ingresa una cantidad válida");
                return;
              }

              try {
                await GoalService.addSaving(
                  goalId,
                  amount,
                );

                Navigator.pop(context);

                await loadGoals();

                showMessage("Ahorro agregado correctamente");
              } catch (e) {
                print("ERROR ADD SAVING:");
                print(e);

                showMessage(e.toString());
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteGoal(String goalId) async {
    if (goalId.isEmpty) {
      showMessage("Error: ID de meta vacío");
      return;
    }

    try {
      await GoalService.deleteGoal(goalId);

      await loadGoals();

      showMessage("Meta eliminada");
    } catch (e) {
      print("ERROR DELETE GOAL:");
      print(e);

      showMessage(e.toString());
    }
  }

  Widget buildGoalCard(dynamic goal) {
    final String goalId =
        goal["id"]?.toString() ?? goal["_id"]?.toString() ?? "";

    final String goalName =
        goal["goal_name"]?.toString() ?? "Meta sin nombre";

    final double targetAmount =
        double.tryParse(goal["target_amount"].toString()) ?? 0;

    final double savedAmount =
        double.tryParse(goal["current_amount"].toString()) ?? 0;

    final double progress = targetAmount > 0
        ? (savedAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final double percentage = progress * 100;

    final bool completed =
        targetAmount > 0 && savedAmount >= targetAmount;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: completed
              ? [
                  Colors.green.shade400,
                  Colors.green.shade700,
                ]
              : [
                  Colors.blue.shade400,
                  Colors.indigo.shade700,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Colors.white.withOpacity(0.2),
                  child: Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.savings,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completed
                            ? "Meta completada"
                            : "Meta en progreso",
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => deleteGoal(goalId),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              "Ahorrado",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "\$${savedAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Objetivo: \$${targetAmount.toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor:
                    Colors.white.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  completed ? "COMPLETADA" : "AHORRANDO",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: completed || goalId.isEmpty
                    ? null
                    : () {
                        showAddSavingDialog(goalId);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  "Agregar ahorro",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 90,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              "Aún no tienes metas de ahorro",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Crea una meta para comenzar a ahorrar de forma progresiva.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: showCreateGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text("Crear mi primera meta"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Metas de ahorro"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadGoals,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCreateGoalDialog,
        icon: const Icon(Icons.add),
        label: const Text("Nueva meta"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : goals.isEmpty
              ? buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadGoals,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 90,
                    ),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return buildGoalCard(goals[index]);
                    },
                  ),
                ),
    );
  }
}