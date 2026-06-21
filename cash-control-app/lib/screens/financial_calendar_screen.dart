import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/date_filter_provider.dart';
import '../services/transaction_service.dart';

class FinancialCalendarScreen extends StatefulWidget {
  final String email;

  const FinancialCalendarScreen({
    super.key,
    required this.email,
  });

  @override
  State<FinancialCalendarScreen> createState() =>
      _FinancialCalendarScreenState();
}

class _FinancialCalendarScreenState
    extends State<FinancialCalendarScreen> {
  bool loading = true;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final data =
          await TransactionService.getTransactions(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        transactions = data;
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
            "Error al cargar calendario: $e",
          ),
        ),
      );
    }
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

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool isIncome(dynamic tx) {
    return tx["type"] == "income";
  }

  double getAmount(dynamic tx) {
    final value = tx["amount"];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  List<dynamic> getTransactionsByDay(DateTime day) {
    return transactions.where((tx) {
      final date = getTransactionDate(tx);

      return isSameDate(date, day);
    }).toList();
  }

  List<dynamic> getTransactionsByMonth(DateTime day) {
    return transactions.where((tx) {
      final date = getTransactionDate(tx);

      return date.year == day.year &&
          date.month == day.month;
    }).toList();
  }

  List<dynamic> getTransactionsByYear(DateTime day) {
    return transactions.where((tx) {
      final date = getTransactionDate(tx);

      return date.year == day.year;
    }).toList();
  }

  DateTime getStartOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(
      Duration(
        days: date.weekday - 1,
      ),
    );
  }

  DateTime getEndOfWeek(DateTime date) {
    final start = getStartOfWeek(date);

    return DateTime(
      start.year,
      start.month,
      start.day + 6,
      23,
      59,
      59,
    );
  }

  List<dynamic> getTransactionsByWeek(DateTime date) {
    final start = getStartOfWeek(date);
    final end = getEndOfWeek(date);

    return transactions.where((tx) {
      final txDate = getTransactionDate(tx);

      return txDate.isAfter(
            start.subtract(
              const Duration(seconds: 1),
            ),
          ) &&
          txDate.isBefore(
            end.add(
              const Duration(seconds: 1),
            ),
          );
    }).toList();
  }

  DateTime getPreviousMonth(DateTime date) {
    if (date.month == 1) {
      return DateTime(
        date.year - 1,
        12,
        1,
      );
    }

    return DateTime(
      date.year,
      date.month - 1,
      1,
    );
  }

  double getIncome(List<dynamic> list) {
    double total = 0;

    for (final tx in list) {
      if (isIncome(tx)) {
        total += getAmount(tx);
      }
    }

    return total;
  }

  double getExpense(List<dynamic> list) {
    double total = 0;

    for (final tx in list) {
      if (!isIncome(tx)) {
        total += getAmount(tx);
      }
    }

    return total;
  }

  double getPercentageChange(
    double current,
    double previous,
  ) {
    if (previous == 0 && current == 0) {
      return 0;
    }

    if (previous == 0 && current > 0) {
      return 100;
    }

    return ((current - previous) / previous) * 100;
  }

  String getChangeText(
    double current,
    double previous,
  ) {
    final change = getPercentageChange(
      current,
      previous,
    );

    if (change > 0) {
      return "+${change.toStringAsFixed(1)}%";
    }

    return "${change.toStringAsFixed(1)}%";
  }

  Color getChangeColor({
    required double current,
    required double previous,
    required bool positiveIsGood,
  }) {
    final difference = current - previous;

    if (difference == 0) {
      return Colors.white54;
    }

    if (positiveIsGood) {
      return difference > 0
          ? Colors.greenAccent
          : Colors.redAccent;
    }

    return difference > 0
        ? Colors.redAccent
        : Colors.greenAccent;
  }

  String getSmartMonthlyMessage({
    required double currentIncome,
    required double previousIncome,
    required double currentExpenses,
    required double previousExpenses,
    required double currentBalance,
    required double previousBalance,
  }) {
    final incomeChange = getPercentageChange(
      currentIncome,
      previousIncome,
    );

    final expenseChange = getPercentageChange(
      currentExpenses,
      previousExpenses,
    );

    final balanceChange = currentBalance - previousBalance;

    if (currentExpenses > previousExpenses &&
        currentIncome <= previousIncome) {
      return "Atención: tus gastos aumentaron ${expenseChange.toStringAsFixed(1)}% y tus ingresos no crecieron. Conviene revisar gastos innecesarios.";
    }

    if (currentIncome > previousIncome &&
        currentExpenses <= previousExpenses) {
      return "Excelente: tus ingresos aumentaron ${incomeChange.toStringAsFixed(1)}% y tus gastos se mantuvieron controlados.";
    }

    if (balanceChange > 0) {
      return "Vas mejor que el mes anterior. Tu balance aumentó \$${balanceChange.toStringAsFixed(2)}.";
    }

    if (balanceChange < 0) {
      return "Tu balance bajó \$${balanceChange.abs().toStringAsFixed(2)} frente al mes anterior. Revisa las categorías con más salidas.";
    }

    return "Tu comportamiento financiero está muy similar al mes anterior.";
  }

  Color getDayColor(DateTime day) {
    final dayTransactions =
        getTransactionsByDay(day);

    if (dayTransactions.isEmpty) {
      return Colors.transparent;
    }

    final hasIncome =
        dayTransactions.any((tx) => isIncome(tx));

    final hasExpense =
        dayTransactions.any((tx) => !isIncome(tx));

    if (hasIncome && hasExpense) {
      return Colors.amberAccent;
    }

    if (hasIncome) {
      return Colors.greenAccent;
    }

    if (hasExpense) {
      return Colors.redAccent;
    }

    return Colors.transparent;
  }

  IconData getDayIcon(DateTime day) {
    final dayTransactions =
        getTransactionsByDay(day);

    if (dayTransactions.isEmpty) {
      return Icons.circle_outlined;
    }

    final hasIncome =
        dayTransactions.any((tx) => isIncome(tx));

    final hasExpense =
        dayTransactions.any((tx) => !isIncome(tx));

    if (hasIncome && hasExpense) {
      return Icons.compare_arrows_rounded;
    }

    if (hasIncome) {
      return Icons.arrow_upward_rounded;
    }

    if (hasExpense) {
      return Icons.arrow_downward_rounded;
    }

    return Icons.circle_outlined;
  }

  dynamic getHighestIncomeDay(
    List<dynamic> weekTransactions,
  ) {
    final Map<String, double> totals = {};

    for (final tx in weekTransactions) {
      if (!isIncome(tx)) continue;

      final date = getTransactionDate(tx);

      final key =
          "${date.year}-${date.month}-${date.day}";

      totals[key] =
          (totals[key] ?? 0) + getAmount(tx);
    }

    if (totals.isEmpty) return null;

    return totals.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
  }

  dynamic getHighestExpenseDay(
    List<dynamic> weekTransactions,
  ) {
    final Map<String, double> totals = {};

    for (final tx in weekTransactions) {
      if (isIncome(tx)) continue;

      final date = getTransactionDate(tx);

      final key =
          "${date.year}-${date.month}-${date.day}";

      totals[key] =
          (totals[key] ?? 0) + getAmount(tx);
    }

    if (totals.isEmpty) return null;

    return totals.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
  }

  String formatWeekDayKey(String key) {
    final parts = key.split("-");

    if (parts.length != 3) {
      return key;
    }

    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    return DateFormat("dd/MM/yyyy").format(date);
  }

  void applyDayFilter() {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
      listen: false,
    );

    dateFilter.setDay(selectedDay);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Filtro aplicado: ${DateFormat("dd/MM/yyyy").format(selectedDay)}",
        ),
      ),
    );

    Navigator.pop(context);
  }

  void applyMonthFilter() {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
      listen: false,
    );

    dateFilter.setMonth(focusedDay);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Filtro aplicado: ${DateFormat("MM/yyyy").format(focusedDay)}",
        ),
      ),
    );

    Navigator.pop(context);
  }

  void applyYearFilter() {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
      listen: false,
    );

    dateFilter.setYear(focusedDay);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Filtro aplicado: año ${focusedDay.year}",
        ),
      ),
    );

    Navigator.pop(context);
  }

  void applyAllFilter() {
    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
      listen: false,
    );

    dateFilter.setAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Filtro eliminado: mostrando todo el historial",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dayTx =
        getTransactionsByDay(selectedDay);

    final weekTx =
        getTransactionsByWeek(selectedDay);

    final monthTx =
        getTransactionsByMonth(focusedDay);

    final previousMonth =
        getPreviousMonth(focusedDay);

    final previousMonthTx =
        getTransactionsByMonth(previousMonth);

    final yearTx =
        getTransactionsByYear(focusedDay);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Calendario Financiero",
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Actualizar",
            onPressed: loadTransactions,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadTransactions,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    buildLegendCard(),

                    const SizedBox(height: 16),

                    buildCalendar(),

                    const SizedBox(height: 20),

                    buildFilterActionsCard(),

                    const SizedBox(height: 20),

                    buildSummaryCard(
                      title: "Resumen del día",
                      subtitle: DateFormat(
                        "dd/MM/yyyy",
                      ).format(selectedDay),
                      list: dayTx,
                      color: getDayColor(selectedDay) ==
                              Colors.transparent
                          ? Colors.greenAccent
                          : getDayColor(selectedDay),
                    ),

                    const SizedBox(height: 20),

                    buildWeeklyReportCard(
                      weekTx,
                    ),

                    const SizedBox(height: 20),

                    buildMonthlyComparisonCard(
                      currentMonth: focusedDay,
                      previousMonth: previousMonth,
                      currentTransactions: monthTx,
                      previousTransactions: previousMonthTx,
                    ),

                    const SizedBox(height: 20),

                    buildSummaryCard(
                      title: "Resumen del mes",
                      subtitle: DateFormat(
                        "MMMM yyyy",
                      ).format(focusedDay),
                      list: monthTx,
                      color: Colors.cyanAccent,
                    ),

                    const SizedBox(height: 20),

                    buildSummaryCard(
                      title: "Resumen del año",
                      subtitle:
                          focusedDay.year.toString(),
                      list: yearTx,
                      color: Colors.amberAccent,
                    ),

                    const SizedBox(height: 20),

                    buildDayMovements(dayTx),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildMonthlyComparisonCard({
    required DateTime currentMonth,
    required DateTime previousMonth,
    required List<dynamic> currentTransactions,
    required List<dynamic> previousTransactions,
  }) {
    final currentIncome =
        getIncome(currentTransactions);
    final previousIncome =
        getIncome(previousTransactions);

    final currentExpenses =
        getExpense(currentTransactions);
    final previousExpenses =
        getExpense(previousTransactions);

    final currentBalance =
        currentIncome - currentExpenses;
    final previousBalance =
        previousIncome - previousExpenses;

    final message = getSmartMonthlyMessage(
      currentIncome: currentIncome,
      previousIncome: previousIncome,
      currentExpenses: currentExpenses,
      previousExpenses: previousExpenses,
      currentBalance: currentBalance,
      previousBalance: previousBalance,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: Colors.blueAccent,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Comparativa mensual",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "${DateFormat("MMMM yyyy").format(currentMonth)} vs ${DateFormat("MMMM yyyy").format(previousMonth)}",
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          buildComparisonRow(
            title: "Ingresos",
            current: currentIncome,
            previous: previousIncome,
            positiveIsGood: true,
          ),

          buildComparisonRow(
            title: "Gastos",
            current: currentExpenses,
            previous: previousExpenses,
            positiveIsGood: false,
          ),

          buildComparisonRow(
            title: "Balance",
            current: currentBalance,
            previous: previousBalance,
            positiveIsGood: true,
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.20),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.blueAccent,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildComparisonRow({
    required String title,
    required double current,
    required double previous,
    required bool positiveIsGood,
  }) {
    final changeText = getChangeText(
      current,
      previous,
    );

    final changeColor = getChangeColor(
      current: current,
      previous: previous,
      positiveIsGood: positiveIsGood,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: changeColor.withOpacity(0.24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                "\$${current.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Antes: \$${previous.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              changeText,
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeeklyReportCard(
    List<dynamic> weekTx,
  ) {
    final start = getStartOfWeek(selectedDay);
    final end = getEndOfWeek(selectedDay);

    final income = getIncome(weekTx);
    final expenses = getExpense(weekTx);
    final balance = income - expenses;

    final highestIncomeDay =
        getHighestIncomeDay(weekTx);

    final highestExpenseDay =
        getHighestExpenseDay(weekTx);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                color: Colors.purpleAccent,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Reporte semanal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "${DateFormat("dd/MM/yyyy").format(start)} - ${DateFormat("dd/MM/yyyy").format(end)}",
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          infoRow(
            "Ingresos de la semana",
            income,
            Colors.greenAccent,
          ),

          infoRow(
            "Gastos de la semana",
            expenses,
            Colors.redAccent,
          ),

          infoRow(
            "Balance semanal",
            balance,
            balance >= 0
                ? Colors.greenAccent
                : Colors.redAccent,
          ),

          const SizedBox(height: 10),

          Text(
            "Movimientos: ${weekTx.length}",
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),

          const SizedBox(height: 16),

          if (highestIncomeDay != null)
            buildBestDayBox(
              title: "Día con más ingresos",
              value:
                  "${formatWeekDayKey(highestIncomeDay.key)} • \$${highestIncomeDay.value.toStringAsFixed(2)}",
              icon: Icons.trending_up_rounded,
              color: Colors.greenAccent,
            ),

          if (highestExpenseDay != null)
            buildBestDayBox(
              title: "Día con más gastos",
              value:
                  "${formatWeekDayKey(highestExpenseDay.key)} • \$${highestExpenseDay.value.toStringAsFixed(2)}",
              icon: Icons.trending_down_rounded,
              color: Colors.redAccent,
            ),

          if (weekTx.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "No hay movimientos registrados en esta semana.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),

          if (weekTx.isNotEmpty) ...[
            const SizedBox(height: 16),

            const Text(
              "Movimientos de la semana",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...weekTx.take(6).map(
                  (tx) => buildCompactMovement(tx),
                ),

            if (weekTx.length > 6)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "+ ${weekTx.length - 6} movimientos más",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget buildBestDayBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompactMovement(dynamic tx) {
    final income = isIncome(tx);
    final amount = getAmount(tx);

    final date = getTransactionDate(tx);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: income
              ? Colors.greenAccent.withOpacity(0.22)
              : Colors.redAccent.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            income
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: income
                ? Colors.greenAccent
                : Colors.redAccent,
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  tx["category"]?.toString() ??
                      "Sin categoría",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat("dd/MM/yyyy").format(date),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "${income ? "+" : "-"}\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: income
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLegendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: Colors.cyanAccent,
              ),
              SizedBox(width: 10),
              Text(
                "Guía de colores",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          legendItem(
            color: Colors.greenAccent,
            title: "Ingresos",
            subtitle: "Días donde solo registraste entradas.",
          ),

          legendItem(
            color: Colors.redAccent,
            title: "Gastos",
            subtitle: "Días donde solo registraste salidas.",
          ),

          legendItem(
            color: Colors.amberAccent,
            title: "Mixto",
            subtitle: "Días con ingresos y gastos.",
          ),
        ],
      ),
    );
  }

  Widget legendItem({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
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
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.25),
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) {
          return isSameDate(
            selectedDay,
            day,
          );
        },
        onDaySelected: (
          selected,
          focused,
        ) {
          setState(() {
            selectedDay = selected;
            focusedDay = focused;
          });
        },
        onPageChanged: (focused) {
          setState(() {
            focusedDay = focused;
          });
        },
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: "Mes",
        },
        eventLoader: (day) {
          return getTransactionsByDay(day);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (
            context,
            day,
            focusedDay,
          ) {
            return buildDayCell(
              day,
              isSelected: false,
              isToday: false,
            );
          },
          todayBuilder: (
            context,
            day,
            focusedDay,
          ) {
            return buildDayCell(
              day,
              isSelected: false,
              isToday: true,
            );
          },
          selectedBuilder: (
            context,
            day,
            focusedDay,
          ) {
            return buildDayCell(
              day,
              isSelected: true,
              isToday: isSameDate(
                day,
                DateTime.now(),
              ),
            );
          },
          outsideBuilder: (
            context,
            day,
            focusedDay,
          ) {
            return Center(
              child: Text(
                "${day.day}",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.18),
                ),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          markersMaxCount: 0,
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.greenAccent,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.greenAccent,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.white70,
          ),
          weekendStyle: TextStyle(
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final color = getDayColor(day);

    final hasTransactions =
        getTransactionsByDay(day).isNotEmpty;

    final icon = getDayIcon(day);

    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.white;

    if (hasTransactions) {
      backgroundColor = color.withOpacity(0.88);
      textColor = Colors.black;
    }

    if (isToday && !isSelected) {
      backgroundColor =
          Colors.white.withOpacity(0.10);
      textColor = Colors.greenAccent;
    }

    if (isSelected) {
      backgroundColor = Colors.cyanAccent;
      textColor = Colors.black;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? Colors.white
              : hasTransactions
                  ? color.withOpacity(0.75)
                  : Colors.white.withOpacity(0.05),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: hasTransactions
            ? [
                BoxShadow(
                  color: color.withOpacity(0.20),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "${day.day}",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (hasTransactions)
            Positioned(
              right: 3,
              bottom: 3,
              child: Icon(
                icon,
                size: 12,
                color: Colors.black.withOpacity(0.78),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFilterActionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Colors.cyanAccent,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Aplicar filtro al Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Selecciona si quieres ver toda la app filtrada por este día, mes o año.",
            style: TextStyle(
              color: Colors.white60,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: filterActionButton(
                  title: "Día",
                  icon: Icons.today_rounded,
                  color: Colors.greenAccent,
                  onTap: applyDayFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: filterActionButton(
                  title: "Mes",
                  icon: Icons.calendar_view_month_rounded,
                  color: Colors.cyanAccent,
                  onTap: applyMonthFilter,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: filterActionButton(
                  title: "Año",
                  icon: Icons.calendar_month_rounded,
                  color: Colors.amberAccent,
                  onTap: applyYearFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: filterActionButton(
                  title: "Todo",
                  icon: Icons.all_inclusive_rounded,
                  color: Colors.white,
                  onTap: applyAllFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget filterActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.35),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard({
    required String title,
    required String subtitle,
    required List<dynamic> list,
    required Color color,
  }) {
    final income = getIncome(list);
    final expenses = getExpense(list);
    final balance = income - expenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),

          const SizedBox(height: 16),

          infoRow(
            "Ingresos",
            income,
            Colors.greenAccent,
          ),

          infoRow(
            "Gastos",
            expenses,
            Colors.redAccent,
          ),

          infoRow(
            "Balance",
            balance,
            balance >= 0
                ? Colors.greenAccent
                : Colors.redAccent,
          ),

          const SizedBox(height: 8),

          Text(
            "Movimientos: ${list.length}",
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
    String title,
    double amount,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDayMovements(
    List<dynamic> list,
  ) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Text(
          "No hay movimientos registrados en este día.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Movimientos del día",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...list.map(
            (tx) {
              final income = isIncome(tx);
              final amount = getAmount(tx);

              return Container(
                margin:
                    const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: income
                        ? Colors.greenAccent
                            .withOpacity(0.25)
                        : Colors.redAccent
                            .withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      income
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: income
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx["category"]?.toString() ??
                                "Sin categoría",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            tx["description"]
                                    ?.toString() ??
                                "",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),

                          if (tx["note"] != null &&
                              tx["note"]
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              "Nota: ${tx["note"]}",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    Text(
                      "${income ? "+" : "-"}\$${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: income
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}