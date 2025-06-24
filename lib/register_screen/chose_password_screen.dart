import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/register_bloc/register_bloc.dart';
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
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if(state.status == RegisterStatus.passwordInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Invalid password')),
            );
          } else if (state.status == RegisterStatus.passwordValid) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              OnboardingDescriptionScreen.routeName,
                  (route) => false,
            );
          } else if (state.status == RegisterStatus.errorRegister) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Registration failed')),
            );
          }
        },
        child: Center(
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
                        onPressed: ()=>context.read<RegisterBloc>().add(RegisterTry(password: passwordController.text, confirmPassword: confirmPasswordController.text)),
                        child: Text(loc.registerPasswordScreen_buttonValidate),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
