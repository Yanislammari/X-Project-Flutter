import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/register/firebase_register_data_source.dart';

class RegisterRepository{
  final FirebaseRegisterDataSource firebaseRegisterDataSource;

  const RegisterRepository({required this.firebaseRegisterDataSource});

  Future<UserCredential?> signUp(String email, String password) async {
    return await firebaseRegisterDataSource.signUp(email, password);
  }
}