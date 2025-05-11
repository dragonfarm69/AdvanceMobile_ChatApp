class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }

    @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          role == other.role;

  @override
  int get hashCode => content.hashCode ^ role.hashCode;
}