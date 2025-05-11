import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static Future<void> storeTokens(String accessToken, String refreshToken, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user_id', userId);

    print('Tokens stored successfully');
    print('Access token: ${prefs.getString('access_token')}');
    print('Refresh token: ${prefs.getString('refresh_token')}');
  }

  static Future<Map<String, String>?> getTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');
    String? userId = prefs.getString('user_id');
    if( accessToken == null || refreshToken == null || userId == null) {
      return null;
    }
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId
    };
  }

  static Future<void> clearTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    print('Tokens cleared successfully');
    print('Access token: ${prefs.getString('access_token')}');
  }
}