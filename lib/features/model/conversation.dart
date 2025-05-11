class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] * 1000),
    );
  }
}