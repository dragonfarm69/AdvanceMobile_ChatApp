class Subscription {
  final String name;
  final int dailyTokens;
  final int monthlyTokens;
  final int annuallyTokens;

  Subscription({
    required this.name,
    required this.dailyTokens,
    required this.monthlyTokens,
    required this.annuallyTokens,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      name: json['name'] as String,
      dailyTokens: json['dailyTokens'] as int,
      monthlyTokens: json['monthlyTokens'] as int,
      annuallyTokens: json['annuallyTokens'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dailyTokens': dailyTokens,
      'monthlyTokens': monthlyTokens,
      'annuallyTokens': annuallyTokens,
    };
  }
}