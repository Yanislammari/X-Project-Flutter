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
              SnackBar(content: Text(state.message ?? "Something went wrong")),
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
                  if (state.imageFile != null)
                    Image.file(state.imageFile!, height: 200)
                  else
                    Text(loc.registerImageScreen_textNoImage),

                  ElevatedButton(
                    onPressed: () => context.read<OnBoardingBloc>().add(
                      OnBoardingChoseImage(imageSource: ImageSource.gallery),
                    ),
                    child: Text(loc.registerImageScreen_buttonPickFromGal),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<OnBoardingBloc>().add(
                      OnBoardingChoseImage(imageSource: ImageSource.camera),
                    ),
                    child: Text(loc.registerImageScreen_buttonTakePhoto),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<OnBoardingBloc>().add(
                      OnBoardingRegisterUser(),
                    ),
                    child: Text(loc.registerDescriptionScreen_buttonValidate),
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
