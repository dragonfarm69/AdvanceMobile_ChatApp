import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Classes/bot.dart';
import './knowledge_management.dart';
import '../../Classes/knowledgeResponse.dart';
import './token_store.dart';

class BotManagement {
  static const String baseUrl = 'https://knowledge-api.dev.jarvis.cx';
  static KnowledgeManager knowledgeManager = KnowledgeManager();

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

  Future<void> addBot(
    String name,
    String instructions,
    String description,
  ) async {
    //request api
    var headers = await _getHeaders();
    var request = http.Request(
      'POST',
      Uri.parse('$baseUrl/kb-core/v1/ai-assistant'),
    );
    request.body = json.encode({
      "assistantName": name,
      "instructions": instructions,
      "description": description,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<List<Bot>> getPublicBots() async {
    final uri = Uri.parse(
      '$baseUrl/kb-core/v1/ai-assistant'
      '?order=DESC&order_field=createdAt&limit=20',
    );
    // print("Fetching bots from: $uri");

    final headers = await _getHeaders();

    final request = http.Request('GET', uri)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to load bots: ${response.reasonPhrase}');
    }

    // 1) Read the raw string
    final responseBody = await response.stream.bytesToString();
    // print("RAW RESPONSE: $responseBody");

    // 2) Decode JSON once
    final decoded = json.decode(responseBody);

    // 3) Extract the list, whether it's raw or wrapped in { data: [...] }
    List<dynamic> jsonData;
    if (decoded is List) {
      jsonData = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      jsonData = decoded['data'] as List<dynamic>;
    } else {
      throw Exception('Unexpected JSON format: $decoded');
    }

    // 4) Map to your Bot model
    return jsonData
        .map(
          (botJson) => Bot(
            id: botJson['id'],
            assistantName: botJson['assistantName'],
            description: botJson['description'],
            instructions: botJson['instructions'],
            openAiAssistantId: botJson['openAiAssistantId'] ?? '',
            openAiVectorStoreId: botJson['openAiVectorStoreId'] ?? '',
            userId: botJson['userId'],
            openAiThreadIdPlay: botJson['openAiThreadIdPlay'] ?? '',
            createdAt: DateTime.parse(botJson['createdAt']),
            updatedAt: DateTime.parse(botJson['updatedAt']),
            createdBy: botJson['createdBy'],
            updatedBy: botJson['updatedBy'],
            deletedAt:
                botJson['deletedAt'] != null
                    ? DateTime.parse(botJson['deletedAt'])
                    : null,
            isDefault: botJson['isDefault'] ?? false,
            isFavorite: botJson['isFavorite'] ?? false,
            permissions: List<String>.from(botJson['permissions'] ?? []),
          ),
        )
        .toList();
  }

  Future<void> deleteBot(String botId) async {
    var headers = await _getHeaders();
    var request = http.Request(
      'DELETE',
      Uri.parse('$baseUrl/kb-core/v1/ai-assistant/$botId'),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> updateBot(
    String name,
    String instructions,
    String description,
    String botId,
  ) async {
    var headers = await _getHeaders();
    var request = http.Request(
      'PATCH',
      Uri.parse('$baseUrl/kb-core/v1/ai-assistant/$botId'),
    );

    request.body = json.encode({
      "assistantName": name,
      "instructions": instructions,
      "description": description,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<List<KnowledgeResponse>> getKnowledge(String botId) async {
    // print("asdfasfasf");
    var headers = await _getHeaders();

    var request = http.Request(
      'GET',
      Uri.parse('$baseUrl/kb-core/v1/ai-assistant/$botId/knowledges'),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      // decoded is Map<String, dynamic> with keys "data" and "meta"
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Expected a JSON object but got: $decoded');
      }

      final dataList = decoded['data'];
      if (dataList is! List) {
        throw Exception('Expected "data" to be a List but got: $dataList');
      }

      // Now you can safely map to your base model:
      final bases =
          dataList
              .map(
                (item) => KnowledgeResponseBase.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();

      // Map KnowledgeResponseBase objects to KnowledgeResponse objects
      List<KnowledgeResponse> responses =
          bases.map((base) => KnowledgeResponse(data: [base])).toList();

      return responses;
    } else {
      throw Exception('Failed to load knowledge: ${response.reasonPhrase}');
    }
  }

  Future<void> removeKnowledge(String botId, String knowledgeId) async {
    var headers = await _getHeaders();
    var request = http.Request(
      'DELETE',
      Uri.parse(
        'https://knowledge-api.dev.jarvis.cx/kb-core/v1/ai-assistant/$botId/knowledges/$knowledgeId',
      ),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    // print("removing knowledge");
    // print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> addKnowledge(String botId, String knowledgeId) async {
    var headers = await _getHeaders();
    var request = http.Request(
      'POST',
      Uri.parse(
        'https://knowledge-api.dev.jarvis.cx/kb-core/v1/ai-assistant/$botId/knowledges/$knowledgeId',
      ),
    );
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    // print("adding knowledge");
    // print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<int> getNumberOfBots() async {
    final uri = Uri.parse(
      '$baseUrl/kb-core/v1/ai-assistant'
      '?order=DESC&order_field=createdAt&limit=20',
    );
    // print("Fetching bots from: $uri");

    final headers = await _getHeaders();

    final request = http.Request('GET', uri)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to load bots: ${response.reasonPhrase}');
    }

    // 1) Read the raw string
    final responseBody = await response.stream.bytesToString();
    // print("RAW RESPONSE: $responseBody");

    // 2) Decode JSON once
    final decoded = json.decode(responseBody);

    // 3) Extract the list, whether it's raw or wrapped in { data: [...] }
    List<dynamic> jsonData;
    if (decoded is List) {
      jsonData = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      jsonData = decoded['data'] as List<dynamic>;
    } else {
      throw Exception('Unexpected JSON format: $decoded');
    }

    // 4) Map to your Bot model
    int numberOfBots = jsonData.length; 
    return numberOfBots;
  }

  // Future<void>
}
