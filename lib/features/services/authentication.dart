import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_chat_app/features/services/token_store.dart';

class AuthService{
  final String baseUrl = 'https://auth-api.dev.jarvis.cx';

  Future<Map<String, dynamic>?> signUp(String email, String password) async {
    final Map<String, String> headers = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      'Content-Type': 'application/json'
    };

    var response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/password/sign-up'),
      headers: headers,
      body: json.encode({
      "email": email,
      "password": password,
      "verification_callback_url": "https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess"
      }),
    );

    if (response.statusCode == 200) {
      var jsonResp = jsonDecode(response.body);
      return jsonResp;
    }
    else {
     print(response.reasonPhrase);
     return null;
    }
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final Map<String, String> headers = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      'Content-Type': 'application/json'
    };

    var response = await http.post(Uri.parse('$baseUrl/api/v1/auth/password/sign-in'), headers: headers, body: json.encode({
      "email": email,
      "password": password,
    }));

    if (response.statusCode == 200) {
      var jsonResp = jsonDecode(response.body);
      await TokenStore.storeTokens(jsonResp['access_token'], jsonResp['refresh_token'], jsonResp['user_id']);
      return jsonResp;
    }

    else {
      print(response.reasonPhrase);
      return null;
    }
  }

  Future<bool> refreshToken() async {
    final userData = await TokenStore.getTokens();
    if (userData == null) {
      return false;
    }
    final refreshToken = userData['refresh_token'];
    final accessToken = userData['access_token'];
    final userId = userData['user_id'];
    if (refreshToken == null || accessToken == null || userId == null) {
      return false;
    }
    var headers = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      'X-Stack-Refresh-Token': refreshToken,
      'Content-Type': 'application/json'
    };
    var response = await http.post(Uri.parse('$baseUrl/api/v1/auth/sessions/current/refresh'), headers: headers, body: json.encode({
      "refresh_token": refreshToken,
      "user_id": userId,
    }));

    if (response.statusCode == 200) {
      var jsonResp = jsonDecode(response.body);
      String newAccessToken = jsonResp['access_token'];
      await TokenStore.storeTokens(newAccessToken, refreshToken, userId);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signOut() async {
    final userData = await TokenStore.getTokens();
    if (userData == null) {
      return false;
    }

    final refreshToken = userData['refresh_token'];
    final accessToken = userData['access_token'];
    final userId = userData['user_id'];
    if (refreshToken == null || accessToken == null || userId == null) {
      return false;
    }
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      'X-Stack-Refresh-Token': refreshToken,
      'Content-Type': 'application/json'
    };

    var response = await http.delete(
      Uri.parse('$baseUrl/api/v1/auth/sessions/current'),
      headers: headers,
      body: json.encode({}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfLoggedIn() async {
    final userData = await TokenStore.getTokens();
    final accessToken = userData?['access_token'];
    final refresh = userData?['refresh_token'];

    if (accessToken == null || refresh == null) {
      return false;
    }

    bool refreshed = await refreshToken();
    return refreshed;
  }
}