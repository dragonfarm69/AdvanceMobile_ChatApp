class Prompt {
  String id;
  String title;
  String content;
  String description;
  bool isPublic = false;
  bool isFavorite = false;

  Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.isPublic,
    required this.isFavorite,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      description: json['description'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'isPublic': isPublic,
      'isFavorite': isFavorite,
    };
  }
}