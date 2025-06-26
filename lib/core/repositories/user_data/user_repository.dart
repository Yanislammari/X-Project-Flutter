import 'dart:io';

import 'package:x_project_flutter/core/repositories/user_data/user_data_source.dart';

import '../../models/user.dart';

class UserRepository {
  final UserDataSource userDataSource;

  UserRepository({required this.userDataSource});

  Future<FirebaseUser?> getUserData(FirebaseUser? user) async {
    return await userDataSource.getUserData(user);
  }

  Future<FirebaseUser?> updateUserImage(FirebaseUser? user,File? imageFile) async {
    return await userDataSource.updateUserImage(user, imageFile);
  }
}