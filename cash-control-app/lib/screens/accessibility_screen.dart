import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/eye_control_provider.dart';
import '../services/eye_control_service.dart';

import 'eye_control_settings_screen.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final eye = Provider.of<EyeControlProvider>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Centro de Accesibilidad",
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

            const SizedBox(height: 25),

            buildEyeControlSwitch(
              eye,
            ),

            const SizedBox(height: 20),

            buildRecalibrationCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildSettingsCard(
              context,
            ),

            const SizedBox(height: 20),

            buildDirectionCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildInstructionsCard(),

            const SizedBox(height: 20),

            buildImportantCard(),
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
        borderRadius: BorderRadius.circular(
          30,
        ),
        gradient: const LinearGradient(
          colors: [
            Colors.greenAccent,
            Colors.tealAccent,
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.accessibility_new_rounded,
            color: Colors.black,
            size: 60,
          ),

          const SizedBox(height: 12),

          const Text(
            "Eye Control Pro",
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
              color: Colors.black.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                18,
              ),
            ),
            child: Text(
              eye.enabled
                  ? eye.calibrated
                      ? "Estado: Activo y calibrado"
                      : "Estado: Activado, calibrando"
                  : "Estado: Apagado",
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

  Widget buildEyeControlSwitch(
    EyeControlProvider eye,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: eye.enabled
              ? Colors.greenAccent.withOpacity(
                  0.35,
                )
              : Colors.white.withOpacity(
                  0.08,
                ),
        ),
      ),
      child: SwitchListTile(
        value: eye.enabled,
        activeColor: Colors.greenAccent,
        title: const Text(
          "Activar Eye Control",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          eye.enabled
              ? "Puntero global visible en toda la app"
              : "Activa control por rostro, mirada y parpadeos",
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        onChanged: (value) async {
          if (value) {
            await EyeControlService.instance.initialize(
              eye,
            );
          } else {
            eye.disable();

            await EyeControlService.instance.dispose();
          }
        },
      ),
    );
  }

  Widget buildRecalibrationCard(
    EyeControlProvider eye,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.center_focus_strong_rounded,
            color: Colors.cyanAccent,
            size: 40,
          ),

          const SizedBox(height: 12),

          const Text(
            "Recalibración",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Úsala si el puntero se mueve al revés, se mueve solo o pierde precisión.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () async {
              await EyeControlService.instance.dispose();

              await EyeControlService.instance.initialize(
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.tune_rounded,
            color: Colors.greenAccent,
            size: 42,
          ),

          const SizedBox(height: 12),

          const Text(
            "Configurar Eye Control",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Ajusta sensibilidad, velocidad, scroll, parpadeos e inversión de ejes.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const EyeControlSettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_rounded,
            ),
            label: const Text(
              "Abrir configuración",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDirectionCard(
    EyeControlProvider eye,
  ) {
    Color color = Colors.greenAccent;

    if (!eye.calibrated && eye.enabled) {
      color = Colors.orangeAccent;
    }

    if (!eye.enabled) {
      color = Colors.white54;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.visibility_rounded,
            color: color,
            size: 40,
          ),

          const SizedBox(height: 12),

          Text(
            "Dirección actual",
            style: TextStyle(
              color: Colors.white.withOpacity(
                0.7,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            eye.direction,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Cursor: ${eye.cursorPosition.dx.toStringAsFixed(0)}, ${eye.cursorPosition.dy.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(
            0.18,
          ),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.gamepad_rounded,
            color: Colors.greenAccent,
            size: 40,
          ),

          SizedBox(height: 12),

          Text(
            "Controles disponibles",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "• Mira izquierda/derecha para mover el puntero\n"
            "• Mira arriba/abajo para mover y hacer scroll\n"
            "• Un parpadeo abre el panel de acción seguro\n"
            "• Doble parpadeo intenta regresar\n"
            "• El puntero aparece encima de todas las pantallas",
            style: TextStyle(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImportantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(
            0.25,
          ),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orangeAccent,
            size: 40,
          ),

          SizedBox(height: 12),

          Text(
            "Importante",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "Este sistema usa detección facial y parpadeos con ML Kit. "
            "Para mejor precisión usa buena iluminación, cámara frontal limpia "
            "y mantén el celular estable.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}