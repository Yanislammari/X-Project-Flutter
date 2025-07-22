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
    final backgroundColor = Colors.black;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '', // Pas de titre pour plus d'épure
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Logo centré, plus grand
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.10),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Titre et sous-titre
                const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Champs email (flottant)
                Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w500),
                      floatingLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: Colors.black,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 18),
                // Champs mot de passe (flottant)
                Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w500),
                      floatingLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: Colors.black,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Bouton login moderne, large, effet tactile
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      context.read<LoginBloc>().add(
                        ConnexionWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                      );
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Lien register
                GestureDetector(
                  onTap: () => ChoseEmailScreen.navigateTo(context),
                  child: const Text(
                    'No account? Register',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
