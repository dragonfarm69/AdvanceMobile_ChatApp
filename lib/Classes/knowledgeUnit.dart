class KnowledgeUnit {
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;
  DateTime? deletedAt;
  String? id;
  String? name;
  String? type;
  int? size;
  bool? status;
  String? userId;
  String? knowledgeId;
  Metadata? metadata;

  KnowledgeUnit({
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
    this.id,
    this.name,
    this.type,
    this.size,
    this.status,
    this.userId,
    this.knowledgeId,
    this.metadata,
  });

  factory KnowledgeUnit.fromJson(Map<String, dynamic> json) {
    return KnowledgeUnit(
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      id: json['id'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
      status: json['status'],
      userId: json['userId'],
      knowledgeId: json['knowledgeId'],
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedAt': deletedAt?.toIso8601String(),
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'status': status,
      'userId': userId,
      'knowledgeId': knowledgeId,
      'metadata': metadata?.toJson(),
    };
  }
}

class Metadata {
  String? fileId;
  String? fileUrl;
  String? mimeType;

  Metadata({
    this.fileId,
    this.fileUrl,
    this.mimeType,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      fileId: json['fileId'],
      fileUrl: json['fileUrl'],
      mimeType: json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileUrl': fileUrl,
      'mimeType': mimeType,
    };
  }
}