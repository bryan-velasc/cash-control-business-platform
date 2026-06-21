import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/credit_bureau_local_service.dart';

class CreditBureauScreen extends StatefulWidget {
  const CreditBureauScreen({
    super.key,
  });

  @override
  State<CreditBureauScreen> createState() =>
      _CreditBureauScreenState();
}

class _CreditBureauScreenState
    extends State<CreditBureauScreen> {
  bool loading = true;

  List<Map<String, dynamic>> accounts = [];
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    loadCreditData();
  }

  Future<void> loadCreditData() async {
    final loadedAccounts =
        await CreditBureauLocalService.getAccounts();

    final loadedPayments =
        await CreditBureauLocalService.getPayments();

    if (!mounted) return;

    setState(() {
      accounts = loadedAccounts;
      payments = loadedPayments;
      loading = false;
    });
  }

  Future<void> openUrl(
    String url,
  ) async {
    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  double parseDouble(
    dynamic value,
  ) {
    return CreditBureauLocalService.parseDouble(
      value,
    );
  }

  DateTime parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return DateTime.now();
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        DateTime.now();
  }

  String formatDate(
    dynamic value,
  ) {
    final date = parseDate(
      value,
    );

    return DateFormat(
      "dd/MM/yyyy",
    ).format(date);
  }

  Color getScoreColor(
    int score,
  ) {
    if (score >= 760) {
      return Colors.greenAccent;
    }

    if (score >= 700) {
      return Colors.lightGreenAccent;
    }

    if (score >= 640) {
      return Colors.amberAccent;
    }

    if (score >= 580) {
      return Colors.orangeAccent;
    }

    return Colors.redAccent;
  }

  Future<void> showAddAccountDialog() async {
    final nameController =
        TextEditingController();

    final limitController =
        TextEditingController();

    final usedController =
        TextEditingController();

    DateTime paymentDate =
        DateTime.now().add(
      const Duration(days: 15),
    );

    String selectedType = "Tarjeta de crédito";

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111111),
              title: const Text(
                "Nueva cuenta crediticia",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildDialogField(
                      controller: nameController,
                      label: "Nombre",
                      hint: "Ejemplo: Tarjeta BBVA",
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor:
                          const Color(0xFF111111),
                      decoration: InputDecoration(
                        labelText: "Tipo",
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Tarjeta de crédito",
                          child: Text(
                            "Tarjeta de crédito",
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Crédito personal",
                          child: Text(
                            "Crédito personal",
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Crédito automotriz",
                          child: Text(
                            "Crédito automotriz",
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Crédito hipotecario",
                          child: Text(
                            "Crédito hipotecario",
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Otro",
                          child: Text(
                            "Otro",
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    buildDialogField(
                      controller: limitController,
                      label: "Límite / Monto aprobado",
                      hint: "Ejemplo: 10000",
                      keyboardType:
                          TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    buildDialogField(
                      controller: usedController,
                      label: "Monto usado / deuda actual",
                      hint: "Ejemplo: 2500",
                      keyboardType:
                          TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            paymentDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.purpleAccent
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Próximo pago: ${DateFormat("dd/MM/yyyy").format(paymentDate)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancelar",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text.trim();

                    final limit =
                        double.tryParse(
                              limitController.text
                                  .trim(),
                            ) ??
                            0;

                    final used =
                        double.tryParse(
                              usedController.text
                                  .trim(),
                            ) ??
                            0;

                    if (name.isEmpty || limit <= 0) {
                      return;
                    }

                    await CreditBureauLocalService
                        .addAccount(
                      name: name,
                      type: selectedType,
                      limit: limit,
                      used: used,
                      paymentDate: paymentDate,
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    await loadCreditData();
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

    nameController.dispose();
    limitController.dispose();
    usedController.dispose();
  }

  Future<void> showAddPaymentDialog() async {
    final amountController =
        TextEditingController();

    final noteController =
        TextEditingController();

    DateTime selectedDate = DateTime.now();

    bool onTime = true;

    String selectedAccount =
        accounts.isNotEmpty
            ? accounts.first["name"].toString()
            : "General";

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111111),
              title: const Text(
                "Registrar pago",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (accounts.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedAccount,
                        dropdownColor:
                            const Color(0xFF111111),
                        decoration: InputDecoration(
                          labelText: "Cuenta",
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        items: accounts.map(
                          (account) {
                            return DropdownMenuItem(
                              value:
                                  account["name"].toString(),
                              child: Text(
                                account["name"].toString(),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedAccount = value;
                          });
                        },
                      ),

                    if (accounts.isNotEmpty)
                      const SizedBox(height: 12),

                    buildDialogField(
                      controller: amountController,
                      label: "Monto pagado",
                      hint: "Ejemplo: 850",
                      keyboardType:
                          TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    buildDialogField(
                      controller: noteController,
                      label: "Nota",
                      hint: "Ejemplo: Pago mínimo / total",
                      maxLines: 3,
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.greenAccent
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Fecha de pago: ${DateFormat("dd/MM/yyyy").format(selectedDate)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SwitchListTile(
                      value: onTime,
                      activeThumbColor:
                          Colors.greenAccent,
                      title: const Text(
                        "Pago a tiempo",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        onTime
                            ? "Este pago ayuda a tu score estimado."
                            : "Este pago puede afectar tu score estimado.",
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          onTime = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancelar",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(
                              amountController.text
                                  .trim(),
                            ) ??
                            0;

                    if (amount <= 0) {
                      return;
                    }

                    await CreditBureauLocalService
                        .addPayment(
                      accountName: selectedAccount,
                      amount: amount,
                      date: selectedDate,
                      onTime: onTime,
                      note: noteController.text,
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    await loadCreditData();
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

    amountController.dispose();
    noteController.dispose();
  }

  Widget buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white70,
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.purpleAccent,
          ),
        ),
      ),
    );
  }

  Future<void> deleteAccount(
    String id,
  ) async {
    await CreditBureauLocalService.deleteAccount(
      id,
    );

    await loadCreditData();
  }

  Future<void> deletePayment(
    String id,
  ) async {
    await CreditBureauLocalService.deletePayment(
      id,
    );

    await loadCreditData();
  }

  @override
  Widget build(BuildContext context) {
    final totalLimit =
        CreditBureauLocalService.getTotalLimit(
      accounts,
    );

    final totalUsed =
        CreditBureauLocalService.getTotalUsed(
      accounts,
    );

    final utilization =
        CreditBureauLocalService
            .getUtilizationPercentage(
      accounts,
    );

    final onTime =
        CreditBureauLocalService.getOnTimePayments(
      payments,
    );

    final late =
        CreditBureauLocalService.getLatePayments(
      payments,
    );

    final score =
        CreditBureauLocalService.estimateScore(
      accounts: accounts,
      payments: payments,
    );

    final level =
        CreditBureauLocalService.getScoreLevel(
      score,
    );

    final scoreColor = getScoreColor(
      score,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Buró de Crédito",
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Actualizar",
            onPressed: loadCreditData,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purpleAccent,
        foregroundColor: Colors.black,
        onPressed: showAddAccountDialog,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          "Cuenta",
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.purpleAccent,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadCreditData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildHeader(),

                    const SizedBox(height: 22),

                    buildScoreCard(
                      score: score,
                      level: level,
                      scoreColor: scoreColor,
                      utilization: utilization,
                    ),

                    const SizedBox(height: 22),

                    buildSummaryCard(
                      totalLimit: totalLimit,
                      totalUsed: totalUsed,
                      utilization: utilization,
                      onTime: onTime,
                      late: late,
                    ),

                    const SizedBox(height: 22),

                    buildOfficialLinksCard(),

                    const SizedBox(height: 22),

                    buildQuickActionsCard(),

                    const SizedBox(height: 22),

                    buildAccountsCard(),

                    const SizedBox(height: 22),

                    buildPaymentsCard(),

                    const SizedBox(height: 22),

                    buildTipsCard(
                      utilization,
                      late,
                    ),

                    const SizedBox(height: 22),

                    buildSecurityNotice(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Colors.purpleAccent,
            Colors.deepPurpleAccent,
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.credit_score_rounded,
            color: Colors.black,
            size: 48,
          ),
          SizedBox(height: 14),
          Text(
            "Buró de Crédito",
            style: TextStyle(
              color: Colors.black,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Organiza tus cuentas, pagos e historial para estimar tu salud crediticia de forma local y segura.",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScoreCard({
    required int score,
    required String level,
    required Color scoreColor,
    required double utilization,
  }) {
    final progress =
        ((score - 300) / 550).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scoreColor.withOpacity(0.28),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.speed_rounded,
            color: scoreColor,
            size: 52,
          ),

          const SizedBox(height: 12),

          const Text(
            "Score estimado",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            score.toString(),
            style: TextStyle(
              color: scoreColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            level,
            style: TextStyle(
              color: scoreColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              backgroundColor:
                  Colors.white.withOpacity(0.12),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                scoreColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Uso de crédito: ${utilization.toStringAsFixed(1)}%",
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard({
    required double totalLimit,
    required double totalUsed,
    required double utilization,
    required int onTime,
    required int late,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen crediticio local",
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          infoRow(
            "Cuentas",
            accounts.length.toString(),
            Colors.white,
          ),

          infoRow(
            "Límite total",
            "\$${totalLimit.toStringAsFixed(2)}",
            Colors.greenAccent,
          ),

          infoRow(
            "Deuda usada",
            "\$${totalUsed.toStringAsFixed(2)}",
            Colors.orangeAccent,
          ),

          infoRow(
            "Uso de crédito",
            "${utilization.toStringAsFixed(1)}%",
            utilization <= 30
                ? Colors.greenAccent
                : Colors.redAccent,
          ),

          infoRow(
            "Pagos a tiempo",
            onTime.toString(),
            Colors.greenAccent,
          ),

          infoRow(
            "Pagos tardíos",
            late.toString(),
            late == 0
                ? Colors.greenAccent
                : Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget buildOfficialLinksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Accesos oficiales",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          officialLinkButton(
            title: "Buró de Crédito",
            subtitle: "Abrir portal oficial",
            icon: Icons.open_in_new_rounded,
            onTap: () {
              openUrl(
                "https://www.burodecredito.com.mx/",
              );
            },
          ),

          officialLinkButton(
            title: "Reporte de Crédito Especial",
            subtitle: "Consulta información oficial",
            icon: Icons.description_rounded,
            onTap: () {
              openUrl(
                "https://www.burodecredito.com.mx/reporte-de-credito-especial.html",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget officialLinkButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.greenAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickActionsCard() {
    return Row(
      children: [
        Expanded(
          child: actionButton(
            title: "Cuenta",
            icon: Icons.credit_card_rounded,
            color: Colors.purpleAccent,
            onTap: showAddAccountDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: actionButton(
            title: "Pago",
            icon: Icons.payments_rounded,
            color: Colors.greenAccent,
            onTap: showAddPaymentDialog,
          ),
        ),
      ],
    );
  }

  Widget actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
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

  Widget buildAccountsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Cuentas crediticias",
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          if (accounts.isEmpty)
            emptyText(
              "No tienes cuentas registradas.",
            )
          else
            ...accounts.map(
              (item) => accountItem(
                item,
              ),
            ),
        ],
      ),
    );
  }

  Widget accountItem(
    Map<String, dynamic> item,
  ) {
    final limit = parseDouble(
      item["limit"],
    );

    final used = parseDouble(
      item["used"],
    );

    final utilization =
        limit > 0 ? (used / limit) * 100 : 0;

    final color =
        utilization <= 30
            ? Colors.greenAccent
            : utilization <= 50
                ? Colors.amberAccent
                : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.credit_card_rounded,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"]?.toString() ??
                      "Cuenta",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item["type"]?.toString() ??
                      "Crédito",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Usado: \$${used.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                Text(
                  "Uso: ${utilization.toStringAsFixed(1)}% • Próximo pago: ${formatDate(item["payment_date"])}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              deleteAccount(
                item["id"].toString(),
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Historial de pagos",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          if (payments.isEmpty)
            emptyText(
              "No tienes pagos registrados.",
            )
          else
            ...payments.map(
              (item) => paymentItem(
                item,
              ),
            ),
        ],
      ),
    );
  }

  Widget paymentItem(
    Map<String, dynamic> item,
  ) {
    final amount = parseDouble(
      item["amount"],
    );

    final onTime =
        item["on_time"] == true;

    final color =
        onTime ? Colors.greenAccent : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            onTime
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item["account_name"]?.toString() ??
                      "Pago",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Monto: \$${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                Text(
                  "${onTime ? "A tiempo" : "Tardío"} • ${formatDate(item["date"])}",
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                  ),
                ),

                if ((item["note"] ?? "")
                    .toString()
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    "Nota: ${item["note"]}",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              deletePayment(
                item["id"].toString(),
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTipsCard(
    double utilization,
    int late,
  ) {
    final List<String> tips = [];

    if (utilization > 30) {
      tips.add(
        "Baja tu uso de crédito por debajo del 30% para mejorar tu perfil.",
      );
    } else {
      tips.add(
        "Tu uso de crédito está saludable. Mantenerlo bajo ayuda a tu historial.",
      );
    }

    if (late > 0) {
      tips.add(
        "Evita pagos tardíos. Cada atraso puede afectar tu historial.",
      );
    } else {
      tips.add(
        "No tienes pagos tardíos registrados. Mantén ese hábito.",
      );
    }

    tips.add(
      "Paga antes de la fecha límite y evita usar todo tu límite disponible.",
    );

    tips.add(
      "Revisa tu reporte oficial periódicamente desde el portal de Buró.",
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Consejos para mejorar",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          ...tips.map(
            (tip) => Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.cyanAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.25),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.privacy_tip_rounded,
            color: Colors.redAccent,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            "Privacidad crediticia",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Esta sección calcula un score estimado local. No reemplaza tu reporte oficial. CASH-CONTROL no solicita contraseñas, tarjetas completas, códigos, documentos oficiales ni información crediticia sensible.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
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
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyText(
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }
}