import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/login/login_data_source.dart';

class LoginRepository {
  final LoginDataSource loginDataSource;

  const LoginRepository({
      required this.loginDataSource,
  });

  Future<UserCredential?> googleAuth() async {
    return await loginDataSource.signInWithGoogle();
  }

  Future<UserCredential?> emailAndPasswordAuth(String? email,String? password) async {
    return await loginDataSource.connectWithEmailAndPassword(email, password);
  }

  Future<bool> checkUidUserExist(String? uid) async{
    return await loginDataSource.checkIfUserUidExist(uid);
  }
}