import 'package:flutter/material.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

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
      body: Center(
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
                onPressed: ()=>ChosePasswordScreen.navigateTo(context),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
