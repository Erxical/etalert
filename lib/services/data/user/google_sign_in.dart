import 'package:flutter/material.dart';
import 'package:frontend/services/data/user/create_user.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInWithGoogle {
  static Future<bool> loginWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? user = await GoogleSignIn(
        scopes: ['email'],
      ).signIn();
      if (user == null) {
        return false;
      }
      final statusCodeRes = await createUser(
          user.id, user.email, user.displayName, user.photoUrl);
      if (statusCodeRes == 208) {
        context.go('/');
      } else {
        context.go('/name/${user.id}');
      }
      GoogleSignInAuthentication userAuth = await user.authentication;
      // print(userAuth.idToken);
      return false;
    } catch (e) {
      return false;
    }
  }
}
