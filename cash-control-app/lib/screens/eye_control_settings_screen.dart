import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/eye_control_provider.dart';

class EyeControlSettingsScreen extends StatelessWidget {
  const EyeControlSettingsScreen({
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
          "Configuración Eye Control",
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildHeader(),

            const SizedBox(height: 20),

            buildPresetCard(
              eye,
            ),

            const SizedBox(height: 20),

            buildSliderCard(
              title: "Sensibilidad horizontal",
              subtitle:
                  "Más alto = menos sensible hacia izquierda y derecha.",
              icon: Icons.swap_horiz_rounded,
              value: eye.horizontalSensitivity,
              min: 6,
              max: 25,
              divisions: 19,
              onChanged: eye.updateHorizontalSensitivity,
            ),

            const SizedBox(height: 20),

            buildSliderCard(
              title: "Sensibilidad vertical",
              subtitle:
                  "Más alto = menos sensible hacia arriba y abajo.",
              icon: Icons.swap_vert_rounded,
              value: eye.verticalSensitivity,
              min: 6,
              max: 25,
              divisions: 19,
              onChanged: eye.updateVerticalSensitivity,
            ),

            const SizedBox(height: 20),

            buildSliderCard(
              title: "Velocidad del puntero",
              subtitle:
                  "Controla qué tan rápido se mueve la mira.",
              icon: Icons.speed_rounded,
              value: eye.cursorSpeed,
              min: 1,
              max: 12,
              divisions: 11,
              onChanged: eye.updateCursorSpeed,
            ),

            const SizedBox(height: 20),

            buildSliderCard(
              title: "Suavizado",
              subtitle:
                  "Más bajo = movimiento más suave y lento. Más alto = responde más rápido.",
              icon: Icons.blur_on_rounded,
              value: eye.smoothing,
              min: 0.05,
              max: 0.40,
              divisions: 35,
              onChanged: eye.updateSmoothing,
            ),

            const SizedBox(height: 20),

            buildSliderCard(
              title: "Cantidad de scroll",
              subtitle:
                  "Controla cuánto sube o baja la pantalla con la mirada.",
              icon: Icons.unfold_more_rounded,
              value: eye.scrollAmount,
              min: 100,
              max: 500,
              divisions: 40,
              onChanged: eye.updateScrollAmount,
            ),

            const SizedBox(height: 20),

            buildSwitchCard(
              title: "Activar parpadeo",
              subtitle:
                  "Un parpadeo abre el panel de acción seguro.",
              icon: Icons.remove_red_eye_rounded,
              value: eye.blinkEnabled,
              onChanged: eye.toggleBlink,
              color: Colors.greenAccent,
            ),

            const SizedBox(height: 20),

            buildSwitchCard(
              title: "Activar doble parpadeo",
              subtitle:
                  "Doble parpadeo intenta regresar a la pantalla anterior.",
              icon: Icons.keyboard_return_rounded,
              value: eye.doubleBlinkEnabled,
              onChanged: eye.toggleDoubleBlink,
              color: Colors.cyanAccent,
            ),

            const SizedBox(height: 20),

            buildSwitchCard(
              title: "Invertir horizontal",
              subtitle:
                  "Actívalo si izquierda y derecha están al revés.",
              icon: Icons.compare_arrows_rounded,
              value: eye.invertHorizontal,
              onChanged: eye.toggleInvertHorizontal,
              color: Colors.orangeAccent,
            ),

            const SizedBox(height: 20),

            buildSwitchCard(
              title: "Invertir vertical",
              subtitle:
                  "Actívalo si arriba y abajo están al revés.",
              icon: Icons.import_export_rounded,
              value: eye.invertVertical,
              onChanged: eye.toggleInvertVertical,
              color: Colors.orangeAccent,
            ),

            const SizedBox(height: 20),

            buildResetCard(
              context,
              eye,
            ),

            const SizedBox(height: 30),

            buildTipsCard(),

            const SizedBox(height: 20),
          ],
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
            Colors.greenAccent,
            Colors.tealAccent,
          ],
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.tune_rounded,
            color: Colors.black,
            size: 62,
          ),
          SizedBox(height: 12),
          Text(
            "Ajustes de precisión",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Personaliza el movimiento, scroll y gestos del modo manos libres.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPresetCard(
    EyeControlProvider eye,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.22),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.dashboard_customize_rounded,
            color: Colors.greenAccent,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            "Perfiles rápidos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: buildPresetButton(
                  title: "Bajo",
                  color: Colors.blueAccent,
                  onTap: eye.setLowSensitivityPreset,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildPresetButton(
                  title: "Medio",
                  color: Colors.greenAccent,
                  onTap: eye.setMediumSensitivityPreset,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildPresetButton(
                  title: "Alto",
                  color: Colors.orangeAccent,
                  onTap: eye.setHighSensitivityPreset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPresetButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildSliderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          Row(
            children: [
              Icon(
                icon,
                color: Colors.greenAccent,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.white12,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildSwitchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: value
              ? color.withOpacity(0.28)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: color,
        secondary: Icon(
          icon,
          color: color,
          size: 34,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            height: 1.4,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildResetCard(
    BuildContext context,
    EyeControlProvider eye,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restart_alt_rounded,
            color: Colors.redAccent,
            size: 42,
          ),

          const SizedBox(height: 12),

          const Text(
            "Restablecer configuración",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Vuelve a los valores recomendados si el puntero se siente extraño o difícil de controlar.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              eye.resetSettings();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Configuración de Eye Control restablecida",
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.restore_rounded,
            ),
            label: const Text(
              "Restablecer valores",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
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

  Widget buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.25),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: Colors.orangeAccent,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            "Consejo de ajuste",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Si el puntero se dispara, usa perfil Bajo.\n"
            "Si no responde, usa perfil Alto.\n"
            "Si los movimientos están invertidos, activa invertir horizontal o vertical.\n"
            "Si hay parpadeos accidentales, desactiva parpadeo o doble parpadeo.",
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