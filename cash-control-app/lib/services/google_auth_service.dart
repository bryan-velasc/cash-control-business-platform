import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

class GoogleAuthService {

  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<UserCredential?>
      signInWithGoogle() async {

    try {

      final GoogleSignInAccount?
          googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {

        print(
          "GOOGLE USER NULL",
        );

        return null;
      }

      final GoogleSignInAuthentication
          googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(

        accessToken:
            googleAuth.accessToken,

        idToken:
            googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance
              .signInWithCredential(
        credential,
      );

      print(
        "GOOGLE FIREBASE LOGIN OK",
      );

      final response = await http.post(

        Uri.parse(
          "$baseUrl/google-login",
        ),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "email":
              userCredential
                  .user!
                  .email,

          "name":
              userCredential
                      .user!
                      .displayName ??
                  "Google User",
        }),

      );

      print(
        "BACKEND RESPONSE:",
      );

      print(response.body);

      if (response.statusCode ==
          200) {

        return userCredential;

      } else {

        print(
          "ERROR BACKEND GOOGLE LOGIN",
        );

        return null;
      }

    } catch (e) {

      print(
        "ERROR GOOGLE LOGIN SERVICE:",
      );

      print(e);

      return null;
    }
  }
}