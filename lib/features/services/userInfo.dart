import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../model/subscription.dart';
import './token_store.dart';
import '../model/tokenUsage.dart';

class Userinfo {
  final String userInfoURL = 'https://api.dev.jarvis.cx/api/v1/auth/me';
  final String subscriptionURL = 'https://api.dev.jarvis.cx/api/v1/subscriptions/me';
  final String tokenUsageURL = 'https://api.dev.jarvis.cx/api/v1/tokens/usage';

  Future<Map<String, String>> _getHeaders() async {
    final tokens = await TokenStore.getTokens();
    if (tokens == null || tokens['access_token'] == null) {
      throw Exception('No access token available');
    }

    return {
      'x-jarvis-guid': '',
      'Authorization': 'Bearer ${tokens['access_token']}',
      'Content-Type': 'application/json',
    };
  }

  Future<User> getUserInfo() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(userInfoURL),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<Subscription> getSubscription() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(subscriptionURL),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Subscription.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load subscription info');
    }
  }

  Future<TokenUsage> getTokenUsage() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(tokenUsageURL),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return TokenUsage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load token usage info');
    }
  }
}