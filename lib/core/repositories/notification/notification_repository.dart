import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification.dart';

class NotificationRepository {
  final _collection = FirebaseFirestore.instance.collection('notifications');

  Future<void> addNotification(AppNotification notification) async {
    await _collection.add(notification.toJson());
  }

  Stream<List<AppNotification>> notificationsStream(String toUserId) {
    return _collection
        .where('toUserId', isEqualTo: toUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data(), doc.id))
            .toList());
  }
} 