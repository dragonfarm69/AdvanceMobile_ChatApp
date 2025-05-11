class Assistant {
  final String id;
  final String name;
  final String model;

  Assistant({
    required this.id,
    required this.name,
    required this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
    };
  }

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'],
      name: json['name'],
      model: json['model'],
    );
  }
}