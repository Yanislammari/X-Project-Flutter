import 'dart:io';

import 'package:x_project_flutter/core/models/user.dart';

abstract class UserDataSource {
  Future<FirebaseUser?> getUserData(FirebaseUser? user);
  Future<FirebaseUser?> updateUserImage(FirebaseUser? user, File? imageFile);
  Future<FirebaseUser?> updateUserBio(String? pseudo, String? bio, FirebaseUser? user);
  Future<FirebaseUser?> getUserById(String uid);
  Future<List<FirebaseUser>> getAllUsers();
}