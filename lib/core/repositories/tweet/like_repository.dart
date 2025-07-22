import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/like.dart';

class LikeRepository {
  final FirebaseFirestore firestore;

  LikeRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addLike({required String userId, required String tweetId}) async {
    final likeRef = firestore.collection('likes').doc('\\${userId}_\\${tweetId}');
    await likeRef.set({
      'userId': userId,
      'tweetId': tweetId,
    });
    await firestore.collection('tweets').doc(tweetId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> removeLike({required String userId, required String tweetId}) async {
    final likeRef = firestore.collection('likes').doc('\\${userId}_\\${tweetId}');
    await likeRef.delete();
    await firestore.collection('tweets').doc(tweetId).update({
      'likes': FieldValue.increment(-1),
    });
  }

  Future<bool> isLiked({required String userId, required String tweetId}) async {
    final likeRef = firestore.collection('likes').doc('\\${userId}_\\${tweetId}');
    final doc = await likeRef.get();
    return doc.exists;
  }
} 