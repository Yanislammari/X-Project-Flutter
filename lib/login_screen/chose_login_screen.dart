
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';

import '../l10n/generated/app_localizations.dart';
import '../on_board_screen/onboarding_description_screen.dart';
import 'login_email_passwd_screen.dart';

class Login extends StatefulWidget {
  static const String routeName = '/';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginScreen_title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            spacing: 30,
            children: [
              GestureDetector(
                onTap: ()=> LoginEmailPasswdScreen.navigateTo(context),
                child: Text(
                  loc.loginScreen_buttonConnectWithEmail,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              GestureDetector(
                onTap:()=>login(signInWithGoogle),
                child: Text(
                  loc.loginScreen_labelConnectWithGoogle,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              /*Text(
                loc.loginScreen_labelConnectWithGitHub,
                style: Theme.of(context).textTheme.labelSmall,
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<bool> checkIfUidExists(String? uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uuid_user', isEqualTo: uid)
        .limit(1) // optional: only need to know if exists
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void login(Future<UserCredential?> Function() signInMethod) async {
    final UserCredential? userCredential = await signInMethod();
    if (userCredential != null) {
      if(await checkIfUidExists(userCredential.user?.uid)){
        HomeScreen.navigateTo(context);
      }
      else{
        OnboardingDescriptionScreen.navigateTo(context);
      }
      print('Google sign-in successful ${userCredential.user?.email}');
      print('User signed in: ${userCredential.user?.uid}');

    } else {
      // Sign-in failed or was canceled
      print('Sign-in failed or canceled');
    }
  }
}
