import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:x_project_flutter/core/repositories/login/login_data_source.dart';

class FirebaseLoginDataSource extends LoginDataSource {
  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserCredential?> connectWithEmailAndPassword(String? email,String? password) async {
    try {
      if (email == null || email.isEmpty || password == null || password.isEmpty) {
        throw Exception("Email and password are required");
      }
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "An unknow error occured");
    }
  }

  @override
  Future<bool> checkIfUserUidExist(String? uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uuid_user', isEqualTo: uid)
        .limit(1) // optional: only need to know if exists
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}