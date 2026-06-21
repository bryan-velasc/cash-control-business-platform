import 'package:flutter/material.dart';

import '../services/financial_health_service.dart';

class FinancialHealthScreen extends StatefulWidget {
  final String email;

  const FinancialHealthScreen({
    super.key,
    required this.email,
  });

  @override
  State<FinancialHealthScreen> createState() =>
      _FinancialHealthScreenState();
}

class _FinancialHealthScreenState
    extends State<FinancialHealthScreen> {
  bool isLoading = true;

  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();

    loadHealth();
  }

  Future<void> loadHealth() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await FinancialHealthService.getFinancialHealth(
        widget.email,
      );

      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR FINANCIAL HEALTH:");
      print(e);

      setState(() {
        isLoading = false;
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

  Color getScoreColor(
    double score,
  ) {
    if (score >= 80) {
      return Colors.greenAccent;
    }

    if (score >= 65) {
      return Colors.lightGreenAccent;
    }

    if (score >= 45) {
      return Colors.orangeAccent;
    }

    if (score >= 25) {
      return Colors.deepOrangeAccent;
    }

    return Colors.redAccent;
  }

  IconData getRiskIcon(
    String risk,
  ) {
    if (risk == "Excelente") {
      return Icons.verified;
    }

    if (risk == "Buena") {
      return Icons.thumb_up_alt;
    }

    if (risk == "Media") {
      return Icons.warning_amber;
    }

    if (risk == "Alta") {
      return Icons.priority_high;
    }

    return Icons.dangerous;
  }

  Widget buildScoreCard() {
    final score =
        double.tryParse(data?["score"].toString() ?? "0") ??
            0;

    final risk =
        data?["risk_level"]?.toString() ??
            "Sin datos";

    final color =
        getScoreColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        28,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          32,
        ),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.95),
            color.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(
              0.25,
            ),
            blurRadius: 20,
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
              Icon(
                getRiskIcon(risk),
                color: Colors.black,
                size: 42,
              ),

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Text(
                  "Salud Financiera",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),

          Text(
            "${score.toStringAsFixed(1)} / 100",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Estado: $risk",
            style: TextStyle(
              color: Colors.black.withOpacity(
                0.75,
              ),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(
                0.0,
                1.0,
              ),
              minHeight: 16,
              backgroundColor:
                  Colors.black.withOpacity(
                0.12,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.45,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              13,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(
                0.16,
              ),
              borderRadius: BorderRadius.circular(
                17,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
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
                  title,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMetrics() {
    final income =
        double.tryParse(data?["income"].toString() ?? "0") ??
            0;

    final expenses =
        double.tryParse(data?["expenses"].toString() ?? "0") ??
            0;

    final balance =
        double.tryParse(data?["balance"].toString() ?? "0") ??
            0;

    final prediction =
        double.tryParse(
              data?["predicted_end_balance"]
                      .toString() ??
                  "0",
            ) ??
            0;

    final savingsRate =
        double.tryParse(
              data?["savings_rate"].toString() ?? "0",
            ) ??
            0;

    final budgetRisk =
        double.tryParse(
              data?["budget_risk"].toString() ?? "0",
            ) ??
            0;

    return Column(
      children: [
        buildMetricCard(
          icon: Icons.trending_up,
          title: "Ingresos",
          value: "\$${income.toStringAsFixed(2)}",
          color: Colors.greenAccent,
        ),

        const SizedBox(
          height: 12,
        ),

        buildMetricCard(
          icon: Icons.trending_down,
          title: "Gastos",
          value: "\$${expenses.toStringAsFixed(2)}",
          color: Colors.redAccent,
        ),

        const SizedBox(
          height: 12,
        ),

        buildMetricCard(
          icon: Icons.account_balance_wallet,
          title: "Balance actual",
          value: "\$${balance.toStringAsFixed(2)}",
          color: balance >= 0
              ? Colors.greenAccent
              : Colors.redAccent,
        ),

        const SizedBox(
          height: 12,
        ),

        buildMetricCard(
          icon: Icons.auto_graph,
          title: "Predicción fin de mes",
          value:
              "\$${prediction.toStringAsFixed(2)}",
          color: prediction >= 0
              ? Colors.greenAccent
              : Colors.redAccent,
        ),

        const SizedBox(
          height: 12,
        ),

        buildMetricCard(
          icon: Icons.savings,
          title: "Tasa de ahorro",
          value:
              "${savingsRate.toStringAsFixed(1)}%",
          color: Colors.blueAccent,
        ),

        const SizedBox(
          height: 12,
        ),

        buildMetricCard(
          icon: Icons.warning_amber,
          title: "Riesgo en presupuestos",
          value:
              "${budgetRisk.toStringAsFixed(1)}%",
          color: budgetRisk >= 40
              ? Colors.orangeAccent
              : Colors.greenAccent,
        ),
      ],
    );
  }

  Widget buildTopCategory() {
    final top =
        data?["top_expense_category"];

    if (top == null) {
      return const SizedBox();
    }

    final category =
        top["category"]?.toString() ??
            "Sin categoría";

    final amount =
        double.tryParse(
              top["amount"].toString(),
            ) ??
            0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: Colors.orangeAccent
              .withOpacity(0.45),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orangeAccent,
            size: 38,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Categoría con mayor gasto",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  "$category • \$${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecommendations() {
    final recommendations =
        data?["recommendations"];

    if (recommendations == null ||
        recommendations is! List ||
        recommendations.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Recomendaciones IA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        ...recommendations.map(
          (item) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              padding: const EdgeInsets.all(
                18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Colors.greenAccent
                      .withOpacity(0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.greenAccent,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      item.toString(),
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.78),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ],
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
          "Salud Financiera IA",
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: loadHealth,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : data == null
              ? const Center(
                  child: Text(
                    "No hay datos disponibles",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadHealth,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        buildScoreCard(),

                        const SizedBox(
                          height: 22,
                        ),

                        buildMetrics(),

                        const SizedBox(
                          height: 22,
                        ),

                        buildTopCategory(),

                        const SizedBox(
                          height: 26,
                        ),

                        buildRecommendations(),
                      ],
                    ),
                  ),
                ),
    );
  }
}