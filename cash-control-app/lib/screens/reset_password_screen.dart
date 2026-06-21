import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart'
    as http;

class ResetPasswordScreen
    extends StatefulWidget {

  final String token;

  const ResetPasswordScreen({

    super.key,

    required this.token,
  });

  @override
  State<ResetPasswordScreen>
      createState() =>
          _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<
        ResetPasswordScreen> {

  final passwordController =
      TextEditingController();

  String message = "";

  bool loading = false;

  Future<void>
      resetPassword() async {

    setState(() {

      loading = true;
    });

    final response = await http.post(

      Uri.parse(
        "http://127.0.0.1:8000/reset-password",
      ),

      headers: {

        "Content-Type":
            "application/json"
      },

      body: jsonEncode({

        "token":
            widget.token,

        "password":
            passwordController.text
      }),
    );

    final data =
        jsonDecode(response.body);

    setState(() {

      loading = false;

      message =
          data["message"] ??
          data["detail"];
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: Center(

        child: Container(

          width: 400,

          padding:
              const EdgeInsets.all(
            30,
          ),

          decoration: BoxDecoration(

            color:
                const Color(
              0xFF111111,
            ),

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Text(

                "Nueva contraseña",

                style: TextStyle(

                  color:
                      Colors.white,

                  fontSize: 28,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextField(

                controller:
                    passwordController,

                obscureText: true,

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),

                decoration:
                    const InputDecoration(

                  hintText:
                      "Nueva contraseña",
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed:
                      loading
                          ? null
                          : resetPassword,

                  child:
                      loading

                          ? const CircularProgressIndicator()

                          : const Text(
                              "CAMBIAR CONTRASEÑA",
                            ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(

                message,

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}