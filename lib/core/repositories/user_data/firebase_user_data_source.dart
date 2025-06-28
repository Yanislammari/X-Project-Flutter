import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_data_source.dart';

import '../../models/user.dart';

class FirebaseUserDataSource extends UserDataSource{

  @override
  Future<FirebaseUser?> getUserData(FirebaseUser? user) async {
    if(user != null) {
      return user;
    }
    if(FirebaseAuth.instance.currentUser?.uid == null){
      throw Exception("No idea how leave and come back to this page");
    }
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (!docSnapshot.exists) {
      throw Exception("User data not found");
    }

    final data = docSnapshot.data()!;
    return FirebaseUser.fromJson(data);
  }

  @override
  Future<FirebaseUser?> updateUserImage(FirebaseUser? user, File? imageFile) async {
    if (user == null) {
      throw Exception("User is null, cannot update image");
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("No user logged in");
    }
    if (imageFile == null) {
      throw Exception("No image file provided");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final storageRef = FirebaseStorage.instance.ref();

    if (user.imagePath != null && user.imagePath!.isNotEmpty) {
      try {
        await FirebaseStorage.instance.refFromURL(user.imagePath!).delete();
      } catch (e) {
        throw Exception("Failed to delete old image: $e");
      }
    }

    final newImageRef = storageRef.child('user_images/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await newImageRef.putFile(imageFile);
    final newImageUrl = await newImageRef.getDownloadURL();

    await userRef.update({
      'image_path': newImageUrl,
    });

    return user.copyWith(imagePath: newImageUrl);
  }

  @override
  Future<FirebaseUser?> updateUserBio(String? pseudo, String? bio, FirebaseUser? user) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final updatedData = <String, dynamic>{
      'pseudo': pseudo,
      'bio': bio,
    };

    await userRef.update(updatedData);

    return user?.copyWith(
      pseudo: pseudo,
      bio: bio,
    );
  }
}