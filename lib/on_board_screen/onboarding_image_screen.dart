import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';

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

  File? imageFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.registerImageScreen_title)),
      body: BlocListener<OnBoardingBloc, OnBoardingState>(
        listener: (context, state) {
          if (state.status == OnBoardingStatus.registerSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.routeName, (route) => false,
            );
          } else if (state.status == OnBoardingStatus.imageInvalid ||
              state.status == OnBoardingStatus.errorRegister) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? loc.registerImageScreen_defaultError)),
            );
          }
        },
        child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
          builder: (context, state) {
            if (state.status == OnBoardingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Column(
                spacing: 30,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  if (state.imageFile != null)
                    ClipOval(
                      child: Image.file(
                        state.imageFile!,
                        fit: BoxFit.cover,
                        height: 150,
                        width: 150,
                      ),
                    )
                  else
                    Text(loc.registerImageScreen_textNoImage),

                  Container(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<OnBoardingBloc>().add(
                              OnBoardingChoseImage(imageSource: ImageSource.gallery),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library),
                                SizedBox(width: 8),
                                Text(loc.registerImageScreen_buttonPickFromGal),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // spacing between buttons
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<OnBoardingBloc>().add(
                              OnBoardingChoseImage(imageSource: ImageSource.camera),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt),
                                SizedBox(width: 8), // spacing between icon and text
                                Text(loc.registerImageScreen_buttonTakePhoto),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () => context.read<OnBoardingBloc>().add(
                        OnBoardingRegisterUser(),
                      ),
                      child: Text(loc.registerDescriptionScreen_buttonValidate),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
