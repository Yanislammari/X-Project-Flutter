import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/profile_screen/profile_screen.dart';
import 'package:x_project_flutter/main_screen.dart';
import 'package:x_project_flutter/register_screen/chose_email_screen.dart';

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
  Widget _buildEmailButton({required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          minimumSize: const Size.fromHeight(56),
          elevation: 6,
          shadowColor: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, height: 24),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.black;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.successfulLoginNoOnBoarding) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                MainScreen.routeName,
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
                    state.message ?? 'Login failed',
                  ),
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Logo principal
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Titre stylé
                  Text(
                    'Welcome to Buzzio',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.08),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect and discover what’s happening now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Bouton Email custom
                  _buildEmailButton(
                    label: 'Connect/Register with email',
                    onPressed: () => LoginEmailPasswdScreen.navigateTo(context),
                  ),
                  // Bouton Google
                  _buildSocialButton(
                    asset: 'assets/google.webp',
                    label: 'Connect/Register with Google',
                    onPressed: () => context.read<LoginBloc>().add(ConnexionWithGoogle()),
                  ),
                  const SizedBox(height: 24),
                  // Option d'inscription
                  TextButton(
                    onPressed: () {
                      ChoseEmailScreen.navigateTo(context);
                    },
                    child: const Text(
                      'No account? Sign up',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

