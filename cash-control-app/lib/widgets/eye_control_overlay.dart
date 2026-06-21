import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/eye_control_provider.dart';

class EyeControlOverlay extends StatelessWidget {
  final Widget child;

  const EyeControlOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EyeControlProvider>(
      builder: (context, eye, _) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            eye.setScreenSize(
              MediaQuery.of(context).size,
            );

            if (eye.backRequested) {
              eye.clearBack();

              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        );

        return Stack(
          children: [
            child,

            if (eye.enabled)
              Positioned(
                left: eye.cursorPosition.dx - 28,
                top: eye.cursorPosition.dy - 28,
                child: IgnorePointer(
                  child: GamerEyeCursor(
                    active: eye.calibrated,
                  ),
                ),
              ),

            if (eye.enabled)
              Positioned(
                top: 55,
                right: 15,
                child: IgnorePointer(
                  child: EyeStatusBadge(
                    status: eye.status,
                    direction: eye.direction,
                    calibrated: eye.calibrated,
                  ),
                ),
              ),

            if (eye.enabled && eye.actionPanelOpen)
              Positioned(
                left: 20,
                right: 20,
                bottom: 40,
                child: EyeActionPanel(
                  onClose: () {
                    eye.closeActionPanel();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class GamerEyeCursor extends StatelessWidget {
  final bool active;

  const GamerEyeCursor({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? Colors.greenAccent : Colors.orangeAccent;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.10),
              border: Border.all(
                color: color.withOpacity(0.80),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.55),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.35),
                width: 1,
              ),
            ),
          ),

          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color.withOpacity(0.95),
              shape: BoxShape.circle,
            ),
          ),

          Positioned(
            top: 0,
            child: Container(
              width: 2,
              height: 18,
              color: color.withOpacity(0.9),
            ),
          ),

          Positioned(
            bottom: 0,
            child: Container(
              width: 2,
              height: 18,
              color: color.withOpacity(0.9),
            ),
          ),

          Positioned(
            left: 0,
            child: Container(
              width: 18,
              height: 2,
              color: color.withOpacity(0.9),
            ),
          ),

          Positioned(
            right: 0,
            child: Container(
              width: 18,
              height: 2,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class EyeStatusBadge extends StatelessWidget {
  final String status;
  final String direction;
  final bool calibrated;

  const EyeStatusBadge({
    super.key,
    required this.status,
    required this.direction,
    required this.calibrated,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 190,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: calibrated
                ? Colors.greenAccent.withOpacity(0.45)
                : Colors.orangeAccent.withOpacity(0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Dirección: $direction",
              style: TextStyle(
                color: calibrated
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EyeActionPanel extends StatelessWidget {
  final VoidCallback onClose;

  const EyeActionPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.92),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.18),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.greenAccent,
              size: 42,
            ),
            const SizedBox(height: 10),
            const Text(
              "Parpadeo detectado",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Acción segura activada.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onClose,
              icon: const Icon(
                Icons.check_circle_rounded,
              ),
              label: const Text("Entendido"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}