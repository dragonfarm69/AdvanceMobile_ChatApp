import 'package:shared_preferences/shared_preferences.dart';

class ChatToken{
  static const String _tokenKey = 'remaining_tokens';

  
  static Future<void> setTokens(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenKey, count);
  }

  static Future<int> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenKey) ?? 0;
  }

  static Future<bool> deductTokens(int cost) async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_tokenKey) ?? 0;
    if (currentCount >= cost) {
      await prefs.setInt(_tokenKey, currentCount - cost);
      return true;
    } else {
      return false; // Not enough tokens
    }
  }

  static Future<void> resetTokens([int amount = 50]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}