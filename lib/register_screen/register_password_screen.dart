import 'package:flutter/material.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

import '../l10n/generated/app_localizations.dart';

class RegisterPasswordScreen extends StatefulWidget {
  static const String routeName = '/register/password';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const RegisterPasswordScreen({super.key});

  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
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
                  onPressed: ()=>HomeScreen.navigateTo(context),
                  child: Text(loc.registerPasswordScreen_buttonValidate),
              )
            ],
          ),
        ),
      ),
    );
  }
}
