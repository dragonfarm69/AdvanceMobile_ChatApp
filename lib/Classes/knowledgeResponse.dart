class KnowledgeResponse {
  final List<KnowledgeResponseBase> data;

  KnowledgeResponse({required this.data});

  factory KnowledgeResponse.fromJson(Map<String, dynamic> json) {
    return KnowledgeResponse(
      data: (json['data'] as List)
          .map((item) => KnowledgeResponseBase.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
      };

  //getter name
  String get name {
    if (data.isNotEmpty) {
      return data[0].knowledgeName;
    } else {
      return '';
    }
  }
}

class KnowledgeResponseBase {
  final String id;
  final String knowledgeName;
  final String description;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic createdBy;
  final dynamic updatedBy;
  final dynamic deletedAt;

  KnowledgeResponseBase({
    required this.id,
    required this.knowledgeName,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
  });

  factory KnowledgeResponseBase.fromJson(Map<String, dynamic> json) {
    return KnowledgeResponseBase(
      id: json['id'],
      knowledgeName: json['knowledgeName'],
      description: json['description'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'knowledgeName': knowledgeName,
        'description': description,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdBy': createdBy,
        'updatedBy': updatedBy,
        'deletedAt': deletedAt?.toIso8601String(),
      };
}