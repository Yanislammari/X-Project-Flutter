import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserFromBloc {
  final String pseudo;
  final String bio;
  final File imageFile;

  UserFromBloc({
    required this.pseudo,
    required this.bio,
    required this.imageFile,
  });
}

class FirebaseUser{
  final String? pseudo;
  final String? bio;
  final String? imagePath;
  final DateTime createdAt;

  FirebaseUser({
    required this.pseudo,
    required this.bio,
    required this.imagePath,
    required this.createdAt,
  });

  FirebaseUser copyWith({
    final String? pseudo,
    final String? bio,
    final String? imagePath,
    final DateTime? createdAt

  }) {
    return FirebaseUser(
      pseudo: pseudo ?? this.pseudo,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FirebaseUser.fromJson(Map<String, dynamic> json) {
    return FirebaseUser(
      pseudo: json['pseudo'] as String,
      bio: json['bio'] as String,
      imagePath: json['image_path'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }
}