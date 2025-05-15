class TokenUsage {
  final int availableTokens;
  final int totalTokens;
  late final bool unlimited;
  final DateTime date;

  TokenUsage({
    required this.availableTokens,
    required this.totalTokens,
    required this.unlimited,
    required this.date,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      availableTokens: json['availableTokens'] as int,
      totalTokens: json['totalTokens'] as int,
      unlimited: json['unlimited'] as bool,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'availableTokens': availableTokens,
        'totalTokens': totalTokens,
        'unlimited': unlimited,
        'date': date.toIso8601String(),
      };
}