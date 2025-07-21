import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/on_board_screen/onboarding_image_screen.dart';

import '../l10n/generated/app_localizations.dart';
import '../widget/text_field_decoration.dart';

class OnboardingDescriptionScreen extends StatefulWidget {
  static const String routeName = '/on_board/description';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const OnboardingDescriptionScreen({super.key});

  @override
  State<OnboardingDescriptionScreen> createState() =>
      _OnboardingDescriptionScreenState();
}

class _OnboardingDescriptionScreenState
    extends State<OnboardingDescriptionScreen> {
  final pseudoTextController = TextEditingController();
  final bioTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final pseudoFromBloc = context.read<OnBoardingBloc>().state.pseudo;
    if (!pseudoFromBloc.isEmptyOrNull()) {
      pseudoTextController.text = pseudoFromBloc!;
    }
    final bioFromBloc = context.read<OnBoardingBloc>().state.description;
    if (!bioFromBloc.isEmptyOrNull()) {
      bioTextController.text = bioFromBloc!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    pseudoTextController.dispose();
    bioTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocListener<OnBoardingBloc, OnBoardingState>(
        listener: (context, state) {
          if(state.status == OnBoardingStatus.pseudoDescValid) {
            OnboardingImageScreen.navigateTo(context);
          } else if (state.status == OnBoardingStatus.pseudoDescInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Please fill in all fields')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Logo centré
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.10),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Titre et sous-titre
                const Text(
                  'Tell us about you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a pseudo and write a short bio',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Champ pseudo flottant
                Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: pseudoTextController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    maxLength: 25,
                    decoration: InputDecoration(
                      labelText: 'Pseudo',
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
                      counterStyle: const TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Champ bio flottant
                Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: bioTextController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    maxLength: 350,
                    minLines: 10,
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Bio',
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
                      counterStyle: const TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Bouton valider moderne
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
                    onPressed: () => context.read<OnBoardingBloc>().add(
                      OnBoardingSendDescriptionAndPseudo(
                        pseudo: pseudoTextController.text,
                        description: bioTextController.text,
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
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
