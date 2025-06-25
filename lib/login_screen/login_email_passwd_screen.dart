import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/login_bloc/login_bloc.dart';
import 'package:x_project_flutter/register_screen/chose_email_screen.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

import '../l10n/generated/app_localizations.dart';

class LoginEmailPasswdScreen extends StatefulWidget {
  static const String routeName = '/login/email_passwd';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const LoginEmailPasswdScreen({super.key});

  @override
  State<LoginEmailPasswdScreen> createState() => _LoginEmailPasswdScreenState();
}

class _LoginEmailPasswdScreenState extends State<LoginEmailPasswdScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginEmailPasswdScreen_title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            spacing: 30,
            children: [
              TextField(
                controller: emailController,
                decoration: textFieldMainDeco(loc.loginEmailPasswdScreen_textFieldEmailPlaceHolder),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: textFieldMainDeco(loc.loginEmailPasswdScreen_textFieldPasswordPlaceHolder)
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: ElevatedButton(
                  onPressed: (){
                    context.read<LoginBloc>().add(ConnexionWithEmailPassword(email: emailController.text,password: passwordController.text));
                  },
                  child: Text(loc.loginEmailPasswdScreen_buttonLogin),
                ),
              ),
              GestureDetector(
                onTap: ()=> ChoseEmailScreen.navigateTo(context),
                child: Text(
                  loc.loginEmailPasswdScreen_buttonRegister,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
