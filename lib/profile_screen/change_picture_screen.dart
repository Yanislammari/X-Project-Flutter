import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';

import '../l10n/generated/app_localizations.dart';

class ProfileChangeImageScreen extends StatefulWidget {
  static const String routeName = '/profile/profile_picture';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const ProfileChangeImageScreen({super.key});

  @override
  State<ProfileChangeImageScreen> createState() => _ProfileChangeImageScreenState();
}

class _ProfileChangeImageScreenState extends State<ProfileChangeImageScreen> {

  @override
  void initState() {
    super.initState();
    if(context.read<UserDataBloc>().state.user == null) {
      context.read<UserDataBloc>().add(UserDataFetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.registerImageScreen_title)),
      body: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state.status == UserDataStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          else if(state.status == UserDataStatus.dataInvalid) {
            return ScaffoldMessenger(
              child: SnackBar(
                content: Text(
                  "An error occurred while loading your profile data. Please try again later.",
                ),
              ),
            );
          }
          final imagePath = state.user?.imagePath ?? '';
          return Center(
            child: Column(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                ClipOval(
                  child: imagePath.isNotEmpty
                      ? Image.network(
                    state.user!.imagePath!,
                    fit: BoxFit.cover,
                    height: 150,
                    width: 150,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 150,
                        width: 150,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 150, color: Colors.red);
                    },
                  ) : Icon(Icons.account_circle, size: 150),
                ),
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
    );
  }
}
