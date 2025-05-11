import '../../Classes/knowledge.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './token_store.dart';

class KnowledgeManager {
  static const String baseUrl = 'https://knowledge-api.dev.jarvis.cx';

  // Helper method to get authorization headers with token
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

  Future<void> createKnowledge(String name, String description) async {
    //request api
    var headers = await _getHeaders();
    var request = http.Request(
      'POST',
      Uri.parse('$baseUrl/kb-core/v1/knowledge'),
    );
    request.body = json.encode({
      "knowledgeName": name,
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

  Future<void> deleteKnowledge(String knowledgeId) async {
    //request api
    var headers = await _getHeaders();
    var request = http.Request(
      'DELETE',
      Uri.parse('$baseUrl/kb-core/v1/knowledge/$knowledgeId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> updateKnowledge(
    String knowledgeId,
    String name,
    String description,
  ) async {
    //request api
    var headers = await _getHeaders();
    var request = http.Request(
      'PATCH',
      Uri.parse('$baseUrl/kb-core/v1/knowledge/$knowledgeId'),
    );

    request.body = json.encode({
      "knowledgeName": name,
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

  Future<List<KnowledgeBase>> getKnowledges() async {
    final uri = Uri.parse(
      '$baseUrl/kb-core/v1/knowledge'
      '?order=DESC&order_field=createdAt&limit=20',
    );
    // print("Fetching knowledges from: $uri");

    final headers = await _getHeaders();
    final request = http.Request('GET', uri)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to load knowledge: ${response.reasonPhrase}');
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

    // 4) Map to your knowledge model
    List<KnowledgeBase> knowledges = jsonData.map((item) {
      return KnowledgeBase(
        name: item['knowledgeName'],
        description: item['description'],
        id: item['id'],
        numUnits: item['numUnits'].toString(),
        totalSize: item['totalSize'].toString(),
      );
    }).toList();

    return knowledges;
  }

  Future<int> getNumberOfKnowledges() async {
        final uri = Uri.parse(
      '$baseUrl/kb-core/v1/knowledge'
      '?order=DESC&order_field=createdAt&limit=20',
    );

    final headers = await _getHeaders();
    final request = http.Request('GET', uri)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to load knowledge: ${response.reasonPhrase}');
    }

    // 1) Read the raw string
    final responseBody = await response.stream.bytesToString();

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

    return jsonData.length;
  }
}