import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { LikeReceived, AskingRelationReceived }

class AppNotification {
  final String id;
  final NotificationType type;
  final String? likeId;
  final String? askingRelationId;
  final String userId;
  final String toUserId;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.type,
    this.likeId,
    this.askingRelationId,
    required this.userId,
    required this.toUserId,
    required this.timestamp,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String id) {
    final ts = json['timestamp'];
    return AppNotification(
      id: id,
      type: NotificationType.values.firstWhere((e) => e.toString() == 'NotificationType.' + (json['type'] as String)),
      likeId: json['likeId'] as String?,
      askingRelationId: json['askingRelationId'] as String?,
      userId: json['userId'] as String,
      toUserId: json['toUserId'] as String,
      timestamp: ts is String
          ? DateTime.parse(ts)
          : (ts is Timestamp ? ts.toDate() : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'likeId': likeId,
      'askingRelationId': askingRelationId,
      'userId': userId,
      'toUserId': toUserId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 