import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/main_screen.dart';

import '../l10n/generated/app_localizations.dart';

class OnboardingImageScreen extends StatefulWidget {
  static const String routeName = '/on_board/profile_picture';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const OnboardingImageScreen({super.key});

  @override
  State<OnboardingImageScreen> createState() => _OnboardingImageScreenState();
}

class _OnboardingImageScreenState extends State<OnboardingImageScreen> {

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
          if (state.status == OnBoardingStatus.registerSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              MainScreen.routeName, (route) => false,
            );
          } else if (state.status == OnBoardingStatus.imageInvalid ||
              state.status == OnBoardingStatus.errorRegister) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'An error occurred, please try again')),
            );
          }
        },
        child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
          builder: (context, state) {
            if (state.status == OnBoardingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
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
                        'Add your profile picture',
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
                        'Choose a photo to personalize your profile',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Preview image stylée
                      if (state.imageFile != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.18),
                                blurRadius: 32,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.file(
                              state.imageFile!,
                              fit: BoxFit.cover,
                              height: 150,
                              width: 150,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.white38, size: 64),
                          ),
                        ),
                      const SizedBox(height: 28),
                      // Boutons galerie/caméra modernes
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.read<OnBoardingBloc>().add(
                                OnBoardingChoseImage(imageSource: ImageSource.gallery),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shadowColor: Colors.white24,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.photo_library),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.read<OnBoardingBloc>().add(
                                OnBoardingChoseImage(imageSource: ImageSource.camera),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shadowColor: Colors.white24,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text(
                                'Camera',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
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
                            OnBoardingRegisterUser(),
                          ),
                          child: const Text(
                            'Finish',
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
            );
          },
        ),
      ),
    );
  }
}
