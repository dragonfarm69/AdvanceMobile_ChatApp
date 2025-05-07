import 'package:shared_preferences/shared_preferences.dart';

class ChatToken{
  static const String _tokenKey = 'remainingUsage';
  final String baseUrl = 'https://api.dev.jarvis.cx';

  static Future<int> initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    
    if (accessToken == null) {
        throw Exception('Access token is not available');
    }

      final response = await http.get(Uri.parse('$baseUrl/api/v1/tokens/usagr'));
      if (response.statusCode == 200) {
      final res = int.parse(response.body);
        await setTokens(res['availableTokens']);
        return res['availableTokens'];
      }

      else{
        print(response.reasonPhrase);
        return 0;
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