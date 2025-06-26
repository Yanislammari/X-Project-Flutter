import 'package:x_project_flutter/core/models/user.dart';

abstract class UserDataSource {
  Future<FirebaseUser?> getUserData();
}