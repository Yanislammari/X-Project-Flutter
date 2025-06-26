import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/profile_screen/profile_screen.dart';

import '../core/blocs/login_bloc/login_bloc.dart';
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
      appBar: AppBar(title: Text(loc.loginScreen_title)),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.successfulLoginNoOnBoarding) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              ProfileScreen.routeName,
              (route) => false,
            );
          } else if (state.status == LoginStatus.successfulLoginOnBoarding) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              OnboardingDescriptionScreen.routeName,
              (route) => false,
            );
          } else if (state.status == LoginStatus.errorLogin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message ?? loc.loginScreen_errorMessageDefault,
                ),
              ),
            );
          }
        },
        child: Center(
          child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              spacing: 30,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () => LoginEmailPasswdScreen.navigateTo(context),
                    child: Text(
                      loc.loginScreen_buttonConnectWithEmail,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: ()=>context.read<LoginBloc>().add(ConnexionWithGoogle()),
                    child: Text(
                      loc.loginScreen_labelConnectWithGoogle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
