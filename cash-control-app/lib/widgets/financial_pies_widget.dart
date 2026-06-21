import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialPiesWidget extends StatefulWidget {
  final List<dynamic> transactions;

  const FinancialPiesWidget({
    super.key,
    required this.transactions,
  });

  @override
  State<FinancialPiesWidget> createState() =>
      _FinancialPiesWidgetState();
}

class _FinancialPiesWidgetState
    extends State<FinancialPiesWidget> {
  int touchedTotalIndex = -1;
  int touchedIncomeIndex = -1;
  int touchedExpenseIndex = -1;

  final List<Color> colors = [
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.amberAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.limeAccent,
  ];

  double parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  double getAmount(dynamic tx) {
    return parseDouble(
      tx["amount"],
    );
  }

  String getCategory(dynamic tx) {
    final category =
        tx["category"]?.toString().trim() ?? "";

    if (category.isEmpty) {
      return "Sin categoría";
    }

    return category;
  }

  String getDescription(dynamic tx) {
    final description =
        tx["description"]?.toString().trim() ?? "";

    if (description.isEmpty) {
      return getCategory(tx);
    }

    return description;
  }

  bool isIncome(dynamic tx) {
    return tx["type"] == "income";
  }

  Color getColor(int index) {
    return colors[index % colors.length];
  }

  List<Map<String, dynamic>> buildTotalPieData() {
    final List<Map<String, dynamic>> incomeItems = [];

    for (final tx in widget.transactions) {
      if (isIncome(tx)) {
        incomeItems.add({
          "label": getDescription(tx),
          "amount": getAmount(tx),
          "remaining_amount": getAmount(tx),
          "used_amount": 0.0,
        });
      }
    }

    return incomeItems;
  }

  List<Map<String, dynamic>> buildIncomePieData() {
    final Map<String, double> grouped = {};

    for (final tx in widget.transactions) {
      if (!isIncome(tx)) {
        continue;
      }

      final category = getCategory(tx);

      grouped[category] =
          (grouped[category] ?? 0) + getAmount(tx);
    }

    return grouped.entries.map(
      (entry) {
        return {
          "label": entry.key,
          "amount": entry.value,
        };
      },
    ).toList();
  }

  List<Map<String, dynamic>> buildExpensePieData() {
    final Map<String, double> grouped = {};

    for (final tx in widget.transactions) {
      if (isIncome(tx)) {
        continue;
      }

      final category = getCategory(tx);

      grouped[category] =
          (grouped[category] ?? 0) + getAmount(tx);
    }

    return grouped.entries.map(
      (entry) {
        return {
          "label": entry.key,
          "amount": entry.value,
        };
      },
    ).toList();
  }

  double getTotalIncome() {
    double total = 0;

    for (final tx in widget.transactions) {
      if (isIncome(tx)) {
        total += getAmount(tx);
      }
    }

    return total;
  }

  double getTotalExpenses() {
    double total = 0;

    for (final tx in widget.transactions) {
      if (!isIncome(tx)) {
        total += getAmount(tx);
      }
    }

    return total;
  }

  Widget buildMainCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  Widget buildEmptyChart(
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildPieChart({
    required List<dynamic> data,
    required String labelKey,
    required String amountKey,
    required int touchedIndex,
    required Function(int) onTouch,
  }) {
    if (data.isEmpty) {
      return buildEmptyChart(
        "No hay datos suficientes para mostrar esta gráfica.",
      );
    }

    final total = data.fold<double>(
      0,
      (sum, item) {
        return sum + parseDouble(item[amountKey]);
      },
    );

    if (total <= 0) {
      return buildEmptyChart(
        "Los valores de esta gráfica son cero.",
      );
    }

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 54,
          sectionsSpace: 3,
          pieTouchData: PieTouchData(
            touchCallback: (
              FlTouchEvent event,
              PieTouchResponse? response,
            ) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                onTouch(-1);
                return;
              }

              onTouch(
                response
                    .touchedSection!
                    .touchedSectionIndex,
              );
            },
          ),
          sections: List.generate(
            data.length,
            (index) {
              final item = data[index];

              final amount =
                  parseDouble(item[amountKey]);

              final percentage =
                  total > 0 ? (amount / total) * 100 : 0;

              final isTouched =
                  index == touchedIndex;

              return PieChartSectionData(
                color: getColor(index),
                value: amount,
                title:
                    "${percentage.toStringAsFixed(0)}%",
                radius: isTouched ? 88 : 72,
                titleStyle: TextStyle(
                  fontSize: isTouched ? 17 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildLegend({
    required List<dynamic> data,
    required String labelKey,
    required String amountKey,
    String? secondaryAmountKey,
    String? secondaryLabel,
  }) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: List.generate(
        data.length,
        (index) {
          final item = data[index];

          final label =
              item[labelKey]?.toString() ??
                  "Sin nombre";

          final amount =
              parseDouble(item[amountKey]);

          final color = getColor(index);

          String extra = "";

          if (secondaryAmountKey != null) {
            final secondary =
                parseDouble(item[secondaryAmountKey]);

            extra =
                " • ${secondaryLabel ?? "Extra"}: \$${secondary.toStringAsFixed(2)}";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Monto: \$${amount.toStringAsFixed(2)}$extra",
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(0.58),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSelectedDetail({
    required List<dynamic> data,
    required int touchedIndex,
    required String labelKey,
    required String amountKey,
    String? remainingKey,
    String? usedKey,
  }) {
    if (touchedIndex < 0 ||
        touchedIndex >= data.length) {
      return const SizedBox();
    }

    final item = data[touchedIndex];

    final label =
        item[labelKey]?.toString() ?? "Detalle";

    final amount =
        parseDouble(item[amountKey]);

    final remaining =
        remainingKey != null
            ? parseDouble(item[remainingKey])
            : null;

    final used =
        usedKey != null
            ? parseDouble(item[usedKey])
            : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getColor(touchedIndex).withOpacity(0.9),
            getColor(touchedIndex).withOpacity(0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Total: \$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.black.withOpacity(0.78),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (remaining != null) ...[
            const SizedBox(height: 5),
            Text(
              "Disponible: \$${remaining.toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.78),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          if (used != null) ...[
            const SizedBox(height: 5),
            Text(
              "Usado: \$${used.toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.78),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTotalPie() {
    final data = buildTotalPieData();

    return buildMainCard(
      title: "Efectivo por entrada",
      subtitle:
          "Cada parte representa una entrada de dinero del periodo filtrado.",
      icon: Icons.pie_chart,
      color: Colors.greenAccent,
      child: Column(
        children: [
          buildSelectedDetail(
            data: data,
            touchedIndex: touchedTotalIndex,
            labelKey: "label",
            amountKey: "amount",
            remainingKey: "remaining_amount",
            usedKey: "used_amount",
          ),

          buildPieChart(
            data: data,
            labelKey: "label",
            amountKey: "amount",
            touchedIndex: touchedTotalIndex,
            onTouch: (index) {
              setState(() {
                touchedTotalIndex = index;
              });
            },
          ),

          const SizedBox(height: 16),

          buildLegend(
            data: data,
            labelKey: "label",
            amountKey: "amount",
            secondaryAmountKey: "remaining_amount",
            secondaryLabel: "Disponible",
          ),
        ],
      ),
    );
  }

  Widget buildIncomePie() {
    final data = buildIncomePieData();

    return buildMainCard(
      title: "Entradas",
      subtitle:
          "Distribución de todos los ingresos por categoría del periodo filtrado.",
      icon: Icons.trending_up,
      color: Colors.blueAccent,
      child: Column(
        children: [
          buildSelectedDetail(
            data: data,
            touchedIndex: touchedIncomeIndex,
            labelKey: "label",
            amountKey: "amount",
          ),

          buildPieChart(
            data: data,
            labelKey: "label",
            amountKey: "amount",
            touchedIndex: touchedIncomeIndex,
            onTouch: (index) {
              setState(() {
                touchedIncomeIndex = index;
              });
            },
          ),

          const SizedBox(height: 16),

          buildLegend(
            data: data,
            labelKey: "label",
            amountKey: "amount",
          ),
        ],
      ),
    );
  }

  Widget buildExpensePie() {
    final data = buildExpensePieData();

    return buildMainCard(
      title: "Salidas",
      subtitle:
          "Distribución de gastos por categoría del periodo filtrado.",
      icon: Icons.trending_down,
      color: Colors.redAccent,
      child: Column(
        children: [
          buildSelectedDetail(
            data: data,
            touchedIndex: touchedExpenseIndex,
            labelKey: "label",
            amountKey: "amount",
          ),

          buildPieChart(
            data: data,
            labelKey: "label",
            amountKey: "amount",
            touchedIndex: touchedExpenseIndex,
            onTouch: (index) {
              setState(() {
                touchedExpenseIndex = index;
              });
            },
          ),

          const SizedBox(height: 16),

          buildLegend(
            data: data,
            labelKey: "label",
            amountKey: "amount",
          ),
        ],
      ),
    );
  }

  Widget buildComparisonCard() {
    final income = getTotalIncome();
    final expenses = getTotalExpenses();
    final balance = income - expenses;

    final expenseRatio =
        income > 0 ? (expenses / income) * 100 : 0.0;

    final ratio =
        income > 0 ? (expenses / income).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.deepPurpleAccent.withOpacity(0.9),
            Colors.purpleAccent.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: Colors.white,
                size: 34,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Comparativa del periodo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "Entradas: \$${income.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Salidas: \$${expenses.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Balance: \$${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 15,
              backgroundColor:
                  Colors.white.withOpacity(0.22),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Tus salidas representan ${expenseRatio.toStringAsFixed(1)}% de tus entradas.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmallMetric(
    String title,
    double value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          "\$${value.toStringAsFixed(0)}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget buildEmptyMainWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            color: Colors.white54,
            size: 54,
          ),
          SizedBox(height: 12),
          Text(
            "Sin datos para graficar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No hay movimientos en el periodo seleccionado.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = getTotalIncome();
    final totalExpenses = getTotalExpenses();
    final totalBalance = totalIncome - totalExpenses;

    if (widget.transactions.isEmpty) {
      return buildEmptyMainWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gráficas inteligentes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "Controla de dónde entra y de dónde sale tu dinero según el filtro seleccionado.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: buildSmallMetric(
                  "Entradas",
                  totalIncome,
                  Colors.greenAccent,
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: Colors.white.withOpacity(0.08),
              ),

              Expanded(
                child: buildSmallMetric(
                  "Salidas",
                  totalExpenses,
                  Colors.redAccent,
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: Colors.white.withOpacity(0.08),
              ),

              Expanded(
                child: buildSmallMetric(
                  "Balance",
                  totalBalance,
                  totalBalance >= 0
                      ? Colors.blueAccent
                      : Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        buildComparisonCard(),

        const SizedBox(height: 22),

        buildTotalPie(),

        const SizedBox(height: 22),

        buildIncomePie(),

        const SizedBox(height: 22),

        buildExpensePie(),
      ],
    );
  }
}