import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

import '../core/blocs/register_bloc/register_bloc.dart';
import 'chose_password_screen.dart';

class ChoseEmailScreen extends StatefulWidget {
  static const String routeName = '/register/email';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const ChoseEmailScreen({super.key});

  @override
  State<ChoseEmailScreen> createState() => _ChoseEmailScreenState();
}

class _ChoseEmailScreenState extends State<ChoseEmailScreen> {

  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final emailFromBloc = context.read<RegisterBloc>().state.email;
    if (!emailFromBloc.isEmptyOrNull()) {
      emailController.text = emailFromBloc!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register with Email'),
      ),
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.emailInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Invalid email address')),
            );
          } else if (state.status == RegisterStatus.emailValid) {
            ChosePasswordScreen.navigateTo(context);
          }
        },
        child: Center(
              child: Container(
                margin: EdgeInsets.all(15),
                child: Column(
                  spacing: 30,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: textFieldMainDeco('Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    ElevatedButton(
                      onPressed: ()=>context.read<RegisterBloc>().add(SendEmailToBloc(email: emailController.text)),
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
