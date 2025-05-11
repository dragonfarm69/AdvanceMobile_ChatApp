import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatToken{
  static const String _tokenKey = 'remainingUsage';

  static const String baseUrl = 'https://api.dev.jarvis.cx';
  static Future<void> initializeTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      throw Exception('Access token is not available');
    } 
    final headers = {
    'x-jarvis-guid': '',
    'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/tokens/usage'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var jsonResp = jsonDecode(response.body);
      int remainingUsage = jsonResp['availableTokens'];
      await setTokens(remainingUsage);
    } else {
      throw Exception('Failed to initialize tokens: ${response.reasonPhrase}');
    }
  }
  
  static Future<void> setTokens(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenKey, count);
  }

  static Future<int> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenKey) ?? 0;
  }
}