import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';
import 'package:x_project_flutter/on_board_screen/onboarding_description_screen.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

import '../l10n/generated/app_localizations.dart';

class ChosePasswordScreen extends StatefulWidget {
  static const String routeName = '/register/password';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const ChosePasswordScreen({super.key});

  @override
  State<ChosePasswordScreen> createState() => _ChosePasswordScreenState();
}

class _ChosePasswordScreenState extends State<ChosePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.registerPasswordScreen_title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            spacing: 15,
            children: [
              TextField(
                decoration: textFieldMainDeco(loc.registerPasswordScreen_textFieldPasswordPlaceHolder),
                controller: passwordController,
                obscureText: true,
              ),
              TextField(
                decoration: textFieldMainDeco(loc.registerPasswordScreen_textFieldConfirmPasswordPlaceHolder),
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  onPressed: loginClassic,
                  child: Text(loc.registerPasswordScreen_buttonValidate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential?> signUp() async{
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: "alexisduplessis2003@gmail.com", password: passwordController.value.text);
      return credential;
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'An unknown error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return null;
    } catch (e) {
      print('Sign-in error: $e');
      return null;
    }
  }

  void loginClassic() async{
    final credential = await signUp();
    if (credential != null) {
      OnboardingDescriptionScreen.navigateTo(context);
    }
  }
}
