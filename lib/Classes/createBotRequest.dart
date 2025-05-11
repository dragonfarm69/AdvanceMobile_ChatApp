class CreateBotRequest {
  final String name;
  final String instructions;
  final String description;

  CreateBotRequest({
    required this.name,
    required this.instructions,
    required this.description,
  });
}