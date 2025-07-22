import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';
import 'package:x_project_flutter/core/models/user.dart';
import 'package:x_project_flutter/main_screen.dart';
import 'package:x_project_flutter/profile_screen/change_picture_screen.dart';

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
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(const UserDataFetch());
  }

  @override
  void dispose() {
    pseudoController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _populateFields(FirebaseUser user) {
    if (!_isDataLoaded) {
      pseudoController.text = user.pseudo ?? '';
      bioController.text = user.bio ?? '';
      _isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserDataBloc, UserDataState>(
      listener: (context, state) {
        if (state.status == UserDataStatus.updateBioSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Profil mis à jour avec succès !',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00BA7C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (Route<dynamic> route) => false,
          );
        } else if (state.status == UserDataStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message ?? 'Une erreur est survenue',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF4212E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state.status == UserDataStatus.descBioInvalid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message ?? 'Veuillez remplir tous les champs',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFFD400),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.user != null) {
          _populateFields(state.user!);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black.withOpacity(0.8),
                pinned: true,
                expandedHeight: 120,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                title: const Text(
                  'Modifier le profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.save_outlined, color: Color(0xFF1D9BF0), size: 20),
                      onPressed: () {
                        if (pseudoController.text.trim().isNotEmpty && bioController.text.trim().isNotEmpty) {
                          context.read<UserDataBloc>().add(
                            UserDataUpdateProfile(
                              pseudo: pseudoController.text.trim(),
                              bio: bioController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Picture Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2F3336),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF1D9BF0),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Photo de profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: (state.user?.imagePath != null && state.user!.imagePath!.isNotEmpty)
                                          ? NetworkImage(state.user!.imagePath!)
                                          : null,
                                      backgroundColor: const Color(0xFF536471),
                                      child: (state.user?.imagePath == null || state.user!.imagePath!.isEmpty)
                                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1D9BF0).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(ProfileChangeImageScreen.routeName);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Form Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2F3336),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF1D9BF0),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Informations personnelles',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Pseudo Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nom d\'utilisateur',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16181C),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF2F3336),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: pseudoController,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    decoration: const InputDecoration(
                                      hintText: 'Votre nom d\'utilisateur',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF71767B),
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Bio Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Biographie',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16181C),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF2F3336),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: bioController,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    maxLines: 4,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      hintText: 'Parlez-nous de vous...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF71767B),
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1D9BF0).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: state.status == UserDataStatus.loading
                                ? null
                                : () {
                                    if (pseudoController.text.trim().isNotEmpty && bioController.text.trim().isNotEmpty) {
                                      context.read<UserDataBloc>().add(
                                        UserDataUpdateProfile(
                                          pseudo: pseudoController.text.trim(),
                                          bio: bioController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                            child: state.status == UserDataStatus.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sauvegarder les modifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
