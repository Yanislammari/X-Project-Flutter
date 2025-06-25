import 'dart:io';

class UserFromBloc {
  final String pseudo;
  final String bio;
  final File imageFile;

  UserFromBloc({
    required this.pseudo,
    required this.bio,
    required this.imageFile,
  });
}