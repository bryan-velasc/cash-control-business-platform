import 'package:flutter/material.dart';

import '../services/security_service.dart';

class SecurityShieldScreen extends StatefulWidget {
  final String email;
  final String? initialContent;

  const SecurityShieldScreen({
    super.key,
    required this.email,
    this.initialContent,
  });

  @override
  State<SecurityShieldScreen> createState() =>
      _SecurityShieldScreenState();
}

class _SecurityShieldScreenState
    extends State<SecurityShieldScreen> {
  final TextEditingController contentController =
      TextEditingController();

  bool isAnalyzing = false;
  bool isLoadingLogs = true;

  Map<String, dynamic>? result;

  List logs = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialContent != null &&
        widget.initialContent!.trim().isNotEmpty) {
      contentController.text = widget.initialContent!;

      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          analyzeContent(
            source: "shared",
          );
        },
      );
    }

    loadLogs();
  }

  Future<void> loadLogs() async {
    if (widget.email.trim().isEmpty) {
      setState(() {
        isLoadingLogs = false;
      });
      return;
    }

    setState(() {
      isLoadingLogs = true;
    });

    try {
      final data = await SecurityService.getLogs(
        widget.email,
      );

      setState(() {
        logs = data;
        isLoadingLogs = false;
      });
    } catch (e) {
      print("ERROR SECURITY LOGS:");
      print(e);

      setState(() {
        isLoadingLogs = false;
      });
    }
  }

  Future<void> analyzeContent({
    String source = "manual",
  }) async {
    final content = contentController.text.trim();

    if (content.isEmpty) {
      showMessage(
        "Pega un SMS, correo, link o mensaje sospechoso",
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
      result = null;
    });

    try {
      final data = await SecurityService.analyzeContent(
        email: widget.email,
        content: content,
        source: source,
      );

      setState(() {
        result = data;
        isAnalyzing = false;
      });

      await loadLogs();
    } catch (e) {
      setState(() {
        isAnalyzing = false;
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

  Color getRiskColor(
    String risk,
  ) {
    if (risk == "alto") {
      return Colors.redAccent;
    }

    if (risk == "medio") {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  IconData getRiskIcon(
    String risk,
  ) {
    if (risk == "alto") {
      return Icons.dangerous;
    }

    if (risk == "medio") {
      return Icons.warning_amber;
    }

    return Icons.verified_user;
  }

  Widget buildAnalyzerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.greenAccent,
                size: 34,
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  "Cash-Control Security Shield",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            widget.initialContent != null
                ? "Texto recibido desde otra app. Puedes analizarlo o editarlo antes."
                : "Pega aquí un SMS, correo, link o mensaje sospechoso para detectar phishing, fraude o enlaces maliciosos.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 14,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: contentController,
            minLines: 5,
            maxLines: 8,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText:
                  "Ej. Tu cuenta BBVA será bloqueada. Verifica aquí: http://...",
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
              ),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isAnalyzing
                      ? null
                      : () {
                          analyzeContent();
                        },
                  icon: isAnalyzing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.shield),
                  label: Text(
                    isAnalyzing
                        ? "Analizando..."
                        : "Analizar amenaza",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: "Limpiar",
                onPressed: isAnalyzing
                    ? null
                    : () {
                        contentController.clear();

                        setState(() {
                          result = null;
                        });
                      },
                icon: const Icon(
                  Icons.cleaning_services,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResultCard() {
    if (result == null) {
      return const SizedBox();
    }

    final risk = result?["risk"]?.toString() ?? "bajo";

    final score =
        double.tryParse(result?["score"].toString() ?? "0") ?? 0;

    final recommendation =
        result?["recommendation"]?.toString() ?? "";

    final threats = result?["threats"];

    final color = getRiskColor(risk);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
            color: color.withOpacity(0.25),
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
              Icon(
                getRiskIcon(risk),
                color: Colors.black,
                size: 42,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Riesgo ${risk.toUpperCase()}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "Score de amenaza: ${score.toStringAsFixed(0)}/100",
            style: TextStyle(
              color: Colors.black.withOpacity(0.78),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              minHeight: 15,
              backgroundColor: Colors.black.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            recommendation,
            style: TextStyle(
              color: Colors.black.withOpacity(0.82),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (threats is List && threats.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              "Señales detectadas:",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...threats.map(
              (item) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 6,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.report,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.78),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget buildLogCard(
    dynamic log,
  ) {
    final risk = log["risk"]?.toString() ?? "bajo";

    final score =
        double.tryParse(log["score"].toString()) ?? 0;

    final createdAt =
        log["created_at"]?.toString() ?? "";

    final content =
        log["content"]?.toString() ?? "";

    final color = getRiskColor(risk);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            getRiskIcon(risk),
            color: color,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Riesgo ${risk.toUpperCase()} • ${score.toStringAsFixed(0)}/100",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  createdAt,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.38),
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

  Widget buildLogsSection() {
    if (widget.email.trim().isEmpty) {
      return Text(
        "Inicia sesión para guardar historial de análisis.",
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Historial de análisis",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        if (isLoadingLogs)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (logs.isEmpty)
          Text(
            "Aún no tienes análisis guardados.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          )
        else
          ...logs.reversed.map(
            (log) => buildLogCard(log),
          ),
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
        title: const Text("Security Shield"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: loadLogs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadLogs,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              buildAnalyzerCard(),

              const SizedBox(height: 22),

              buildResultCard(),

              const SizedBox(height: 26),

              buildLogsSection(),
            ],
          ),
        ),
      ),
    );
  }
}