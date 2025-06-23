import 'package:flutter/material.dart';
import 'package:x_project_flutter/register_screen/register_password_screen.dart';

import '../l10n/generated/app_localizations.dart';
import '../widget/text_field_decoration.dart';

class RegisterChoseCredentialsScreen extends StatefulWidget {
  static const String routeName = '/register/credentials';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const RegisterChoseCredentialsScreen({super.key});

  @override
  State<RegisterChoseCredentialsScreen> createState() => _RegisterChoseCredentialsScreenState();
}

class _RegisterChoseCredentialsScreenState extends State<RegisterChoseCredentialsScreen> {
  final emailTextController = TextEditingController();

  @override
  void dispose() {
    emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.registerCredentialsScreen_title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            spacing: 10,
            children: [
              TextField(
                controller: emailTextController,
                decoration: textFieldMainDeco(loc.loginScreen_textFieldEmailPlaceholder),
              ),
              ElevatedButton(
                onPressed: ()=>RegisterPasswordScreen.navigateTo(context),
                child: Text(loc.loginScreen_buttonConnectWithEmail),
              ),
              SizedBox(height: 15),
              Text(
                loc.loginScreen_labelConnectWithGoogle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(height: 15),
              Text(
                loc.loginScreen_labelConnectWithGitHub,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
