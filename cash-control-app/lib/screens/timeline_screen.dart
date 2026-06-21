import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/transaction_service.dart';
import '../providers/date_filter_provider.dart';

class TimelineScreen extends StatefulWidget {
  final String email;

  const TimelineScreen({
    super.key,
    required this.email,
  });

  @override
  State<TimelineScreen> createState() =>
      _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool loading = true;

  List timeline = [];

  @override
  void initState() {
    super.initState();

    loadTimeline();
  }

  Future<void> loadTimeline() async {
    try {
      final data = await TransactionService.getTimeline(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        timeline = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
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

  DateTime getTransactionDate(dynamic tx) {
    final rawDate =
        tx["created_at"] ??
        tx["date"] ??
        tx["createdAt"];

    if (rawDate == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          rawDate.toString(),
        ) ??
        DateTime.now();
  }

  String formatDate(dynamic tx) {
    final date = getTransactionDate(tx);

    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$day/$month/$year - $hour:$minute";
  }

  bool isIncome(dynamic tx) {
    return tx["type"] == "income";
  }

  double getTotalIncome(List list) {
    double total = 0;

    for (final tx in list) {
      if (isIncome(tx)) {
        total += parseDouble(tx["amount"]);
      }
    }

    return total;
  }

  double getTotalExpenses(List list) {
    double total = 0;

    for (final tx in list) {
      if (!isIncome(tx)) {
        total += parseDouble(tx["amount"]);
      }
    }

    return total;
  }

  Widget buildTimelineItem(
    dynamic tx,
    int index,
    bool isLast,
  ) {
    final type = tx["type"]?.toString() ?? "expense";
    final income = type == "income";

    final amount = parseDouble(tx["amount"]);
    final category =
        tx["category"]?.toString().trim() ?? "";
    final description =
        tx["description"]?.toString().trim() ?? "";
    final note = tx["note"]?.toString().trim() ?? "";
    final sourceName =
        tx["source_transaction_name"]?.toString().trim() ??
            "";

    final color =
        income ? Colors.greenAccent : Colors.redAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            if (!isLast)
              Container(
                width: 3,
                height: 135,
                color: Colors.white.withOpacity(0.12),
              ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withOpacity(0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 14,
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
                    Icon(
                      income
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: color,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        income ? "Entrada" : "Salida",
                        style: TextStyle(
                          color: color,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      "${income ? "+" : "-"}\$${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  description.isEmpty
                      ? "Movimiento sin descripción"
                      : description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category.isEmpty
                            ? "Sin categoría"
                            : category,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                if (!income &&
                    sourceName.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          Colors.orangeAccent.withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.orangeAccent
                            .withOpacity(0.28),
                      ),
                    ),
                    child: Text(
                      "Origen del dinero: $sourceName",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                if (note.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Text(
                      "Nota: $note",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDate(tx),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader(
    DateFilterProvider dateFilter,
    List filteredTimeline,
  ) {
    final income = getTotalIncome(filteredTimeline);
    final expenses = getTotalExpenses(filteredTimeline);
    final balance = income - expenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.amberAccent.withOpacity(0.95),
            Colors.orangeAccent.withOpacity(0.85),
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
            Icons.timeline_rounded,
            color: Colors.black,
            size: 42,
          ),

          const SizedBox(height: 14),

          const Text(
            "Timeline Financiero",
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
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

          const SizedBox(height: 18),

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
                  "Movimientos",
                  filteredTimeline.length.toString(),
                ),
                metricRow(
                  "Entradas",
                  "\$${income.toStringAsFixed(2)}",
                ),
                metricRow(
                  "Salidas",
                  "\$${expenses.toStringAsFixed(2)}",
                ),
                metricRow(
                  "Balance",
                  "\$${balance.toStringAsFixed(2)}",
                ),
              ],
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
              Icons.timeline_rounded,
              size: 90,
              color:
                  Colors.amberAccent.withOpacity(0.7),
            ),

            const SizedBox(height: 20),

            const Text(
              "Sin movimientos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              dateFilter.filterType ==
                      DateFilterType.all
                  ? "Registra entradas y salidas para ver aquí tu historial financiero."
                  : "No hay movimientos en el periodo seleccionado.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
              ),
            ),

            const SizedBox(height: 22),

            if (dateFilter.filterType !=
                DateFilterType.all)
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

  @override
  Widget build(BuildContext context) {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
    );

    final filteredTimeline =
        dateFilter.filterTransactions(
      timeline,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Timeline"),
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
            onPressed: loadTimeline,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amberAccent,
              ),
            )
          : filteredTimeline.isEmpty
              ? buildEmptyState(
                  dateFilter,
                )
              : RefreshIndicator(
                  onRefresh: loadTimeline,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount:
                        filteredTimeline.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return buildHeader(
                          dateFilter,
                          filteredTimeline,
                        );
                      }

                      final tx =
                          filteredTimeline[index - 1];

                      return buildTimelineItem(
                        tx,
                        index - 1,
                        index ==
                            filteredTimeline.length,
                      );
                    },
                  ),
                ),
    );
  }
}