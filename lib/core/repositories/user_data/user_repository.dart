import 'package:x_project_flutter/core/repositories/user_data/user_data_source.dart';

import '../../models/user.dart';

class UserRepository {
  final UserDataSource userDataSource;

  UserRepository({required this.userDataSource});

  Future<FirebaseUser?> getUserData() async {
    return await userDataSource.getUserData();
  }
}