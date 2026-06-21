  import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool loading = false;

  String message = "";

  final String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  Future<void> register() async {

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      setState(() {

        message =
            "Completa todos los campos";
      });

      return;
    }

    setState(() {

      loading = true;

      message = "";
    });

    try {

      final response = await http.post(

        Uri.parse(
          "$baseUrl/register",
        ),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "name":
              nameController.text.trim(),

          "email":
              emailController.text.trim(),

          "password":
              passwordController.text.trim(),
        }),

      ).timeout(
        const Duration(seconds: 10),
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {

        setState(() {

          loading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "Usuario registrado correctamente",
            ),
          ),
        );

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const LoginScreen(),
          ),
        );

      } else {

        setState(() {

          loading = false;

          message =
              data["detail"] ??
              "Error al registrar";
        });
      }

    } catch (e) {

      setState(() {

        loading = false;

        message =
            "Error de conexión: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(30),

          child: Container(

            width: 420,

            padding:
                const EdgeInsets.all(30),

            decoration: BoxDecoration(

              color:
                  const Color(0xFF0C0C0C),

              borderRadius:
                  BorderRadius.circular(25),

              border: Border.all(
                color: Colors.white12,
              ),
            ),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(

                  Icons.account_balance_wallet,

                  size: 90,

                  color: Color(0xFF10B981),
                ),

                const SizedBox(height: 20),

                const Text(

                  "Crear Cuenta",

                  style: TextStyle(

                    fontSize: 32,

                    fontWeight:
                        FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(

                  controller:
                      nameController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(

                    hintText: "Nombre",

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),

                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF10B981),
                    ),

                    filled: true,

                    fillColor:
                        const Color(0xFF151515),

                    border: OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                      emailController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(

                    hintText: "Correo electrónico",

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),

                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF10B981),
                    ),

                    filled: true,

                    fillColor:
                        const Color(0xFF151515),

                    border: OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                      passwordController,

                  obscureText: true,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(

                    hintText: "Contraseña",

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),

                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF10B981),
                    ),

                    filled: true,

                    fillColor:
                        const Color(0xFF151515),

                    border: OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(

                  width: double.infinity,

                  height: 58,

                  child: ElevatedButton(

                    onPressed:
                        loading
                            ? null
                            : register,

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(0xFF10B981),

                      shape: RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),

                    child: loading

                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )

                        : const Text(

                            "REGISTRARSE",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.bold,

                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                if (message.isNotEmpty)

                  Text(

                    message,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),

                const SizedBox(height: 20),

                TextButton(

                  onPressed: () {

                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const LoginScreen(),
                      ),
                    );
                  },

                  child: const Text(

                    "¿Ya tienes cuenta? Inicia sesión",

                    style: TextStyle(
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}