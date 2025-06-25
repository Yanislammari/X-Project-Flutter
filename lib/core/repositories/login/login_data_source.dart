import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginDataSource {
  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential?> connectWithEmailAndPassword(String? email,String? password);
  Future<bool> checkIfUserUidExist(String? uid);
}