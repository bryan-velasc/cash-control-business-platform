import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart'
    as http;

class ForgotPasswordScreen
    extends StatefulWidget {

  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() =>
          _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController
      emailController =
      TextEditingController();

  bool loading = false;

  String message = "";

  Future<void> sendEmail() async {

    setState(() {

      loading = true;

      message = "";
    });

    try {

      final response =
          await http.post(

        Uri.parse(
          "http://localhost:8000/forgot-password",
        ),

        headers: {

          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "email":
              emailController.text
                  .trim()
        }),
      );

      final data =
          jsonDecode(response.body);

      setState(() {

        loading = false;

        if (response.statusCode ==
            200) {

          message =
              "Correo enviado correctamente";

        } else {

          message =
              data["detail"];
        }
      });

    } catch (e) {

      setState(() {

        loading = false;

        message =
            "Error de conexión";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        title: const Text(
          "Recuperar contraseña",
        ),
      ),

      body: Center(

        child: Container(

          width: 400,

          padding:
              const EdgeInsets.all(30),

          decoration: BoxDecoration(

            color:
                const Color(0xFF111111),

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Icon(

                Icons.lock_reset,

                size: 80,

                color:
                    Color(0xFF10B981),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(

                "Recuperar contraseña",

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,

                  color:
                      Colors.white,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextField(

                controller:
                    emailController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(

                  hintText:
                      "Correo electrónico",

                  hintStyle:
                      TextStyle(
                    color:
                        Colors.grey,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF1A1A1A,
                  ),

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton(

                  onPressed:
                      loading
                          ? null
                          : sendEmail,

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(
                      0xFF10B981,
                    ),
                  ),

                  child:
                      loading

                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )

                          : const Text(

                              "ENVIAR CORREO",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(

                message,

                style: TextStyle(

                  color:
                      message.contains(
                              "correctamente")
                          ? Colors.green

                          : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}