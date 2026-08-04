import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  /// Google Signin
  Future<UserCredential?> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('\nCANCELLED LOGIN');
      // Dialogs.showSnackbar(context, 'Something went wrong! Try again...');
      return null;
    }
  }

  //signout
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await GoogleSignIn.instance.disconnect();
  }

  
}