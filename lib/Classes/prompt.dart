class Prompt {
  final String category;
  final String content;
  final String createdAt;
  final bool isFavorite;
  final bool isPublic;
  final String title;
  final String updatedAt;
  final String userId;
  final String userName;
  final String id;

  Prompt({
    required this.category,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
    this.isPublic = true,
    required this.title,
    required this.updatedAt,
    required this.userId,
    required this.userName,
    required this.id,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isPublic: json['isPublic'] ?? true,
      title: json['title'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'content': content,
      'createdAt': createdAt,
      'isFavorite': isFavorite,
      'isPublic': isPublic,
      'title': title,
      'updatedAt': updatedAt,
      'userId': userId,
      'userName': userName,
      '_id': id,
    };
  }
}