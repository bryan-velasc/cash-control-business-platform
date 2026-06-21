import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/eye_control_provider.dart';
import '../services/eye_control_service.dart';

class EyeControlScreen extends StatefulWidget {
  final String email;

  const EyeControlScreen({
    super.key,
    required this.email,
  });

  @override
  State<EyeControlScreen> createState() =>
      _EyeControlScreenState();
}

class _EyeControlScreenState extends State<EyeControlScreen> {
  bool loadingAction = false;

  Future<void> startEyeControl(
    EyeControlProvider eye,
  ) async {
    if (loadingAction) return;

    setState(() {
      loadingAction = true;
    });

    await EyeControlService.instance.initialize(
      eye,
    );

    if (!mounted) return;

    setState(() {
      loadingAction = false;
    });
  }

  Future<void> stopEyeControl(
    EyeControlProvider eye,
  ) async {
    if (loadingAction) return;

    setState(() {
      loadingAction = true;
    });

    eye.disable();

    await EyeControlService.instance.dispose();

    if (!mounted) return;

    setState(() {
      loadingAction = false;
    });
  }

  Future<void> recalibrateEyeControl(
    EyeControlProvider eye,
  ) async {
    if (loadingAction) return;

    setState(() {
      loadingAction = true;
    });

    await EyeControlService.instance.dispose();

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    await EyeControlService.instance.initialize(
      eye,
    );

    if (!mounted) return;

    setState(() {
      loadingAction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eye =
        Provider.of<EyeControlProvider>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Eye Control Pro",
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildHeaderCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildCameraPreviewCard(),

            const SizedBox(height: 20),

            buildStatusCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildControlsCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildSensitivityCard(),

            const SizedBox(height: 20),

            buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderCard(
    EyeControlProvider eye,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: eye.enabled
              ? [
                  Colors.greenAccent,
                  Colors.tealAccent,
                ]
              : [
                  Colors.white24,
                  Colors.white10,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            eye.enabled
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: Colors.black,
            size: 62,
          ),
          const SizedBox(height: 12),
          const Text(
            "Control por Mirada",
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eye.status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              eye.enabled
                  ? eye.calibrated
                      ? "Activo y calibrado"
                      : "Activo, esperando calibración"
                  : "Sistema apagado",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCameraPreviewCard() {
    final service =
        EyeControlService.instance;

    final controller =
        service.cameraController;

    final ready = controller != null &&
        controller.value.isInitialized;

    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: ready
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.55,
                    child: CameraPreview(
                      controller,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.center_focus_strong_rounded,
                      color: Colors.greenAccent,
                      size: 70,
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.black,
                child: const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_rounded,
                      color: Colors.white38,
                      size: 60,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Cámara inactiva",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildStatusCard(
    EyeControlProvider eye,
  ) {
    Color color = Colors.white54;

    if (eye.enabled && !eye.calibrated) {
      color = Colors.orangeAccent;
    }

    if (eye.enabled && eye.calibrated) {
      color = Colors.greenAccent;
    }

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
        children: [
          Icon(
            Icons.track_changes_rounded,
            color: color,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            "Estado del puntero",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          infoRow(
            "Dirección",
            eye.direction,
            color,
          ),
          infoRow(
            "Cursor X",
            eye.cursorPosition.dx.toStringAsFixed(0),
            color,
          ),
          infoRow(
            "Cursor Y",
            eye.cursorPosition.dy.toStringAsFixed(0),
            color,
          ),
          infoRow(
            "Pantalla",
            "${eye.screenSize.width.toStringAsFixed(0)} x ${eye.screenSize.height.toStringAsFixed(0)}",
            color,
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
                color: Colors.white54,
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

  Widget buildControlsCard(
    EyeControlProvider eye,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.20),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.settings_accessibility_rounded,
            color: Colors.cyanAccent,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            "Controles",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          SwitchListTile(
            value: eye.enabled,
            activeColor: Colors.greenAccent,
            title: const Text(
              "Activar Eye Control",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Muestra la mira global encima de toda la app.",
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
            onChanged: loadingAction
                ? null
                : (value) async {
                    if (value) {
                      await startEyeControl(
                        eye,
                      );
                    } else {
                      await stopEyeControl(
                        eye,
                      );
                    }
                  },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: loadingAction
                      ? null
                      : () async {
                          await recalibrateEyeControl(
                            eye,
                          );
                        },
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    "Recalibrar",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: loadingAction
                      ? null
                      : () async {
                          await stopEyeControl(
                            eye,
                          );
                        },
                  icon: const Icon(
                    Icons.power_settings_new_rounded,
                  ),
                  label: const Text(
                    "Apagar",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (loadingAction) ...[
            const SizedBox(height: 18),
            const LinearProgressIndicator(
              color: Colors.greenAccent,
              backgroundColor: Colors.white12,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSensitivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.20),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.tune_rounded,
            color: Colors.orangeAccent,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            "Sensibilidad recomendada",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "El sistema ya fue ajustado para evitar movimientos bruscos:\n\n"
            "• Zona muerta más amplia\n"
            "• Velocidad reducida\n"
            "• Filtro de suavizado\n"
            "• Menos scroll accidental\n"
            "• Menos parpadeos falsos",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.20),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.greenAccent,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            "Cómo usarlo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "1. Activa Eye Control.\n"
            "2. Mira al centro mientras calibra.\n"
            "3. La mira aparecerá sobre toda la app.\n"
            "4. Mueve la cabeza muy lentamente.\n"
            "5. Mira arriba o abajo para hacer scroll.\n"
            "6. Un parpadeo abre el panel seguro.\n"
            "7. Doble parpadeo intenta regresar.\n\n"
            "Recomendación: usa buena luz y mantén el celular estable.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}