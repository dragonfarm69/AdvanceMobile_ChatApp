class Bot {
  final String id;
  final String assistantName;
  final String? description;
  final String instructions;
  final String? openAiAssistantId;
  final String openAiVectorStoreId;
  final String userId;
  final String? openAiThreadIdPlay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? deletedAt;
  final bool isDefault;
  final bool isFavorite;
  final List<String> permissions;

  Bot({
    required this.id,
    required this.assistantName,
    required this.instructions,
    required this.openAiVectorStoreId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
    required this.isFavorite,
    required this.permissions,
    this.description,
    this.openAiAssistantId,
    this.openAiThreadIdPlay,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
  });
}