class AskingRelation {
  final String fromUserId;
  final String toUserId;

  AskingRelation({
    required this.fromUserId,
    required this.toUserId,
  });

  factory AskingRelation.fromJson(Map<String, dynamic> json) {
    return AskingRelation(
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    };
  }
} 