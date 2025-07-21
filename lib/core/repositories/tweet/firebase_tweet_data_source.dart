import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x_project_flutter/core/models/tweet.dart';

class FirebaseTweetDataSource {
  final FirebaseFirestore firestore;

  FirebaseTweetDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Tweet>> fetchTweets() async {
    final snapshot = await firestore.collection('tweets').get();
    print('Nombre de tweets Firestore: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      print('Tweet Firestore: ${doc.data()}');
    }
    return snapshot.docs.map((doc) {
      final data = doc.data();
      try {
        return Tweet.fromJson({
          ...data,
          'id': doc.id,
        });
      } catch (e) {
        print('Erreur parsing tweet: ${e}, data: ${data}');
        return null;
      }
    }).whereType<Tweet>().toList();
  }

  Future<Tweet?> fetchTweetById(String id) async {
    final doc = await firestore.collection('tweets').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Tweet.fromJson({
      ...data,
      'id': doc.id,
    });
  }
} 