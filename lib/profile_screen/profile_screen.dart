import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';
import 'package:x_project_flutter/profile_screen/change_picture_screen.dart';
import 'package:x_project_flutter/widget/text_field_decoration.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocListener<UserDataBloc, UserDataState>(
        listener: (context, state) {
          if (state.status == UserDataStatus.descBioInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message ?? "Nothing to update",
                ),
              ),
            );
          }
          else if (state.status == UserDataStatus.hasData){
            pseudoController.text = state.user?.pseudo ?? '';
            bioController.text = state.user?.bio ?? '';
          }
          else if (state.status == UserDataStatus.updateBioSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Profile updated successfully",
                ),
              ),
            );
            pseudoController.text = state.user?.pseudo ?? '';
            bioController.text = state.user?.bio ?? '';
          }
          else if(state.status == UserDataStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "An error occurred, please try again later.",
                ),
              ),
            );
          }
        },
        child: BlocBuilder<UserDataBloc, UserDataState>(
          builder: (context, state) {
            if (state.status == UserDataStatus.loading) {
              // Loading indicator
              return Center(child: CircularProgressIndicator());
            } else if (state.status == UserDataStatus.error) {
              // Error screen
              return Center(
                child: Text(
                  "Error loading profile data, please try again later.",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            }
            else {
              final imagePath = state.user?.imagePath ?? '';
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    spacing: 15,
                    children: [
                      SizedBox(height: 20),
                      ClipOval(
                        child:
                        imagePath.isNotEmpty
                            ? Image.network(
                          state.user!.imagePath!,
                          fit: BoxFit.cover,
                          height: 150,
                          width: 150,
                          loadingBuilder: (context,
                              child,
                              loadingProgress,) {
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
                            return Icon(
                              Icons.error,
                              size: 150,
                              color: Colors.red,
                            );
                          },
                        )
                            : Icon(Icons.account_circle, size: 150),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => ProfileChangeImageScreen.navigateTo(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Wrap content tightly
                          children: [
                            Icon(Icons.mode),
                            // Icon fitting "change profile picture"
                            SizedBox(width: 8),
                            // Spacing between icon and text
                            Text("Change Profile Picture"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: pseudoController,
                        decoration: textFieldMainDeco("New pseudo"),
                        maxLength: 25,
                      ),
                      TextField(
                        controller: bioController,
                        decoration: textFieldMainDeco("New bio"),
                        maxLength: 350,
                        minLines: 5,
                        maxLines: 15,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: ()=>context.read<UserDataBloc>().add(
                          UserDataUpdateProfile(
                            pseudo: pseudoController.text,
                            bio: bioController.text,
                          ),
                        ),
                        child: Text("Save new profile"),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
