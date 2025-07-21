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

  Future<FirebaseUser?> updateUserBio(String? pseudo, String? bio, FirebaseUser? user) async {
    return await userDataSource.updateUserBio(pseudo, bio, user);
  }

  Future<FirebaseUser?> getUserById(String uid) async {
    return await userDataSource.getUserById(uid);
  }

  Future<List<FirebaseUser>> getAllUsers() async {
    return await userDataSource.getAllUsers();
  }
}