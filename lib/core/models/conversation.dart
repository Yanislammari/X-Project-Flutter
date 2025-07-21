import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class Conversation {
  final String id;
  final List<String> participants;
  final Message? lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String id) {
    return Conversation(
      id: id,
      participants: List<String>.from(json['participants']),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(Map<String, dynamic>.from(json['lastMessage']), 'last')
          : null,
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage?.toJson(),
      'updatedAt': updatedAt,
    };
  }
} 