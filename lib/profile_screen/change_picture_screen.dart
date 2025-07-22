import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';

import '../l10n/generated/app_localizations.dart';

class ProfileChangeImageScreen extends StatefulWidget {
  static const String routeName = '/profile/profile_picture';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const ProfileChangeImageScreen({super.key});

  @override
  State<ProfileChangeImageScreen> createState() =>
      _ProfileChangeImageScreenState();
}

class _ProfileChangeImageScreenState extends State<ProfileChangeImageScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(UserDataFetch());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(loc.profileChangePictureScreen_title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: BlocListener<UserDataBloc, UserDataState>(
        listener: (context, state) {
          if(state.status == UserDataStatus.updateImageSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.profileChangePictureScreen_successMessage),
              ),
            );
          } else if (state.status == UserDataStatus.imageInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.profileChangePictureScreen_defaultError),
              ),
            );
          }
        },
        child: BlocBuilder<UserDataBloc, UserDataState>(
          builder: (context, state) {
            Widget imageWidget = Icon(Icons.account_circle, size: 150);
            if (state.status == UserDataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == UserDataStatus.error) {
              return ScaffoldMessenger(
                child: SnackBar(
                  content: Text(
                    loc.profileChangePictureScreen_defaultError,
                  ),
                ),
              );
            } else if (state.status == UserDataStatus.imageValid &&
                state.imageFile != null) {
              // Show picked image from local file
              imageWidget = Image.file(
                state.imageFile!,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
              );
            } else if (state.user?.imagePath != null &&
                state.user!.imagePath!.isNotEmpty) {
              // Show image from network URL
              imageWidget = Image.network(
                state.user!.imagePath!,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 150,
                    width: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 150, color: Colors.red);
                },
              );
            }
            return Center(
              child: Column(
                spacing: 30,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  ClipOval(child: imageWidget),
                  Container(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => context.read<UserDataBloc>().add(
                                  UserDataSendImage(
                                    imageSource: ImageSource.gallery,
                                  ),
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
                            onPressed:
                                () => context.read<UserDataBloc>().add(
                                  UserDataSendImage(
                                    imageSource: ImageSource.camera,
                                  ),
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt),
                                SizedBox(width: 8),
                                // spacing between icon and text
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
                      onPressed:
                          () => context.read<UserDataBloc>().add(
                            UserDataUpdateImage(),
                          ),
                      child: Text(loc.profileChangePictureScreen_buttonValidate),
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
