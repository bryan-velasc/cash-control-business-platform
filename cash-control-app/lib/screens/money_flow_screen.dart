import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/transaction_service.dart';
import '../providers/date_filter_provider.dart';

class MoneyFlowScreen extends StatefulWidget {
  final String email;

  const MoneyFlowScreen({
    super.key,
    required this.email,
  });

  @override
  State<MoneyFlowScreen> createState() =>
      _MoneyFlowScreenState();
}

class _MoneyFlowScreenState extends State<MoneyFlowScreen> {
  bool loading = true;

  List flow = [];

  @override
  void initState() {
    super.initState();
    loadMoneyFlow();
  }

  Future<void> loadMoneyFlow() async {
    try {
      final data = await TransactionService.getMoneyFlow(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        flow = data["flow"] ?? [];
        loading = false;
      });
    } catch (e) {
      print("ERROR MONEY FLOW:");
      print(e);

      if (!mounted) return;

      setState(() {
        loading = false;
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

  DateTime getItemDate(dynamic item) {
    final rawDate =
        item["created_at"] ??
        item["date"] ??
        item["createdAt"];

    if (rawDate == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          rawDate.toString(),
        ) ??
        DateTime.now();
  }

  String formatDate(dynamic item) {
    final date = getItemDate(item);

    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$day/$month/$year - $hour:$minute";
  }

  bool isInsideFilter(
    dynamic item,
    DateFilterProvider dateFilter,
  ) {
    if (dateFilter.filterType == DateFilterType.all) {
      return true;
    }

    final date = getItemDate(item);

    return date.isAfter(
          dateFilter.startDate.subtract(
            const Duration(seconds: 1),
          ),
        ) &&
        date.isBefore(
          dateFilter.endDate.add(
            const Duration(seconds: 1),
          ),
        );
  }

  List filterMoneyFlow(
    DateFilterProvider dateFilter,
  ) {
    if (dateFilter.filterType == DateFilterType.all) {
      return flow;
    }

    final List filtered = [];

    for (final item in flow) {
      final expenses = item["linked_expenses"];

      final List filteredExpenses = [];

      if (expenses is List) {
        for (final expense in expenses) {
          if (isInsideFilter(
            expense,
            dateFilter,
          )) {
            filteredExpenses.add(expense);
          }
        }
      }

      final incomeInside = isInsideFilter(
        item,
        dateFilter,
      );

      if (incomeInside || filteredExpenses.isNotEmpty) {
        final Map<String, dynamic> copiedItem =
            Map<String, dynamic>.from(item);

        copiedItem["linked_expenses"] = filteredExpenses;

        final periodUsed = filteredExpenses.fold<double>(
          0,
          (sum, expense) {
            return sum + parseDouble(
              expense["amount"],
            );
          },
        );

        final amount = parseDouble(
          copiedItem["amount"],
        );

        copiedItem["used_amount"] = periodUsed;

        copiedItem["remaining_amount"] =
            amount - periodUsed;

        copiedItem["used_percentage"] = amount > 0
            ? (periodUsed / amount) * 100
            : 0;

        copiedItem["period_filtered"] = true;

        filtered.add(copiedItem);
      }
    }

    return filtered;
  }

  double getTotalIncome(
    List filteredFlow,
    DateFilterProvider dateFilter,
  ) {
    double total = 0;

    for (final item in filteredFlow) {
      final incomeInside = isInsideFilter(
        item,
        dateFilter,
      );

      if (dateFilter.filterType == DateFilterType.all ||
          incomeInside) {
        total += parseDouble(
          item["amount"],
        );
      }
    }

    return total;
  }

  double getTotalUsed(List filteredFlow) {
    double total = 0;

    for (final item in filteredFlow) {
      total += parseDouble(
        item["used_amount"],
      );
    }

    return total;
  }

  double getTotalRemaining(List filteredFlow) {
    double total = 0;

    for (final item in filteredFlow) {
      total += parseDouble(
        item["remaining_amount"],
      );
    }

    return total;
  }

  int getTotalLinkedExpenses(List filteredFlow) {
    int total = 0;

    for (final item in filteredFlow) {
      final expenses = item["linked_expenses"];

      if (expenses is List) {
        total += expenses.length;
      }
    }

    return total;
  }

  Widget buildIncomeFlowCard(
    dynamic item,
    DateFilterProvider dateFilter,
  ) {
    final description =
        item["description"]?.toString() ?? "Ingreso";

    final category =
        item["category"]?.toString() ?? "Entrada";

    final amount = parseDouble(
      item["amount"],
    );

    final used = parseDouble(
      item["used_amount"],
    );

    final remaining = parseDouble(
      item["remaining_amount"],
    );

    final usedPercentage = parseDouble(
      item["used_percentage"],
    );

    final expenses = item["linked_expenses"];

    final periodFiltered =
        item["period_filtered"] == true;

    final incomeInside = isInsideFilter(
      item,
      dateFilter,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.greenAccent,
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
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      formatDate(item),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (periodFiltered) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: incomeInside
                    ? Colors.greenAccent.withOpacity(0.10)
                    : Colors.orangeAccent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: incomeInside
                      ? Colors.greenAccent.withOpacity(0.25)
                      : Colors.orangeAccent.withOpacity(0.25),
                ),
              ),
              child: Text(
                incomeInside
                    ? "Esta entrada pertenece al periodo filtrado."
                    : "Esta entrada es anterior, pero tiene salidas dentro del periodo filtrado.",
                style: TextStyle(
                  color: incomeInside
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: buildMiniMetric(
                  "Entró",
                  amount,
                  Colors.greenAccent,
                ),
              ),
              Expanded(
                child: buildMiniMetric(
                  "Usado",
                  used,
                  Colors.redAccent,
                ),
              ),
              Expanded(
                child: buildMiniMetric(
                  "Disponible",
                  remaining,
                  remaining >= 0
                      ? Colors.blueAccent
                      : Colors.orangeAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (usedPercentage / 100).clamp(
                0.0,
                1.0,
              ),
              minHeight: 14,
              backgroundColor:
                  Colors.white.withOpacity(0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Colors.greenAccent,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${usedPercentage.toStringAsFixed(1)}% usado de esta entrada",
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Salidas ligadas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (expenses is List && expenses.isNotEmpty)
            ...expenses.map(
              (expense) => buildExpenseFlowItem(
                expense,
              ),
            )
          else
            Text(
              dateFilter.filterType == DateFilterType.all
                  ? "No hay salidas ligadas a esta entrada."
                  : "No hay salidas ligadas dentro del periodo filtrado.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildMiniMetric(
    String title,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "\$${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildExpenseFlowItem(dynamic expense) {
    final category =
        expense["category"]?.toString() ?? "Salida";

    final description =
        expense["description"]?.toString() ?? "";

    final note =
        expense["note"]?.toString() ?? "";

    final amount = parseDouble(
      expense["amount"],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_downward,
            color: Colors.redAccent,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  formatDate(expense),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),

                if (note.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Nota: $note",
                    style: TextStyle(
                      color: Colors.orangeAccent
                          .withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Text(
            "-\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState(
    DateFilterProvider dateFilter,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 90,
              color: Colors.greenAccent.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sin flujo de dinero",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dateFilter.filterType == DateFilterType.all
                  ? "Registra entradas y liga salidas a una entrada específica para ver aquí la trazabilidad."
                  : "No hay flujo de dinero dentro del periodo seleccionado.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
              ),
            ),

            const SizedBox(height: 22),

            if (dateFilter.filterType != DateFilterType.all)
              ElevatedButton.icon(
                onPressed: () {
                  dateFilter.setAll();
                },
                icon: const Icon(
                  Icons.all_inclusive_rounded,
                ),
                label: const Text(
                  "Ver todo el historial",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(
    DateFilterProvider dateFilter,
    List filteredFlow,
  ) {
    final totalIncome = getTotalIncome(
      filteredFlow,
      dateFilter,
    );

    final totalUsed = getTotalUsed(
      filteredFlow,
    );

    final totalRemaining = getTotalRemaining(
      filteredFlow,
    );

    final linkedExpenses = getTotalLinkedExpenses(
      filteredFlow,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.95),
            Colors.tealAccent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_tree,
            color: Colors.black,
            size: 42,
          ),

          const SizedBox(height: 14),

          const Text(
            "Análisis de flujo de dinero",
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            dateFilter.filterDescription,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                metricRow(
                  "Entradas",
                  "\$${totalIncome.toStringAsFixed(2)}",
                ),
                metricRow(
                  "Usado",
                  "\$${totalUsed.toStringAsFixed(2)}",
                ),
                metricRow(
                  "Disponible",
                  "\$${totalRemaining.toStringAsFixed(2)}",
                ),
                metricRow(
                  "Salidas ligadas",
                  linkedExpenses.toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Visualiza de dónde entró tu dinero, en qué se usó y cuánto queda disponible.",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget metricRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black.withOpacity(0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
    );

    final filteredFlow = filterMoneyFlow(
      dateFilter,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Flujo de dinero",
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: "Ver todo",
            onPressed: () {
              dateFilter.setAll();
            },
            icon: const Icon(
              Icons.all_inclusive_rounded,
            ),
          ),
          IconButton(
            tooltip: "Actualizar",
            onPressed: loadMoneyFlow,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : filteredFlow.isEmpty
              ? buildEmptyState(
                  dateFilter,
                )
              : RefreshIndicator(
                  onRefresh: loadMoneyFlow,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredFlow.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return buildHeader(
                          dateFilter,
                          filteredFlow,
                        );
                      }

                      return buildIncomeFlowCard(
                        filteredFlow[index - 1],
                        dateFilter,
                      );
                    },
                  ),
                ),
    );
  }
}