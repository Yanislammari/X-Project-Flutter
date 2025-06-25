import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/register/register_data_source.dart';

class RegisterRepository{
  final RegisterDataSource registerDataSource;

  const RegisterRepository({required this.registerDataSource});

  Future<UserCredential?> signUp(String email, String password) async {
    return await registerDataSource.signUp(email, password);
  }
}