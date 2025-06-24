import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/register/register_data_source.dart';

class FirebaseRegisterDataSource extends RegisterDataSource {

  @override
  Future<UserCredential?> signUp(String email,String password) async{
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during registration, please try again.');
    } catch (e) {
      throw Exception('An error occurred during registration, please try again.');
    }
  }
}