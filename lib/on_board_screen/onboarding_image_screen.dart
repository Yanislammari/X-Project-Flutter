import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? image;
  final picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.registerImageScreen_title)),
      body: Center(
        child: Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            image == null
                ? Text(loc.registerImageScreen_textNoImage)
                : Image.file(image!, height: 200),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: Text(loc.registerImageScreen_buttonPickFromGal),
            ),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: Text(loc.registerImageScreen_buttonTakePhoto),
            ),
            ElevatedButton(
                onPressed: ()=>HomeScreen.navigateTo(context),
                child: Text(loc.registerDescriptionScreen_buttonValidate)
            )
          ],
        ),
      ),
    );
  }
}
