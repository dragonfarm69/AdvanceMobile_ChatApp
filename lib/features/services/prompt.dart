import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_chat_app/features/model/prompt.dart';

class PromptManage{
    final String baseUrl = 'https://api.dev.jarvis.cx';

    Future<void> createPrompt({
      required String title,
      required String content,
      required String description,
      bool isPublic = false,
      bool isFavorite = false,
    }) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
            'Content-Type': 'application/json',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts');

        var request = http.Request('POST', uri);
        request.headers.addAll(headers);
        request.body = jsonEncode({
            'title': title,
            'content': content,
            'description': description,
            'isPublic': isPublic,
            'isFavorite': isFavorite,
        });

        var response = await request.send();
        if (response.statusCode == 200) {
            debugPrint('Prompt created successfully');
        } else {
            throw Exception('Failed to create prompt');
        }
    }

    Future<List<Prompt>?> getPrompt({
      String? query,
      int offset = 0,
      int limit = 20,
      bool isFavorite = false,
      bool isPublic = false,
    }) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts').replace(
            queryParameters: {
                if (query != null && query.isNotEmpty) 'query': query,
                'offset': offset.toString(),
                'limit': limit.toString(),
                'isFavorite': isFavorite.toString(),
                if (isFavorite == false) 'isPublic': isPublic.toString(),
            },
        );

        final response = await http.get(uri, headers: headers);
        if (response.statusCode == 200) {
            final jsonResp = jsonDecode(response.body);
            final items = jsonResp['items'];
            final List<Prompt> prompts = [];
            for (var item in items) {
                final id = item['_id'] as String;
                final title = item['title'] as String;
                final content = item['content'] as String;
                final description = item['description'] as String? ?? '';
                final isPublic = item['isPublic'] as bool? ?? false;
                final isFavorite = item['isFavorite'] as bool? ?? false;
                final prompt = Prompt(
                    id: id,
                    title: title,
                    content: content,
                    description: description.isNotEmpty ? description : 'No description provided',
                    isPublic: isPublic,
                    isFavorite: isFavorite,
                );

                prompts.add(prompt);
            }

            return prompts;
        } else {
          print('Error: ${response.reasonPhrase}');
            throw Exception('Failed to load prompt');
        }
    }

    Future<void> updatePrompt({
      required String id,
      required String title,
      required String content,
      required String description,
      bool isPublic = false,
    }) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
            'Content-Type': 'application/json',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts/$id');

        var request = http.Request('PATCH', uri);
        request.headers.addAll(headers);
        request.body = jsonEncode({
            'title': title,
            'content': content,
            'description': description,
            'isPublic': isPublic,
        });

        if (isPublic == true){
            throw Exception('This prompt must be private');
        }

        var response = await request.send();
        if (response.statusCode == 200) {
            debugPrint('Prompt updated successfully');
        } else {
            throw Exception('Failed to update prompt');
        }
    }

    Future<void> deletePrompt(String id) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts/$id');

        var request = http.Request('DELETE', uri);
        request.headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
            debugPrint('Prompt deleted successfully');
        } else {
            throw Exception('Failed to delete prompt');
        }
    }

    Future<bool> addFavoritePrompt(String id) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts/$id/favorite');

        final response = await http.post(
          uri,
          headers: headers,
        );
        if (response.statusCode == 200) {
            print('Prompt added to favorites successfully');
            return true;
        } else {
            print('Error: ${response.reasonPhrase}');
            return false;
        }
    }

    Future<bool> removeFavoritePrompt(String id) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'x-jarvis-guid': '',
        };

        final uri = Uri.parse('$baseUrl/api/v1/prompts/$id/favorite');

        final response = await http.delete(
          uri,
          headers: headers,
        );
        if (response.statusCode == 200) {
            print('Prompt removed from favorites successfully');
            return true;
        } else {
            print('Error: ${response.reasonPhrase}');
            return false;
        }
    }
}