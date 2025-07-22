import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message.dart';

class MessageRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> messagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(Message message) async {
    await _firestore
        .collection('conversations')
        .doc(message.conversationId)
        .collection('messages')
        .add(message.toJson());
    await _firestore.collection('conversations').doc(message.conversationId).set({
      'lastMessage': message.toJson(),
      'updatedAt': message.sentAt,
    }, SetOptions(merge: true));
  }
} 