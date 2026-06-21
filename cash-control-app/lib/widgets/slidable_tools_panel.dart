import 'package:flutter/material.dart';

class SlidableToolsPanel extends StatefulWidget {
  final List<Widget> children;

  const SlidableToolsPanel({
    super.key,
    required this.children,
  });

  @override
  State<SlidableToolsPanel> createState() =>
      _SlidableToolsPanelState();
}

class _SlidableToolsPanelState
    extends State<SlidableToolsPanel> {
  bool expanded = true;

  void togglePanel() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (_) {
        togglePanel();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.greenAccent,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    "Herramientas rápidas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: togglePanel,
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              expanded
                  ? "Desliza hacia un lado o toca la flecha para ocultar."
                  : "Desliza hacia un lado o toca la flecha para desplegar.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),

            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                  children: widget.children,
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}