import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/transaction_service.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../services/notification_service.dart';
import '../services/goal_service.dart';
import '../services/offline_sync_service.dart';

import '../providers/theme_provider.dart';
import '../providers/eye_control_provider.dart';
import '../providers/date_filter_provider.dart';

import 'add_transaction_screen.dart';
import 'login_screen.dart';
import 'goals_screen.dart';
import 'ocr_screen.dart';
import 'budgets_screen.dart';
import 'notifications_screen.dart';
import 'copilot_screen.dart';
import 'security_shield_screen.dart';
import 'money_flow_screen.dart';
import 'timeline_screen.dart';
import 'academy_screen.dart';
import 'accessibility_screen.dart';
import 'financial_calendar_screen.dart';
import 'global_market_screen.dart';
import 'sat_screen.dart';
import 'credit_bureau_screen.dart';

import '../widgets/balance_card.dart';
import '../widgets/income_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/ai_advice_widget.dart';
import '../widgets/transactions_widget.dart';
import '../widgets/financial_pies_widget.dart';
import '../widgets/slidable_tools_panel.dart';

class DashboardScreen extends StatefulWidget {
  final String email;

  const DashboardScreen({
    super.key,
    required this.email,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loading = true;

  double balance = 0;
  double income = 0;
  double expenses = 0;

  int unreadNotifications = 0;

  int totalGoals = 0;
  double totalGoalsSaved = 0;
  double totalGoalsTarget = 0;

  List transactions = [];
  List advice = [];

  Map<String, dynamic>? chartSummary;

  StreamSubscription? connectivitySubscription;

  bool isOnline = true;
  bool syncing = false;
  int pendingTransactions = 0;

  @override
  void initState() {
    super.initState();

    loadData();
    loadUnreadNotifications();
    loadGoalsSummary();
    initConnectivityMonitor();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> initConnectivityMonitor() async {
    final online = await OfflineSyncService.hasInternet();

    if (!mounted) return;

    setState(() {
      isOnline = online;
    });

    await updatePendingCount();

    if (online && pendingTransactions > 0) {
      await syncOfflineData();
    }

    connectivitySubscription =
        OfflineSyncService.connectivityStream().listen(
      (event) async {
        final hasInternet =
            !event.contains(ConnectivityResult.none);

        if (!mounted) return;

        setState(() {
          isOnline = hasInternet;
        });

        if (hasInternet) {
          await syncOfflineData();
        }
      },
    );
  }

  Future<void> updatePendingCount() async {
    final count =
        await OfflineSyncService.getPendingCount();

    if (!mounted) return;

    setState(() {
      pendingTransactions = count;
    });
  }

  Future<void> syncOfflineData() async {
    final count =
        await OfflineSyncService.getPendingCount();

    if (count == 0) {
      await updatePendingCount();
      return;
    }

    if (!mounted) return;

    setState(() {
      syncing = true;
    });

    final result =
        await OfflineSyncService.syncPending();

    if (!mounted) return;

    setState(() {
      syncing = false;
    });

    await updatePendingCount();
    await refreshDashboard();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["message"].toString(),
        ),
      ),
    );
  }

