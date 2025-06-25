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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.registerDescriptionScreen_title)),
      body: BlocListener<OnBoardingBloc, OnBoardingState>(
        listener: (context, state) {
          if(state.status == OnBoardingStatus.pseudoDescValid) {
            OnboardingImageScreen.navigateTo(context);
          } else if (state.status == OnBoardingStatus.pseudoDescInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? loc.registerDescriptionScreen_defaultError)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.all(15),
              child: Column(
                spacing: 30,
                children: [
                  TextField(
                    controller: pseudoTextController,
                    decoration: textFieldMainDeco(
                      loc.registerDescriptionScreen_textFieldPseudoPlaceholder,
                    ),
                    maxLength: 25,
                  ),
                  TextField(
                    controller: bioTextController,
                    decoration: textFieldMainDeco(
                      loc.registerDescriptionScreen_textFieldBioPlaceholder,
                    ),
                    maxLength: 350,
                    minLines: 10,
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<OnBoardingBloc>().add(
                      OnBoardingSendDescriptionAndPseudo(
                        pseudo: pseudoTextController.text,
                        description: bioTextController.text,
                      ),
                    ),
                    child: Text(loc.registerDescriptionScreen_buttonValidate),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
