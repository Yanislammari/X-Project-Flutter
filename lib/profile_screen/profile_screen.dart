import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';
import 'package:x_project_flutter/profile_screen/change_picture_screen.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

import '../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final pseudoController = TextEditingController();
  final bioController = TextEditingController();

  bool _firstBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstBuild) {
      context.read<UserDataBloc>().add(UserDataFetch());
      _firstBuild = false;
    }
  }

  @override
  void dispose() {
    pseudoController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(UserDataFetch());
  }

  @override
  Widget build(BuildContext context) {
    // final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Photo de profil stylée
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
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
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white10,
                        backgroundImage: /* Remplace par l'image de profil de l'utilisateur */ null,
                        child: const Icon(Icons.person, color: Colors.white38, size: 54),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(ProfileChangeImageScreen.routeName);
                        },
                        child: const Icon(Icons.camera_alt, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Material(
                color: Colors.transparent,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
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
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.transparent,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  minLines: 4,
                  maxLines: 8,
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
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Bouton save moderne
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
                  onPressed: () {/* Sauvegarder les modifications */},
                  child: const Text(
                    'Save',
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
  }
}
