class Relation {
  final String firstUserId;
  final String secondUserId;

  Relation({required this.firstUserId, required this.secondUserId});

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      firstUserId: json['firstUserId'] as String,
      secondUserId: json['secondUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstUserId': firstUserId,
      'secondUserId': secondUserId,
    };
  }
} 