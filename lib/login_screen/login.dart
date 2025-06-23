import 'package:flutter/material.dart';
import 'package:x_project_flutter/register_screen/register_description_screen.dart';

import '../l10n/generated/app_localizations.dart';
import '../widget/text_field_decoration.dart';

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

    final loginController = TextEditingController();
    final loc = AppLocalizations.of(context)!;

    @override
    void dispose() {
      super.dispose();
      loginController.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginScreen_title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            spacing: 10,
            children: [
              TextField(
                controller: loginController,
                decoration: textFieldMainDeco(loc.loginScreen_textFieldEmailPlaceholder),
              ),
              ElevatedButton(
                  onPressed: ()=>{},
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
              Spacer(flex:15),
              GestureDetector(
                onTap: ()=>RegisterDescriptionScreen.navigateTo(context),
                child: Text(
                  loc.loginScreen_labelRegister,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
