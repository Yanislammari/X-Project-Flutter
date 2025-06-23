import 'package:flutter/material.dart';
import 'package:x_project_flutter/register_screen/regsiter_image_screen.dart';

import '../l10n/generated/app_localizations.dart';
import '../widget/text_field_decoration.dart';

class RegisterDescriptionScreen extends StatefulWidget {
  static const String routeName = '/register/description';
  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
  const RegisterDescriptionScreen({super.key});

  @override
  State<RegisterDescriptionScreen> createState() => _RegisterDescriptionScreenState();
}

class _RegisterDescriptionScreenState extends State<RegisterDescriptionScreen> {

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pseudoTextController = TextEditingController();
    final bioTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.registerDescriptionScreen_title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              spacing: 30,
              children: [
                TextField(
                  controller: pseudoTextController,
                  decoration: textFieldMainDeco(loc.registerDescriptionScreen_textFieldPseudoPlaceholder),
                  maxLength: 25,
                ),
                TextField(
                  controller: bioTextController,
                  decoration: textFieldMainDeco(loc.registerDescriptionScreen_textFieldBioPlaceholder),
                  maxLength: 350,
                  minLines: 10,
                  maxLines: 15,
                  keyboardType: TextInputType.multiline,
                ),
                ElevatedButton(
                  onPressed: ()=>{RegisterImageScreen.navigateTo(context)},
                  child: Text(loc.registerDescriptionScreen_buttonValidate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
