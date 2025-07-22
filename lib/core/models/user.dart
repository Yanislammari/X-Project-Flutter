import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserFromBloc {
  final String pseudo;
  final String bio;
  final File? imageFile;
  final String? imageUrl;

  UserFromBloc({
    required this.pseudo,
    required this.bio,
    this.imageFile,
    this.imageUrl,
  });

  // Constructeur par défaut pour les cas de chargement
  UserFromBloc.empty() : 
    pseudo = '',
    bio = '',
    imageFile = null,
    imageUrl = null;
}

class FirebaseUser{
  final String uid;
  final String? pseudo;
  final String? bio;
  final String? imagePath;
  final DateTime createdAt;

  FirebaseUser({
    required this.uid,
    required this.pseudo,
    required this.bio,
    required this.imagePath,
    required this.createdAt,
  });

  FirebaseUser copyWith({
    final String? uid,
    final String? pseudo,
    final String? bio,
    final String? imagePath,
    final DateTime? createdAt

  }) {
    return FirebaseUser(
      uid: uid ?? this.uid,
      pseudo: pseudo ?? this.pseudo,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FirebaseUser.fromJson(Map<String, dynamic> json, {required String uid}) {
    return FirebaseUser(
      uid: uid,
      pseudo: json['pseudo'] as String?,
      bio: json['bio'] as String?,
      imagePath: json['image_path'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }
}

extension FirebaseUserToUserFromBloc on FirebaseUser {
  UserFromBloc toUserFromBloc() {
    return UserFromBloc(
      pseudo: pseudo ?? '',
      bio: bio ?? '',
      imageFile: null,
      imageUrl: imagePath,
    );
  }
}