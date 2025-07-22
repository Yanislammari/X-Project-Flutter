import 'package:meta/meta.dart';

class Tweet {
  final String id;
  final String userId;
  final String content;
  final String? photo;
  final int likes;
  final bool isComment;
  final String? replyToTweetId;

  Tweet({
    required this.id,
    required this.userId,
    required this.content,
    this.photo,
    this.likes = 0,
    this.isComment = false,
    this.replyToTweetId,
  });

  Tweet.empty() : 
    id = '',
    userId = '',
    content = '',
    photo = null,
    likes = 0,
    isComment = false,
    replyToTweetId = null;

  Tweet copyWith({
    String? id,
    String? userId,
    String? content,
    String? photo,
    int? likes,
    bool? isComment,
    String? replyToTweetId,
  }) {
    return Tweet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      photo: photo ?? this.photo,
      likes: likes ?? this.likes,
      isComment: isComment ?? this.isComment,
      replyToTweetId: replyToTweetId ?? this.replyToTweetId,
    );
  }

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      photo: json['photo'] as String?,
      likes: json['likes'] as int? ?? 0,
      isComment: json['isComment'] as bool? ?? false,
      replyToTweetId: json['replyToTweetId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'photo': photo,
      'likes': likes,
      'isComment': isComment,
      'replyToTweetId': replyToTweetId,
    };
  }
} 