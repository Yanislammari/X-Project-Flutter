import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/conversation.dart';

class ConversationRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Conversation>> conversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromJson(doc.data(), doc.id))
            .toList());
  }
} 