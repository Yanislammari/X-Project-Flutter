import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_data_source.dart';

import '../../models/user.dart';

class FirebaseUserDataSource extends UserDataSource{

  @override
  Future<FirebaseUser?> getUserData() async {
    if(FirebaseAuth.instance.currentUser?.uid == null){
      throw Exception("No idea how leave and come back to this page");
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_uuid', isEqualTo: uid)
        .get();

    print("User data fetched for UID: $uid");
    print(docSnapshot.docs.first.data());
    if (!docSnapshot.docs.isNotEmpty) {
      throw Exception("User data not found");
    }
    final data = docSnapshot.docs.first.data();
    return FirebaseUser.fromJson(data);
  }
}