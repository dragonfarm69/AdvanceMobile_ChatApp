class Assistant {
  final String id;
  final String name;
  final String model;
  final int tokenCost;

  Assistant({
    required this.id,
    required this.name,
    required this.model,
    this.tokenCost = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'tokenCost': tokenCost,
    };
  }

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'],
      name: json['name'],
      model: json['model'],
      tokenCost: json['tokenCost'] ?? 0,
    );
  }
}