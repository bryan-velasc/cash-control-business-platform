import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  static final Uri academyUrl = Uri.parse(
    "https://my.coursebox.ai/courses/019e0e54-71de-7111-908a-b74bc0fdab64/about",
  );

  Future<void> openAcademy() async {
    await launchUrl(
      academyUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Cash-Control Academy"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_rounded,
                size: 90,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                "Cash-Control Academy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Aprende finanzas, ahorro, negocios e inteligencia financiera.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: openAcademy,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text("Entrar a la Academia"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}