  Future<void> loadUnreadNotifications() async {
    try {
      final count =
          await NotificationService.getUnreadCount(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        unreadNotifications = count;
      });
    } catch (e) {
      debugPrint("ERROR NOTIFICATIONS:");
      debugPrint(e.toString());
    }
  }

  Future<void> loadGoalsSummary() async {
    try {
      final summary =
          await GoalService.getGoalsSummary(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        totalGoals = summary["total_goals"] ?? 0;
        totalGoalsSaved =
            (summary["total_saved"] as num?)
                    ?.toDouble() ??
                0;
        totalGoalsTarget =
            (summary["total_target"] as num?)
                    ?.toDouble() ??
                0;
      });
    } catch (e) {
      debugPrint("ERROR GOALS SUMMARY:");
      debugPrint(e.toString());
    }
  }

  Future<void> loadData() async {
    try {
      final balanceData =
          await TransactionService.getBalance(
        widget.email,
      );

      final txData =
          await TransactionService.getTransactions(
        widget.email,
      );

      Map<String, dynamic>? chartData;

      try {
        chartData =
            await TransactionService.getChartSummary(
          widget.email,
        );
      } catch (e) {
        debugPrint("ERROR CHART SUMMARY:");
        debugPrint(e.toString());
      }

      List adviceData = [];

      try {
        adviceData =
            await TransactionService.getFinancialAdvice(
          widget.email,
        );
      } catch (e) {
        debugPrint("ERROR IA:");
        debugPrint(e.toString());
      }

      double tempIncome = 0;
      double tempExpenses = 0;

      for (var tx in txData) {
        final amount =
            (tx["amount"] as num).toDouble();

        if (tx["type"] == "income") {
          tempIncome += amount;
        } else {
          tempExpenses += amount;
        }
      }

      if (!mounted) return;

      setState(() {
        balance =
            (balanceData["balance"] as num).toDouble();
        income = tempIncome;
        expenses = tempExpenses;
        transactions = txData;
        advice = adviceData;
        chartSummary = chartData;
        loading = false;
      });
    } catch (e) {
      debugPrint("ERROR DASHBOARD:");
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> refreshDashboard() async {
    await loadData();
    await loadUnreadNotifications();
    await loadGoalsSummary();
    await updatePendingCount();
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("user_email");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Widget buildConnectionStatusCard() {
    Color color;
    String text;
    IconData icon;

    if (syncing) {
      color = Colors.orangeAccent;
      text = "Sincronizando datos";
      icon = Icons.sync_rounded;
    } else if (!isOnline) {
      color = Colors.redAccent;
      text = "Modo Offline";
      icon = Icons.cloud_off_rounded;
    } else {
      color = Colors.greenAccent;
      text = "Conectado";
      icon = Icons.cloud_done_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(0.35),
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
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (pendingTransactions > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "$pendingTransactions pendientes",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDateFilterCard(
    DateFilterProvider dateFilter,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_rounded,
                color: Colors.cyanAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFilter.filterTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateFilter.filterDescription,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: filterButton(
                  title: "Todo",
                  selected:
                      dateFilter.filterType ==
                          DateFilterType.all,
                  onTap: () {
                    dateFilter.setAll();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: filterButton(
                  title: "Día",
                  selected:
                      dateFilter.filterType ==
                          DateFilterType.day,
                  onTap: () async {
                    final picked =
                        await showDatePicker(
                      context: context,
                      initialDate:
                          dateFilter.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );

                    if (picked != null) {
                      dateFilter.setDay(
                        picked,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: filterButton(
                  title: "Mes",
                  selected:
                      dateFilter.filterType ==
                          DateFilterType.month,
                  onTap: () async {
                    final picked =
                        await showDatePicker(
                      context: context,
                      initialDate:
                          dateFilter.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );

                    if (picked != null) {
                      dateFilter.setMonth(
                        picked,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: filterButton(
                  title: "Año",
                  selected:
                      dateFilter.filterType ==
                          DateFilterType.year,
                  onTap: () async {
                    final picked =
                        await showDatePicker(
                      context: context,
                      initialDate:
                          dateFilter.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );

                    if (picked != null) {
                      dateFilter.setYear(
                        picked,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget filterButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.cyanAccent
              : Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(
              selected ? 0.8 : 0.25,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget buildWelcomeHeader(
    double currentBalance,
    String filterText,
  ) {
    final name = widget.email.split("@").first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.96),
            Colors.tealAccent.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, $name",
            style: TextStyle(
              color: Colors.black.withOpacity(0.72),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tu control financiero inteligente",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              filterText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "\$${currentBalance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Balance del periodo seleccionado",
            style: TextStyle(
              color: Colors.black.withOpacity(0.66),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.35),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickAccessCard() {
    return SlidableToolsPanel(
      children: [
        buildQuickButton(
          title: "Nuevo",
          icon: Icons.add_circle_outline_rounded,
          color: Colors.greenAccent,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddTransactionScreen(
                  email: widget.email,
                ),
              ),
            );

            if (result == true) {
              refreshDashboard();
            }
          },
        ),

        buildQuickButton(
          title: "Calendario",
          icon: Icons.calendar_month_rounded,
          color: Colors.cyanAccent,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FinancialCalendarScreen(
                  email: widget.email,
                ),
              ),
            );

            refreshDashboard();
          },
        ),

        buildQuickButton(
          title: "Mercado",
          icon: Icons.public_rounded,
          color: Colors.greenAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const GlobalMarketScreen(),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "SAT",
          icon: Icons.account_balance_rounded,
          color: Colors.cyanAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SatScreen(),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "Buró",
          icon: Icons.credit_score_rounded,
          color: Colors.purpleAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const CreditBureauScreen(),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "Acceso",
          icon: Icons.accessibility_new_rounded,
          color: Colors.lightGreenAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AccessibilityScreen(),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "Flujo",
          icon: Icons.account_tree_rounded,
          color: Colors.greenAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MoneyFlowScreen(
                  email: widget.email,
                ),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "Timeline",
          icon: Icons.timeline_rounded,
          color: Colors.amberAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TimelineScreen(
                  email: widget.email,
                ),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "OCR",
          icon: Icons.document_scanner_rounded,
          color: Colors.orangeAccent,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OCRScreen(
                  email: widget.email,
                ),
              ),
            );

            if (result == true) {
              refreshDashboard();
            }
          },
        ),

        buildQuickButton(
          title: "Metas",
          icon: Icons.flag_circle_rounded,
          color: Colors.blueAccent,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalsScreen(
                  userEmail: widget.email,
                ),
              ),
            );

            refreshDashboard();
          },
        ),

        buildQuickButton(
          title: "Presup.",
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.purpleAccent,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BudgetsScreen(
                  email: widget.email,
                ),
              ),
            );

            refreshDashboard();
          },
        ),

        buildQuickButton(
          title: "Shield",
          icon: Icons.verified_user_rounded,
          color: Colors.redAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SecurityShieldScreen(
                  email: widget.email,
                ),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "IA",
          icon: Icons.auto_awesome_rounded,
          color: Colors.tealAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CopilotScreen(
                  email: widget.email,
                ),
              ),
            );
          },
        ),

        buildQuickButton(
          title: "Academy",
          icon: Icons.school_rounded,
          color: Colors.cyanAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AcademyScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget buildCleanAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        "CASH-CONTROL",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      actions: [
        IconButton(
          tooltip: "Sincronizar",
          onPressed:
              syncing ? null : syncOfflineData,
          icon: Icon(
            syncing
                ? Icons.sync_rounded
                : Icons.cloud_sync_rounded,
          ),
        ),
        IconButton(
          tooltip: "Notificaciones",
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NotificationsScreen(
                  email: widget.email,
                ),
              ),
            );

            loadUnreadNotifications();
          },
          icon: const Icon(
            Icons.notifications_rounded,
          ),
        ),
        PopupMenuButton<String>(
          color: const Color(0xFF151515),
          icon: const Icon(
            Icons.more_vert_rounded,
          ),
          onSelected: (value) {
            if (value == "theme") {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme();
            }

            if (value == "logout") {
              logout();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: "theme",
                child: Text(
                  "Cambiar tema",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              PopupMenuItem(
                value: "logout",
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget buildPremiumCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(
              Icons.open_in_new_rounded,
            ),
            label: const Text("Abrir"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: colors.first,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGoalsSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF111111),
      ),
      child: Text(
        "Metas activas: $totalGoals\nAhorrado: \$${totalGoalsSaved.toStringAsFixed(2)}\nObjetivo: \$${totalGoalsTarget.toStringAsFixed(2)}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.45,
        ),
      ),
    );
  }

  Widget buildExportCard({
    required double currentBalance,
    required double currentIncome,
    required double currentExpenses,
    required List currentTransactions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                PdfService.generateReport(
                  email: widget.email,
                  balance: currentBalance,
                  income: currentIncome,
                  expenses: currentExpenses,
                  transactions: currentTransactions,
                );
              },
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
              ),
              label: const Text("PDF"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ExcelService.exportExcel(
                  email: widget.email,
                  balance: currentBalance,
                  income: currentIncome,
                  expenses: currentExpenses,
                  transactions: currentTransactions,
                );
              },
              icon: const Icon(
                Icons.table_chart_rounded,
              ),
              label: const Text("Excel"),
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
    final eyeProvider =
        Provider.of<EyeControlProvider>(
      context,
    );

    final dateFilter =
        Provider.of<DateFilterProvider>(
      context,
    );

    final filteredTransactions =
        dateFilter.filterTransactions(
      transactions,
    );

    final filteredIncome =
        dateFilter.getIncome(
      filteredTransactions,
    );

    final filteredExpenses =
        dateFilter.getExpenses(
      filteredTransactions,
    );

    final filteredBalance =
        dateFilter.getBalance(
      filteredTransactions,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildCleanAppBar(),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshDashboard,
              child: SingleChildScrollView(
                controller:
                    eyeProvider.globalScrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    buildConnectionStatusCard(),

                    const SizedBox(height: 18),

                    buildDateFilterCard(
                      dateFilter,
                    ),

                    const SizedBox(height: 18),

                    buildWelcomeHeader(
                      filteredBalance,
                      dateFilter.filterDescription,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: IncomeCard(
                            income: filteredIncome,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ExpenseCard(
                            expenses: filteredExpenses,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    BalanceCard(
                      balance: filteredBalance,
                    ),

                    const SizedBox(height: 30),

                    buildQuickAccessCard(),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Análisis visual",
                      "Consulta tus ingresos, salidas y distribución del efectivo por periodo.",
                    ),

                    FinancialPiesWidget(
                      transactions: filteredTransactions,
                    ),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Accesibilidad",
                      "Controla CASH-CONTROL con herramientas adaptadas.",
                    ),

                    buildPremiumCard(
                      "Centro de Accesibilidad",
                      "Configura Eye Control, recalibración y funciones manos libres.",
                      Icons.accessibility_new_rounded,
                      [
                        Colors.lightGreenAccent,
                        Colors.greenAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AccessibilityScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Modo Manos Libres",
                      "Controla la aplicación mediante mirada, parpadeos y accesos especiales.",
                      Icons.pan_tool_alt_rounded,
                      [
                        Colors.cyanAccent,
                        Colors.lightBlueAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AccessibilityScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Auditoría financiera",
                      "Rastrea el origen y destino de tu dinero.",
                    ),

                    buildPremiumCard(
                      "Calendario Financiero",
                      "Consulta ingresos, gastos y balance por día, mes y año.",
                      Icons.calendar_month_rounded,
                      [
                        Colors.cyanAccent,
                        Colors.lightBlueAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FinancialCalendarScreen(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Flujo de Dinero",
                      "Audita de dónde entró y salió tu dinero.",
                      Icons.account_tree_rounded,
                      [
                        Colors.greenAccent,
                        Colors.tealAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MoneyFlowScreen(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Timeline Financiero",
                      "Consulta tus movimientos en orden cronológico.",
                      Icons.timeline_rounded,
                      [
                        Colors.amberAccent,
                        Colors.orangeAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TimelineScreen(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Servicios financieros",
                      "Mercado global, SAT y salud crediticia.",
                    ),

                    buildPremiumCard(
                      "Mercado Global",
                      "Consulta mercados, divisas, criptomonedas y simulaciones de inversión.",
                      Icons.public_rounded,
                      [
                        Colors.greenAccent,
                        Colors.tealAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const GlobalMarketScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "SAT",
                      "Organiza información fiscal, facturas, obligaciones y accesos oficiales.",
                      Icons.account_balance_rounded,
                      [
                        Colors.cyanAccent,
                        Colors.blueAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SatScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Buró de Crédito",
                      "Consulta salud crediticia, historial de pagos y consejos para mejorar tu score.",
                      Icons.credit_score_rounded,
                      [
                        Colors.purpleAccent,
                        Colors.deepPurpleAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreditBureauScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Herramientas inteligentes",
                      "IA, seguridad, academia, metas y exportaciones.",
                    ),

                    buildPremiumCard(
                      "Cash-Control IA",
                      "Consulta consejos y análisis financiero inteligente.",
                      Icons.auto_awesome_rounded,
                      [
                        Colors.tealAccent,
                        Colors.greenAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CopilotScreen(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Cash-Control Academy",
                      "Cursos de educación financiera, ahorro, negocios e inteligencia financiera.",
                      Icons.school_rounded,
                      [
                        Colors.cyanAccent,
                        Colors.blueAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AcademyScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildPremiumCard(
                      "Security Shield",
                      "Analiza enlaces, textos y posibles fraudes.",
                      Icons.verified_user_rounded,
                      [
                        Colors.redAccent,
                        Colors.deepOrangeAccent,
                      ],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SecurityShieldScreen(
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    buildGoalsSummaryCard(),

                    const SizedBox(height: 22),

                    AiAdviceWidget(
                      advice: advice,
                    ),

                    const SizedBox(height: 22),

                    buildExportCard(
                      currentBalance: filteredBalance,
                      currentIncome: filteredIncome,
                      currentExpenses: filteredExpenses,
                      currentTransactions:
                          filteredTransactions,
                    ),

                    const SizedBox(height: 34),

                    sectionTitle(
                      "Movimientos recientes",
                      "Últimos registros financieros.",
                    ),

                    TransactionsWidget(
                      transactions: filteredTransactions,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}