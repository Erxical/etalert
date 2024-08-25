import 'package:flutter/material.dart';
import 'package:frontend/services/data/user/create_user.dart';
import 'package:frontend/services/maps/get_distance_matrix.dart';
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
        final distance = await getDistanceMatrix(
            13.6512522,
            100.4938679,
            13.7457749,
            100.5318268,
            DateTime.parse('2024-08-26 02:30:00Z').toLocal());
        print(distance);
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
