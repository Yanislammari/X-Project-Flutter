class Like {
  final String userId;
  final String tweetId;

  Like({required this.userId, required this.tweetId});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      userId: json['userId'] as String,
      tweetId: json['tweetId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tweetId': tweetId,
    };
  }
} 