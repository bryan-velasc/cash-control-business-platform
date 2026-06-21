import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

import '../services/google_auth_service.dart';

import 'dashboard_screen.dart';

import 'register_screen.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  String message = "";

  bool loading = false;

  bool obscurePassword = true;

  Future<void> login() async {

    setState(() {

      loading = true;

      message = "";
    });

    try {

      final response =
          await AuthService.login(

        emailController.text.trim(),

        passwordController.text.trim(),
      );

      setState(() {

        loading = false;
      });

      if (response["token"] != null) {

        final prefs =
            await SharedPreferences
                .getInstance();

        await prefs.setString(

          "user_email",

          emailController.text.trim(),
        );

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                DashboardScreen(

              email:
                  emailController.text
                      .trim(),
            ),
          ),
        );

      } else {

        setState(() {

          message =
              response["detail"] ??
              "Credenciales incorrectas";
        });
      }

    } catch (e) {

      setState(() {

        loading = false;

        message =
            "Error de conexión";
      });
    }
  }

  Future<void>
      loginWithGoogle() async {

    try {

      final user =
          await GoogleAuthService
              .signInWithGoogle();

      if (user != null) {

        final prefs =
            await SharedPreferences
                .getInstance();

        await prefs.setString(

          "user_email",

          user.user!.email!,
        );

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                DashboardScreen(

              email:
                  user.user!.email!,
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {

        message =
            "Error con Google";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: Center(

        child:
            SingleChildScrollView(

          padding:
              const EdgeInsets.all(
            25,
          ),

          child: Container(

            width: 420,

            padding:
                const EdgeInsets.all(
              30,
            ),

            decoration: BoxDecoration(

              color:
                  const Color(
                0xFF0C0C0C,
              ),

              borderRadius:
                  BorderRadius.circular(
                25,
              ),

              border: Border.all(
                color:
                    Colors.white12,
              ),

              boxShadow: [

                BoxShadow(

                  color:
                      Colors.green
                          .withOpacity(
                    0.15,
                  ),

                  blurRadius: 30,

                  spreadRadius: 5,
                ),
              ],
            ),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(

                  Icons
                      .account_balance_wallet,

                  size: 90,

                  color:
                      Color(
                    0xFF10B981,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(

                  "CASH-CONTROL",

                  style: TextStyle(

                    fontSize: 32,

                    fontWeight:
                        FontWeight
                            .bold,

                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(

                  "Bienvenido de nuevo",

                  style: TextStyle(

                    color:
                        Colors.grey
                            .shade400,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                TextField(

                  controller:
                      emailController,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),

                  decoration:
                      InputDecoration(

                    hintText:
                        "Correo electrónico",

                    hintStyle:
                        TextStyle(
                      color:
                          Colors.grey
                              .shade500,
                    ),

                    prefixIcon:
                        const Icon(

                      Icons.email,

                      color:
                          Color(
                        0xFF10B981,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        const Color(
                      0xFF151515,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextField(

                  controller:
                      passwordController,

                  obscureText:
                      obscurePassword,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),

                  decoration:
                      InputDecoration(

                    hintText:
                        "Contraseña",

                    hintStyle:
                        TextStyle(
                      color:
                          Colors.grey
                              .shade500,
                    ),

                    prefixIcon:
                        const Icon(

                      Icons.lock,

                      color:
                          Color(
                        0xFF10B981,
                      ),
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(

                        obscurePassword

                            ? Icons
                                .visibility

                            : Icons
                                .visibility_off,

                        color:
                            Colors.grey,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        const Color(
                      0xFF151515,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                Align(

                  alignment:
                      Alignment
                          .centerRight,

                  child: TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const ForgotPasswordScreen(),
                        ),
                      );
                    },

                    child: const Text(

                      "¿Olvidaste tu contraseña?",

                      style: TextStyle(

                        color:
                            Color(
                          0xFF10B981,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(

                  width:
                      double.infinity,

                  height: 58,

                  child:
                      ElevatedButton(

                    onPressed:
                        loading
                            ? null
                            : login,

                    style:
                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          const Color(
                        0xFF10B981,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    child:
                        loading

                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )

                            : const Text(

                                "INICIAR SESIÓN",

                                style:
                                    TextStyle(

                                  color:
                                      Colors.white,

                                  fontSize:
                                      16,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(

                  width:
                      double.infinity,

                  height: 58,

                  child:
                      ElevatedButton.icon(

                    onPressed:
                        loginWithGoogle,

                    icon:
                        Image.network(

                      "https://cdn-icons-png.flaticon.com/512/281/281764.png",

                      height: 24,
                    ),

                    label:
                        const Text(

                      "Continuar con Google",

                      style: TextStyle(
                        color:
                            Colors.black,
                      ),
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                if (message.isNotEmpty)

                  Text(

                    message,

                    style:
                        const TextStyle(

                      color:
                          Colors.redAccent,
                    ),
                  ),

                const SizedBox(
                  height: 20,
                ),

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    Text(

                      "¿No tienes cuenta?",

                      style: TextStyle(

                        color:
                            Colors.grey
                                .shade400,
                      ),
                    ),

                    TextButton(

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const RegisterScreen(),
                          ),
                        );
                      },

                      child:
                          const Text(

                        "Registrarse",

                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF10B981,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}