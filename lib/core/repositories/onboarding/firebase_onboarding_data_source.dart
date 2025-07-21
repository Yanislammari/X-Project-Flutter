import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/core/repositories/onboarding/onboarding_data_source.dart';

import '../../models/user.dart';

class FirebaseOnBoardingDataSource extends OnboardingDataSource{
  @override
  Future<void> registerUser(UserFromBloc user) async {
    if(FirebaseAuth.instance.currentUser?.uid == null){
      throw Exception("Re login please");
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$uid.jpg');

    if (user.imageFile == null) {
      throw Exception("Aucune image sélectionnée pour l'utilisateur.");
    }
    await ref.putFile(user.imageFile!);
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'pseudo': user.pseudo,
      'bio': user.bio,
      'image_path': imageUrl,
      'created_at': Timestamp.now(),
    });
  }
}