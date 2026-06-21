import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/sat_local_service.dart';

class SatScreen extends StatefulWidget {
  const SatScreen({
    super.key,
  });

  @override
  State<SatScreen> createState() => _SatScreenState();
}

class _SatScreenState extends State<SatScreen> {
  bool loading = true;

  List<Map<String, dynamic>> obligations = [];
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    loadSatData();
  }

  Future<void> loadSatData() async {
    final loadedObligations =
        await SatLocalService.getObligations();

    final loadedInvoices =
        await SatLocalService.getInvoices();

    if (!mounted) return;

    setState(() {
      obligations = loadedObligations;
      invoices = loadedInvoices;
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
    final date = parseDate(value);

    return DateFormat("dd/MM/yyyy").format(date);
  }

  int getPendingObligations() {
    return obligations.where(
      (item) {
        return item["status"] != "Completada";
      },
    ).length;
  }

  Future<void> showAddObligationDialog() async {
    final titleController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    DateTime selectedDate =
        DateTime.now().add(
      const Duration(days: 7),
    );

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
                "Nueva obligación fiscal",
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
                      controller: titleController,
                      label: "Título",
                      hint: "Ejemplo: Declaración mensual",
                    ),
                    const SizedBox(height: 12),
                    buildDialogField(
                      controller: descriptionController,
                      label: "Descripción",
                      hint: "Ejemplo: IVA / ISR del mes",
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
                            color: Colors.cyanAccent
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.cyanAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Fecha límite: ${DateFormat("dd/MM/yyyy").format(selectedDate)}",
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
                    final title =
                        titleController.text.trim();

                    if (title.isEmpty) {
                      return;
                    }

                    await SatLocalService.addObligation(
                      title: title,
                      description:
                          descriptionController.text,
                      dueDate: selectedDate,
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    await loadSatData();
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

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> showAddInvoiceDialog() async {
    final folioController =
        TextEditingController();

    final issuerController =
        TextEditingController();

    final conceptController =
        TextEditingController();

    final amountController =
        TextEditingController();

    DateTime selectedDate = DateTime.now();
    String selectedType = "Recibida";

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
                "Registrar CFDI manual",
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
                      controller: folioController,
                      label: "Folio / UUID",
                      hint: "Ejemplo: ABCD-1234",
                    ),
                    const SizedBox(height: 12),
                    buildDialogField(
                      controller: issuerController,
                      label: "Emisor / Receptor",
                      hint: "Ejemplo: Cliente o proveedor",
                    ),
                    const SizedBox(height: 12),
                    buildDialogField(
                      controller: conceptController,
                      label: "Concepto",
                      hint: "Ejemplo: Compra de material",
                    ),
                    const SizedBox(height: 12),
                    buildDialogField(
                      controller: amountController,
                      label: "Monto",
                      hint: "Ejemplo: 1500",
                      keyboardType:
                          TextInputType.number,
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
                          value: "Recibida",
                          child: Text("Recibida"),
                        ),
                        DropdownMenuItem(
                          value: "Emitida",
                          child: Text("Emitida"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
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
                            color: Colors.orangeAccent
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Fecha CFDI: ${DateFormat("dd/MM/yyyy").format(selectedDate)}",
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
                    final amount =
                        double.tryParse(
                              amountController.text
                                  .trim(),
                            ) ??
                            0;

                    if (folioController.text
                            .trim()
                            .isEmpty ||
                        amount <= 0) {
                      return;
                    }

                    await SatLocalService.addInvoice(
                      folio: folioController.text,
                      issuer: issuerController.text,
                      concept: conceptController.text,
                      amount: amount,
                      date: selectedDate,
                      type: selectedType,
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    await loadSatData();
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

    folioController.dispose();
    issuerController.dispose();
    conceptController.dispose();
    amountController.dispose();
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
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Future<void> toggleObligationStatus(
    Map<String, dynamic> item,
  ) async {
    final currentStatus =
        item["status"]?.toString() ?? "Pendiente";

    final nextStatus = currentStatus == "Completada"
        ? "Pendiente"
        : "Completada";

    await SatLocalService.updateObligationStatus(
      id: item["id"].toString(),
      status: nextStatus,
    );

    await loadSatData();
  }

  Future<void> deleteObligation(
    String id,
  ) async {
    await SatLocalService.deleteObligation(
      id,
    );

    await loadSatData();
  }

  Future<void> deleteInvoice(
    String id,
  ) async {
    await SatLocalService.deleteInvoice(
      id,
    );

    await loadSatData();
  }

  @override
  Widget build(BuildContext context) {
    final totalInvoices =
        SatLocalService.getTotalInvoicesAmount(
      invoices,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SAT"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Actualizar",
            onPressed: loadSatData,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        onPressed: showAddObligationDialog,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          "Obligación",
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadSatData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    buildHeader(),

                    const SizedBox(height: 22),

                    buildSummaryCard(
                      totalInvoices,
                    ),

                    const SizedBox(height: 22),

                    buildOfficialLinksCard(),

                    const SizedBox(height: 22),

                    buildQuickActionsCard(),

                    const SizedBox(height: 22),

                    buildObligationsCard(),

                    const SizedBox(height: 22),

                    buildInvoicesCard(),

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
            Colors.cyanAccent,
            Colors.blueAccent,
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_rounded,
            color: Colors.black,
            size: 48,
          ),
          SizedBox(height: 14),
          Text(
            "Centro SAT",
            style: TextStyle(
              color: Colors.black,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Organiza obligaciones fiscales, facturas CFDI y accesos oficiales sin guardar contraseñas sensibles.",
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

  Widget buildSummaryCard(
    double totalInvoices,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          const Text(
            "Resumen fiscal local",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          infoRow(
            "Obligaciones",
            obligations.length.toString(),
            Colors.white,
          ),
          infoRow(
            "Pendientes",
            getPendingObligations().toString(),
            Colors.orangeAccent,
          ),
          infoRow(
            "CFDI registrados",
            invoices.length.toString(),
            Colors.white,
          ),
          infoRow(
            "Monto CFDI",
            "\$${totalInvoices.toStringAsFixed(2)}",
            Colors.greenAccent,
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
            title: "Portal del SAT",
            subtitle: "Abrir sitio oficial",
            icon: Icons.open_in_new_rounded,
            onTap: () {
              openUrl(
                "https://www.sat.gob.mx/",
              );
            },
          ),
          officialLinkButton(
            title: "Buzón tributario",
            subtitle: "Abrir acceso oficial",
            icon: Icons.mark_email_read_rounded,
            onTap: () {
              openUrl(
                "https://www.sat.gob.mx/personas/buzon-tributario",
              );
            },
          ),
          officialLinkButton(
            title: "Factura electrónica",
            subtitle: "Información oficial CFDI",
            icon: Icons.receipt_long_rounded,
            onTap: () {
              openUrl(
                "https://www.sat.gob.mx/personas/factura-electronica",
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
            title: "Agregar CFDI",
            icon: Icons.receipt_long_rounded,
            color: Colors.orangeAccent,
            onTap: showAddInvoiceDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: actionButton(
            title: "Obligación",
            icon: Icons.event_note_rounded,
            color: Colors.cyanAccent,
            onTap: showAddObligationDialog,
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

  Widget buildObligationsCard() {
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
            "Obligaciones fiscales",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (obligations.isEmpty)
            emptyText(
              "No tienes obligaciones registradas.",
            )
          else
            ...obligations.map(
              (item) => obligationItem(
                item,
              ),
            ),
        ],
      ),
    );
  }

  Widget obligationItem(
    Map<String, dynamic> item,
  ) {
    final status =
        item["status"]?.toString() ?? "Pendiente";

    final completed =
        status == "Completada";

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? Colors.greenAccent.withOpacity(0.25)
              : Colors.orangeAccent.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            color: completed
                ? Colors.greenAccent
                : Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"]?.toString() ??
                      "Obligación fiscal",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["description"]?.toString() ??
                      "",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Fecha límite: ${formatDate(item["due_date"])}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  toggleObligationStatus(
                    item,
                  );
                },
                icon: Icon(
                  completed
                      ? Icons.undo_rounded
                      : Icons.check_rounded,
                  color: completed
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                ),
              ),
              IconButton(
                onPressed: () {
                  deleteObligation(
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
        ],
      ),
    );
  }

  Widget buildInvoicesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "CFDI registrados",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (invoices.isEmpty)
            emptyText(
              "No tienes CFDI registrados manualmente.",
            )
          else
            ...invoices.map(
              (item) => invoiceItem(
                item,
              ),
            ),
        ],
      ),
    );
  }

  Widget invoiceItem(
    Map<String, dynamic> item,
  ) {
    final amount =
        parseDouble(item["amount"]);

    final type =
        item["type"]?.toString() ?? "Recibida";

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item["concept"]?.toString() ??
                      "CFDI",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Folio: ${item["folio"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Emisor/Receptor: ${item["issuer"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Tipo: $type • Fecha: ${formatDate(item["date"])}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                "\$${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  deleteInvoice(
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
            Icons.security_rounded,
            color: Colors.redAccent,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            "Protección fiscal",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "CASH-CONTROL no solicita ni guarda contraseña del SAT, e.firma, llave privada, CIEC ni credenciales fiscales. Usa esta sección solo para organización local y accesos oficiales.",
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